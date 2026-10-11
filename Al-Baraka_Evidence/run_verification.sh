#!/bin/bash
# run_verification.sh

DB_NAME="stage1_test"
PSQL_CMD="psql -X -v ON_ERROR_STOP=1 -v VERBOSITY=verbose -d $DB_NAME"
EXPECTED_PLPGSQL_ERROR_STATE="P0001"

echo "============================================================"
echo "STAGE 1 FUNCTIONAL VERIFICATION HARNESS"
echo "============================================================"

# --- SUCCESS CASE RUNNER ---
run_pass_case() {
    local test_name=$1
    local file_name=$2
    echo "Running $test_name..."
    output=$($PSQL_CMD -f "$file_name" 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        if echo "$output" | grep -q "COMMIT SUCCEEDED"; then
            echo "[PASS] $test_name"
        else
            echo "[FAIL] $test_name succeeded, but 'COMMIT SUCCEEDED' marker missing."
            exit 1
        fi
    else
        echo "[FAIL] $test_name failed unexpectedly!"
        echo "$output"
        exit 1
    fi
}

# --- D1 DEFERRED FAILURE RUNNER ---
run_d1_fail_case() {
    local test_name=$1
    local file_name=$2
    local expected_sqlstate=$3
    local expected_error_msg=$4
    echo "Running $test_name..."
    output=$($PSQL_CMD -f "$file_name" 2>&1)
    exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        # 1. Must reach BEFORE COMMIT
        if ! echo "$output" | grep -q "BEFORE COMMIT"; then
            echo "[FAIL] $test_name failed BEFORE reaching COMMIT!"
            echo "$output"
            exit 1
        fi
        
        # 2. Must NOT reach COMMIT SUCCEEDED
        if echo "$output" | grep -q "COMMIT SUCCEEDED"; then
            echo "[FAIL] $test_name executed COMMIT SUCCEEDED which should be impossible!"
            exit 1
        fi

        # 3. Extract and assert ACTUAL SQLSTATE
        actual_sqlstate=$(echo "$output" | grep -oE "ERROR:  [A-Z0-9]{5}:" | head -n 1 | cut -d" " -f3 | tr -d ":")
        
        if [ -z "$actual_sqlstate" ]; then
            echo "[FAIL] $test_name: Actual SQLSTATE could not be extracted from PostgreSQL output."
            echo "$output"
            exit 1
        fi

        if [ "$actual_sqlstate" != "$expected_sqlstate" ]; then
            echo "[FAIL] $test_name SQLSTATE mismatch. Expected: $expected_sqlstate, Got: $actual_sqlstate"
            echo "$output"
            exit 1
        fi

        # 4. Assert Message
        if echo "$output" | grep -q "$expected_error_msg"; then
            echo "[PASS] $test_name failed AT COMMIT as expected (SQLSTATE: $actual_sqlstate)."
        else
            echo "[FAIL] $test_name failed with correct SQLSTATE but WRONG MESSAGE!"
            echo "$output"
            exit 1
        fi
    else
        echo "[FAIL] $test_name COMMITTED SUCCESSFULLY WHEN IT SHOULD HAVE FAILED!"
        exit 1
    fi
}

# --- A5 IMMEDIATE FAILURE RUNNER ---
run_a5_immediate_fail_case() {
    local test_name=$1
    local file_name=$2
    local expected_sqlstate=$3
    local expected_error_msg=$4
    echo "Running $test_name..."
    output=$($PSQL_CMD -f "$file_name" 2>&1)
    exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        # 1. Must reach BEFORE UPDATE
        if ! echo "$output" | grep -q "BEFORE UPDATE"; then
            echo "[FAIL] $test_name failed before reaching UPDATE statement!"
            echo "$output"
            exit 1
        fi
        
        # 2. Must NOT reach BEFORE COMMIT
        if echo "$output" | grep -q "BEFORE COMMIT"; then
            echo "[FAIL] $test_name reached BEFORE COMMIT, meaning immediate failure was bypassed!"
            exit 1
        fi

        # 3. Must NOT reach COMMIT SUCCEEDED
        if echo "$output" | grep -q "COMMIT SUCCEEDED"; then
            echo "[FAIL] $test_name reached COMMIT SUCCEEDED!"
            exit 1
        fi

        # 4. Extract and assert ACTUAL SQLSTATE
        actual_sqlstate=$(echo "$output" | grep -oE "ERROR:  [A-Z0-9]{5}:" | head -n 1 | cut -d" " -f3 | tr -d ":")
        
        if [ -z "$actual_sqlstate" ]; then
            echo "[FAIL] $test_name: Actual SQLSTATE could not be extracted from PostgreSQL output."
            echo "$output"
            exit 1
        fi

        if [ "$actual_sqlstate" != "$expected_sqlstate" ]; then
            echo "[FAIL] $test_name SQLSTATE mismatch. Expected: $expected_sqlstate, Got: $actual_sqlstate"
            echo "$output"
            exit 1
        fi

        # 5. Assert Message
        if echo "$output" | grep -q "$expected_error_msg"; then
            echo "[PASS] $test_name failed IMMEDIATELY on UPDATE as expected (SQLSTATE: $actual_sqlstate)."
        else
            echo "[FAIL] $test_name failed with correct SQLSTATE but WRONG MESSAGE!"
            echo "$output"
            exit 1
        fi
    else
        echo "[FAIL] $test_name UPDATED SUCCESSFULLY WHEN IT SHOULD HAVE FAILED!"
        exit 1
    fi
}

# 1. Structural Verification
echo "Running Structural Verification..."
output=$($PSQL_CMD -f 01_verify_structure.sql 2>&1)
exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo "HARNESS SETUP FAILURE: Structural verification blocked."
    echo "$output"
    exit 1
fi
echo "[PASS] Exact Canonical Structure Verified."

# 2. Setup Prerequisites
echo "Running Prerequisites Setup..."
output=$($PSQL_CMD -f 02_setup_prerequisites.sql 2>&1)
exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo "HARNESS SETUP FAILURE: Prerequisite records failed."
    echo "$output"
    exit 1
fi
echo "[PASS] Prerequisites setup completed."

# 3. Functional Execution Cases
echo "------------------------------------------------------------"
run_pass_case "Case A (Valid UPDATE A->B, Delete Reg A)" "case_a.sql"
run_d1_fail_case "Case B (Orphan Reg A via UPDATE A->B)" "case_b.sql" "$EXPECTED_PLPGSQL_ERROR_STATE" "D1 Violation: Registry exists without Root"
run_d1_fail_case "Case C (Registry without Root)" "case_c.sql" "$EXPECTED_PLPGSQL_ERROR_STATE" "D1 Violation: Registry exists without Root"
run_d1_fail_case "Case D (Multiple Roots)" "case_d.sql" "$EXPECTED_PLPGSQL_ERROR_STATE" "D1 Violation: Multiple Roots"
run_d1_fail_case "Case E (Type Mismatch)" "case_e.sql" "$EXPECTED_PLPGSQL_ERROR_STATE" "D1 Violation: Registry event_type"
run_pass_case "Case F (Deferred Valid INSERT)" "case_f.sql"

run_a5_immediate_fail_case "A5 Immutability (Update to new device)" "case_a5_fail.sql" "$EXPECTED_PLPGSQL_ERROR_STATE" "A5 Violation: pos_device_id attribution is historically immutable"
run_pass_case "A5 Same-value Update" "case_a5_pass.sql"

echo "============================================================"
echo "TEST HARNESS EXECUTION COMPLETED."

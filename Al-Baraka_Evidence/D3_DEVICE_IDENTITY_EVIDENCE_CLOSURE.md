# D3 — DEVICE IDENTITY EVIDENCE CLOSURE

## 1. PURPOSE

This artifact documents the evidence status of D3 — POS Physical Device Identity
and Historical Device Attribution.

This is an evidence-closure artifact only.

NO schema modification is authorized.
NO DDL modification is authorized.
NO new entity, column, constraint, trigger, function, or policy is introduced
by this artifact.

STEP-8 execution remains NOT AUTHORIZED unless and until all required
dependencies are independently closed.

---

## 2. CANONICAL SOURCE

Canonical Stage-1 artifact:

Filename:
canonical_stage1_ddl_v2.sql

Library file identity:
file_00000000eaf4820a84b9abc3cc150397

Frozen artifact size:
25406 bytes

The canonical artifact contains the POS device structures and A5
historical device attribution mechanism documented below.

---

## 3. DATABASE DEVICE IDENTITY — PROVEN

The canonical Stage-1 DDL defines:

CREATE TABLE pos_devices (
id UUID PRIMARY KEY,
branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
device_uuid VARCHAR NOT NULL UNIQUE
);

Therefore:

- POS device identity exists structurally.
- Each device has a UUID primary identity.
- device_uuid is mandatory.
- device_uuid is unique.
- The device is bound to a branch.
- The device is bound to a warehouse.

STATUS:

PROVEN — STRUCTURAL

---

## 4. REGISTER SESSION DEVICE ATTRIBUTION — PROVEN

The canonical Stage-1 DDL defines:

register_sessions.pos_device_id UUID NOT NULL
REFERENCES pos_devices(id) ON DELETE RESTRICT

Therefore:

- A register session must identify a POS device.
- The device reference is mandatory.
- The referenced device must exist.

STATUS:

PROVEN — STRUCTURAL

---

## 5. A5 HISTORICAL DEVICE ATTRIBUTION IMMUTABILITY — PROVEN

The canonical Stage-1 DDL defines:

FUNCTION:
enforce_a5_device_immutability()

The function rejects a change when:

NEW.pos_device_id IS DISTINCT FROM OLD.pos_device_id

with:

A5 Violation: pos_device_id attribution is historically immutable.

The canonical artifact also defines:

trg_a5_device_immutability

as:

BEFORE UPDATE ON register_sessions
FOR EACH ROW
EXECUTE FUNCTION enforce_a5_device_immutability()

Therefore the intended structural invariant is:

Once a register session has been attributed to a POS device,
the historical device attribution cannot be changed.

STATUS:

PROVEN — STRUCTURAL

---

## 6. A5 RUNTIME EVIDENCE — PROVEN

The existing verification harness contains:

case_a5_fail.sql

which attempts to change the register session's pos_device_id.

The existing verification harness also contains:

case_a5_pass.sql

which performs a same-value assignment.

Previously executed runtime verification established:

1. Changing pos_device_id fails immediately during UPDATE.
2. The failure occurs before commit.
3. SQLSTATE is P0001.
4. The expected A5 violation message is produced.
5. A same-value assignment succeeds.
6. No successful commit occurs for the prohibited device reassignment.

Therefore the A5 historical immutability behavior is independently
supported by runtime evidence.

STATUS:

PROVEN — RUNTIME

---

## 7. DEVICE-RELATED SUPPORT STRUCTURES — PROVEN

The canonical Stage-1 DDL also defines:

device_tokens

with:

pos_device_id UUID NOT NULL
REFERENCES pos_devices(id) ON DELETE RESTRICT

and:

sync_conflicts

with:

pos_device_id UUID NOT NULL
REFERENCES pos_devices(id) ON DELETE RESTRICT

These structures establish database-level linkage of those records
to the POS device identity.

STATUS:

PROVEN — STRUCTURAL

---

## 8. PHYSICAL / TRUSTED DEVICE ORIGIN — NOT PROVEN

The available canonical Stage-1 evidence establishes:

- device_uuid exists;
- device_uuid is unique;
- register sessions reference pos_devices;
- historical attribution is immutable;
- device_tokens and sync_conflicts reference pos_devices.

However, the available Frozen Stage-1 DDL does NOT independently prove:

- physical hardware identity attestation;
- trusted-device attestation;
- cryptographic hardware-backed identity;
- operating-system/device attestation;
- a trusted external device identity authority;
- proof that device_uuid originated from a physically trusted device.

No such mechanism is established by the available D3 canonical evidence.

STATUS:

NOT PROVEN

This is an evidence gap.

It is NOT classified as an architecture defect.

---

## 9. FROZEN SOURCE / HISTORICAL POLICY STATUS

The original historical Frozen Source establishing any stronger
physical/trusted-device-origin requirement has not been recovered.

Therefore:

Original Frozen D3 physical/trusted-origin evidence:

NOT RECOVERED / NOT PROVEN

No historical requirement may be reconstructed from assumption.

No missing policy may be invented.

---

## 10. CANONICAL SOURCE TEXT ANOMALY

During direct inspection of canonical_stage1_ddl_v2.sql, the A5 function
definition contains the following textual sequence between the function
body and LANGUAGE plpgsql:

\[
 LANGUAGE plpgsql;

This sequence is recorded strictly as a source-artifact anomaly.

It is NOT interpreted as:

- a schema defect;
- an architecture defect;
- authorization to modify the canonical DDL;
- authorization to recreate or replace the function;
- authorization to alter the database.

Runtime evidence independently establishes that the A5 function and trigger
exist and that the prohibited reassignment is rejected as expected.

Therefore this anomaly remains documented and unresolved at this gate.

---

## 11. EVIDENCE RECONCILIATION

D3 evidence status:

Database Device Identity:
PROVEN

Register Session → POS Device:
PROVEN

A5 Structural Immutability:
PROVEN

A5 Runtime Enforcement:
PROVEN

Device Token → POS Device linkage:
PROVEN

Sync Conflict → POS Device linkage:
PROVEN

Physical / Trusted Device Origin:
NOT PROVEN

Original Frozen Source for Physical / Trusted Device Origin:
NOT RECOVERED

Architecture Defect:
NOT ESTABLISHED

---

## 12. FINAL D3 CLASSIFICATION

D3 — DEVICE IDENTITY:

OPEN / PARTIALLY PROVEN

The database-level POS device identity and historical attribution
immutability are proven.

The physical/trusted origin of the device identity is not independently
proven from the recovered evidence.

This classification does not establish an architecture defect.

---

## 13. STEP-8 AUTHORIZATION

D3 does NOT authorize STEP-8 execution.

STEP-8 remains:

NOT AUTHORIZED

This artifact does not authorize:

- production implementation;
- schema changes;
- DDL changes;
- new entities;
- new constraints;
- new triggers;
- new functions;
- policy reconstruction;
- modification of the canonical Stage-1 artifact.

---

## 14. CLOSURE PRINCIPLE

Only evidence actually recovered and independently verified is classified
as PROVEN.

Unrecovered historical requirements remain NOT PROVEN.

No inference is promoted to a binding architectural requirement.

No evidence gap is converted into an architecture defect without proof.

END OF D3 EVIDENCE CLOSURE

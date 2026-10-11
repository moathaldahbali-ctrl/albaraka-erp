# BUILD_FSM_REQUIREMENTS_MATRIX.md
Purpose: Controlled FSM requirements matrix based strictly on recovered policy.
Source Basis: Verified Pass-3 Baseline.
Evidence Classification: [E6] Structural/Root-Specific Policy.
Current Status: STRUCTURALLY UNPROVEN / ROOT-SPECIFIC POLICY UNPROVEN.
Explicit Limitations: No states or generalized transitions invented. 

| Root | Current State | Command / Operation | Target State | Preconditions | Source | Class | VM | DD Class | Status |
|---|---|---|---|---|---|---|---|---|---|
| UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | NONE | [E6] | VM-6 | DD-1 | NOT PROVEN |

*(Evidence Gap: Root-specific FSM policy transitions and structural state transitions are currently NOT PROVEN without unsupported generalization).*

### OPERATIONS / COMMANDS (Non-FSM States)
- **Edit**: Operation/Command (Recovered Policy [E3]). Does not constitute a state transition.

### CORRECTION / REVERSAL MECHANISMS (Non-FSM States)
- **Reversal**: Recovered B2 policy requirement [E3]. Handled via return/refund documentation preserving causal ancestry. This is a correction mechanism, NOT an FSM state transition.

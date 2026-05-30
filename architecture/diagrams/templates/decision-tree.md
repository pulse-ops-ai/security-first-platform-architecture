# Template — Decision tree / state machine

**Archetype:** Decision tree / state machine (Mermaid `flowchart` / `stateDiagram-v2`) — answers *"What state transitions are possible? What decisions branch where?"*

## How to use

1. Copy to `docs/diagrams/<name>.md` or `architecture/diagrams/<name>.md`.
2. Pick the form that fits:
   - **`flowchart`** for a decision tree (branch on conditions) — the first block below.
   - **`stateDiagram-v2`** for a state machine (named states + transitions) — the second block below; delete whichever you do not use.
3. No trust-zone colours needed for this archetype (`standards/diagramming-conventions.md` §Diagram archetypes). If a decision is security-relevant, name the control layer in the node text (e.g. "L4 decision").

## Decision tree (`flowchart`)

```mermaid
flowchart TD
    start([Request arrives]) --> authn{Authenticated?}
    authn -- no --> r401[401 Unauthorized]
    authn -- yes --> authz{Authorized?<br/>L4 decision}
    authz -- no --> r403[403 Forbidden]
    authz -- yes --> env{Envelope valid?<br/>signature / audience / expiry / jti}
    env -- no --> r401b[401 Invalid envelope]
    env -- yes --> serve[Serve request]
    serve --> audit[(Audit log)]
```

## State machine (`stateDiagram-v2`)

```mermaid
stateDiagram-v2
    [*] --> Received
    Received --> Authenticating
    Authenticating --> Rejected: invalid token
    Authenticating --> Authorizing: identity verified
    Authorizing --> Rejected: denied (fail-closed)
    Authorizing --> Serving: allowed
    Serving --> Audited
    Audited --> [*]
    Rejected --> [*]
```

**Source of truth:** _cite the runbook / ADR / control-layer doc this logic comes from._
**Last reviewed:** `YYYY-MM-DD` by `@handle` · **Next review:** `YYYY-MM-DD` (+90 days). Add the row to your `diagrams/INDEX.md`.

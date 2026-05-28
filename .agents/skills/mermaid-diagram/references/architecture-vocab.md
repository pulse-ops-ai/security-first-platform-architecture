# Mermaid: workspace architecture vocabulary

Apply this when the Mermaid diagram depicts a concept from this workspace's visual vocabulary (trust zones, layer interactions, agents-as-clients, envelope crossings, deviation callouts). The source-of-truth for the vocabulary is [`../../../../standards/diagramming-conventions.md`](../../../../standards/diagramming-conventions.md); this file translates it into Mermaid-specific patterns.

---

## Trust-zone notation in participants

Annotate each participant with its trust zone in parentheses. This is the single most useful convention — it makes the trust-crossing structure visible without colour (Mermaid does not honour custom zone fills the way drawio does).

```mermaid
sequenceDiagram
    participant U as User (Z0)
    participant CF as Cloudflare Tunnel (L1)
    participant K as Kong (L2 / Z1)
    participant KC as Keycloak (L3 / Z2)
    participant OF as OpenFGA (L4 / Z3)
    participant BFF as Orchestrator (L6 / Z4)
    participant S as Service (L7)
```

Read the participants left-to-right and you see the zone progression `Z0 → Z1 → Z2 → Z3 → Z4`.

---

## Layer-to-zone mapping (cheat sheet)

When labelling a participant, the zone is what the participant produces AFTER its check runs, not what it operates in:

| Layer | Operates in | Produces (zone of subsequent traffic) |
|---|---|---|
| L1 Network reachability | Z0 / public | Z0 — admission only, no zone change |
| L2 Edge gateway | Z0 → Z1 | Z1 — perimeter crossed, TLS terminated |
| L3 Identity | Z1 | Z2 — authenticated identity verified |
| L4 Authorization | Z2 | Z3 — decision recorded |
| L5 Operational guardrails | Z3 | Z3 (no zone change — gating only) |
| L6 Orchestrator / BFF | Z3 → Z4 | Z4 — envelope issued |
| L7 Service enforcement | Z4 | Z4 (verifies envelope every hop) |
| L8 Semantic / agent | Re-enters at L1/L2 as a client | n/a — not in the request path; uses the same chain |

In participant labels, write the layer the participant *is*, and the zone of the traffic *leaving* it. So Kong is `Kong (L2 / Z1)`; the request *arriving at* Kong is Z0, but the traffic *leaving* Kong is Z1.

---

## Agent-as-client lane

Per [ADR-0002](../../../../docs/decisions/ADR-0002-agents-are-clients-not-insiders.md), agents traverse the same chain as users — no back-channel. In Mermaid, depict this with a dashed line connecting the agent back to L1/L2 so it visually obvious:

```mermaid
sequenceDiagram
    participant A as Claude / Codex / Automation (L8)
    participant K as Kong (L2 / Z1)
    participant KC as Keycloak (L3 / Z2)
    participant S as Service (L7)
    A-->>K: HTTPS request (principal_type=agent)
    note right of A: agent re-enters at L1/L2<br/>NOT a back-channel to L7
    K->>KC: verify JWT
    KC-->>K: ok
    K->>S: forward (Z1 → Z4 via L6, omitted)
```

The `-->>` (dashed arrow) on the first message reinforces "this is an agent traversing the public path" visually.

---

## Envelope crossing (Z3 → Z4)

The L6→L7 envelope handoff is the most security-critical seam. In sequence diagrams, mark it explicitly with a `note` and a labelled message:

```mermaid
sequenceDiagram
    participant BFF as Orchestrator (L6)
    participant S as Service (L7)
    Note over BFF,S: Z3 → Z4 envelope crossing<br/>(ADR-0003)
    BFF->>S: request + signed envelope (JWS / JOSE)
    S->>S: verify envelope signature + claims
    S-->>BFF: response
```

The `Note over` annotation cites the ADR; the message label spells out the envelope mechanism. Both are required if the diagram includes this seam.

---

## Deviation callouts

When the diagram depicts a consumer's deviation from the reference architecture (e.g., `DEV-002` shared-secret instead of envelope), call it out with a `Note over` annotation referencing the deviation ID. The full reason + compensating control stay in `security-first-adoption.md`, not on the diagram.

```mermaid
sequenceDiagram
    participant BFF as Orchestrator (L6)
    participant S as Service (L7)
    Note over BFF,S: DEV-002 — shared-secret X-Internal-Auth header<br/>(should be Z4 envelope per ADR-0003)
    BFF->>S: request + X-Internal-Auth: <secret>
    S->>S: validate shared secret
    S-->>BFF: response
```

The deviation ID `DEV-002` matches the entry in trupryce's `security-first-adoption.md` `deviations:` list.

---

## Activation bars for in-flight requests

Use `+` and `-` on the message arrow to draw activation bars (the vertical rectangles that show when a participant is "busy"):

```mermaid
sequenceDiagram
    User->>+Kong: GET /v1/echo
    Kong->>+Keycloak: verify JWT
    Keycloak-->>-Kong: 200 ok
    Kong-->>-User: 200 echo
```

This is optional but makes the per-participant work boundaries clear when reading a complex sequence.

---

## Flowchart variants for OpenSpec / lifecycle diagrams

When diagramming the OpenSpec tier triage or dependency-record lifecycle, use `flowchart` with shape vocabulary matching the model:

```mermaid
flowchart TD
    A[PR opened] --> B{Touches Tier-3 path?}
    B -->|Yes| T3[Tier 3: OpenSpec + ADR]
    B -->|No| C{Touches Tier-2 path?}
    C -->|Yes| T2[Tier 2: OpenSpec proposal]
    C -->|No| T1[Tier 1: normal PR]
```

Diamond shapes (`{...}`) are decisions; square shapes (`[...]`) are outcomes; arrows have labels for the decision branches.

---

## C4 archetypes in Mermaid (`C4Context`, `C4Container`, `C4Dynamic`)

Mermaid natively supports the C4 model. Use these for the C4 archetypes defined in [`../../../../standards/diagramming-conventions.md`](../../../../standards/diagramming-conventions.md) §Diagram archetypes when the diagram should render inline in markdown rather than as a separate `.drawio` file. (For C4 diagrams that go in a dedicated file, use the drawio skill with the drawio C4 stencil library instead.)

### C4 System Context (Level 1)

The system as a black box plus its external actors and dependencies:

```mermaid
C4Context
    title System Context: platform-edge
    Person(consumer_lead, "Consumer team lead", "Operates a consuming repo (trupryce, future apps).")
    Person(end_user, "End user", "Accesses applications routed through platform-edge.")
    Person_Ext(agent, "Agent runtime", "Claude / Codex / automation — connects as a client per ADR-0002.")
    System(platform_edge, "platform-edge", "Workspace-shared L1–L5 edge: Cloudflare Tunnel → Kong → Traefik → (Keycloak, OpenFGA).")
    System_Ext(consumer_l6, "Consumer-owned L6", "Each team's orchestrator/BFF — issues the internal identity envelope per ADR-0003.")
    System_Ext(keycloak, "Keycloak", "Workspace identity provider.")
    Rel(end_user, platform_edge, "HTTPS")
    Rel(agent, platform_edge, "HTTPS (principal_type=agent)")
    Rel(platform_edge, keycloak, "JWT verification (offline JWKS)")
    Rel(platform_edge, consumer_l6, "Forwards verified request + headers")
    Rel(consumer_lead, consumer_l6, "Operates")
```

### C4 Container (Level 2)

Inside the system: major containers (apps, services, datastores), still owned-vs-external coloured:

```mermaid
C4Container
    title Container: platform-edge at step 4
    System_Ext(consumer_l6, "Consumer-owned L6", "BFF, issues envelopes")
    System_Boundary(pe, "platform-edge") {
        Container(kong, "Kong CE 3.9", "Edge gateway", "Public L2 + L3 jwt + L4 OpenFGA plugin")
        Container(traefik, "Traefik v3", "Internal router", "L2 east-west, require-envelope presence check")
        Container(keycloak, "Keycloak", "L3 identity", "JWT issuance, JWKS for Kong")
        Container(openfga, "OpenFGA", "L4 PDP", "Audit-only at step 3; fail-closed at step 5")
        ContainerDb(redis, "Redis", "L5 counters", "Rate-limit, kill-switch state")
    }
    Rel(kong, keycloak, "Verify JWT (offline JWKS)")
    Rel(kong, openfga, "Check policy decision")
    Rel(kong, traefik, "Forward with x-request-id + authz_decision_id")
    Rel(traefik, consumer_l6, "Forward with envelope-required header")
    Rel(kong, redis, "Counters")
```

### C4 Dynamic (sequence-style, but with C4 actor types)

Renders as a sequence diagram with C4 person/system stencils. Useful for "how a specific scenario plays out across the C4 actors":

```mermaid
C4Dynamic
    title Dynamic: user request reaches consumer L7
    Person(u, "End user")
    System(pe, "platform-edge (L1–L5)")
    System_Ext(l6, "Consumer L6 (orchestrator)")
    System_Ext(l7, "Consumer L7 (service)")
    Rel(u, pe, "1. HTTPS request + JWT")
    Rel(pe, l6, "2. Verified, forwarded with claims + authz_decision_id")
    Rel(l6, l7, "3. Signed envelope (ADR-0003, Z3 → Z4)")
    Rel(l7, l6, "4. Response after envelope verification")
    Rel(l6, u, "5. Response via pe")
```

### C4 vs the trust-zone archetype

A C4 Mermaid diagram uses the **C4 palette** (owned blue, external gray) NOT the trust-zone palette. The two archetypes answer different questions:

- **C4 archetype**: who and what makes up the system; ownership boundaries.
- **Trust-zone archetype**: how a request traverses security boundaries.

Do not overlay one on the other in a single diagram. If both are needed, ship two diagrams and cross-link them in their captions. The standard's §Diagram archetypes and §Anti-patterns codify this.

### C4 reference

- C4 model documentation: <https://c4model.com/>
- C4 Container reference example: <https://c4model.com/diagrams/container>
- Mermaid C4 syntax: <https://mermaid.js.org/syntax/c4.html>

---

## Anti-patterns

- **Inventing your own zone colours via `linkStyle` / `classDef`.** Mermaid colours diverge from drawio's vocabulary, and consumers reading both will get confused. Stick to the `(Zn)` annotation in participant labels.
- **Depicting agents on a direct path to L7.** ADR-0002 forbids it. If the sequence requires an agent reaching a service, route it through Kong, even if that adds participants. A diagram that shows otherwise is the bug.
- **Omitting the envelope citation on Z3→Z4 messages.** The L6→L7 crossing is the most reviewable security boundary in the system. Every diagram that depicts it must cite ADR-0003.

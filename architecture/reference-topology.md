# Reference Topology

Abstract topology of the security-first platform architecture. Implementation profiles map vendors to these nodes.

```
                     [ external client / agent ]
                                |
                                v
                 +-------------------------------+
                 |  L1: Network reachability     |
                 |  (private mesh / tunnel /     |
                 |   VPC + PrivateLink)          |
                 +-------------------------------+
                                |
                                v
                 +-------------------------------+
                 |  L2: Edge gateway / routing   |
                 |  (TLS term, routing, WAF)     |
                 +-------------------------------+
                                |
                                v
                 +-------------------------------+
                 |  L3: Identity (authn, tokens) |
                 +-------------------------------+
                                |
                                v
                 +-------------------------------+
                 |  L4: Authorization (PDP)      |
                 +-------------------------------+
                                |
                                v
                 +-------------------------------+
                 |  L5: Operational guardrails   |
                 +-------------------------------+
                                |
                                v
                 +-------------------------------+
                 |  L6: Orchestrator / BFF       |  <-- carries signed internal envelope
                 +-------------------------------+
                       |               |
                       v               v
            +------------------+   +------------------+
            | L7: Service A    |   | L7: Service B    |
            | (per-svc authz,  |   | (per-svc authz,  |
            |  tenant scope)   |   |  tenant scope)   |
            +------------------+   +------------------+
                       |               |
                       v               v
                  [ data stores, message buses, external systems ]

        L8: Semantic / agent reasoning sits *beside* this stack.
        Agents call back into L1/L2 as clients; they do not bypass.
```

## Cross-cutting

- **Observability bus**: every layer emits to a common pipeline. See [`observability.md`](observability.md).
- **Secrets / key material**: managed by a dedicated secrets store; never embedded in service config.
- **Audit log**: tamper-evident sink, written from L6/L7 and any layer that makes a security-relevant decision.

## What this diagram does *not* say

- It does not name vendors. Vendors live in [`profiles/`](profiles/).
- It does not prescribe network topology. Profiles describe whether the gateway is reachable from the public internet, a Tailnet, or a VPC peering.
- It does not prescribe service granularity. L7 services may be monolithic, modular, or microservices.

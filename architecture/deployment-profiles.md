# Deployment Profiles

A **deployment profile** maps the eight control layers to concrete technology. The architecture stays constant across profiles; the technology varies.

## Why profiles exist

Different deployments have different constraints:

- A new product validating market fit on a single VPS needs low cost and fast iteration.
- A regulated workload on AWS needs managed services and compliance evidence.
- A hybrid product needs a private mesh between on-prem data and cloud compute.

The architecture must support all three without being redesigned for each.

## What a profile must specify

For each of the eight control layers, a profile specifies:

1. **Implementation.** Which product / service plays the role.
2. **Contract preservation.** How the layer satisfies its contract from [`control-layers.md`](control-layers.md).
3. **Observability mapping.** Where signals go (per [`observability.md`](observability.md)).
4. **Failure mode.** What happens if this implementation degrades.
5. **Migration path.** What it takes to swap this implementation for another.

## Current profiles

| Profile | Status | Path |
|---|---|---|
| Self-hosted VPS | reference | [`profiles/self-hosted-vps.md`](profiles/self-hosted-vps.md) |
| AWS managed | reference | [`profiles/aws-managed.md`](profiles/aws-managed.md) |
| Hybrid tailnet | reference | [`profiles/hybrid-tailnet.md`](profiles/hybrid-tailnet.md) |
| Azure managed | future | not yet drafted |
| GCP managed | future | not yet drafted |

## Adding a new profile

1. Open an OpenSpec proposal (see [`team-os/openspec-policy.md`](../team-os/openspec-policy.md)).
2. Use the profile structure from existing profiles: one section per control layer, plus observability, failure modes, and migration paths.
3. Run the architecture review skill ([`../.agents/skills/architecture-review/SKILL.md`](../.agents/skills/architecture-review/SKILL.md)) before merging.

## Rules

- Profiles **must not** dilute the architecture. If a vendor cannot satisfy a layer's contract, do not weaken the contract — describe the gap and the compensating control (see below).
- Profiles **must not** add new layers. The architecture has eight layers; profiles satisfy them, they don't expand the model.
- Profiles **must** stay implementation-neutral *outside* their own file. Don't smuggle vendor names into `architecture/*.md` (excluding `profiles/`).

## Compensating controls

A **compensating control** is the explicit countermeasure a profile uses when its chosen vendor cannot fully satisfy a control-layer contract. It is the mechanism by which a profile can ship without lying about which contracts are met natively.

A compensating control is documented inline in the relevant profile file, under a `## Compensating controls` section. Every entry MUST include:

| Field | Definition |
|---|---|
| `id:` | Stable identifier, e.g., `CC-aws-managed-L5-001`. Never reused. |
| `layer:` | Which of L1–L8 the gap is in. |
| `gap:` | The specific contract this profile cannot meet natively — quote the contract sentence from `control-layers.md` if possible. |
| `control:` | The countermeasure. Must be concrete (a configuration, a workflow, a service), not aspirational ("we plan to…"). |
| `evidence:` | How a reviewer verifies the control is in place. Paths to config, queries against a control plane, screenshots referenced from `docs/operations/`. |
| `monitoring:` | The signal that fires when the control fails. Connects to `architecture/observability.md`. |
| `expires:` | ISO 8601 date by which the gap must close OR the control re-justified. `n/a` only when the architecture has explicitly accepted the substitute as permanent (rare). |
| `accepted_by:` | The human who took the trade-off. Required. |

Compensating controls are reviewed at the same cadence as the profile that owns them. A control whose `expires:` date has passed is automatically in violation; the profile must either renew the acceptance, close the gap, or document why the substitute is now permanent.

### Anti-patterns

- **"The control is process."** Compensating controls must be technical or operational, not aspirational. "We require code review" is not a compensating control for a missing authorization layer.
- **Stacking compensating controls.** A profile that needs three compensating controls for one layer is signaling that the vendor doesn't fit the profile. Reconsider the vendor before stacking.
- **`expires: n/a` by default.** The intent of expiration is to force re-evaluation. Permanent acceptance is rare and requires an ADR.

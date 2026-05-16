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

- Profiles **must not** dilute the architecture. If a vendor cannot satisfy a layer's contract, do not weaken the contract — describe the gap and the compensating control.
- Profiles **must not** add new layers. The architecture has eight layers; profiles satisfy them, they don't expand the model.
- Profiles **must** stay implementation-neutral *outside* their own file. Don't smuggle vendor names into `architecture/*.md` (excluding `profiles/`).

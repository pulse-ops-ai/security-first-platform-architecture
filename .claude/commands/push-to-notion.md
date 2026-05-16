# Push to Notion

Use the `push-to-notion` skill to create or update a durable Notion record in the Security-First Platform Knowledge Base.

## User request

$ARGUMENTS

## Instructions

1. Decide the correct target database:
   - Prompt Playbook for reusable prompts.
   - Platform Context Library for meeting notes, project briefs, decisions, architecture notes, runbooks, and reference docs.
2. Normalize the current context into a concise, reusable record.
3. Default new records to Draft unless the user explicitly says Active or final.
4. Include repo/project/tag metadata when available.
5. Do not save secrets, credentials, tokens, or private customer data.
6. Return the created or updated Notion page link.
7. If the content is executable repo truth, recommend also updating GitHub files.

## Known targets

- Platform Context Library: https://www.notion.so/cf3ef3acd8df47dea22022417bf89688
- Platform Context Library data source: `collection://cb26d15b-04c6-49b7-918c-fa338d98848c`
- Prompt Playbook: https://www.notion.so/4207ae57396c404f86fda4bdb2719fb7
- Prompt Playbook data source: `collection://38504aa9-28b3-4995-b837-d99ea5bafa42`

## Required body shapes

For Platform Context Library records, include:

```markdown
## Agent Context Card

Purpose:

Use When:

Do Not Use For:

Current Status:

Canonical Source:

Summary:

## Details

## Related Links
```

For Prompt Playbook records, include:

```markdown
## Purpose

## Target Agent

## Inputs Required

## Prompt

## Expected Output

## Validation

## Related Context
```

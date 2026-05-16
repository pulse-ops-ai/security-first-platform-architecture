---
name: push-to-notion
description: Create or update Notion knowledge records from the current working context. Use when the user asks to save a prompt, meeting note, project brief, architecture note, decision, or reference summary to Notion.
argument-hint: "[what to save and target database]"
---

# Push to Notion

Use this skill to save durable context into the Notion knowledge layer without making chat history the source of truth.

## Known Notion targets

- Hub page: Security-First Platform Knowledge Base
- Platform Context Library database: https://www.notion.so/cf3ef3acd8df47dea22022417bf89688
- Platform Context Library data source: `collection://cb26d15b-04c6-49b7-918c-fa338d98848c`
- Prompt Playbook database: https://www.notion.so/4207ae57396c404f86fda4bdb2719fb7
- Prompt Playbook data source: `collection://38504aa9-28b3-4995-b837-d99ea5bafa42`

## Inputs

Use `$ARGUMENTS` to determine what should be saved and where.

Examples:

- `/push-to-notion save this scaffold prompt to Prompt Playbook`
- `/push-to-notion save this architecture decision to Platform Context Library`
- `/push-to-notion create a project brief for FindEvil from this discussion`

## Procedure

1. Determine the correct target:
   - Prompt Playbook for reusable prompts.
   - Platform Context Library for briefs, meeting notes, decisions, architecture notes, runbooks, and reference docs.
2. Normalize the content before saving.
3. Include an Agent Context Card for long-form context records.
4. Include purpose, inputs, expected output, and validation for prompt records.
5. Mark new records as `Draft` unless the user explicitly says they are final or active.
6. Include repo/project/tag metadata when available.
7. Return the created or updated Notion page link.

## Output

Return:

- The Notion page URL of the created or updated record.
- The target database (Platform Context Library or Prompt Playbook).
- The record status (`Draft` by default; `Active` only when explicitly requested).
- A one-line summary of what was saved.

## Platform Context Library page body template

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

## Prompt Playbook page body template

```markdown
## Purpose

## Target Agent

## Inputs Required

## Prompt

## Expected Output

## Validation

## Related Context
```

## Guardrails

- Do not save secrets, credentials, tokens, or private customer data.
- Do not mark a record Active unless requested or clearly appropriate.
- Do not treat Notion as overriding GitHub, AGENTS.md, CLAUDE.md, OpenSpec, CI policy, security controls, or source code.
- For executable repo policy, create or update GitHub files instead of only saving to Notion.

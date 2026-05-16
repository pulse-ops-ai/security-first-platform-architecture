---
name: pull-from-notion
description: Pull relevant context from the Security-First Platform Notion knowledge base. Use when loading project context, prompts, meeting notes, project briefs, architecture notes, or reference docs from Notion before coding or reviewing.
---

# Pull from Notion

Retrieve targeted context from Notion without bloating the active prompt.

## Known Notion sources

- Hub page: Security-First Platform Knowledge Base
- Platform Context Library database: https://www.notion.so/cf3ef3acd8df47dea22022417bf89688
- Platform Context Library data source: `collection://cb26d15b-04c6-49b7-918c-fa338d98848c`
- Prompt Playbook database: https://www.notion.so/4207ae57396c404f86fda4bdb2719fb7
- Prompt Playbook data source: `collection://38504aa9-28b3-4995-b837-d99ea5bafa42`

## Procedure

1. Interpret the user's request as a retrieval query.
2. Search Notion for matching records in Platform Context Library and Prompt Playbook.
3. Prefer records with `Status = Active`.
4. Prefer records whose `Repo`, `Project`, or `Tags` match the current task.
5. Fetch only the smallest relevant set of records.
6. Summarize the context before using it.
7. State which Notion records were used.
8. Treat GitHub, AGENTS.md, OpenSpec, CI policy, security controls, and source code as authoritative over Notion.

## Output

Return:

- Context loaded
- Source records used
- Constraints or decisions affecting the task
- Any stale, superseded, or ambiguous context

## Guardrails

- Do not pull entire databases into context.
- Do not use archived or superseded records unless the user asks for history.
- Do not expose secrets, credentials, tokens, or private customer data.
- If Notion and GitHub conflict, GitHub is authoritative for executable repo truth.

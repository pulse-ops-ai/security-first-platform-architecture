---
name: pull-from-notion
description: Pull relevant context from the Security-First Platform Notion knowledge base. Use when the user asks to load project context, prompts, meeting notes, project briefs, architecture notes, or reference docs from Notion before working.
argument-hint: "[query or context need]"
---

# Pull from Notion

Use this skill to retrieve targeted context from Notion without bloating the chat.

## Known Notion sources

- Hub page: Security-First Platform Knowledge Base
- Platform Context Library database: https://www.notion.so/cf3ef3acd8df47dea22022417bf89688
- Platform Context Library data source: `collection://cb26d15b-04c6-49b7-918c-fa338d98848c`
- Prompt Playbook database: https://www.notion.so/4207ae57396c404f86fda4bdb2719fb7
- Prompt Playbook data source: `collection://38504aa9-28b3-4995-b837-d99ea5bafa42`

## Inputs

Use `$ARGUMENTS` as the retrieval request.

Examples:

- `/pull-from-notion find the latest TeamOS scaffold prompt`
- `/pull-from-notion load active FindEvil project briefs`
- `/pull-from-notion retrieve security-first architecture decisions for repo adoption`

## Procedure

1. Search Notion for `$ARGUMENTS` across the Platform Context Library and Prompt Playbook.
2. Prefer records with `Status = Active`.
3. Prefer records whose `Repo`, `Project`, or `Tags` match the current repo/task.
4. Fetch only the smallest relevant set of pages.
5. Summarize the retrieved context before using it.
6. State which Notion records were used.
7. Do not treat Notion as overriding GitHub, AGENTS.md, CLAUDE.md, OpenSpec, CI policy, security controls, or source code.

## Output

Return:

- Context loaded
- Source records used
- Decisions or constraints that affect the current task
- Any stale, superseded, or ambiguous context

## Guardrails

- Do not pull entire databases into context.
- Do not use archived or superseded records unless the user explicitly asks for history.
- Do not expose secrets, credentials, tokens, or private customer data.
- If Notion and GitHub conflict, GitHub is authoritative for executable repo truth.

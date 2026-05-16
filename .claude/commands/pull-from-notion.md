# Pull from Notion

Use the `pull-from-notion` skill to retrieve targeted context from the Security-First Platform Knowledge Base.

## User request

$ARGUMENTS

## Instructions

1. Use the Notion knowledge layer only as a retrieval source.
2. Search the Platform Context Library and Prompt Playbook for the user request.
3. Prefer Active records and records matching the current repo, project, or task.
4. Load only the smallest relevant context.
5. Summarize what was loaded before using it.
6. State the Notion records used.
7. If Notion conflicts with GitHub, AGENTS.md, CLAUDE.md, OpenSpec, CI policy, security controls, or source code, treat GitHub/repo truth as authoritative.

## Known sources

- Platform Context Library: https://www.notion.so/cf3ef3acd8df47dea22022417bf89688
- Platform Context Library data source: `collection://cb26d15b-04c6-49b7-918c-fa338d98848c`
- Prompt Playbook: https://www.notion.so/4207ae57396c404f86fda4bdb2719fb7
- Prompt Playbook data source: `collection://38504aa9-28b3-4995-b837-d99ea5bafa42`

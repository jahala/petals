# Claude Code Hooks & MCP Authentication — Research

**Date:** June 3, 2026

---

## Part 1: Claude Code Hook System

### Available Hook Events (29 total)

Key ones for petal:

| Hook Event | Fires When | Can Block? | Matches On |
|---|---|---|---|
| **PreToolUse** | Before any tool executes | Yes | Tool name |
| **PostToolUse** | After tool completes | No (context only) | Tool name |
| **SessionStart** | Session begins/resumes | No | startup/resume/clear/compact |
| **Stop** | Agent finishes responding | Yes | None |
| **UserPromptSubmit** | User submits prompt | Yes | None |
| **SubagentStart** | Subagent spawned | No | Agent type |

### PreToolUse — Key for Petal

Receives `tool_name` and `tool_input` (with `file_path`, `content`, etc). Can:
1. **Block** (exit code 2) — e.g., prevent writing hardcoded colors
2. **Modify** — return `updatedInput` to redirect or alter the write
3. **Inject context** — return `additionalContext` ("this file uses brand tokens: use var(--nr-primary)")
4. **Require approval** — return `permissionDecision: "ask"` to show user

### Context Injection Mechanisms

- **SessionStart hooks** → `additionalContext` injected before first prompt
- **PostToolUse hooks** → `additionalContext` appended to tool result Claude sees
- **UserPromptSubmit hooks** → `additionalContext` added alongside user prompt
- **SubagentStart hooks** → `additionalContext` for spawned subagents
- **Plain stdout** from command hooks (exit 0) → added to transcript as context

### Matcher System

- `"Write|Edit"` — exact match on tool names (pipe = OR)
- `"mcp__tilth__.*"` — regex for MCP tools (since `mcp__tilth` is exact-matched as literal)
- `"*"` — matches everything

### Hook Handler Types
| Type | Description |
|------|-------------|
| `command` | Shell command (can block via exit code 2) |
| `prompt` | LLM-based evaluation (fast model) |
| `http` | POST to HTTP endpoint |
| `mcp_tool` | Call MCP tool on connected server |

### Configuration Precedence (highest first)
1. CLI arguments
2. `.claude/settings.local.json` (personal, gitignored)
3. `.claude/settings.json` (project-level, committable)
4. `~/.claude/settings.json` (global user)

### Rate Limiting
- 60s timeout for command hooks, 30s for prompt hooks
- All matching hooks run in parallel
- Hooks load at session start; changes require restart
- `"once": true` runs hook once per session

---

## Part 2: MCP Authentication & Security

### CVE-2025-49596 (CVSS 9.4 Critical)
- MCP Inspector <0.14.1: unauthenticated port 6277 + `0.0.0.0` → localhost + permissive CORS = drive-by RCE
- Patched June 2025: session tokens, bind to 127.0.0.1, origin validation
- **Key lesson:** Local services need same security as production

### MCP Spec: OAuth 2.1 is the Standard
- Roles: MCP Server = Resource Server, MCP Client = Client, Authorization Server = token issuer
- Authorization Code + PKCE S256 (mandatory)
- RFC 9728 Protected Resource Metadata at `/.well-known/oauth-protected-resource`
- Short-lived access tokens (≤15 min), refresh token rotation
- HTTPS mandatory, redirect URIs must be `localhost` or HTTPS

### Transport-Specific Auth
| Transport | Auth |
|-----------|------|
| **stdio** | No explicit auth — credentials from environment |
| **Streamable HTTP** | Full OAuth 2.1 + PKCE |
| **SSE** | Deprecated |

### Current State
The ecosystem is still maturing. Known bugs in Claude Code: OAuth scope parameter sometimes missing, Authorization headers sometimes ignored, UI showing "not authenticated" when it actually is. But the architectural direction is clear: OAuth 2.1 with PKCE.

### For Petal (file-based, self-hosted)
- **stdio MCP server** → no auth needed. Local transport, filesystem only.
- **Remote MCP later** → OAuth 2.1 + PKCE, exactly what everyone else does
- **Security:** bind to 127.0.0.1, input validation with JSON Schema, no secrets in logs

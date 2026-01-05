# Writing Skills Guide

## What is a Skill?

A **Skill** is a reusable knowledge file that teaches agents how to perform a specific task. Think of it as a playbook that combines:

- **Context**: When to use this approach
- **Rules**: What must/must not be done
- **Examples**: Code snippets and patterns
- **Pitfalls**: Common mistakes to avoid

Skills live in `docs/skills/` and are organized by domain (e.g., `frontend/`, `backend/`, `devops/`).

## Why Write Skills?

### Without Skills
Every time you ask an agent to perform a task, it starts from scratch:
- Might forget project conventions
- Could make the same mistakes repeatedly
- No shared knowledge between agents

### With Skills
Agents have a persistent memory:
- ✅ Remember your team's standards
- ✅ Avoid known pitfalls
- ✅ Apply consistent patterns
- ✅ Learn from past experiences

## The Learning Loop

```
1. DO TASK        → You or an agent completes work
2. DISCOVER       → Notice a pattern or mistake
3. DOCUMENT       → Create or update a skill
4. REFERENCE      → Agent uses skill for future tasks
5. IMPROVE        → Refine skill based on results
```

### Example Loop

1. **Do Task**: Build a REST API endpoint
2. **Discover**: Forgot to add error handling → bug in production
3. **Document**: Create `docs/skills/backend/api-error-handling/SKILL.md`
4. **Reference**: Next endpoint automatically includes proper error handling
5. **Improve**: Add more edge cases to the skill over time

## Anatomy of a Skill

### YAML Frontmatter

Every skill starts with metadata:

```yaml
---
skill: "Building FastAPI Endpoints"
domain: "backend"
agent: "Backend Specialist"
version: "1.0.0"
status: "active"
---
```

**Field Guide**:
- `skill`: Human-readable name
- `domain`: Category (frontend, backend, devops, etc.)
- `agent`: Which agent primarily uses this
- `version`: Semantic versioning (update when rules change)
- `status`: `draft`, `active`, `deprecated`

### Required Sections

#### 1. **Overview**
A one-sentence description of what the skill enables.

```md
## Overview
This skill defines the standard pattern for creating REST API endpoints using FastAPI.
```

#### 2. **Context**
When and why this skill should be applied.

```md
## Context
Use this skill when:
- Creating new API routes
- Implementing CRUD operations
- Exposing backend functionality to frontend

Avoid for:
- Internal helper functions
- Background jobs
- Websocket handlers (use websocket skill instead)
```

#### 3. **Rules**
Clear do's and don'ts.

```md
## Rules

### Must Do
- Use Pydantic models for request/response
- Include type hints on all parameters
- Add docstrings with example requests
- Handle errors with proper HTTP status codes

### Must Not Do
- Return raw database objects
- Use mutable default arguments
- Skip input validation
- Expose internal implementation details
```

#### 4. **Implementation Guide**
Step-by-step instructions with code examples.

````md
## Implementation Guide

### Step 1: Define Pydantic Models

```python
from pydantic import BaseModel

class UserCreateRequest(BaseModel):
    email: str
    name: str
```
````

#### 5. **Common Pitfalls**
Real mistakes from real projects.

```md
## Common Pitfalls

### Pitfall 1: Mutable Default Arguments
**Problem**: Using `list` or `dict` as default parameters causes state leakage.
**Solution**: Use `None` and initialize inside function.
**Example**:
```python
# ❌ Wrong
def get_users(filters: dict = {}):
    pass

# ✅ Correct
def get_users(filters: dict | None = None):
    filters = filters or {}
```
```

#### 6. **Testing**
How to verify the skill was applied correctly.

````md
## Testing

### How to Verify
- [ ] Endpoint returns correct status codes
- [ ] Response matches Pydantic schema
- [ ] Error cases are handled
- [ ] API docs are auto-generated

### Test Cases
```python
def test_create_user_success():
    response = client.post("/users", json={"email": "test@example.com"})
    assert response.status_code == 201
```
````

## Dos and Don'ts

### ✅ DO

**Be Specific**
- ✅ "Always use `async def` for database operations"
- ❌ "Use async when appropriate"

**Include Edge Cases**
- ✅ "Handle empty lists, null values, and missing fields"
- ❌ "Handle errors"

**Show Code Examples**
- ✅ Provide working snippets with imports
- ❌ Use pseudocode or incomplete examples

**Link to Related Skills**
- ✅ "`See also: [Database Migrations](../migrations/SKILL.md)`"
- ❌ Assume agents know about other skills

**Update When Patterns Change**
- ✅ Increment version and document changes
- ❌ Let skills become outdated

### ❌ DON'T

**Dump Entire Codebases**
- ❌ Don't paste 500 lines of code
- ✅ Extract the reusable pattern (10-20 lines)

**Use Vague Language**
- ❌ "Should probably", "might want to", "it's better to"
- ✅ "Must", "Never", "Always", "Only when"

**Skip the "Why"**
- ❌ "Use Redis for caching" (no explanation)
- ✅ "Use Redis for caching to reduce database load and improve response times"

**Create One Mega-Skill**
- ❌ "Complete Backend Development Guide" (500 lines)
- ✅ Separate skills: API Design, Database Queries, Caching, Error Handling

**Forget to Test**
- ❌ No examples of how to verify
- ✅ Include test cases and verification steps

## Skill Organization

### Directory Structure

```
docs/skills/
├── _template/
│   └── SKILL.md                    # Blank template
├── frontend/
│   ├── react-components/
│   │   └── SKILL.md
│   └── state-management/
│       └── SKILL.md
├── backend/
│   ├── api-design/
│   │   └── SKILL.md
│   └── database-queries/
│       └── SKILL.md
├── devops/
│   └── docker-deployment/
│       └── SKILL.md
└── quality-standards/
    └── SKILL.md                    # Cross-cutting standards
```

### Naming Conventions

**Skill Names** (in YAML):
- Use action phrases: "Building X", "Implementing Y"
- Be specific: ❌ "APIs", ✅ "Building RESTful CRUD APIs"

**Folder Names**:
- Use kebab-case: `api-error-handling`
- Match the skill domain
- One skill per folder

**File Names**:
- Always `SKILL.md` (uppercase)
- Agents look for this exact filename

## When to Create a New Skill

### Good Reasons ✅

1. **You solved the same problem twice**
   - Created a second React form with validation? → Skill time!

2. **You discovered a gotcha**
   - Hit an edge case that caused a bug? → Document it!

3. **You have a team standard**
   - "We always use X library for Y" → Make it a skill!

4. **You onboarded a new developer**
   - Explained the same pattern 3 times? → Write it down!

5. **An agent made the same mistake twice**
   - QA rejected for the same reason? → Create a skill!

### Bad Reasons ❌

1. **It's a one-off solution**
   - Unlikely to be reused → Not worth documenting yet

2. **It's already in official docs**
   - Don't duplicate FastAPI docs → Link to them instead

3. **It's too project-specific**
   - Business logic for "Calculate shipping" → Not reusable

4. **It's still experimental**
   - Still testing approaches? → Wait until pattern stabilizes

## Skill Lifecycle

### 1. Draft
- Status: `draft`
- Newly created, still being refined
- May have incomplete sections

### 2. Active
- Status: `active`
- Tested and validated
- Actively referenced by agents

### 3. Deprecated
- Status: `deprecated`
- Better pattern found
- Link to replacement skill

### 4. Archived
- Moved to `docs/skills/_archive/`
- No longer relevant but kept for history

## Advanced Tips

### Cross-Reference Skills

Link related skills to create a knowledge graph:

```md
## Related Skills
- [`API Authentication`](../auth/SKILL.md) - Add auth to endpoints
- [`Database Transactions`](../../backend/transactions/SKILL.md) - Ensure data consistency
- [`Error Logging`](../../observability/logging/SKILL.md) - Track API errors
```

### Version Control

Update the version when rules change:

```md
## Changelog

### Version 2.0.0 (2024-01-15)
- BREAKING: Changed from `dict` to Pydantic models for all responses
- Added: New section on pagination

### Version 1.0.0 (2023-12-01)
- Initial skill definition
```

### Include Decision Trees

Help agents choose between approaches:

```md
## When to Use

**Use Redis Caching** if:
- Data is read-heavy (>90% reads)
- Data changes infrequently (< once per hour)
- Response time < 100ms is critical

**Use Database Query Optimization** if:
- Data changes frequently
- Cache invalidation is complex
- Strong consistency is required
```

## Examples Gallery

### Minimal Skill (Quick Start)

See `examples/minimal-skill/SKILL.md` for the absolute minimum viable skill.

### Complete Skill (Reference)

See `examples/python-api/SKILL.md` for a fully documented example.

### Quality Standards (Cross-Cutting)

See `docs/skills/quality-standards/SKILL.md` for standards that apply across all domains.

## Getting Help

**Stuck on what to document?**
- Ask the Orchestrator: "What patterns should I document?"

**Not sure if it's skill-worthy?**
- Ask the QA Lead: "Is this pattern reusable?"

**Need a review?**
- Ask: "Review my skill draft for X"

---

**Ready to document your first skill?** Copy `docs/skills/_template/SKILL.md` and start writing! 🚀

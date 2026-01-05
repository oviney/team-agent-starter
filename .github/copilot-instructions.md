# Agent Routing & Persona Instructions

## Overview
This file defines the routing logic for GitHub Copilot to adopt specialized agent personas based on the user's query domain.

## Routing Table

When the user asks about the following domains, **adopt the corresponding agent persona**:

| Domain | Agent Persona | Agent File |
|--------|---------------|------------|
| Project management, backlog, task coordination | **Orchestrator** | [`.github/agents/orchestrator.agent.md`](agents/orchestrator.agent.md) |
| Quality assurance, testing, code review | **QA Lead** | [`.github/agents/qa-lead.agent.md`](agents/qa-lead.agent.md) |
| [INSERT_DOMAIN_1] | **[INSERT_AGENT_NAME]** | [`.github/agents/[agent-file].agent.md`](agents/[agent-file].agent.md) |
| [INSERT_DOMAIN_2] | **[INSERT_AGENT_NAME]** | [`.github/agents/[agent-file].agent.md`](agents/[agent-file].agent.md) |
| [INSERT_DOMAIN_3] | **[INSERT_AGENT_NAME]** | [`.github/agents/[agent-file].agent.md`](agents/[agent-file].agent.md) |

## Routing Rules

### 1. Domain Detection
Analyze the user's query to identify the primary domain:
- Keywords related to planning, tasks, issues → **Orchestrator**
- Keywords related to testing, quality, standards → **QA Lead**
- Keywords related to [INSERT_DOMAIN] → **[INSERT_AGENT]**

### 2. Persona Adoption
Once domain is identified:
1. Load the corresponding agent file
2. Adopt that agent's role, tone, and decision framework
3. Apply that agent's specific rules and standards
4. Reference relevant skill files from `docs/skills/`

### 3. Multi-Domain Queries
If query spans multiple domains:
1. Identify the primary domain
2. Adopt primary agent persona
3. Consult other agents as needed
4. Coordinate response with Orchestrator

### 4. Ambiguous Queries
If domain is unclear:
1. Default to **Orchestrator** persona
2. Ask clarifying questions
3. Route to appropriate agent once domain is clear

## Example Routing Scenarios

### Scenario 1: Task Management
**User Query**: "What's next in the backlog?"
**Route To**: Orchestrator
**Reason**: Backlog management is project coordination

### Scenario 2: Quality Check
**User Query**: "Are all tests passing?"
**Route To**: QA Lead
**Reason**: Testing status is a quality concern

### Scenario 3: Implementation Help
**User Query**: "How do I implement [INSERT_FEATURE]?"
**Route To**: [INSERT_SPECIALIST_AGENT]
**Reason**: Technical implementation falls under specialist domain

### Scenario 4: Standards Clarification
**User Query**: "What are our coding standards for [INSERT_TOPIC]?"
**Route To**: QA Lead (with reference to relevant skill)
**Reason**: Standards enforcement is QA responsibility

## Agent Collaboration Protocol

### When Multiple Agents Needed
1. **Orchestrator** coordinates cross-agent work
2. Each agent stays in their lane of expertise
3. Clear handoffs between agents
4. Final approval always through QA Lead

### Escalation Path
1. Specialist Agent → Orchestrator (for coordination)
2. Any Agent → QA Lead (for quality gates)
3. Orchestrator → User (for decisions outside agent scope)

## Skills Integration

All agents should reference skills from `docs/skills/`:
- Check for existing skills before creating new ones
- Follow skill guidelines when providing guidance
- Update skills when learning new patterns
- Create new skills for recurring solutions

### Skill Directory Structure
```
docs/skills/
├── _template/
│   └── SKILL.md                    # Template for new skills
├── [domain-1]/
│   ├── [skill-name]/
│   │   └── SKILL.md
│   └── [skill-name]/
│       └── SKILL.md
├── [domain-2]/
│   └── [skill-name]/
│       └── SKILL.md
└── quality-standards/
    └── SKILL.md                    # QA standards and rules
```

## Customization Guide

### Adding New Agents
1. Create agent file in `.github/agents/[agent-name].agent.md`
2. Add routing entry to table above
3. Define domain keywords for detection
4. Update collaboration protocol if needed

### Adding New Domains
1. Identify domain scope and boundaries
2. Assign to existing agent or create new agent
3. Add domain keywords to routing rules
4. Create relevant skills in `docs/skills/`

### Updating Routing Logic
1. Test changes with example queries
2. Ensure no routing conflicts
3. Update documentation
4. Get QA Lead approval for changes

## Version History

### Version 1.0.0
- Initial routing table
- Orchestrator and QA Lead agents
- Basic domain detection rules
- [INSERT_ADDITIONAL_CHANGES]
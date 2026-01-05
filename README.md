# Team Agent Starter Kit

> **An Orchestrator-Worker architecture for building AI-powered development teams**

Transform GitHub Copilot into a multi-agent system with specialized roles, persistent memory, and intelligent routing.

## 🎯 What is This?

The **Team Agent Starter Kit** provides a framework for creating AI agent teams that collaborate on software projects. Instead of treating AI as a single assistant, this architecture creates **specialized agents** (Orchestrator, QA Lead, Domain Specialists) that work together with **defined roles** and **persistent knowledge**.

### Core Concepts

**Role-Based Agents**: Each agent has a specific job (project management, quality assurance, architecture, etc.) with its own decision-making framework and communication style.

**Persistent Skill Memory**: Knowledge is stored in `docs/skills/` as reusable "skill files" that agents reference. When an agent learns a pattern, it can be documented once and reused forever.

**Auto-Routing**: GitHub Copilot automatically adopts the correct agent persona based on your question. Ask about testing → get the QA Lead. Ask about tasks → get the Orchestrator.

**Definition of Done**: Every task follows a checklist enforced by the Orchestrator and verified by the QA Lead.

## 🚀 Quick Start

### Installation

1. **Clone this repository**:
   ```bash
   git clone https://github.com/oviney/team-agent-starter.git
   cd team-agent-starter
   ```

2. **Run the installer in your target project**:
   ```bash
   cd /path/to/your/project
   /path/to/team-agent-starter/bootstrap.sh
   ```

3. **Restart VS Code**:
   - Press `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows/Linux)
   - Select "Developer: Reload Window"

4. **Test the system**:
   - Open GitHub Copilot Chat
   - Ask: "What's in the backlog?"
   - The Orchestrator agent should respond!

### First Steps

1. **Customize your agents** in `.github/copilot-instructions.md`
2. **Define quality standards** in `docs/skills/quality-standards/SKILL.md`
3. **Create your first domain skill** using the template in `docs/skills/_template/SKILL.md`
4. **Read the guide** at `docs/WRITING_SKILLS.md`

## 📦 What Gets Installed

```
your-project/
├── .github/
│   ├── copilot-instructions.md       # Routing table & agent config
│   └── agents/
│       ├── orchestrator.agent.md     # Project Manager agent
│       └── qa-lead.agent.md          # Quality Control agent
├── docs/
│   ├── ISSUES.md                     # Project backlog
│   ├── WRITING_SKILLS.md             # How to write skills
│   └── skills/
│       ├── _template/
│       │   └── SKILL.md              # Blank skill template
│       └── quality-standards/
│           └── SKILL.md              # QA standards (to customize)
└── examples/
    └── python-api/
        └── SKILL.md                  # Example skill reference
```

## ✨ Features

### 1. **Orchestrator Agent** (Project Manager)
- Manages the backlog in `docs/ISSUES.md`
- Delegates tasks to specialist agents
- Enforces Definition of Done
- Coordinates cross-team work

### 2. **QA Lead Agent** (Quality Gatekeeper)
- Reviews all changes before approval
- Enforces testing standards
- Never approves broken builds
- Provides constructive feedback

### 3. **Skill Memory System**
- Agents learn patterns and store them as skills
- Skills are reusable across projects
- Each skill includes rules, examples, and pitfalls
- Create once, reference forever

### 4. **Auto-Routing**
Ask any question and get the right agent automatically:
- "What's next?" → Orchestrator
- "Are tests passing?" → QA Lead
- "How do I implement X?" → Domain Specialist

### 5. **Extensible Architecture**
Add new agents by:
1. Creating a new agent file in `.github/agents/`
2. Adding a routing rule in `.github/copilot-instructions.md`
3. Defining domain-specific skills in `docs/skills/`

## 📚 Documentation

- **[Writing Skills Guide](docs/WRITING_SKILLS.md)** - How to create effective skill files
- **[Example Skill](examples/python-api/SKILL.md)** - Reference implementation for FastAPI
- **[Orchestrator Agent](.github/agents/orchestrator.agent.md)** - Project management persona
- **[QA Lead Agent](.github/agents/qa-lead.agent.md)** - Quality assurance persona

## 🎓 Learning Path

1. **Start Simple**: Use the two default agents (Orchestrator + QA Lead)
2. **Document Patterns**: When you solve a problem, create a skill file
3. **Add Specialists**: Create domain-specific agents for your tech stack
4. **Iterate**: Update skills as you learn better patterns

## 🛠️ Customization Examples

### Add a Frontend Specialist

1. Create `.github/agents/frontend-specialist.agent.md`:
   ```md
   ---
   name: "Frontend Specialist"
   description: "React & TypeScript Expert"
   role: "frontend-development"
   ---
   
   You are a Frontend Specialist focused on React, TypeScript, and modern CSS...
   ```

2. Add routing rule to `.github/copilot-instructions.md`:
   ```md
   | React, TypeScript, CSS, UI components | **Frontend Specialist** | [`.github/agents/frontend-specialist.agent.md`](agents/frontend-specialist.agent.md) |
   ```

3. Create skills in `docs/skills/frontend/`:
   ```
   docs/skills/frontend/
   ├── react-component-patterns/SKILL.md
   ├── typescript-best-practices/SKILL.md
   └── responsive-design/SKILL.md
   ```

### Add a DevOps Agent

1. Create `.github/agents/devops-engineer.agent.md`
2. Add routing for Docker, CI/CD, deployment keywords
3. Create skills for common deployment patterns

## 🤝 Contributing

This is a starter template - fork it and make it your own!

Share your custom agents and skills:
1. Fork this repo
2. Add your agent/skill
3. Submit a PR with your contribution

## 📝 License

MIT License - See [LICENSE](LICENSE) for details

## 🙏 Acknowledgments

Inspired by:
- Multi-agent systems research
- Software engineering best practices
- The GitHub Copilot community

---

**Ready to build your AI development team?** Run `./bootstrap.sh` and start collaborating! 🚀

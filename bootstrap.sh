#!/bin/bash
# filepath: bootstrap.sh
# Agent Starter Kit Bootstrap Installer
# Usage: ./bootstrap.sh [target-directory]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET_DIR="${1:-.}"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Agent Starter Kit Bootstrap Installer            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Step 1: Validate target directory
echo -e "${BLUE}Step 1: Validating target directory...${NC}"
if [ ! -d "$TARGET_DIR" ]; then
    print_error "Target directory does not exist: $TARGET_DIR"
    exit 1
fi

cd "$TARGET_DIR"
TARGET_DIR="$(pwd)"
print_status "Installing to: $TARGET_DIR"
echo ""

# Step 2: Safety checks
echo -e "${BLUE}Step 2: Running safety checks...${NC}"

if [ -f ".github/copilot-instructions.md" ]; then
    print_warning "Found existing .github/copilot-instructions.md"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Installation cancelled by user"
        exit 1
    fi
fi

if [ -d "docs/skills" ] && [ "$(ls -A docs/skills)" ]; then
    print_warning "Found existing docs/skills/ directory with content"
    read -p "Do you want to merge with existing skills? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Installation cancelled by user"
        exit 1
    fi
fi

print_status "Safety checks passed"
echo ""

# Step 3: Create directory structure
echo -e "${BLUE}Step 3: Creating directory structure...${NC}"

mkdir -p .github/agents
mkdir -p docs/skills/_template
mkdir -p docs/skills/quality-standards
mkdir -p examples

print_status "Directory structure created"
echo ""

# Step 4: Copy agent files
echo -e "${BLUE}Step 4: Installing agent configuration files...${NC}"

# Copy copilot instructions
if [ -f "$SCRIPT_DIR/.github/copilot-instructions.md" ]; then
    cp "$SCRIPT_DIR/.github/copilot-instructions.md" .github/
    print_status "Installed: .github/copilot-instructions.md"
else
    print_error "Source file not found: .github/copilot-instructions.md"
    exit 1
fi

# Copy agent files
for agent_file in "$SCRIPT_DIR/.github/agents"/*.md; do
    if [ -f "$agent_file" ]; then
        cp "$agent_file" .github/agents/
        print_status "Installed: .github/agents/$(basename "$agent_file")"
    fi
done

echo ""

# Step 5: Copy skill templates
echo -e "${BLUE}Step 5: Installing skill templates...${NC}"

if [ -f "$SCRIPT_DIR/docs/skills/_template/SKILL.md" ]; then
    cp "$SCRIPT_DIR/docs/skills/_template/SKILL.md" docs/skills/_template/
    print_status "Installed: docs/skills/_template/SKILL.md"
else
    print_error "Source file not found: docs/skills/_template/SKILL.md"
    exit 1
fi

echo ""

# Step 6: Copy example skills
echo -e "${BLUE}Step 6: Installing example skills...${NC}"

if [ -d "$SCRIPT_DIR/examples" ]; then
    cp -r "$SCRIPT_DIR/examples"/* examples/ 2>/dev/null || true
    print_status "Installed example skills to examples/"
else
    print_warning "No example skills found to install"
fi

echo ""

# Step 7: Copy documentation
echo -e "${BLUE}Step 7: Installing documentation...${NC}"

if [ -f "$SCRIPT_DIR/docs/WRITING_SKILLS.md" ]; then
    cp "$SCRIPT_DIR/docs/WRITING_SKILLS.md" docs/
    print_status "Installed: docs/WRITING_SKILLS.md"
fi

if [ -f "$SCRIPT_DIR/docs/ISSUES.md" ]; then
    if [ ! -f "docs/ISSUES.md" ]; then
        cp "$SCRIPT_DIR/docs/ISSUES.md" docs/
        print_status "Installed: docs/ISSUES.md (backlog template)"
    else
        print_warning "Skipped: docs/ISSUES.md (already exists)"
    fi
fi

echo ""

# Step 8: Set permissions
echo -e "${BLUE}Step 8: Setting permissions...${NC}"

chmod +x "$SCRIPT_DIR/bootstrap.sh" 2>/dev/null || true
print_status "Script permissions updated"
echo ""

# Step 9: Create initial backlog if needed
if [ ! -f "docs/ISSUES.md" ]; then
    echo -e "${BLUE}Step 9: Creating initial backlog...${NC}"
    cat > docs/ISSUES.md << 'EOF'
# Project Backlog

## Status: Ready to Start

## Active Sprint
- No active tasks yet

## Backlog
1. **[TASK-001]** Set up project-specific agents
   - **Status**: Todo
   - **Agent**: Orchestrator
   - **Priority**: High
   - **Description**: Customize the placeholder agents in `.github/copilot-instructions.md`

2. **[TASK-002]** Define quality standards
   - **Status**: Todo
   - **Agent**: QA Lead
   - **Priority**: High
   - **Description**: Create `docs/skills/quality-standards/SKILL.md`

3. **[TASK-003]** Document first project skill
   - **Status**: Todo
   - **Agent**: Orchestrator
   - **Priority**: Medium
   - **Description**: Create your first domain-specific skill

## Completed
- Agent Starter Kit installed successfully! 🎉
EOF
    print_status "Created initial backlog: docs/ISSUES.md"
    echo ""
fi

# Success message
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            Installation Complete! 🎉                     ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo ""
echo "1. 🔄 Restart VS Code to activate the agent system"
echo "   ${YELLOW}Press Cmd+Shift+P → 'Developer: Reload Window'${NC}"
echo ""
echo "2. 📝 Customize your agents:"
echo "   - Edit ${YELLOW}.github/copilot-instructions.md${NC} to add domain-specific agents"
echo "   - Replace ${YELLOW}[INSERT_DOMAIN_X]${NC} placeholders with your domains"
echo ""
echo "3. 📚 Read the documentation:"
echo "   - ${YELLOW}docs/WRITING_SKILLS.md${NC} - How to create skills"
echo "   - ${YELLOW}examples/python-api/SKILL.md${NC} - Example skill reference"
echo ""
echo "4. 🎯 Test the system:"
echo "   - Open GitHub Copilot Chat"
echo "   - Ask: ${YELLOW}\"What's in the backlog?\"${NC}"
echo "   - The Orchestrator agent should respond!"
echo ""
echo "5. 🚀 Start building:"
echo "   - Check ${YELLOW}docs/ISSUES.md${NC} for your initial tasks"
echo "   - Create your first skill in ${YELLOW}docs/skills/your-domain/${NC}"
echo ""
echo -e "${BLUE}Resources:${NC}"
echo "  📖 Documentation: https://github.com/oviney/team-agent-starter"
echo "  💬 Get help: Open an issue on GitHub"
echo ""
echo -e "${GREEN}Happy building! 🚀${NC}"

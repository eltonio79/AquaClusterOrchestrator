# Git Workflow for Agent Files

## Status: COMMIT THESE FILES

**Decision**: Files in `tasks/agents/*.md` should be **committed to Git** as they are:
- Instruction files for agents (part of the project documentation)
- Reference material for agent implementations
- Part of the project structure

## Default Behavior: Files Are NOT Processed Automatically

**Important**: These instruction files are **reference material**, not active task files.

### When Files Are Used:
1. **Explicit mention in chat**: User explicitly says "read tasks/agents/01_RASTER_MONITOR_AGENT.md"
2. **Agent assigned to role**: When agent is specifically assigned to an agent role via `.cursor/rules/`
3. **Via task delegation**: When a task file in `tasks/` explicitly references one of these instruction files

### When Files Are NOT Used:
- By default, NO agent instruction files apply
- Agents should NOT automatically read these files unless:
  - Assigned via `.cursor/rules/` (then ONLY their specific file)
  - Explicitly mentioned by user
  - Referenced in a task file

## Task System vs Delegation System

### Task System (`tasks/*.json`)
- **Purpose**: Ad-hoc task delegation between agents
- **Format**: JSON files with task instructions
- **Created by**: `delegate_task_to_agent.ps1` script
- **Used for**: One-off tasks, specific instructions, temporary assignments
- **Example**: "Clean up logs in this directory"

### Delegation via `.cursor/rules/`
- **Purpose**: Persistent agent role assignment
- **Format**: `.mdc` rule files in `.cursor/rules/`
- **Created by**: System administrator
- **Used for**: Long-term agent roles, permanent assignments
- **Example**: "You are the Raster Monitor Agent"

### How They Work Together:
- **Task system** (`tasks/*.json`): For ad-hoc tasks, temporary work, one-time operations
- **Rule system** (`.cursor/rules/*.mdc`): For persistent agent roles, ongoing responsibilities
- **Both can coexist**: An agent can have a persistent role (via rules) AND receive ad-hoc tasks (via task files)

### When to Use Which:
- **Use task system**: When you need to give a specific agent a one-time task
- **Use rule system**: When you want to assign an agent to a permanent role
- **Combine both**: Agent with permanent role can also receive ad-hoc tasks

---

## Recommendation

**Keep both systems:**
- Task system (`tasks/*.json`) - For ad-hoc delegation
- Rule system (`.cursor/rules/`) - For permanent agent roles
- Instruction files (`tasks/agents/*.md`) - Reference material, commit to Git

**Workflow:**
1. Agent assigned permanent role via `.cursor/rules/`
2. Agent receives ad-hoc tasks via `tasks/*.json` when needed
3. Agent follows instructions from `tasks/agents/*.md` as reference
4. Agent works on own Git branch (`agent/<name>`)
5. Agent commits after logical changes following Git workflow rules


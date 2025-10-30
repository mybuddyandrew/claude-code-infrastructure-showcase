# Claude Integration Guide

**FOR CLAUDE CODE:** When a user asks you to integrate components from this showcase repository into their project, follow these instructions carefully.

---

## Overview

This repository is a **reference library** of Claude Code infrastructure components. Users will ask you to help integrate specific pieces into their projects. Your role is to:

1. **Ask clarifying questions** about their project structure
2. **Copy the appropriate files**
3. **Customize configurations** for their setup
4. **Verify the integration** works correctly

**Key Principle:** ALWAYS ask before assuming project structure. What works for one project won't work for another.

---

## General Integration Pattern

When user says: **"Add [component] to my project"**

1. Identify component type (skill/hook/agent/command)
2. Ask about their project structure
3. Copy files
4. Customize for their setup
5. Verify integration
6. Provide next steps

---

## Integrating Skills

### Step-by-Step Process

**When user requests a skill** (e.g., "add backend-dev-guidelines"):

#### 1. Understand Their Project

**ASK THESE QUESTIONS:**
- "What's your project structure? Single app, monorepo, or multi-service?"
- "Where is your [backend/frontend] code located?"
- "What frameworks/technologies do you use?"

#### 2. Copy the Skill

```bash
cp -r /path/to/showcase/.claude/skills/[skill-name] \\
      $CLAUDE_PROJECT_DIR/.claude/skills/
```

#### 3. Handle skill-rules.json

**Check if it exists:**
```bash
ls $CLAUDE_PROJECT_DIR/.claude/skills/skill-rules.json
```

**If NO (doesn't exist):**
- Copy the template from showcase
- Remove skills user doesn't want
- Customize for their project

**If YES (exists):**
- Read their current skill-rules.json
- Add the new skill entry
- Merge carefully to avoid breaking existing skills

#### 4. Customize Path Patterns

**CRITICAL:** Update `pathPatterns` in skill-rules.json to match THEIR structure:

**Example - User has monorepo:**
```json
{
  "backend-dev-guidelines": {
    "fileTriggers": {
      "pathPatterns": [
        "packages/api/src/**/*.ts",
        "packages/server/src/**/*.ts",
        "apps/backend/**/*.ts"
      ]
    }
  }
}
```

**Example - User has single backend:**
```json
{
  "backend-dev-guidelines": {
    "fileTriggers": {
      "pathPatterns": [
        "src/**/*.ts",
        "backend/**/*.ts"
      ]
    }
  }
}
```

**Safe Generic Patterns** (when unsure):
```json
{
  "pathPatterns": [
    "**/*.ts",          // All TypeScript files
    "src/**/*.ts",      // Common src directory
    "backend/**/*.ts"   // Common backend directory
  ]
}
```

#### 5. Verify Integration

```bash
# Check skill was copied
ls -la $CLAUDE_PROJECT_DIR/.claude/skills/[skill-name]

# Validate skill-rules.json syntax
cat $CLAUDE_PROJECT_DIR/.claude/skills/skill-rules.json | jq .
```

**Tell user:** "Try editing a file in [their-backend-path] and the skill should activate."

---

### Skill-Specific Notes

#### backend-dev-guidelines
- **Needs:** Backend directory paths
- **Ask:** "Where's your backend code?" "Do you use Express?"
- **Customize:** pathPatterns only
- **Example paths:** `api/`, `server/`, `backend/`, `services/*/src/`

#### frontend-dev-guidelines
- **Needs:** Frontend directory + framework check
- **Ask:** "Do you use React with MUI v7?" "Where's your frontend code?"
- **Customize:** pathPatterns + warn if not React/MUI
- **Example paths:** `frontend/`, `client/`, `web/`, `apps/web/src/`

#### route-tester
- **Needs:** Auth type + API paths
- **Ask:** "Do you use JWT cookie-based authentication?"
- **If NO:** "This skill is designed for JWT cookies. Want me to adapt it or skip it?"
- **Customize:** Service URLs, auth patterns

#### error-tracking
- **Needs:** Backend paths
- **Ask:** "Do you use Sentry?" "Where's your backend code?"
- **Customize:** pathPatterns

#### skill-developer
- **Needs:** Nothing!
- **Copy as-is** - meta-skill, fully generic

---

## Integrating Hooks

### Essential Hooks (Always Safe to Copy)

#### skill-activation-prompt (UserPromptSubmit)

**Purpose:** Auto-suggests skills based on user prompts

**Integration (NO customization needed):**

```bash
# Copy both files
cp showcase/.claude/hooks/skill-activation-prompt.sh \\
   $CLAUDE_PROJECT_DIR/.claude/hooks/
cp showcase/.claude/hooks/skill-activation-prompt.ts \\
   $CLAUDE_PROJECT_DIR/.claude/hooks/

# Make executable
chmod +x $CLAUDE_PROJECT_DIR/.claude/hooks/skill-activation-prompt.sh

# Install dependencies if needed
if [ -f "showcase/.claude/hooks/package.json" ]; then
  cp showcase/.claude/hooks/package.json \\
     $CLAUDE_PROJECT_DIR/.claude/hooks/
  cd $CLAUDE_PROJECT_DIR/.claude/hooks && npm install
fi
```

**Add to settings.json:**
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/skill-activation-prompt.sh"
          }
        ]
      }
    ]
  }
}
```

**This hook is FULLY GENERIC** - works anywhere, no customization needed!

#### post-tool-use-tracker (PostToolUse)

**Purpose:** Tracks file changes for context management

**Integration (NO customization needed):**

```bash
# Copy file
cp showcase/.claude/hooks/post-tool-use-tracker.sh \\
   $CLAUDE_PROJECT_DIR/.claude/hooks/

# Make executable
chmod +x $CLAUDE_PROJECT_DIR/.claude/hooks/post-tool-use-tracker.sh
```

**Add to settings.json:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|MultiEdit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/post-tool-use-tracker.sh"
          }
        ]
      }
    ]
  }
}
```

**This hook is FULLY GENERIC** - auto-detects project structure!

---

### Optional Hooks (Require Heavy Customization)

#### tsc-check.sh and trigger-build-resolver.sh (Stop hooks)

⚠️ **WARNING:** These hooks are configured for a specific multi-service monorepo structure.

**Before integrating, ask:**
1. "Do you have a monorepo with multiple TypeScript services?"
2. "What are your service directory names?"
3. "Where are your tsconfig.json files located?"

**For SIMPLE projects (single service):**
- **RECOMMEND SKIPPING** these hooks
- They're overkill for single-service projects
- User can run `tsc --noEmit` manually instead

**For COMPLEX projects (multi-service monorepo):**

1. Copy the files
2. **MUST EDIT** tsc-check.sh - find this section:
```bash
case "$repo" in
    email|exports|form|frontend|projects|uploads|users|utilities|events|database)
        echo "$repo"
        return 0
        ;;
esac
```

3. Replace with USER'S actual service names:
```bash
case "$repo" in
    api|web|auth|payments|notifications)  # ← User's services
        echo "$repo"
        return 0
        ;;
esac
```

4. Test manually before adding to settings.json:
```bash
./.claude/hooks/tsc-check.sh
```

**IMPORTANT:** If this hook fails, it will block Stop events. Only add if you're sure it works for their setup.

---

## Integrating Agents

**Agents are STANDALONE** - easiest to integrate!

### Standard Agent Integration

```bash
# Copy the agent file
cp showcase/.claude/agents/[agent-name].md \\
   $CLAUDE_PROJECT_DIR/.claude/agents/
```

**That's it!** Agents work immediately, no configuration needed.

### Check for Hardcoded Paths

Some agents may reference paths. **Before copying, read the agent file and check for:**

- `~/git/old-project/` → Should be `$CLAUDE_PROJECT_DIR` or `.`
- `/root/git/project/` → Should be `$CLAUDE_PROJECT_DIR` or `.`
- Hardcoded screenshot paths → Ask user where they want screenshots

**If found, update them:**
```bash
sed -i 's|~/git/old-project/|.|g' $CLAUDE_PROJECT_DIR/.claude/agents/[agent].md
sed -i 's|/root/git/.*PROJECT.*DIR|$CLAUDE_PROJECT_DIR|g' \\
    $CLAUDE_PROJECT_DIR/.claude/agents/[agent].md
```

### Agent-Specific Notes

**auth-route-tester / auth-route-debugger:**
- Requires JWT cookie-based authentication in user's project
- Ask: "Do you use JWT cookies for auth?"
- If NO: "These agents are for JWT cookie auth. Skip them or want me to adapt?"

**frontend-error-fixer:**
- May reference screenshot paths
- Ask: "Where should screenshots be saved?"

**All other agents:**
- Copy as-is, they're fully generic

---

## Integrating Slash Commands

```bash
# Copy command file
cp showcase/.claude/commands/[command].md \\
   $CLAUDE_PROJECT_DIR/.claude/commands/
```

### Customize Paths

Commands may reference dev docs paths. **Check and update:**

**dev-docs and dev-docs-update:**
- Look for `dev/active/` path references
- Ask: "Where do you want dev documentation stored?"
- Update paths in the command files

**route-research-for-testing:**
- May reference service paths
- Ask about their API structure

---

## Common Patterns & Best Practices

### Pattern: Asking About Project Structure

**DON'T assume:**
- ❌ "I'll add this for your blog-api service"
- ❌ "Configuring for your frontend directory"

**DO ask:**
- ✅ "What's your project structure? Monorepo or single app?"
- ✅ "Where is your backend code located?"
- ✅ "Do you use workspaces or have multiple services?"

### Pattern: Customizing skill-rules.json

**User has monorepo with workspaces:**
```json
{
  "pathPatterns": [
    "packages/*/src/**/*.ts",
    "apps/*/src/**/*.tsx"
  ]
}
```

**User has Nx monorepo:**
```json
{
  "pathPatterns": [
    "apps/api/src/**/*.ts",
    "libs/*/src/**/*.ts"
  ]
}
```

**User has simple structure:**
```json
{
  "pathPatterns": [
    "src/**/*.ts",
    "backend/**/*.ts"
  ]
}
```

### Pattern: settings.json Integration

**NEVER copy the showcase settings.json directly!**

Instead, **extract and merge** the sections they need:

1. Read their existing settings.json
2. Add the hook configurations they want
3. Preserve their existing config

**Example merge:**
```json
{
  // ... their existing config ...
  "hooks": {
    // ... their existing hooks ...
    "UserPromptSubmit": [  // ← Add this section
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/skill-activation-prompt.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Verification Checklist

After integration, **verify these items:**

```bash
# 1. Hooks are executable
ls -la $CLAUDE_PROJECT_DIR/.claude/hooks/*.sh
# Should show: -rwxr-xr-x

# 2. skill-rules.json is valid JSON
cat $CLAUDE_PROJECT_DIR/.claude/skills/skill-rules.json | jq .
# Should parse without errors

# 3. Hook dependencies installed (if TypeScript hooks)
ls $CLAUDE_PROJECT_DIR/.claude/hooks/node_modules/
# Should show packages if package.json exists

# 4. Settings.json is valid JSON
cat $CLAUDE_PROJECT_DIR/.claude/settings.json | jq .
# Should parse without errors
```

**Then ask user to test:**
- "Try editing a file in [relevant-path] - the skill should activate"
- "Try asking me a question about [topic] - I should suggest the skill"

---

## Common Mistakes to Avoid

### ❌ DON'T: Copy settings.json as-is
**Why:** The Stop hooks reference non-existent services
**DO:** Extract only UserPromptSubmit and PostToolUse sections

### ❌ DON'T: Keep example service names
**Why:** User doesn't have blog-api, auth-service, etc.
**DO:** Ask about their actual structure and update

### ❌ DON'T: Skip making hooks executable
**Why:** Hooks won't run without execute permission
**DO:** Always `chmod +x` after copying

### ❌ DON'T: Assume monorepo structure
**Why:** Most projects are single-service
**DO:** Ask first, then customize

### ❌ DON'T: Add all skills at once
**Why:** Overwhelming and may not all be relevant
**DO:** Ask which skills are relevant to their work

### ❌ DON'T: Copy Stop hooks without testing
**Why:** They can block the Stop event if they fail
**DO:** Test manually first, only add if working

---

## Example Integration Conversations

### Example 1: Adding Backend Skill

**User:** "Add the backend-dev-guidelines skill to my project"

**Claude should respond:**
```
I'll add the backend-dev-guidelines skill. First, I need to understand
your project structure:

1. Is this a monorepo with multiple services, or a single backend application?
2. Where is your backend code located? (e.g., src/, backend/, server/)
3. Do you use Express.js?
```

**User:** "Single app, code is in src/api/, yes we use Express"

**Claude should:**
1. Copy the skill directory
2. Update skill-rules.json with pathPattern: `"src/api/**/*.ts"`
3. Verify it's copied correctly
4. Respond:
```
✅ Added backend-dev-guidelines skill!

Configuration:
- Skill triggers when editing files in src/api/
- Activated by keywords like "controller", "service", "route", "API"

Try it: Edit a file in src/api/ and you should see the skill suggestion.
```

### Example 2: Setting Up Hooks

**User:** "Set up the skill activation hooks"

**Claude should respond:**
```
I'll set up the skill auto-activation system. This requires two hooks:
1. skill-activation-prompt - Suggests skills based on your prompts
2. post-tool-use-tracker - Tracks file changes

Do you have a .claude/settings.json file already, or should I create one?
```

**User:** "I have settings.json already"

**Claude should:**
1. Read their settings.json
2. Copy both hook files
3. Run npm install in hooks directory
4. Add hook configurations to their settings.json (preserving existing config)
5. Make hooks executable
6. Respond:
```
✅ Skill activation hooks installed!

What I did:
- Copied skill-activation-prompt hook
- Copied post-tool-use-tracker hook
- Installed dependencies
- Added to your settings.json

Test it: Ask me "help with backend development" and I should suggest
the backend-dev-guidelines skill.
```

### Example 3: Adding Agent

**User:** "Add the code-architecture-reviewer agent"

**Claude should:**
```
The code-architecture-reviewer agent reviews code for architectural issues
and best practices. This agent works standalone, no configuration needed.

I'll copy it to your .claude/agents/ directory now.
```

**Then:**
1. Copy the agent file
2. Respond:
```
✅ Added code-architecture-reviewer agent!

Use it by running the Task tool with:
- subagent_type: "code-architecture-reviewer"
- prompt: Description of code to review

The agent will review your code and provide architectural feedback.
```

---

## Quick Reference Tables

### What Needs Customization?

| Component | Customization | What to Ask |
|-----------|--------------|-------------|
| **skill-developer** | ✅ None | Copy as-is |
| **backend-dev-guidelines** | ⚠️ Paths | "Where's your backend code?" |
| **frontend-dev-guidelines** | ⚠️ Paths + framework | "Do you use React/MUI?" |
| **route-tester** | ⚠️ Auth + paths | "JWT cookie auth?" |
| **error-tracking** | ⚠️ Paths | "Where's your backend?" |
| **skill-activation-prompt** | ✅ None | Copy as-is |
| **post-tool-use-tracker** | ✅ None | Copy as-is |
| **tsc-check** | ⚠️⚠️⚠️ Heavy | "Monorepo or single service?" |
| **All agents** | ✅ Minimal | Check paths |
| **All commands** | ⚠️ Paths | "Where for dev docs?" |

### When to Recommend Skipping

| Component | Skip If... |
|-----------|-----------|
| **tsc-check hooks** | Single-service project or different build setup |
| **route-tester** | Not using JWT cookie authentication |
| **frontend-dev-guidelines** | Not using React + MUI |
| **auth agents** | Not using JWT cookie auth |

---

## Final Tips for Claude

**When user says "add everything":**
- Start with essentials: skill-activation hooks + 1-2 relevant skills
- Don't overwhelm them with all 5 skills + 10 agents
- Ask what they actually need

**When something doesn't work:**
- Check verification checklist
- Verify paths match their structure
- Test hooks manually
- Check for JSON syntax errors

**When user is unsure:**
- Recommend starting with just skill-activation hooks
- Add backend OR frontend skill (whichever they use)
- Add more later as needed

**Always explain what you're doing:**
- Show the commands you're running
- Explain why you're asking questions
- Provide clear next steps after integration

---

**Remember:** This is a reference library, not a working application. Your job is to help users cherry-pick and adapt components for THEIR specific project structure.

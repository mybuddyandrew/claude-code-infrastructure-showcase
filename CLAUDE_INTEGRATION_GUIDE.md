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

## Tech Stack Compatibility Check

**CRITICAL:** Before integrating a skill, verify the user's tech stack matches the skill requirements.

### Rails Backend Skills

**rails-backend-guidelines requires:**
- Ruby on Rails (7.x recommended)
- Ruby 3.x
- ActiveRecord
- Standard Rails MVC structure

**Before integrating, ask:**
"Are you using Ruby on Rails for your backend?"

**If NO:**
```
The rails-backend-guidelines skill is designed specifically for Ruby on Rails. I can:
1. Help you create similar guidelines adapted for [their stack] using this as a template
2. Extract the architecture patterns (MVC, service objects - work with most frameworks)
3. Skip this skill if not relevant

Which would you prefer?
```

**rails-testing-guide requires:**
- Rails with Minitest (default Rails testing)
- Can adapt for RSpec if needed

**rails-api-patterns requires:**
- Rails API-only mode or mixed
- JSON serialization (JBuilder, ActiveModel::Serializers, etc.)

### Skills That Are Tech-Agnostic

These work for ANY tech stack:
- ✅ **skill-developer** - Meta-skill, no tech requirements
- ✅ **error-tracking** - Error monitoring works with most stacks

---

## General Integration Pattern

When user says: **"Add [component] to my project"**

1. Identify component type (skill/hook/agent/command)
2. **CHECK TECH STACK COMPATIBILITY** (for frontend/backend skills)
3. Ask about their project structure
4. Copy files OR adapt for their stack
5. Customize for their setup
6. Verify integration
7. Provide next steps

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

**Example - User has Rails engine in monorepo:**
```json
{
  "rails-backend-guidelines": {
    "fileTriggers": {
      "pathPatterns": [
        "engines/*/app/**/*.rb",
        "apps/api/app/**/*.rb",
        "packages/backend/app/**/*.rb"
      ]
    }
  }
}
```

**Example - User has standard Rails app:**
```json
{
  "rails-backend-guidelines": {
    "fileTriggers": {
      "pathPatterns": [
        "app/controllers/**/*.rb",
        "app/models/**/*.rb",
        "app/services/**/*.rb",
        "config/routes.rb",
        "db/migrate/**/*.rb"
      ]
    }
  }
}
```

**Safe Generic Patterns** (when unsure):
```json
{
  "pathPatterns": [
    "app/**/*.rb",          // All Rails app files
    "config/routes.rb",     // Routes file
    "db/migrate/**/*.rb"    // Migrations
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

#### rails-backend-guidelines
- **Tech Requirements:** Ruby on Rails 7.x, Ruby 3.x, ActiveRecord
- **Ask:** "Are you using Rails?" "Standard Rails structure or custom?" "Rails API or full-stack?"
- **If different Ruby framework:** Offer to adapt for Sinatra, Hanami, etc.
- **Customize:** pathPatterns
- **Example paths:** `app/controllers/`, `app/models/`, `app/services/`, `engines/*/app/`
- **Adaptation tip:** MVC + Service objects pattern transfers to most frameworks
- **Includes:** Devise authentication, Pundit authorization, background jobs, Minitest testing

#### rails-testing-guide
- **Tech Requirements:** Rails with Minitest (default)
- **Ask:** "Using Minitest or RSpec?"
- **If RSpec:** Can adapt patterns for RSpec syntax
- **Customize:** pathPatterns for test locations
- **Example paths:** `test/`, `spec/`

#### rails-api-patterns
- **Tech Requirements:** Rails (API-only or mixed)
- **Ask:** "Building API-only or full-stack?" "Using serializers?"
- **Customize:** pathPatterns, serialization approach
- **Example paths:** `app/controllers/api/`, `app/serializers/`
- **Adaptation tip:** REST API patterns and serialization concepts transfer to most frameworks

#### error-tracking
- **Tech Requirements:** Error monitoring service (Sentry, Bugsnag, etc.)
- **Ask:** "Do you use error monitoring?" "Which service?"
- **If different service:** "Want to use this as template for [their error tracking]?"
- **Customize:** pathPatterns, service-specific code
- **Example paths:** `config/initializers/sentry.rb`, `app/controllers/application_controller.rb`
- **Adaptation tip:** Error tracking philosophy transfers to other tools (Rollbar, Bugsnag, Airbrake, etc.)

#### skill-developer
- **Tech Requirements:** None!
- **Copy as-is** - meta-skill, fully generic, teaches skill creation for ANY tech stack
- **Use for:** Creating new skills for Rails or any other framework

---

## Adapting Skills for Different Tech Stacks

When user's tech stack differs from skill requirements, you have options:

### Option 1: Adapt Existing Skill (Recommended)

**When to use:** User wants similar guidelines but for different tech

**Process:**
1. **Copy the skill as a starting point:**
   ```bash
   cp -r showcase/.claude/skills/rails-backend-guidelines \\
         $CLAUDE_PROJECT_DIR/.claude/skills/sinatra-backend-guidelines
   ```

2. **Identify what needs changing:**
   - Framework-specific code examples (Rails → Sinatra)
   - Library APIs (ActiveRecord → DataMapper/Sequel)
   - Route definitions (config/routes.rb → Sinatra DSL)
   - Framework conventions

3. **Keep what transfers:**
   - MVC architecture principles
   - Service object patterns
   - Database optimization strategies
   - Testing philosophies
   - General best practices

4. **Replace examples systematically:**
   - Ask user for equivalent patterns in their stack
   - Update code examples to their framework
   - Keep the overall structure and sections

5. **Update skill name and triggers:**
   - Rename skill appropriately
   - Update skill-rules.json triggers for their stack
   - Test activation

**Example - Adapting frontend-dev-guidelines for Vue:**
```
I'll create vue-dev-guidelines based on the React skill structure:
- Replace React.FC → Vue defineComponent
- Replace useSuspenseQuery → Vue composables
- Replace MUI components → [their component library]
- Keep: File organization, performance patterns, TypeScript guidelines

This will take a few minutes. Sound good?
```

### Option 2: Extract Framework-Agnostic Patterns

**When to use:** Stacks are very different, but core principles apply

**Process:**
1. Read through the existing skill
2. Identify framework-agnostic patterns:
   - Layered architecture (backend)
   - File organization strategies
   - Performance optimization principles
   - Testing strategies
   - Error handling philosophy

3. Create new skill with just those patterns
4. User can add framework-specific examples later

**Example:**
```
The backend-dev-guidelines uses Express, but the layered architecture
(Routes → Controllers → Services → Repositories) works for Django too.

I can create a skill with:
- Layered architecture pattern
- Separation of concerns principles
- Error handling best practices
- Testing strategies

Then you can add Django-specific examples as you establish patterns.
```

### Option 3: Use as Reference Only

**When to use:** Too different to adapt, but user wants inspiration

**Process:**
1. User browses the existing skill
2. You help create a new skill from scratch
3. Use existing skill's structure as a template
4. Follow modular pattern (main + resource files)

### What Usually Transfers Across Tech Stacks

**Architecture & Organization:**
- ✅ Layered architecture (Routes/Controllers/Services pattern)
- ✅ Separation of concerns
- ✅ File organization strategies (features/ pattern)
- ✅ Progressive disclosure (main + resource files)
- ✅ Repository pattern for data access

**Development Practices:**
- ✅ Error handling philosophy
- ✅ Input validation importance
- ✅ Testing strategies
- ✅ Performance optimization principles
- ✅ TypeScript best practices

**Framework-Specific Code:**
- ❌ React hooks → Don't transfer to Vue/Angular
- ❌ MUI components → Different component libraries
- ❌ Prisma queries → Different ORM syntax
- ❌ Express middleware → Different framework patterns
- ❌ Routing implementations → Framework-specific

### When to Recommend Adaptation vs Skipping

**Recommend adaptation if:**
- User wants similar guidelines for their stack
- Core patterns apply (layered architecture, etc.)
- User has time to help with framework-specific examples

**Recommend skipping if:**
- Stacks are completely different
- User doesn't need those patterns
- Would take too long to adapt
- User prefers creating from scratch

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

### Example 3: Tech Stack Mismatch

**User:** "Add the frontend-dev-guidelines skill to my Vue project"

**Claude should:**
```
I see you're using Vue. The frontend-dev-guidelines skill is specifically
designed for React + MUI v7. I have a few options:

Option 1 (Recommended): I can create a vue-dev-guidelines skill using the
React skill as a template. I'll adapt:
- Component patterns for Vue (Composition API, defineComponent)
- Replace MUI examples with your component library
- Adapt data fetching for Vue patterns
- Keep: File organization, performance principles, TypeScript standards

Option 2: Extract only the framework-agnostic patterns (file organization,
performance, testing) without React-specific code.

Option 3: Skip it and help you create Vue guidelines from scratch.

Which would you prefer?
```

**User:** "Option 1 sounds good, I use Vuetify"

**Claude should:**
1. Copy frontend-dev-guidelines as vue-dev-guidelines
2. Go through each resource file
3. Replace React patterns with Vue Composition API
4. Replace MUI components with Vuetify
5. Update skill-rules.json with Vue-specific triggers (.vue files)
6. Respond:
```
✅ Created vue-dev-guidelines skill adapted for Vue 3 + Vuetify!

What I changed:
- React.FC components → Vue defineComponent
- MUI v7 examples → Vuetify components
- TanStack Query → Your data fetching approach
- File patterns → .vue files

What I kept:
- File organization (features/ pattern)
- Performance optimization strategies
- TypeScript standards
- Loading/error state principles

Try editing a .vue file - the skill should activate.
```

---

## Quick Reference Tables

### What Needs Customization?

| Component | Tech Requirements | Customization | What to Ask |
|-----------|------------------|--------------|-------------|
| **skill-developer** | None | ✅ None | Copy as-is |
| **backend-dev-guidelines** | Express/Prisma/Node | ⚠️ Paths + tech check | "Use Express/Prisma?" "Where's backend?" |
| **frontend-dev-guidelines** | React/MUI v7 | ⚠️⚠️ Paths + framework | "Use React/MUI v7?" "Where's frontend?" |
| **route-tester** | JWT cookies | ⚠️ Auth + paths | "JWT cookie auth?" |
| **error-tracking** | Sentry | ⚠️ Paths | "Use Sentry?" "Where's backend?" |
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

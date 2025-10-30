# Claude Code Rails Infrastructure Showcase

**A curated reference library of production-tested Claude Code infrastructure for Ruby on Rails.**

Born from real-world Rails development experience, this showcase provides the patterns and systems that solved the "skills don't activate automatically" problem and scaled Claude Code for Rails development - from APIs to full-stack applications.

> **This is NOT a working application** - it's a reference library. Copy what you need into your own projects.

---

## What's Inside

**Production-tested infrastructure for:**
- ✅ **Auto-activating skills** via hooks
- ✅ **Modular skill pattern** (500-line rule with progressive disclosure)
- ✅ **Specialized agents** for complex tasks
- ✅ **Dev docs system** that survives context resets
- ✅ **Comprehensive examples** using generic blog domain

**Time investment to build:** 6 months of iteration
**Time to integrate into your project:** 15-30 minutes

---

## Quick Start - Pick Your Path

### 🤖 Using Claude Code to Integrate?

**Claude:** Read [`CLAUDE_INTEGRATION_GUIDE.md`](CLAUDE_INTEGRATION_GUIDE.md) for step-by-step integration instructions tailored for AI-assisted setup.

### 🎯 I want skill auto-activation

**The breakthrough feature:** Skills that actually activate when you need them.

**What you need:**
1. The skill-activation hooks (2 files)
2. A skill or two relevant to your work
3. 15 minutes

**👉 [Setup Guide: .claude/hooks/README.md](.claude/hooks/README.md)**

### 📚 I want to add ONE skill

Browse the [skills catalog](.claude/skills/) and copy what you need.

**Available:**
- **rails-backend-guidelines** - Rails MVC, Service objects, Concerns, Authentication/Authorization
- **rails-testing-guide** - Minitest patterns, fixtures, integration tests
- **rails-api-patterns** - API-only Rails, serialization, versioning
- **skill-developer** - Meta-skill for creating skills
- **error-tracking** - Error monitoring integration patterns

**👉 [Skills Guide: .claude/skills/README.md](.claude/skills/README.md)**

### 🤖 I want specialized agents

10 production-tested agents for complex tasks:
- Code architecture review
- Refactoring assistance
- Documentation generation
- Error debugging
- And more...

**👉 [Agents Guide: .claude/agents/README.md](.claude/agents/README.md)**

---

## What Makes This Different?

### The Auto-Activation Breakthrough

**Problem:** Claude Code skills just sit there. You have to remember to use them.

**Solution:** UserPromptSubmit hook that:
- Analyzes your prompts
- Checks file context
- Automatically suggests relevant skills
- Works via `skill-rules.json` configuration

**Result:** Skills activate when you need them, not when you remember them.

### Production-Tested Patterns

These aren't theoretical examples - they're built from real Rails experience:
- ✅ Rails APIs in production
- ✅ Full-stack Rails applications
- ✅ Service objects and business logic patterns
- ✅ Authentication and authorization systems (Devise, Pundit)
- ✅ Real-world Rails development with Claude Code

The patterns work because they're based on actual Rails projects.

### Modular Skills (500-Line Rule)

Large skills hit context limits. The solution:

```
skill-name/
  SKILL.md                  # <500 lines, high-level guide
  resources/
    topic-1.md              # <500 lines each
    topic-2.md
    topic-3.md
```

**Progressive disclosure:** Claude loads main skill first, loads resources only when needed.

---

## Repository Structure

```
.claude/
├── skills/                 # Rails-focused skills
│   ├── rails-backend-guidelines/  (10+ resource files)
│   ├── rails-testing-guide/       (Minitest patterns)
│   ├── rails-api-patterns/        (API-specific patterns)
│   ├── skill-developer/           (7 resource files)
│   ├── error-tracking/            (Error monitoring)
│   └── skill-rules.json           # Skill activation configuration
├── hooks/                  # 6 hooks for automation
│   ├── skill-activation-prompt.*  (ESSENTIAL)
│   ├── post-tool-use-tracker.sh   (ESSENTIAL)
│   └── ... additional hooks       (optional)
├── agents/                 # 10 specialized agents
│   ├── code-architecture-reviewer.md
│   ├── refactor-planner.md
│   ├── documentation-architect.md
│   └── ... 7 more
└── commands/               # 3 slash commands
    ├── dev-docs.md
    └── ...

dev/
└── active/                 # Dev docs pattern examples
```

---

## Component Catalog

### 🎨 Skills (5)

| Skill | Purpose | Best For |
|-------|---------|----------|
| [**rails-backend-guidelines**](.claude/skills/rails-backend-guidelines/) | Rails MVC, Services, Concerns, Auth | Rails applications |
| [**rails-testing-guide**](.claude/skills/rails-testing-guide/) | Minitest patterns and best practices | Rails testing |
| [**rails-api-patterns**](.claude/skills/rails-api-patterns/) | API-only Rails, serialization, versioning | Rails APIs |
| [**skill-developer**](.claude/skills/skill-developer/) | Creating and managing skills | Meta-development |
| [**error-tracking**](.claude/skills/error-tracking/) | Error monitoring integration | Production apps |

**All skills follow the modular pattern** - main file + resource files for progressive disclosure.

**👉 [How to integrate skills →](.claude/skills/README.md)**

### 🪝 Hooks (6)

| Hook | Type | Essential? | Customization |
|------|------|-----------|---------------|
| skill-activation-prompt | UserPromptSubmit | ✅ YES | ✅ None needed |
| post-tool-use-tracker | PostToolUse | ✅ YES | ✅ None needed |
| error-handling-reminder | Stop | ⚠️ Optional | ⚠️ Moderate |
| stop-build-check-enhanced | Stop | ⚠️ Optional | ⚠️ Moderate |

**Start with the two essential hooks** - they enable skill auto-activation and work out of the box.

**👉 [Hook setup guide →](.claude/hooks/README.md)**

### 🤖 Agents (10)

**Standalone - just copy and use!**

| Agent | Purpose |
|-------|---------|
| code-architecture-reviewer | Review code for architectural consistency |
| code-refactor-master | Plan and execute refactoring |
| documentation-architect | Generate comprehensive documentation |
| plan-reviewer | Review development plans |
| refactor-planner | Create refactoring strategies |
| web-research-specialist | Research technical issues online |
| auth-route-tester | Test authenticated endpoints |
| auth-route-debugger | Debug auth issues |
| frontend-error-fixer | Debug errors in web interfaces |
| auto-error-resolver | Auto-fix common errors |

**👉 [How agents work →](.claude/agents/README.md)**

### 💬 Slash Commands (3)

| Command | Purpose |
|---------|---------|
| /dev-docs | Create structured dev documentation |
| /dev-docs-update | Update docs before context reset |
| /route-research-for-testing | Research route patterns for testing |

---

## Key Concepts

### Hooks + skill-rules.json = Auto-Activation

**The system:**
1. **skill-activation-prompt hook** runs on every user prompt
2. Checks **skill-rules.json** for trigger patterns
3. Suggests relevant skills automatically
4. Skills load only when needed

**This solves the #1 problem** with Claude Code skills: they don't activate on their own.

### Progressive Disclosure (500-Line Rule)

**Problem:** Large skills hit context limits

**Solution:** Modular structure
- Main SKILL.md <500 lines (overview + navigation)
- Resource files <500 lines each (deep dives)
- Claude loads incrementally as needed

**Example:** rails-backend-guidelines has 10+ resource files covering controllers, models, services, concerns, routes, migrations, authentication, testing, etc.

### Dev Docs Pattern

**Problem:** Context resets lose project context

**Solution:** Three-file structure
- `[task]-plan.md` - Strategic plan
- `[task]-context.md` - Key decisions and files
- `[task]-tasks.md` - Checklist format

**Works with:** `/dev-docs` slash command to generate these automatically

---

## ⚠️ Important: What Won't Work As-Is

### settings.json
The included `settings.json` is an **example only**:
- Stop hooks may need customization for your Rails setup
- Example paths reference standard Rails structure (app/controllers, app/models, etc.)
- MCP servers may not exist in your setup

**To use it:**
1. Extract ONLY UserPromptSubmit and PostToolUse hooks
2. Customize optional hooks for your needs
3. Update MCP server list for your setup

### Example Domain
Skills use generic examples (Post/Comment/User):
- These are **teaching examples**, not requirements
- Patterns work for any domain (e-commerce, SaaS, content management, etc.)
- Adapt the patterns to your Rails application's domain

---

## Integration Workflow

**Recommended approach:**

### Phase 1: Skill Activation (15 min)
1. Copy skill-activation-prompt hook
2. Copy post-tool-use-tracker hook
3. Update settings.json
4. Install hook dependencies

### Phase 2: Add First Skill (10 min)
1. Pick ONE relevant skill
2. Copy skill directory
3. Create/update skill-rules.json
4. Customize path patterns

### Phase 3: Test & Iterate (5 min)
1. Edit a file - skill should activate
2. Ask a question - skill should be suggested
3. Add more skills as needed

### Phase 4: Optional Enhancements
- Add agents you find useful
- Add slash commands
- Customize Stop hooks (advanced)

---

## Getting Help

### For Users
**Issues with integration?**
1. Check [CLAUDE_INTEGRATION_GUIDE.md](CLAUDE_INTEGRATION_GUIDE.md)
2. Ask Claude: "Why isn't [skill] activating?"
3. Open an issue with your project structure

### For Claude Code
When helping users integrate:
1. **Read CLAUDE_INTEGRATION_GUIDE.md FIRST**
2. Ask about their project structure
3. Customize, don't blindly copy
4. Verify after integration

---

## What This Solves

### Before This Infrastructure

❌ Skills don't activate automatically
❌ Have to remember which skill to use
❌ Large skills hit context limits
❌ Context resets lose project knowledge
❌ No consistency across development
❌ Manual agent invocation every time

### After This Infrastructure

✅ Skills suggest themselves based on context
✅ Hooks trigger skills at the right time
✅ Modular skills stay under context limits
✅ Dev docs preserve knowledge across resets
✅ Consistent patterns via guardrails
✅ Agents streamline complex tasks

---

## Community

**Found this useful?**

- ⭐ Star this repo
- 🐛 Report issues or suggest improvements
- 💬 Share your own skills/hooks/agents
- 📝 Contribute examples from your domain

**Background:**
This is a Rails adaptation of the infrastructure detailed in the viral Reddit post ["Claude Code is a Beast - Part 2"](https://www.reddit.com/r/ClaudeAI/comments/1gc4xme/claude_code_is_a_beast_part_2_the_secret_to/). The original TypeScript/Node.js showcase was forked and adapted for the Rails community.

---

## License

MIT License - Use freely in your projects, commercial or personal.

---

## Quick Links

- 📖 [Claude Integration Guide](CLAUDE_INTEGRATION_GUIDE.md) - For AI-assisted setup
- 🎨 [Skills Documentation](.claude/skills/README.md)
- 🪝 [Hooks Setup](.claude/hooks/README.md)
- 🤖 [Agents Guide](.claude/agents/README.md)
- 📝 [Dev Docs Pattern](dev/README.md)

**Start here:** Copy the two essential hooks, add one skill, and see the auto-activation magic happen.

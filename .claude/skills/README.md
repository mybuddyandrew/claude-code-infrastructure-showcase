# Skills

Production-tested skills for Claude Code with Ruby on Rails that auto-activate based on context.

---

## What Are Skills?

Skills are modular knowledge bases that Claude loads when needed. They provide:
- Domain-specific guidelines for Rails development
- Best practices for MVC, services, and concerns
- Code examples for common patterns
- Anti-patterns to avoid

**Problem:** Skills don't activate automatically by default.

**Solution:** This showcase includes the hooks + configuration to make them activate.

---

## Available Skills

### skill-developer (Meta-Skill)
**Purpose:** Creating and managing Claude Code skills

**Files:** 7 resource files (426 lines total)

**Use when:**
- Creating new skills
- Understanding skill structure
- Working with skill-rules.json
- Debugging skill activation

**Customization:** ✅ None - copy as-is

**[View Skill →](skill-developer/)**

---

### rails-backend-guidelines
**Purpose:** Ruby on Rails backend development patterns

**Files:** 12 resource files (comprehensive coverage)

**Covers:**
- Rails MVC architecture (Routes → Controllers → Services → Models)
- Service objects for business logic
- ActiveRecord patterns (associations, validations, scopes)
- Devise authentication
- Pundit authorization
- Concerns for shared behavior
- Database migrations (safe patterns)
- Background jobs (Sidekiq)
- Minitest testing strategies
- Performance optimization (N+1 prevention, caching)

**Use when:**
- Creating/modifying Rails controllers or models
- Building service objects
- Implementing authentication/authorization
- Working with ActiveRecord
- Writing migrations or background jobs

**Customization:** ⚠️ Update `pathPatterns` in skill-rules.json to match your Rails structure

**Example pathPatterns:**
```json
{
  "pathPatterns": [
    "app/controllers/**/*.rb",
    "app/models/**/*.rb",
    "app/services/**/*.rb",
    "config/routes.rb",
    "db/migrate/**/*.rb"
  ]
}
```

**[View Skill →](rails-backend-guidelines/)**

---

### rails-testing-guide
**Purpose:** Rails testing patterns with Minitest

**Files:** 1 main file (expandable with resources)

**Covers:**
- Minitest testing patterns (default Rails)
- Model tests (validations, associations)
- Controller tests (requests, responses)
- Integration tests
- Fixtures usage
- Test helpers and assertions

**Use when:**
- Writing tests for Rails models
- Testing controllers
- Creating integration tests
- Working with test fixtures

**Customization:** ⚠️ Update `pathPatterns` for test directories

**Example pathPatterns:**
```json
{
  "pathPatterns": [
    "test/**/*.rb",
    "test/models/**/*_test.rb",
    "test/controllers/**/*_test.rb",
    "test/integration/**/*_test.rb"
  ]
}
```

**Note:** Can be adapted for RSpec if needed.

**[View Skill →](rails-testing-guide/)**

---

### rails-api-patterns
**Purpose:** Rails API development patterns

**Files:** 1 main file (expandable with resources)

**Covers:**
- Rails API-only controllers
- API versioning strategies
- JSON serialization (JBuilder, ActiveModel::Serializers)
- API authentication (JWT, tokens)
- Error response formatting
- CORS configuration

**Use when:**
- Building Rails APIs
- Creating API controllers
- Implementing serializers
- Setting up API versioning

**Customization:** ⚠️ Update `pathPatterns` for API structure

**Example pathPatterns:**
```json
{
  "pathPatterns": [
    "app/controllers/api/**/*.rb",
    "app/serializers/**/*.rb",
    "app/views/**/*.jbuilder"
  ]
}
```

**[View Skill →](rails-api-patterns/)**

---

### error-tracking
**Purpose:** Error tracking and monitoring patterns

**Files:** 1 main file (~250 lines)

**Covers:**
- Error monitoring service integration (Sentry, Bugsnag, Airbrake, etc.)
- Error capture patterns for Rails
- Breadcrumbs and user context
- Performance monitoring
- Integration with Rails controllers and background jobs

**Use when:**
- Setting up error tracking
- Capturing exceptions
- Adding error context
- Debugging production issues

**Customization:** ⚠️ Update `pathPatterns` for your backend

**[View Skill →](error-tracking/)**

---

## How to Add a Skill to Your Project

### Quick Integration

**For Claude Code:**
```
User: "Add the rails-backend-guidelines skill to my project"

Claude should:
1. Ask about Rails project structure
2. Copy skill directory
3. Update skill-rules.json with their paths
4. Verify integration
```

See [CLAUDE_INTEGRATION_GUIDE.md](../../CLAUDE_INTEGRATION_GUIDE.md) for complete instructions.

### Manual Integration

**Step 1: Copy the skill directory**
```bash
cp -r claude-code-rails-showcase/.claude/skills/rails-backend-guidelines \\
      your-rails-project/.claude/skills/
```

**Step 2: Update skill-rules.json**

If you don't have one, create it:
```bash
cp claude-code-rails-showcase/.claude/skills/skill-rules.json \\
   your-rails-project/.claude/skills/
```

Then customize the `pathPatterns` for your project:
```json
{
  "skills": {
    "rails-backend-guidelines": {
      "fileTriggers": {
        "pathPatterns": [
          "app/controllers/**/*.rb",  // ← Verify this matches your structure
          "app/models/**/*.rb",
          "app/services/**/*.rb"
        ]
      }
    }
  }
}
```

**Step 3: Test**
- Edit a Rails controller or model file
- The skill should activate automatically

---

## skill-rules.json Configuration

### What It Does

Defines when skills should activate based on:
- **Keywords** in user prompts ("rails", "controller", "model", "activerecord")
- **Intent patterns** (regex matching user intent)
- **File path patterns** (editing Rails files)
- **Content patterns** (code contains ActiveRecord patterns)

### Configuration Format

```json
{
  "skill-name": {
    "type": "domain" | "guardrail",
    "enforcement": "suggest" | "block",
    "priority": "high" | "medium" | "low",
    "promptTriggers": {
      "keywords": ["list", "of", "keywords"],
      "intentPatterns": ["regex patterns"]
    },
    "fileTriggers": {
      "pathPatterns": ["app/**/*.rb"],
      "contentPatterns": ["class.*< ApplicationController", "belongs_to"]
    }
  }
}
```

### Enforcement Levels

- **suggest**: Skill appears as suggestion, doesn't block
- **block**: Must use skill before proceeding (guardrail)

**Use "block" for:**
- Preventing breaking changes (MUI v6→v7)
- Critical database operations
- Security-sensitive code

**Use "suggest" for:**
- General best practices
- Domain guidance
- Code organization

---

## Creating Your Own Skills

See the **skill-developer** skill for complete guide on:
- Skill YAML frontmatter structure
- Resource file organization
- Trigger pattern design
- Testing skill activation

**Quick template:**
```markdown
---
name: my-skill
description: What this skill does
---

# My Skill Title

## Purpose
[Why this skill exists]

## When to Use This Skill
[Auto-activation scenarios]

## Quick Reference
[Key patterns and examples]

## Resource Files
- [topic-1.md](resources/topic-1.md)
- [topic-2.md](resources/topic-2.md)
```

---

## Troubleshooting

### Skill isn't activating

**Check:**
1. Is skill directory in `.claude/skills/`?
2. Is skill listed in `skill-rules.json`?
3. Do `pathPatterns` match your files?
4. Are hooks installed and working?
5. Is settings.json configured correctly?

**Debug:**
```bash
# Check skill exists
ls -la .claude/skills/

# Validate skill-rules.json
cat .claude/skills/skill-rules.json | jq .

# Check hooks are executable
ls -la .claude/hooks/*.sh

# Test hook manually
./.claude/hooks/skill-activation-prompt.sh
```

### Skill activates too often

Update skill-rules.json:
- Make keywords more specific
- Narrow `pathPatterns`
- Increase specificity of `intentPatterns`

### Skill never activates

Update skill-rules.json:
- Add more keywords
- Broaden `pathPatterns`
- Add more `intentPatterns`

---

## For Claude Code

**When integrating a skill for a user:**

1. **Read [CLAUDE_INTEGRATION_GUIDE.md](../../CLAUDE_INTEGRATION_GUIDE.md)** first
2. Ask about their project structure
3. Customize `pathPatterns` in skill-rules.json
4. Verify the skill file has no hardcoded paths
5. Test activation after integration

**Common mistakes:**
- Keeping example paths (blog-api/, frontend/)
- Not asking about monorepo vs single-app
- Copying skill-rules.json without customization

---

## Next Steps

1. **Start simple:** Add one skill that matches your work
2. **Verify activation:** Edit a relevant file, skill should suggest
3. **Add more:** Once first skill works, add others
4. **Customize:** Adjust triggers based on your workflow

**Questions?** See [CLAUDE_INTEGRATION_GUIDE.md](../../CLAUDE_INTEGRATION_GUIDE.md) for comprehensive integration instructions.

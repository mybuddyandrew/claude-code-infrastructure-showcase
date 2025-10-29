# Public Infrastructure Repository - Context & Key Information

**Last Updated:** 2025-10-29
**Project:** claude-code-infrastructure-showcase
**Purpose:** Public repository showcasing Claude Code infrastructure from 6-month production use

---

## SESSION PROGRESS (2025-10-29)

### ✅ COMPLETED

**Phase 1: Repository Setup**
- Created repo at `~/git/claude-code-infrastructure-showcase/`
- Initialized git with anonymous identity: "Claude Code Infrastructure <noreply@example.com>"
- **CRITICAL:** Git history rewritten - no personal names in commits
- Created directory structure (.claude/hooks, skills, agents, commands, docs, templates, examples, dev)
- Added .gitignore, LICENSE (MIT), initial README.md

**Phase 2: Hooks System**
- ✅ Copied all 5 hooks (skill-activation-prompt, error-handling-reminder, post-tool-use-tracker, stop-build-check, stop-prettier)
- ✅ Genericized error-handling-reminder.ts (removed specific service names)
- ✅ Made post-tool-use-tracker.sh auto-detect project structure (frontend, backend, packages, etc.)
- ✅ Updated stop-prettier-formatter.sh (searches upward for .prettierrc)
- ✅ stop-build-check-enhanced.sh already generic
- ✅ Installed npm dependencies in .claude/hooks/
- ✅ Created comprehensive hooks/README.md
- ✅ Created hooks/CONFIG.md with customization guide

**Phase 3: Skills System (PARTIAL)**
- ✅ Copied skill-developer/ (7 files)
- ✅ Scrubbed all references (plp-database-verification → database-verification, etc.)
- ✅ Copied backend-dev-guidelines/ (12 files) - **NEEDS SCRUBBING**
- ✅ Copied frontend-dev-guidelines/ - **NEEDS SCRUBBING**
- ❌ database-verification skill - **NOT CREATED YET**
- ❌ error-tracking skill - **NOT CREATED YET**
- ❌ skill-rules.json - **NOT CREATED YET**

**Phase 4: Agents & Commands (PARTIAL)**
- ✅ Copied auto-error-resolver.md agent
- ✅ Copied /dev-docs and /dev-docs-update slash commands
- ❌ Need to update paths in commands

**Dev Docs**
- ✅ Copied plan/context/tasks to `dev/active/public-infrastructure-repo/`

### ⚠️ CRITICAL ITEMS FOR NEXT SESSION

**1. ANONYMITY MAINTAINED**
- Git configured locally: `user.name="Claude Code Infrastructure"`, `user.email="noreply@example.com"`
- **ALL future commits:** NO references to names, company, or work project in commit messages
- Commit history already rewritten - all commits show anonymous author

**2. SCRUBBING STILL REQUIRED**

**backend-dev-guidelines/** - Contains many references:
- Service names (form-service, email-service, users-service) → genericize
- Table names (WorkflowInstance, SubmissionAttributeFlat) → use Post, User, Comment
- Features (closeout, monthly reports) → generic blog examples
- Need to run: `grep -ri "plp\|submission\|workflow\|closeout\|miltech" .`

**frontend-dev-guidelines/** - Contains references:
- Form/submission components → blog components
- Specific features (form builder, project catalog) → generic examples
- Need to run: `grep -ri "plp\|submission\|form.*builder\|project.*catalog" .`

**slash commands** - Need path updates:
- dev-docs.md and dev-docs-update.md reference /root/git/work-project paths
- Update to use $CLAUDE_PROJECT_DIR or relative paths

**3. STILL TO CREATE**

- database-verification skill (generic Prisma column verification)
- error-tracking skill (generic Sentry patterns)
- skill-rules.json (5 skills, heavily commented)
- Blog API example (examples/blog-api/)
- PM2 ecosystem.config.js
- Comprehensive documentation (SETUP.md, HOOKS_SYSTEM.md, SKILLS_SYSTEM.md, DEV_DOCS_PATTERN.md, PM2_DEBUGGING.md)
- All templates (skill, hook, agent, command, dev-docs)

### 📋 IMMEDIATE NEXT STEPS

1. **Scrub backend-dev-guidelines:** Replace all work-specific examples with blog examples
2. **Scrub frontend-dev-guidelines:** Replace form/submission examples with blog UI examples
3. **Create database-verification skill:** Generic Prisma best practices
4. **Create error-tracking skill:** Generic Sentry integration patterns
5. **Create skill-rules.json:** 5 skills with extensive comments
6. **Update slash commands:** Fix paths to be generic

---

## Quick Context

Creating a public GitHub repository to share the sophisticated Claude Code setup that was detailed in the viral Reddit post "Claude Code is a Beast - Part 2". Goal is to help community solve the "skills don't activate automatically" problem while keeping all proprietary work code private.

**Time Budget:** 10-15 hours (MVP)
**Scope:** Infrastructure showcase with minimal examples
**Domain:** Blog platform (simple, universal)

---

## Key Decisions Made

### Repository Scope (Infrastructure-Focused)

**User chose:**
- Infrastructure showcase (NOT full application)
- Minimal time investment (10-15 hours)
- Emphasis on: Skills auto-activation, modular skills pattern, dev docs system, PM2 debugging
- Domain: Blog platform (simple)

**What this means:**
- Focus on hooks, skills, configs, docs
- One simple blog API service (not multiple microservices)
- No full frontend (maybe basic examples in docs)
- Templates over complete implementations

### What Gets Extracted

**Infrastructure (Core Value - COPY):**
1. Hooks system (5 hooks)
   - skill-activation-prompt.ts
   - error-handling-reminder.ts
   - post-tool-use-tracker.sh
   - stop-build-check-enhanced.sh
   - stop-prettier-formatter.sh

2. Skills system
   - skill-developer (7 files) - Keep with minor scrubbing
   - backend-dev-guidelines (12 files) - Genericize examples
   - frontend-dev-guidelines (11 files) - Genericize examples
   - database-verification - Create generic version
   - error-tracking - Create generic version
   - skill-rules.json - Rewrite with comments

3. Agents
   - auto-error-resolver - Copy as-is
   - Templates for others

4. Slash commands
   - /dev-docs, /dev-docs-update - Copy with path updates

5. PM2 configuration
   - ecosystem.config.js pattern
   - PM2 scripts from package.json

6. Dev docs pattern
   - Example from dev/active/
   - Templates

### What Gets Left Behind

**Project-specific (DO NOT INCLUDE):**
- All plp-* skills (workflow, notification, catalog, etc.)
- Business logic and domain concepts
- Actual microservices code (except genericized example)
- Frontend application (except maybe docs)
- Database schema (except generic blog schema)
- Any work-specific workflows

---

## Key Files to Reference During Implementation

### Source Files (Current Project)

**Hooks:**
- `/root/git/PLP_pre/.claude/hooks/` - All hook files
- `/root/git/PLP_pre/.claude/settings.json` - Hook registration

**Skills:**
- `/root/git/PLP_pre/.claude/skills/skill-developer/` - Copy mostly as-is
- `/root/git/PLP_pre/.claude/skills/backend-dev-guidelines/` - Genericize
- `/root/git/PLP_pre/.claude/skills/frontend-dev-guidelines/` - Genericize
- `/root/git/PLP_pre/.claude/skills/skill-rules.json` - Rewrite

**Agents:**
- Agent configurations in .claude/agents/ (if exists)
- System prompts for agents (in agent tool descriptions)

**Commands:**
- `/root/git/PLP_pre/.claude/commands/` - Slash commands

**PM2:**
- `/root/git/PLP_pre/ecosystem.config.js` - PM2 configuration
- Root package.json - PM2 scripts

**Dev Docs:**
- `/root/git/PLP_pre/dev/active/` - Multiple examples to reference
- Look for well-structured examples

**Documentation:**
- `/root/git/PLP_pre/dev/active/skill-auto-activation-system/` - Great docs on hooks/skills

### Target Repository Structure

**Location:** `~/git/claude-code-infrastructure-showcase/` (new repo)

**Structure:**
```
claude-code-infrastructure-showcase/
├── .claude/
│   ├── hooks/
│   ├── skills/
│   ├── agents/
│   └── commands/
├── docs/
├── templates/
├── examples/
│   └── blog-api/
├── dev/
│   └── active/add-blog-comments/
└── ecosystem.config.js
```

---

## Scrubbing Requirements (CRITICAL)

### Search & Destroy Patterns

**Must remove ALL instances of:**
- "PLP" (case-sensitive)
- "plp" (lowercase)
- "Project Lifecycle Portal"
- "plp_dev" (database name)
- "dieter" / "Dieter"
- "dietergrosswiler"
- "MilTech" / "miltech"
- "@miltech.com"
- "plp.miltech.com"
- Any work URLs

**Project-specific terms to remove:**
- DHS_CLOSEOUT, AFRL (workflow codes)
- Submission, SubmissionAttributeFlat (tables)
- Closeout, Monthly Report (features)
- Form service, Email service (replace with generic names)
- WorkflowInstance (replace with Order, Post, etc.)
- Contract mechanism

**Scrubbing commands:**
```bash
# Run in new repo after copying
grep -ri "plp" . --exclude-dir=node_modules --exclude-dir=.git
grep -r "dieter" . --exclude-dir=node_modules
grep -ri "miltech" . --exclude-dir=node_modules
grep -r "workflow.*DHS\|workflow.*AFRL" . --include="*.md"
```

**If found:** Replace or remove entire section if too specific

### Generic Replacements

**Domain concepts:**
- Submission → Post, Product, Order (blog domain)
- Form → PostForm, CommentForm
- Project → Blog
- User workflow → Post approval, comment moderation
- Contract → Order
- Closeout → Order fulfillment

**Services:**
- form-service → blog-api, posts-service
- email-service → notifications-service
- users-service → auth-service

**Database tables:**
- WorkflowInstance → Post, Order
- SubmissionAttributeFlat → (remove, use Post)
- FormResponse → CommentResponse

---

## Technical Decisions

### Example Application: Blog API

**Why blog platform:**
- Simple and universal
- Shows backend patterns clearly
- Familiar to all developers
- Less complexity than e-commerce or project management

**Schema (Prisma):**
```prisma
model User {
  id       String @id @default(uuid())
  email    String @unique
  name     String
  posts    Post[]
  comments Comment[]
}

model Post {
  id        String   @id @default(uuid())
  title     String
  content   String
  authorId  String
  author    User     @relation(fields: [authorId])
  comments  Comment[]
  published Boolean  @default(false)
  createdAt DateTime @default(now())
}

model Comment {
  id      String @id @default(uuid())
  content String
  postId  String
  post    Post   @relation(fields: [postId])
  userId  String
  user    User   @relation(fields: [userId])
  createdAt DateTime @default(now())
}
```

### Hooks Configuration

**Keep all 5 hooks:**
1. skill-activation-prompt (UserPromptSubmit)
2. error-handling-reminder (Stop)
3. post-tool-use-tracker (PostToolUse)
4. stop-build-check (Stop)
5. stop-prettier-formatter (Stop)

**Modify:**
- Make repo detection configurable
- Make build commands configurable
- Generic technology checks

### Skills to Include

**Generic skills (5 total):**
1. skill-developer - Meta-skill (mostly as-is)
2. backend-dev-guidelines - Genericized
3. frontend-dev-guidelines - Genericized
4. database-verification - Generic Prisma patterns
5. error-tracking - Generic Sentry patterns

**Remove:**
- All plp-* skills (7 skills)
- Too project-specific to genericize

**skill-rules.json:**
- Only 5 skills configured
- Heavily commented
- Examples included

### PM2 Configuration

**Simple config for blog API:**
```javascript
module.exports = {
  apps: [{
    name: 'blog-api',
    cwd: './examples/blog-api',
    script: 'npm',
    args: 'run dev',
    error_file: './examples/blog-api/logs/error.log',
    out_file: './examples/blog-api/logs/out.log',
    watch: false,
    instances: 1,
  }]
};
```

**Show pattern for multiple services** (commented out examples)

---

## File Extraction Checklist

**Hooks (copy with modifications):**
- [ ] skill-activation-prompt.ts ✅
- [ ] skill-activation-prompt.sh ✅
- [ ] error-handling-reminder.ts ⚠️ (genericize)
- [ ] error-handling-reminder.sh ✅
- [ ] post-tool-use-tracker.sh ⚠️ (make configurable)
- [ ] stop-build-check-enhanced.sh ⚠️ (make configurable)
- [ ] stop-prettier-formatter.sh ⚠️ (minor tweaks)
- [ ] hooks/README.md ⚠️ (update examples)
- [ ] hooks/package.json ✅
- [ ] hooks/tsconfig.json ✅

**Skills (copy with scrubbing):**
- [ ] skill-developer/ ⚠️ (scrub PLP)
- [ ] backend-dev-guidelines/ ⚠️ (genericize all examples)
- [ ] frontend-dev-guidelines/ ⚠️ (genericize all examples)
- [ ] Create database-verification/ (new, generic)
- [ ] Create error-tracking/ (new, generic)
- [ ] skill-rules.json ⚠️ (complete rewrite with comments)

**Agents:**
- [ ] auto-error-resolver.md ✅ (copy as-is)
- [ ] Create agent templates

**Commands:**
- [ ] /dev-docs ⚠️ (update paths)
- [ ] /dev-docs-update ⚠️ (update paths)

**PM2:**
- [ ] ecosystem.config.js ⚠️ (create new for blog)
- [ ] PM2 scripts from package.json ✅ (copy as-is)

**Dev Docs:**
- [ ] Create example (add-blog-comments/)
- [ ] Create templates

---

## Important Notes

### What Makes This Valuable

**The breakthrough:** Hooks that make skills actually activate automatically

**Why people care:**
- Skills feature released by Anthropic
- Everyone struggles with "skills just sit there and don't activate"
- No official solution for auto-activation
- This setup solves it with hooks + skill-rules.json

**Secondary value:**
- Modular skills pattern (500-line rule)
- Dev docs methodology (survives context resets)
- PM2 debugging workflow
- Production-tested over 6 months

### What NOT to Include

**Avoid:**
- Any domain-specific business logic
- Work-specific workflows (closeout, monthly reports, etc.)
- Complex microservices architecture (keep it simple)
- Full frontend application (infrastructure showcase, not app showcase)
- Proprietary database schemas
- Work-specific agents/patterns

**Remember:** Infrastructure showcase, not application showcase

### Testing Strategy

**Before publishing:**
1. Clone to completely new location
2. Delete all node_modules
3. Follow SETUP.md exactly
4. Time the setup (should be < 15 min)
5. Test every hook
6. Test every skill activation
7. Run scrubbing verification commands
8. Manual review of every file
9. External review (friend/colleague)

**If any PLP references found:** Fix immediately, re-test

---

## Success Criteria

**MVP is complete when:**
- ✅ All hooks extracted and working
- ✅ 5 generic skills with auto-activation
- ✅ skill-rules.json is self-documenting
- ✅ Dev docs pattern with real example
- ✅ PM2 configuration example
- ✅ Comprehensive README + 4 guide docs
- ✅ Templates for skills, agents, hooks, commands
- ✅ One working blog API service
- ✅ Setup takes < 15 minutes
- ✅ ZERO identifiable references
- ✅ Published on GitHub
- ✅ Announced to community

**Then:** Ship it and iterate based on feedback!

---

## Related Files

**Current work project files:**
- This plan references paths in /root/git/PLP_pre/
- All will be copied to ~/git/claude-code-infrastructure-showcase/

**Documentation:**
- Reddit post: `/root/git/PLP_pre/documentation/write-ups/Claude Code is a Beast – Part 2 (Complete).md`
- Dev docs: `/root/git/PLP_pre/dev/active/skill-auto-activation-system/`

**Key infrastructure:**
- Hooks: `/root/git/PLP_pre/.claude/hooks/`
- Skills: `/root/git/PLP_pre/.claude/skills/`
- Settings: `/root/git/PLP_pre/.claude/settings.json`

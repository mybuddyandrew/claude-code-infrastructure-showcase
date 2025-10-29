# Public Infrastructure Repository - Implementation Plan

**Created:** 2025-10-27
**Last Updated:** 2025-10-27
**Status:** Ready to implement
**Estimated Time:** 10-15 hours (MVP)

---

## Executive Summary

Create a public GitHub repository showcasing the sophisticated Claude Code infrastructure developed over 6 months, including the hooks system (skill auto-activation, build checking, error reminders), modular skills pattern (500-line rule), dev docs system (plan/context/tasks), and PM2 multi-service debugging setup. Repository will be infrastructure-focused with minimal working examples, designed for 10-15 hour time investment, and completely scrubbed of all proprietary/identifiable information.

**Primary Goal:** Help the community solve the "skills don't activate automatically" problem and showcase enterprise-grade Claude Code workflow patterns.

**Key Constraint:** NO proprietary code, business logic, or identifiable information from work project.

---

## Current State Analysis

### Existing Infrastructure (Ready to Extract)

**Hooks System:**
- ✅ skill-activation-prompt.ts (133 lines) - UserPromptSubmit hook
- ✅ error-handling-reminder.ts (212 lines) - Stop hook for gentle reminders
- ✅ post-tool-use-tracker.sh (145 lines) - PostToolUse tracking
- ✅ stop-build-check-enhanced.sh (125 lines) - Build validation
- ✅ stop-prettier-formatter.sh (88 lines) - Auto formatting
- ✅ Registered in .claude/settings.json
- ⚠️ Some project-specific references need scrubbing

**Skills System:**
- ✅ skill-developer (7 files, modular, 426-line main)
- ✅ backend-dev-guidelines (12 files, modular, 304-line main)
- ✅ frontend-dev-guidelines (11 files, modular, 398-line main)
- ✅ skill-rules.json with 10 skills configured
- ⚠️ 7 skills are project-specific (plp-*), need removal/replacement
- ✅ 3 skills are generic, need minor scrubbing

**Agents:**
- ✅ auto-error-resolver (completely generic)
- ⚠️ auth-route-tester (needs auth generalization)
- ⚠️ Multiple other agents (can be converted to templates)

**Slash Commands:**
- ✅ /dev-docs (create dev docs)
- ✅ /dev-docs-update (update dev docs)
- ✅ /route-research-for-testing (can be genericized)

**PM2 Setup:**
- ✅ ecosystem.config.js (6 services configured)
- ✅ PM2 scripts in package.json
- ⚠️ Service names are project-specific

**Dev Docs Pattern:**
- ✅ Well-established in dev/active/
- ✅ Multiple real examples to reference
- ✅ Plan/Context/Tasks methodology proven

### Identifiable Information to Scrub

**Project-specific references:**
- "PLP" / "plp" / "Project Lifecycle Portal"
- "plp_dev" database name
- Service names: form, email, users, projects, utilities
- Workflow codes: DHS_CLOSEOUT, AFRL workflows
- Domain concepts: submissions, closeout, monthly reports

**Personal/Company references:**
- "dieter" / "Dieter" (username)
- "MilTech" / "miltech" (company)
- "dietergrosswiler" (paths)
- "@miltech.com" (emails)
- Any URLs (plp.miltech.com, etc.)

**Business Logic:**
- Workflow engine specifics
- Form submission patterns
- Contract management
- Project catalog
- All domain-specific features

---

## Proposed Future State

### Repository: claude-code-infrastructure-showcase

**Public GitHub repository providing:**

1. **Core Infrastructure** (production-ready, copy-paste)
   - Complete hooks system with auto-skill-activation
   - Modular skills following 500-line rule
   - Agent templates
   - Slash command examples
   - PM2 multi-service configuration

2. **Comprehensive Documentation**
   - How the system works (HOOKS_SYSTEM.md)
   - How to create skills (SKILLS_SYSTEM.md)
   - Dev docs methodology (DEV_DOCS_PATTERN.md)
   - PM2 debugging workflow (PM2_DEBUGGING.md)

3. **Templates** (ready to customize)
   - Skill template with annotations
   - Agent template with structure
   - Hook template
   - Dev docs templates

4. **Minimal Working Example**
   - Simple blog API service (one microservice)
   - Demonstrates backend patterns
   - Shows skills in action
   - PM2 configuration
   - Generic Prisma schema

5. **Zero Proprietary Information**
   - All PLP references removed
   - Generic examples only (blog posts, users, comments)
   - No business logic
   - No identifiable information

**Target Audience:**
- Developers struggling with Claude Code at scale
- Teams wanting to establish consistency
- Anyone who read the Reddit post and wants to see it in action

**Value Proposition:**
- Solves "skills don't activate" problem
- Proven patterns from 6 months of real-world use
- Production-grade infrastructure
- Saves months of experimentation

---

## Implementation Phases

### Phase 1: Repository Setup & Structure (30 min - Effort: S)

**Tasks:**

1.1 Create new Git repository
- Create directory: `~/git/claude-code-infrastructure-showcase/`
- Run: `git init`
- Create `.gitignore`
- Acceptance: Clean repo with initial commit

1.2 Create directory structure
- Create all directories from plan
- Acceptance: Directory tree matches proposed structure

1.3 Create initial README.md
- Compelling introduction
- Quick feature highlights
- "Coming soon" sections
- Acceptance: Professional README with clear value prop

1.4 Add LICENSE
- MIT License recommended
- Acceptance: LICENSE file in root

### Phase 2: Extract & Genericize Hooks (2 hours - Effort: M)

**Tasks:**

2.1 Copy hooks directory
- `cp -r .claude/hooks/ ../claude-code-infrastructure-showcase/.claude/hooks/`
- Acceptance: All hook files copied

2.2 Genericize skill-activation-prompt.ts
- ✅ No changes needed (already generic)
- Test with generic skill-rules.json
- Acceptance: Hook works with genericized skills

2.3 Genericize error-handling-reminder.ts
- Remove PrismaService-specific checks
- Make technology checks configurable
- Replace backend/frontend categories with generic patterns
- Acceptance: Hook works without PLP-specific patterns

2.4 Genericize post-tool-use-tracker.sh
- Remove hardcoded repo names (form, email, etc.)
- Add repo detection from package.json workspaces or config
- Create repos.config.json example
- Acceptance: Configurable repo detection works

2.5 Genericize stop-build-check-enhanced.sh
- Make build commands configurable
- Support custom tsc commands per repo
- Create build.config.json example
- Acceptance: Works with example blog service

2.6 Genericize stop-prettier-formatter.sh
- Update config path detection
- Support multiple prettier config locations
- Acceptance: Formats blog service files correctly

2.7 Update hooks/README.md
- Remove PLP examples
- Add generic examples (blog, e-commerce)
- Document configuration options
- Acceptance: Clear, generic documentation

2.8 Create hooks/CONFIG.md
- Configuration guide
- Customization instructions
- Examples for different project types
- Acceptance: Users can configure for their projects

### Phase 3: Extract & Genericize Skills (2.5 hours - Effort: M)

**Tasks:**

3.1 Copy skill-developer (minor scrubbing)
- `cp -r .claude/skills/skill-developer/ {new-repo}/.claude/skills/`
- Find/replace "PLP" references
- Update examples to be generic
- Acceptance: No PLP references, works independently

3.2 Genericize backend-dev-guidelines
- Copy all 12 files
- Replace PLP-specific examples:
  - WorkflowInstance → Order, Post, User
  - SubmissionController → PostController
  - responseRoutes.ts bad example → genericize to blogRoutes.ts
- Update file path references
- Keep all patterns (BaseController, DI, repositories, etc.)
- Acceptance: Examples use blog/ecommerce domain, no PLP references

3.3 Genericize frontend-dev-guidelines
- Copy all 11 files
- Replace examples:
  - Submissions → Posts, Products
  - Project Catalog → Product Catalog / Post List
  - Form submission → Blog post creation
- Keep all patterns (Suspense, lazy loading, MUI v7, etc.)
- Acceptance: Examples use blog domain, no PLP references

3.4 Create database-verification skill (generic)
- Extract pattern from plp-database-verification
- Generic Prisma column verification
- Use blog schema examples (User, Post, Comment)
- Acceptance: Generic Prisma verification skill

3.5 Create error-tracking skill (generic)
- Extract from plp-sentry-integration
- Generic Sentry patterns
- Remove project-specific error types
- Acceptance: Universal Sentry patterns documented

3.6 Rewrite skill-rules.json
- Remove all plp-* entries
- Keep: skill-developer, backend-dev-guidelines, frontend-dev-guidelines, database-verification, error-tracking
- Add EXTENSIVE inline comments explaining each field
- Include commented-out examples
- Acceptance: 5 skills, heavily documented, self-explanatory

3.7 Final skills scrubbing pass
- grep -r "PLP\|plp" .claude/skills/
- Remove any remaining references
- Verify examples are generic
- Acceptance: Zero PLP references in skills

### Phase 4: Extract Agents & Commands (1 hour - Effort: S)

**Tasks:**

4.1 Copy auto-error-resolver agent
- ✅ Copy as-is (completely generic)
- Add to .claude/agents/
- Acceptance: Agent works with example project

4.2 Create agent templates
- templates/agents/AGENT_TEMPLATE.md
- Include YAML frontmatter structure
- Annotated example
- Acceptance: Template is clear and reusable

4.3 Copy slash commands
- Copy /dev-docs, /dev-docs-update
- Update paths to be generic
- Acceptance: Commands work in new repo

4.4 Create command template
- templates/commands/COMMAND_TEMPLATE.md
- Document structure
- Annotated example
- Acceptance: Users can create custom commands

### Phase 5: Create Blog API Example (1.5 hours - Effort: M)

**Tasks:**

5.1 Create Prisma schema
- Simple blog schema: User, Post, Comment
- Generic, understandable
- Shows relationships
- Acceptance: schema.prisma compiles, shows patterns

5.2 Create blog-api service structure
- src/ with standard backend structure
- instrument.ts (Sentry)
- config/config.ts (unifiedConfig pattern)
- controllers/BaseController.ts + PostController.ts
- routes/postRoutes.ts (clean delegation)
- services/postService.ts (business logic)
- repositories/PostRepository.ts (data access)
- Acceptance: Service structure demonstrates all backend patterns

5.3 Implement one complete endpoint
- POST /api/posts (create post)
- Shows: route → controller → service → repository
- Validation with Zod
- Error handling with Sentry
- Acceptance: Working endpoint demonstrating patterns

5.4 Add README for blog-api
- What it demonstrates
- How to run it
- Key patterns highlighted
- Acceptance: Clear documentation

### Phase 6: PM2 & Configuration (30 min - Effort: S)

**Tasks:**

6.1 Create ecosystem.config.js
- Configure blog-api service
- Show pattern for multiple services
- Include comments
- Acceptance: `pm2 start ecosystem.config.js` works

6.2 Add PM2 scripts to package.json
- pm2:start, pm2:stop, pm2:logs, etc.
- Copy from PLP project (generic scripts)
- Acceptance: All PM2 commands work

6.3 Create PM2 documentation
- docs/PM2_DEBUGGING.md
- Setup guide
- Log viewing patterns
- How Claude uses PM2 for debugging
- Acceptance: Complete PM2 guide

### Phase 7: Dev Docs Example (1 hour - Effort: S)

**Tasks:**

7.1 Create example dev docs
- dev/active/add-blog-comments/
- Real plan.md (plan for adding comments feature)
- Real context.md (key files, decisions)
- Real tasks.md (checklist format)
- Acceptance: Demonstrates complete dev docs pattern

7.2 Create dev docs templates
- templates/dev-docs-templates/plan-template.md
- templates/dev-docs-templates/context-template.md
- templates/dev-docs-templates/tasks-template.md
- With annotations and guidance
- Acceptance: Templates are clear and reusable

7.3 Create dev/README.md
- Explain dev docs system
- When to use
- How to create
- How to maintain
- Acceptance: Complete guide to dev docs pattern

### Phase 8: Comprehensive Documentation (2 hours - Effort: M)

**Tasks:**

8.1 Write stellar README.md
- Hook readers immediately
- Clear value proposition
- 5-minute quick start
- Feature highlights with examples
- Architecture overview
- Links to detailed docs
- Community section
- Acceptance: Professional, compelling README

8.2 Create SETUP.md
- Step-by-step setup (< 15 minutes)
- Prerequisites
- Installation
- Configuration
- Testing
- Customization
- Acceptance: Anyone can follow and get working

8.3 Write docs/HOOKS_SYSTEM.md
- What hooks are
- Why they're the breakthrough for skills
- Each hook explained (purpose, mechanism, configuration)
- How to create custom hooks
- Exit codes and behaviors
- Session state management
- Examples
- Acceptance: Complete hooks reference

8.4 Write docs/SKILLS_SYSTEM.md
- What skills are
- Why they don't activate without hooks
- How hooks + skills work together
- skill-rules.json deep dive
- Creating skills (500-line rule, progressive disclosure)
- Trigger types (keywords, intent, files, content)
- Examples of skill activation
- Acceptance: Complete skills guide

8.5 Write docs/DEV_DOCS_PATTERN.md
- Plan/Context/Tasks methodology
- Why it works
- When to use
- Integration with slash commands
- Examples
- Acceptance: Complete dev docs guide

8.6 Write docs/PM2_DEBUGGING.md
- Why PM2 for multi-service dev
- Setup and configuration
- Debugging workflow with Claude
- Log management
- How it changed debugging
- Acceptance: Complete PM2 guide

### Phase 9: Create Templates (1.5 hours - Effort: S)

**Tasks:**

9.1 Create skill template
- templates/skill-template/SKILL_TEMPLATE.md
- With extensive inline comments
- Example frontmatter
- Structure guidance
- Acceptance: Users can create skills from template

9.2 Create hook template
- templates/hook-template.ts
- TypeScript skeleton
- Comments explaining each part
- Acceptance: Developers can create custom hooks

9.3 Create agent template
- templates/agent-template.md
- YAML frontmatter structure
- Agent design patterns
- Example agent with annotations
- Acceptance: Users can create custom agents

9.4 Update all templates with examples
- Add "fill in the blanks" sections
- Include decision guidance
- Acceptance: Templates are self-explanatory

### Phase 10: Testing & Validation (2 hours - Effort: M)

**Tasks:**

10.1 Fresh clone test
- Clone repo to new location
- Follow SETUP.md exactly
- Verify all steps work
- Time the setup process
- Acceptance: Setup completes in < 15 minutes

10.2 Test hooks
- Trigger skill-activation-prompt with test prompts
- Trigger error-handling-reminder by editing files
- Verify build-check works
- Verify prettier runs
- Acceptance: All hooks work correctly

10.3 Test skill activation
- Test each skill with relevant prompts
- Verify triggers work (keywords, intent, files)
- Check no false positives
- Acceptance: Skills activate as expected

10.4 Comprehensive scrubbing verification
```bash
grep -ri "plp" . --exclude-dir=node_modules --exclude-dir=.git
grep -ri "project lifecycle" . --exclude-dir=node_modules
grep -r "dieter" . --exclude-dir=node_modules
grep -ri "miltech" . --exclude-dir=node_modules
grep -r "@.*miltech" . --include="*.ts" --include="*.md"
```
- Acceptance: ZERO matches for identifiable terms

10.5 Validate blog API example
- Run blog-api service
- Test endpoint
- Verify PM2 logging works
- Acceptance: Example demonstrates patterns

10.6 Documentation review
- Proofread all markdown
- Check all links work
- Verify code examples
- Acceptance: Professional documentation quality

### Phase 11: Polish & Publish (30 min - Effort: S)

**Tasks:**

11.1 Final README polish
- Add badges
- Add architecture diagram (Mermaid or ASCII)
- Screenshots of hook output
- Example skill activation
- Acceptance: README is compelling

11.2 Create GitHub repository
- Repository name: `claude-code-infrastructure-showcase`
- Description: "Production-grade Claude Code infrastructure: hooks for skill auto-activation, modular skills, dev docs system, PM2 debugging"
- Add topics: claude-code, ai-development, hooks, skills, developer-productivity, claude, anthropic
- Acceptance: Public repo created

11.3 Push code
- Initial commit
- Push to GitHub
- Acceptance: Code is public

11.4 Create release
- Tag v1.0.0
- Release notes
- Acceptance: Release published

11.5 Announcement
- Update Reddit post with link
- Post on dev.to
- Share in Claude Code communities
- Acceptance: Community notified

---

## Risk Assessment and Mitigation

### Risk 1: Identifiable Information Leaks

**Likelihood:** Medium
**Impact:** High (could expose work project)

**Mitigation:**
- Triple-pass scrubbing (automated grep + manual review)
- Use generic domain (blog) completely different from work
- Review every file manually before publish
- Have someone else review for anything missed

### Risk 2: Infrastructure Doesn't Work Without Project Context

**Likelihood:** Low
**Impact:** High (ruins value)

**Mitigation:**
- Test in completely fresh environment
- Follow setup guide exactly as written
- Get external tester to verify
- Ensure all dependencies documented

### Risk 3: Time Overrun

**Likelihood:** Medium
**Impact:** Medium (delays release)

**Mitigation:**
- Stick to MVP scope (no feature creep)
- Skip "nice to haves" (video, frontend, extra services)
- Can always add more later
- Set hard deadline (2 weekends max)

### Risk 4: Community Reception

**Likelihood:** Low (Reddit post was hit)
**Impact:** Low (but would be disappointing)

**Mitigation:**
- Focus on solving real pain points (skills activation)
- Provide working examples
- Comprehensive documentation
- Active in responding to questions/issues

---

## Success Metrics

### Quantitative Metrics

- ✅ Repository cloned 100+ times in first month
- ✅ 50+ stars on GitHub
- ✅ 10+ community contributions / PRs
- ✅ Setup time < 15 minutes for users
- ✅ Zero PLP references found by community
- ✅ 20+ Reddit upvotes on announcement post

### Qualitative Metrics

- ✅ Users report skills actually activating for them
- ✅ Positive feedback on hooks system
- ✅ Requests for additional skills/patterns
- ✅ Community shares their own skills
- ✅ People successfully integrate into their projects

### Personal Success

- ✅ Helped community solve skills activation problem
- ✅ Gave back to Claude Code community
- ✅ No work project exposure
- ✅ Established reputation in AI dev space

---

## Required Resources and Dependencies

### Tools & Technologies

**Already have:**
- Git
- Node.js / TypeScript
- Text editor
- GitHub account

**Need to install/configure:**
- Fresh testing environment (new directory)
- External tester (friend/colleague) for validation

### Knowledge Requirements

**Already have:**
- Deep knowledge of hooks system
- Understanding of skills architecture
- Dev docs methodology
- PM2 setup experience

**Might need:**
- Markdown diagram tools (Mermaid)
- Screenshot tools for README
- Video recording (optional, can skip for MVP)

---

## Timeline Estimates

### Aggressive Schedule (MVP in 2 weekends)

**Weekend 1 (8 hours):**
- Friday evening (2h): Phase 1-2 (repo setup, extract hooks)
- Saturday (4h): Phase 3 (extract skills)
- Sunday (2h): Phase 4-5 (agents, blog API example)

**Weekend 2 (7 hours):**
- Friday evening (2h): Phase 6-7 (PM2, dev docs example)
- Saturday (3h): Phase 8 (comprehensive documentation)
- Sunday (2h): Phase 9-11 (templates, testing, publish)

**Total:** 15 hours over 2 weekends

### Relaxed Schedule (MVP in 2-3 weeks)

**Week 1:** Phases 1-5 (infrastructure extraction)
**Week 2:** Phases 6-8 (examples & documentation)
**Week 3:** Phases 9-11 (polish & publish)

**Effort:** 2-3 hours per evening, 3-4 evenings per week

---

## Dependencies Between Tasks

**Critical Path:**
1. Repo setup (1.x) → Everything
2. Hooks extraction (2.x) → Skills work
3. Skills extraction (3.x) → skill-rules.json
4. skill-rules.json (3.6) → Skill activation testing
5. Blog API (5.x) → PM2 demo, docs examples
6. Documentation (8.x) → User onboarding
7. Testing (10.x) → Publish (11.x)

**Parallel Opportunities:**
- Agents (4.x) can happen anytime after repo setup
- Commands (4.3-4.4) can happen anytime
- Templates (9.x) can happen alongside phases 2-8

---

## Next Steps

**Immediate Actions:**
1. Create new repo directory
2. Start Phase 1 (repo setup)
3. Begin Phase 2 (hooks extraction)

**Track Progress:**
- Update tasks.md as work progresses
- Update context.md with decisions
- Keep plan.md current with any scope changes

**When to Pause:**
- After Phase 5 (have infrastructure + example)
- Could publish "Part 1" and add more later

---

**Status:** Ready to implement
**Confidence:** High (extracting proven patterns, not building new)
**Expected Outcome:** Valuable community resource in 10-15 hours

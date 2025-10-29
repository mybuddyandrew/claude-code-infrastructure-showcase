# Public Infrastructure Repository - Task Checklist

**Last Updated:** 2025-10-29 15:59
**Status:** Phase 2 Complete, Phase 3 Partial
**Estimated:** 10-15 hours total

**⚠️ CRITICAL: Git configured with anonymous identity - NO personal names in commits!**

---

## Phase 1: Repository Setup & Structure (30 min) ✅ COMPLETE

- [x] Create new directory: `~/git/claude-code-infrastructure-showcase/`
- [x] Run `git init`
- [x] Configure git: `user.name="Claude Code Infrastructure"`, `user.email="noreply@example.com"`
- [x] Rewrite commit history to use anonymous author (done via git rebase)
- [x] Create `.gitignore` (node_modules, .env, logs, etc.)
- [x] Create directory structure (see plan)
- [x] Create initial README.md with introduction
- [x] Add MIT LICENSE file

---

## Phase 2: Extract & Genericize Hooks (2 hours) ✅ COMPLETE

- [x] Copy entire `.claude/hooks/` directory to new repo
- [x] skill-activation-prompt.ts and .sh (no changes needed)
- [x] Genericize error-handling-reminder.ts (removed specific services, made path detection generic)
- [x] Make post-tool-use-tracker.sh configurable (auto-detects frontend/backend/packages/examples)
- [x] stop-build-check-enhanced.sh (already generic)
- [x] Update stop-prettier-formatter.sh (searches upward for .prettierrc, uses defaults if not found)
- [x] Update hooks/README.md (comprehensive, no work-specific examples)
- [x] Create hooks/CONFIG.md (detailed configuration guide)
- [x] Install npm dependencies: `cd .claude/hooks && npm install`

---

## Phase 3: Extract & Genericize Skills (2.5 hours) 🟡 IN PROGRESS

- [x] Copy skill-developer/ directory (7 files)
- [x] Scrub all references from skill-developer (plp-* → generic names, paths updated)
- [x] Copy backend-dev-guidelines/ directory (12 files) - **⚠️ NEEDS SCRUBBING**
- [x] Copy frontend-dev-guidelines/ directory - **⚠️ NEEDS SCRUBBING**
- [ ] **URGENT:** Scrub backend-dev-guidelines (form-service→blog-api, WorkflowInstance→Post, etc.)
- [ ] **URGENT:** Scrub frontend-dev-guidelines (form builder→blog UI, submissions→posts)
- [ ] Create database-verification/ skill (generic Prisma patterns, ~200 lines)
- [ ] Create error-tracking/ skill (generic Sentry patterns, ~200 lines)
- [ ] Rewrite skill-rules.json (5 skills: skill-developer, backend-dev-guidelines, frontend-dev-guidelines, database-verification, error-tracking)
- [ ] Final verification: `cd .claude/skills && grep -ri "plp\|submission\|workflow\|closeout\|miltech\|dieter" .`

**Scrubbing Checklist for backend-dev-guidelines:**
- [ ] Replace service names: form-service, email-service, users-service → blog-api, auth-service
- [ ] Replace tables: WorkflowInstance, SubmissionAttributeFlat → Post, User, Comment
- [ ] Replace features: closeout, monthly reports → post moderation, comment approval
- [ ] Update all code examples to use blog domain
- [ ] Verify no file paths reference work project

**Scrubbing Checklist for frontend-dev-guidelines:**
- [ ] Replace components: FormBuilder, SubmissionDataGrid → PostEditor, CommentList
- [ ] Replace features: project catalog, form designer → blog dashboard, post management
- [ ] Update all examples to blog UI patterns
- [ ] Verify no references to work-specific features

---

## Phase 4: Extract Agents & Commands (1 hour) 🟡 PARTIAL

- [x] Copy auto-error-resolver.md agent
- [ ] Update auto-error-resolver.md paths (if any references exist)
- [ ] Create templates/agents/AGENT_TEMPLATE.md (annotated template with instructions)
- [x] Copy /dev-docs slash command
- [x] Copy /dev-docs-update slash command
- [ ] **Update dev-docs.md:** Change paths from /root/git/work-project to $CLAUDE_PROJECT_DIR
- [ ] **Update dev-docs-update.md:** Change paths to be generic
- [ ] Create templates/commands/COMMAND_TEMPLATE.md (template with examples)

---

## Phase 5: Create Blog API Example (1.5 hours)

- [ ] Create examples/blog-api/ directory structure
- [ ] Create package.json (express, typescript, prisma, @sentry/node)
- [ ] Create Prisma schema (User, Post, Comment with relations)
- [ ] Create src/instrument.ts (Sentry v8 setup)
- [ ] Create src/config/unifiedConfig.ts (environment config pattern)
- [ ] Create src/controllers/BaseController.ts (error handling, Sentry integration)
- [ ] Create src/controllers/PostController.ts (extends BaseController)
- [ ] Create src/services/PostService.ts (business logic)
- [ ] Create src/repositories/PostRepository.ts (data access layer)
- [ ] Create src/routes/postRoutes.ts (clean Express routes)
- [ ] Create src/app.ts (Express app setup)
- [ ] Create src/server.ts (server entry point)
- [ ] Implement POST /api/posts endpoint (complete, working example)
- [ ] Add blog-api/README.md (how to run, architecture overview)
- [ ] Add blog-api/tsconfig.json
- [ ] Test: `cd examples/blog-api && npm install && npm run dev`

---

## Phase 6: PM2 & Configuration (30 min)

- [ ] Create ecosystem.config.js at root (blog-api service with logs path)
- [ ] Add PM2 scripts to root package.json (pm2:start, pm2:logs, pm2:stop)
- [ ] Test `pm2 start ecosystem.config.js`
- [ ] Test `pm2 logs blog-api`
- [ ] Test `pm2 restart blog-api`
- [ ] Create docs/PM2_DEBUGGING.md (complete guide with examples)
- [ ] Document common PM2 commands
- [ ] Document how Claude accesses logs via PM2

---

## Phase 7: Dev Docs Example (1 hour)

- [ ] Create dev/active/add-blog-comments/ directory
- [ ] Write add-blog-comments-plan.md (realistic plan showing dev docs usage)
- [ ] Write add-blog-comments-context.md (key files, decisions, API structure)
- [ ] Write add-blog-comments-tasks.md (checklist format with phases)
- [ ] Create dev/README.md (explain dev docs methodology)
- [ ] Create templates/dev-docs-templates/plan-template.md (annotated)
- [ ] Create templates/dev-docs-templates/context-template.md (annotated)
- [ ] Create templates/dev-docs-templates/tasks-template.md (annotated)

---

## Phase 8: Comprehensive Documentation (2 hours)

- [ ] Create SETUP.md (< 15 minute setup guide, step-by-step)
- [ ] Write docs/HOOKS_SYSTEM.md (complete reference: UserPromptSubmit, PreToolUse, PostToolUse, Stop)
- [ ] Write docs/SKILLS_SYSTEM.md (skill-rules.json format, trigger types, hooks integration)
- [ ] Write docs/DEV_DOCS_PATTERN.md (methodology, when to use, best practices)
- [ ] Write docs/PM2_DEBUGGING.md (from Phase 6)
- [ ] Update root README.md (polish, add architecture diagram)
- [ ] Add quick start example to README
- [ ] Verify all internal doc links work

---

## Phase 9: Create Templates (1.5 hours)

- [ ] Create templates/skill-template/SKILL_TEMPLATE.md (YAML frontmatter, structure, examples)
- [ ] Create templates/skill-template/RESOURCE_FILE_TEMPLATE.md (for modular skills)
- [ ] Create templates/hook-template.sh (bash wrapper skeleton)
- [ ] Create templates/hook-template.ts (TypeScript implementation skeleton)
- [ ] Verify templates/agents/AGENT_TEMPLATE.md (from Phase 4)
- [ ] Verify templates/commands/COMMAND_TEMPLATE.md (from Phase 4)
- [ ] Verify templates/dev-docs-templates/* (from Phase 7)
- [ ] Add usage instructions to each template
- [ ] Create templates/README.md (index of all templates)

---

## Phase 10: Testing & Validation (2 hours)

- [ ] **Final scrub verification:**
  - [ ] `cd ~/git/claude-code-infrastructure-showcase`
  - [ ] `grep -ri "plp\|dieter\|grosswiler\|miltech\|montana\.edu" . --exclude-dir=.git --exclude-dir=node_modules`
  - [ ] If any found: fix immediately and re-test
- [ ] Clone repo to temp location: `git clone ~/git/claude-code-infrastructure-showcase /tmp/test-repo`
- [ ] Follow SETUP.md exactly in temp repo
- [ ] Time the setup (should be < 15 min)
- [ ] Test skill-activation-prompt hook (create test prompt, verify skill suggestions)
- [ ] Test post-tool-use-tracker (make edit, verify cache created)
- [ ] Test prettier formatter (verify files get formatted)
- [ ] Test build checker (introduce error, verify detection)
- [ ] Test blog-api service: `cd examples/blog-api && npm install && npm run dev`
- [ ] Test PM2: `pm2 start ecosystem.config.js && pm2 logs blog-api`
- [ ] Check all documentation links
- [ ] Proofread all markdown files
- [ ] Manual review of every file for sensitive info

---

## Phase 11: Polish & Publish (30 min)

- [ ] Final README polish (compelling introduction, clear value prop)
- [ ] Add badges to README (License: MIT, etc.)
- [ ] Add hook output examples to README (screenshot or code block)
- [ ] Add skill activation example to README
- [ ] Commit all changes (generic commit message: "Complete infrastructure showcase")
- [ ] Create GitHub repository (public)
- [ ] Set repository description: "Production-tested Claude Code infrastructure with automatic skill activation"
- [ ] Set topics: claude-code, claude, ai-development, hooks, skills, automation
- [ ] Push: `git remote add origin <url> && git push -u origin main`
- [ ] Create v1.0.0 release with comprehensive release notes
- [ ] Test: Clone from GitHub and verify setup works
- [ ] Update original Reddit post with repository link
- [ ] Post announcement on dev.to
- [ ] Share in Claude Code communities

---

## Progress Tracking

- [x] Phase 1 complete (repo setup) ✅
- [x] Phase 2 complete (hooks) ✅
- [ ] Phase 3 in progress (skills) 🟡 - 40% done (skill-developer complete, 2 skills copied, need scrubbing + 2 new skills + rules.json)
- [ ] Phase 4 partial (agents & commands) 🟡 - 50% done (files copied, need path updates + templates)
- [ ] Phase 5 not started (blog API) ⏳
- [ ] Phase 6 not started (PM2) ⏳
- [ ] Phase 7 not started (dev docs example) ⏳
- [ ] Phase 8 not started (documentation) ⏳
- [ ] Phase 9 not started (templates) ⏳
- [ ] Phase 10 not started (testing) ⏳
- [ ] Phase 11 not started (published!) ⏳

---

## Quick Resume for New Session

**Context to load:**
1. Read `dev/active/public-infrastructure-repo/public-infrastructure-repo-context.md` (has SESSION PROGRESS section at top)
2. Read this tasks file
3. Read `dev/active/public-infrastructure-repo/public-infrastructure-repo-plan.md` (if needed)

**Immediate priorities:**
1. Scrub backend-dev-guidelines (grep for work-specific terms, replace with blog examples)
2. Scrub frontend-dev-guidelines (same process)
3. Create database-verification skill (~200 lines)
4. Create error-tracking skill (~200 lines)
5. Create skill-rules.json with 5 skills and extensive comments

**Commands to verify clean:**
```bash
cd ~/git/claude-code-infrastructure-showcase

# Check for any identifiable information
grep -ri "plp\|dieter\|grosswiler\|miltech\|montana" . --exclude-dir=.git --exclude-dir=node_modules

# Check for work-specific domain terms
grep -ri "submission\|workflow.*instance\|closeout\|monthly.*report\|contract.*mechanism" .claude/skills/ --exclude-dir=node_modules

# Check git author (should be anonymous)
git log --format="%an <%ae>" | sort -u
```

**Target repo location:** `~/git/claude-code-infrastructure-showcase/`

---

**Total Tasks Remaining:** ~60 tasks (25 completed, ~60 remaining)
**Estimated Time Remaining:** 8-10 hours
**Next Session Start:** Phase 3 - Scrub backend-dev-guidelines

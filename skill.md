---
name: build-agents-md
description: Analyze repository code and comments to build comprehensive agents.md files capturing developer patterns, then optionally modularize into .mdc rule files
version: 1.0.0
---

# Build agents.md Skill

You are an expert at analyzing codebases and creating comprehensive `agents.md` files that capture how the primary developer actually works.

**Requirements:**
- GitLab repository (uses `glab` CLI)
- Git repository with commit history
- Access to GitLab API for fetching MR comments

## Quick Start

When this skill is invoked, immediately ask the user for the following information:

### Required Information

1. **Absolute repository path**
   - Ask: "What is the absolute path to the repository on your local machine?"
   - Example: `/Users/username/projects/my-api-project`
   - This is where you'll navigate to create .temp files and write the final agents.md

2. **Primary developer to analyze**
   - Ask: "Which developer's patterns should I analyze? Please provide their GitLab username."
   - Example: `john.doe`
   - This is the developer whose code review comments and commit patterns will be analyzed
   - Note: Their git author name may differ from GitLab username - you may need to ask for both

3. **GitLab project path** (URL-encoded)
   - Ask: "What is the GitLab project path? (Format: organization/project, will be URL-encoded)"
   - Example: User provides `my-org/my-api-project`, you encode it as `my-org%2Fmy-api-project`
   - Used for GitLab API calls to fetch merge request comments

4. **Time window** (Optional)
   - Ask: "How far back should I analyze? (Default: 6 months)"
   - Default: `6 months`
   - You'll calculate the cutoff date from this

5. **Check for existing documentation**
   - After receiving the repo path, check if any of these files exist:
     - `{REPO_PATH}/agents.md`
     - `{REPO_PATH}/AGENTS.md`
     - `{REPO_PATH}/.claude/CLAUDE.md`
     - `{REPO_PATH}/.cursor/rules/*.mdc` (modular rules)
   - If found, inform the user and ask about it (see "Existing Documentation" section below)

### Existing Documentation

If you discover existing documentation files, present this to the user:

```
I found existing documentation:
- [List files found, e.g., "agents.md (2,500 lines)", ".cursor/rules/20-32 (13 .mdc files)"]

How should I handle this existing documentation?

Please describe how you'd like me to use it:
- Examples:
  • "It's outdated, start fresh but reference it for structure"
  • "It's solid but incomplete, use it as a foundation and expand"
  • "It's accurate for the patterns it covers, but we need to add testing/error handling sections"
  • "Ignore it completely, it's from an old approach"
  • Or describe your own approach...

What's your guidance?
```

**After receiving user guidance:**
- If high weight: Read existing docs first, use as primary structure, fill gaps
- If medium weight: Read for inspiration, adopt good patterns, expand significantly
- If low weight: Quick skim for structure ideas, build mostly from code analysis
- If ignore: Don't read it, start completely fresh

**Store user's guidance** for reference throughout the process. When making decisions, refer back to this guidance.

## Standard Artifact Names (Idempotency)

This skill uses standardized artifact names in `.temp/` to enable idempotent execution. If you re-run the skill, existing artifacts can be reused instead of re-fetching data.

**Standard artifacts:**
- `.temp/dev_comments.json` - Raw MR comments from developer
- `.temp/dev_source_files.txt` - List of source files modified by developer
- `.temp/dev_test_files.txt` - List of test files modified by developer
- `.temp/architecture_analysis.md` - Codebase architecture analysis
- `.temp/diffnotes.json` - Filtered code review comments
- `.temp/prescriptive.json` - Filtered teaching/guidance comments
- `.temp/testing_comments.json` - Filtered testing-related comments
- `.temp/sample_100.json` - Sample of 100 comments for validation
- `.temp/dev_code_patterns.md` - Extracted code patterns from sampling
- `.temp/synthesis_notes.md` - Synthesized findings across all sources
- `.temp/agents_DRAFT.md` - Draft agents.md for user review

**Benefits:**
- ♻️  Reuse expensive GitLab API calls (comment fetching can take 10-15 minutes)
- 🔄 Selective re-fetching (e.g., re-analyze code but keep comments)
- 🚀 Faster iterations during review/revision cycles

## Overview

This skill follows an 11-step process:

1. **Check Existing Documentation** - Discover and assess existing agents.md or similar files
2. **Setup & Data Collection** - Create scripts to fetch MR comments
3. **Identify Legacy vs Modern Code** - Distinguish outdated from current patterns
4. **Analyze Code** - Sample and extract developer's patterns
5. **Analyze Comments** - Filter and read prescriptive guidance
6. **Synthesize Findings** - Validate patterns across sources (integrate existing docs if applicable)
7. **Validate Key Findings** - Interactive checkpoint before building full draft
8. **Build agents.md** - Create comprehensive documentation
9. **User Review & Revision** - Collaborative review and edits with user
10. **Finalize** - Optional: human guide, agent templates, AI optimization, then write final files
11. **Modularize** (Optional) - Split into .mdc files for maintainability

## Step 1: Check Existing Documentation

### Discover Existing Files

Check for existing documentation in the repository:

```bash
cd {ABSOLUTE_REPO_PATH}

# Check for common documentation files
[ -f "agents.md" ] && echo "Found: agents.md"
[ -f "AGENTS.md" ] && echo "Found: AGENTS.md"
[ -f ".claude/CLAUDE.md" ] && echo "Found: .claude/CLAUDE.md"
[ -d ".cursor/rules" ] && echo "Found: .cursor/rules/ ($(ls .cursor/rules/*.mdc 2>/dev/null | wc -l | tr -d ' ') .mdc files)"
```

### Present Findings to User

**If existing documentation found:**
- Use the "Existing Documentation" prompt from Quick Start section above
- Get user's guidance on how to weight/use existing docs
- Note the guidance for use in later steps (especially Step 5: Synthesize)

**If no existing documentation found:**
- Inform user: "No existing documentation found. I'll build agents.md from scratch based on code and comment analysis."
- Proceed to Step 2

## Step 2: Setup and Data Collection

### Create Working Directory

Navigate to the repository path provided by the user and create the working directory:

```bash
cd {ABSOLUTE_REPO_PATH}  # Use the exact path provided by user
mkdir -p .temp
```

### Check for Existing Artifacts (Idempotency)

Before fetching data, check if recent artifacts already exist:

```bash
# Standard artifact names
ARTIFACTS=(
  ".temp/dev_comments.json"
  ".temp/dev_source_files.txt"
  ".temp/dev_test_files.txt"
  ".temp/architecture_analysis.md"
  ".temp/diffnotes.json"
  ".temp/prescriptive.json"
  ".temp/testing_comments.json"
)

# Check which exist
for artifact in "${ARTIFACTS[@]}"; do
  [ -f "$artifact" ] && echo "Found: $artifact ($(wc -l < "$artifact" 2>/dev/null || echo 'N/A') lines)"
done
```

**Present findings to user:**

```
I found existing artifacts from a previous run:
- dev_comments.json (1,234 comments) - Modified 2 days ago
- dev_source_files.txt (456 files) - Modified 2 days ago
- [... list all found artifacts with age ...]

Would you like to:
1. ♻️  Reuse existing artifacts (skip data collection, saves significant time)
2. 🔄 Re-fetch some data (specify which: comments/files/analysis)
3. 🆕 Start fresh (delete .temp/ and re-collect everything)

What would you like to do?
```

**Based on user response:**
- If reuse: Skip to Step 4 (Analyze Code) with existing artifacts
- if re-fetch specific: Only run those collection steps
- If start fresh: `rm -rf .temp/* && mkdir -p .temp`, proceed with all collection

### Fetch Comments (If Needed)

**Only proceed if:**
- User chose "start fresh" OR
- User chose "re-fetch" and included comments OR
- `.temp/dev_comments.json` doesn't exist

**Use the template:** `resources/fetch_dev_comments.sh`

1. Read the template file
2. Replace placeholders:
   - `{{PROJECT_PATH}}` → GitLab project path (URL-encoded, e.g., `my-org%2Fmy-repo`)
   - `{{DEV_USERNAME}}` → Developer's GitLab username
   - `{{CUTOFF_DATE}}` → ISO 8601 format (e.g., `2024-04-22T00:00:00Z` for 6 months ago)
   - `{{REPO_NAME}}` → Repository name
   - `{{TIME_WINDOW}}` → Human-readable time window (e.g., `6 months`)
3. Write to `.temp/fetch_dev_comments.sh` in the repository
4. Make executable and run in background:
   ```bash
   chmod +x .temp/fetch_dev_comments.sh
   .temp/fetch_dev_comments.sh &
   ```
5. Inform user: "Comment fetch running in background (this may take 5-15 minutes)..."

### Identify Developer's Recent Files (If Needed)

**Only proceed if:**
- User chose "start fresh" OR
- User chose "re-fetch" and included files OR
- `.temp/dev_source_files.txt` or `.temp/dev_test_files.txt` don't exist

**Use the template:** `resources/identify_dev_files.sh`

1. Read the template file
2. Replace placeholders:
   - `{{CUTOFF_DATE}}` → YYYY-MM-DD format (e.g., `2024-04-22`)
   - `{{DEV_USERNAME}}` → Developer's git author name (may differ from GitLab username)
3. Write to `.temp/identify_dev_files.sh` in the repository
4. Make executable and run:
   ```bash
   chmod +x .temp/identify_dev_files.sh
   .temp/identify_dev_files.sh
   ```

This will create:
- `.temp/dev_source_files.txt` - List of source files
- `.temp/dev_test_files.txt` - List of test files

### Launch Architecture Analysis (If Needed)

**Only proceed if:**
- User chose "start fresh" OR
- User chose "re-fetch" and included analysis OR
- `.temp/architecture_analysis.md` doesn't exist

Use Task tool with subagent_type=Explore (medium thoroughness):

**Prompt:**
```
Analyze the {REPO_NAME} codebase architecture.

Provide:
- Directory structure and organization
- Key architectural patterns (Repository, Service, Component, etc.)
- Naming conventions for files, functions, classes
- Testing approach and patterns
- Technology stack details
- Any anti-patterns or code smells
- How different layers communicate
```

Save output to: `.temp/architecture_analysis.md`

## Step 3: Identify Legacy vs Modern Code

### Ask User About Code Organization

Before analyzing code patterns, identify which parts of the codebase represent current best practices vs. outdated patterns.

**Ask the user:**

```
Before I analyze code patterns, I want to make sure I'm focusing on current best practices.

Are there any directories in the codebase that contain legacy or outdated patterns that should NOT be used as reference for new code?

Common examples:
• Directories like: legacy/, old/, v1/, deprecated/, archive/
• Code from before a major refactor or framework migration
• UI components that are being replaced (e.g., old-ui/ vs new-ui/)
• Patterns that are no longer recommended

If you're not sure, I can proceed with standard analysis.
```

**Based on user response:**

**If user identifies legacy directories:**
- **Document them:** Note these for exclusion/de-prioritization when sampling files
- **Weight analysis:** Strongly prefer files from modern directories
- **Tag patterns:** Mark patterns found predominantly in legacy dirs as "legacy-only" or "deprecated"
- **Example:** If user says "components/ui/ is legacy, use components/v2/ instead", prioritize v2 files and mark ui-specific patterns as outdated

**If no legacy directories identified:**
- Proceed with standard sampling across all directories
- Still prefer recently modified files (use git log dates)
- Watch for low-frequency patterns (may indicate legacy)

### Pattern Confidence Indicators

As you analyze code, watch for these signals:

**Modern/Current patterns (high confidence):**
- Found in 80%+ of recent files
- Consistently used in files modified in last 6 months
- Found in explicitly "new" or "v2" directories

**Suspected legacy patterns (low confidence):**
- Found in <10% of files
- Concentrated in specific old directories
- Not seen in recently modified files
- Use outdated library APIs or deprecated features

**Flag for user validation** if a pattern seems critical but has low frequency - it may be legacy.

## Step 4: Analyze Developer's Code

### Sample Files Strategically

**Don't read all files!** Sample 10-15 representative files:

```bash
head -30 .temp/dev_source_files.txt  # View to pick samples
```

**Selection criteria:**
- Different file types/layers (commands, services, components)
- Mix of simple and complex files
- Recently modified (top of list)
- Core patterns (frequently used structures)

**Recommended sample:**
- 5-7 source files showing main patterns
- 3-5 test files showing testing approach

### Extract Patterns to `.temp/dev_code_patterns.md`

**Use the template:** `resources/dev_code_patterns_template.md`

1. Read the template file
2. Replace placeholders with actual content from sampled files:
   - `{{DEVELOPER}}` → Developer's name
   - `{{REPO_NAME}}` → Repository name
   - `{{Pattern N Name}}` → Actual pattern names (e.g., "Command Pattern", "Service Pattern")
   - `{{language}}` → Programming language (e.g., "javascript", "typescript")
   - Fill in all sections with actual code examples

**Focus on:**
- Actual code, not theory
- Concrete examples
- Repeated patterns across files
- What they avoid doing

## Step 5: Analyze Comments

### Check for Existing Filtered Comments

Before filtering, check if filtered comment files already exist:

```bash
[ -f ".temp/diffnotes.json" ] && echo "Found filtered comments"
[ -f ".temp/prescriptive.json" ] && echo "Found prescriptive comments"
```

**If filtered comments exist:**
- Inform user: "Found existing filtered comment files. Reusing those."
- Skip filtering, proceed to "Read Strategically"

**If not exist:**
- Proceed with filtering below

### Wait for Background Job (If Needed)

**Only if comments were fetched in Step 2:**
Check if comment fetch completed using BashOutput tool.

### Filter Comments Strategically (If Needed)

**Only proceed if filtered comment files don't exist**

**Use the script:** `resources/filter_comments.sh`

1. Read the script (no placeholders to replace)
2. Write to `.temp/filter_comments.sh` in the repository
3. Make executable and run:
   ```bash
   chmod +x .temp/filter_comments.sh
   .temp/filter_comments.sh
   ```

This will create:
- `.temp/diffnotes.json` - Code review comments only
- `.temp/prescriptive.json` - Teaching/guidance comments (READ THIS FIRST)
- `.temp/testing_comments.json` - Testing-related comments
- `.temp/sample_100.json` - Sample for validation

### Read Strategically (Priority Order)

1. **Read:** `prescriptive.json` - Highest signal
2. **Read:** `testing_comments.json` - If testing patterns need clarification
3. **Sample:** `sample_100.json` - Validate patterns from code

**Look for:**
- Repeated phrases (indicates pattern)
- "Should/must/don't/always/never" (prescriptive)
- Explanations of why (not just what)
- Corrections of common mistakes

## Step 6: Synthesize Findings

### Integrate Existing Documentation (If Applicable)

**If user provided guidance on existing docs in Step 1:**
- Review the existing documentation according to the weight given by user
- Extract structure, patterns, and content as appropriate
- Note what's accurate, what's missing, what's outdated
- Plan how to integrate with new findings

### Create `.temp/synthesis_notes.md`

**Use the template:** `resources/synthesis_notes_template.md`

1. Read the template file
2. Replace placeholders and fill in all sections:
   - `{{REPO_NAME}}` → Repository name
   - `{{DEVELOPER}}` → Developer's name
   - `{{N}}` → Actual counts
   - `{{Pattern Name}}` → Actual pattern names
   - Fill sections with validated patterns, evidence, questions
3. **If integrating existing docs:** Add a section noting which patterns came from existing docs vs. new analysis

### Identify Priority Levels

**Critical** (non-negotiable):
- Patterns with "must/never/always" in comments
- Used 100% consistently across files
- Testing patterns
- Explicitly corrected in code reviews

**Important** (best practices):
- Used >80% of the time
- Mentioned in comments without "must"
- Naming conventions

**Nice-to-have**:
- Optimization techniques
- Rare advanced patterns

### Note Template-Worthy Patterns

As you synthesize, watch for patterns that could become **agent templates** (copy-paste-ready examples):

**Good template candidates:**
- Complete, self-contained code examples (>15 lines)
- Patterns demonstrating full workflow (imports → logic → error handling → export)
- Examples that will be referenced across multiple sections
- Common patterns: components, API wrappers, event handlers, validators, error handling, i18n usage, tests

**Make a note in synthesis_notes.md:**
```markdown
## Potential Agent Templates
- [Pattern name] - [Why it's a good template candidate]
```

These may be extracted later during finalization/optimization phase.

## Step 7: Validate Key Findings (Interactive Checkpoint)

Before building the full draft, present key findings to the user for validation. This catches errors early and prevents spending time documenting incorrect or legacy patterns.

### Prepare Validation Summary

From your synthesis notes, extract:

**Top 5-7 Most Common Patterns:**
- Pattern name + usage frequency (e.g., "Named exports - 95% of files")
- Brief description
- Source (code, comments, or both)

**Suspected Legacy or Low-Confidence Patterns:**
- Patterns found in <10% of files
- Patterns concentrated in identified legacy directories
- Patterns that conflict with comment guidance
- Mark why you suspect they may be outdated

**Potential Contradictions or Questions:**
- Code does X but comments suggest Y
- Architecture doc mentions pattern Z but code rarely uses it
- Multiple approaches seen for same problem

### Present to User

**Format your message like this:**

```
I've completed my analysis and identified the key patterns. Before I build the full agents.md draft, I want to validate these findings with you to catch any errors early.

## Top Patterns Found (High Confidence)

1. **[Pattern 1 Name]** - Found in 95% of files
   - [Brief description]
   - Source: Code + Comments

2. **[Pattern 2 Name]** - Found in 87% of files
   - [Brief description]
   - Source: Code analysis

3. **[Pattern 3 Name]** - Found in 82% of files
   - [Brief description]
   - Source: Comments (strongly prescriptive)

[Continue for 5-7 patterns]

## Suspected Legacy Patterns (Low Confidence)

⚠️  **[Pattern X]** - Only 8% of files, mostly in [directory/]
   - [Description]
   - Why I'm unsure: [Reason - e.g., "Concentrated in components/ui/ which may be legacy"]

⚠️  **[Pattern Y]** - Only 12% of files
   - [Description]
   - Why I'm unsure: [Reason - e.g., "Not seen in files modified in last 6 months"]

## Questions/Contradictions

❓ [Describe contradiction or question]
❓ [Describe contradiction or question]

---

**Does this look correct?**

Please choose:
1. ✅ **Looks accurate** - Proceed to build full draft
2. 🔧 **Needs adjustments** - I'll clarify what's current vs legacy (tell me what needs changing)
3. 🔍 **Investigate further** - Dig deeper into specific patterns (tell me which ones)
```

### Handle User Response

**If "Looks accurate" (Option 1):**
- Proceed directly to Step 8: Build agents.md
- User has validated your findings

**If "Needs adjustments" (Option 2):**
- Ask: "What needs to be adjusted? Please clarify which patterns are current, legacy, or incorrect."
- Update your synthesis notes based on feedback
- Optionally: Present revised summary if changes are significant
- Once confirmed, proceed to Step 8

**If "Investigate further" (Option 3):**
- Ask: "Which patterns should I investigate further?"
- Sample additional files related to those patterns
- Re-analyze comments for clarification
- Present updated findings
- Repeat validation until user approves

### Benefits of This Checkpoint

- ⚡ **Catches errors early:** Fix misunderstandings before writing 2,000+ lines
- 🎯 **Validates priorities:** Confirms which patterns are actually critical
- 🗑️ **Filters legacy code:** User can correct if you sampled old patterns
- 💬 **Builds confidence:** User knows the draft will be based on accurate findings

## Step 8: Build agents.md

### Ask User: Monolithic or Modular?

**Option A: Single agents.md file**
- Simpler, everything in one place
- Good for smaller repos
- Target: 2,000-4,000 tokens

**Option B: Modular .mdc files** (Recommended for larger repos)
- Split into `.cursor/rules/{NN}-{name}.mdc`
- DRY: Claude + Cursor reference same files
- Better token management
- Easier to update sections

**If monolithic chosen:**

**Use the template:** `resources/agents_monolithic_template.md`

1. Read the template file
2. Replace all placeholders with actual content from your analysis:
   - `{{REPOSITORY_NAME}}` → Repository name
   - `{{Language}} {{Version}}` → Technology stack details
   - `{{Pattern N Name}}` → Actual pattern names
   - `{{language}}` → Code language for syntax highlighting
   - Fill all sections with actual code examples from dev_code_patterns.md and synthesis_notes.md
3. Write to `{REPO_NAME}/agents.md`

### Self-Review Before Presenting

Before presenting the draft to the user, do a quick self-review:

✅ **Accuracy:** All code examples are real, patterns match actual usage, no contradictions
✅ **Completeness:** All critical patterns documented, testing covered, anti-patterns clear
✅ **Clarity:** Concrete examples, clear headers, navigable structure
✅ **Actionability:** Copy-paste templates, specific checklists, "Don't X, do Y" format

## Step 9: User Review & Revision

**IMPORTANT:** Do not proceed to finalization until the user has reviewed and approved the agents.md content.

### Write Draft to .temp for Review

Write the draft agents.md to a temporary location for user review:

```bash
# Write draft to: {ABSOLUTE_REPO_PATH}/.temp/agents_DRAFT.md
```

### Prompt User for Review

Present the following to the user:

```
I've written a draft agents.md to .temp/agents_DRAFT.md for your review.

Please review the document and let me know:
1. ✅ Approve as-is - Ready to finalize
2. 🔧 Request changes - I'll make edits based on your feedback
3. 📝 You'll edit directly - Let me know when you're done and I'll read the updated file

What would you like to do?
```

### Handle User Feedback

**If user approves:**
- Proceed to Step 10 (Finalize)

**If user requests changes:**
- Ask: "What changes would you like me to make?"
- Make the requested edits to `.temp/agents_DRAFT.md`
- Show the diff or summary of changes
- Return to "Prompt User for Review" above (iterate until approved)

**If user will edit directly:**
- Wait for user confirmation that edits are complete
- Read the updated `.temp/agents_DRAFT.md` file
- Summarize what changed (if substantial)
- Ask: "Should I proceed with these changes?"
- If yes, proceed to Step 10 (Finalize)

### Revision Tips

**Common revision requests:**
- Add missing patterns or anti-patterns
- Clarify confusing sections
- Add more concrete examples
- Adjust tone or emphasis
- Add domain-specific context
- Remove incorrect or outdated patterns
- Reorganize sections for better flow

**Be prepared to:**
- Read specific source files for clarification
- Search comments for additional context
- Explain reasoning behind documented patterns
- Suggest alternatives when patterns conflict

## Step 10: Finalize

After user approval in Step 9, we'll go through an optional refinement workflow, then write final files.

**Workflow:**
1. Extract human-readable guide (optional)
2. Extract agent templates (optional)
3. Optimize for AI consumption (optional)
4. Write final files

### Substep A: Human-Readable Guide (Optional)

Ask the user if they want a developer-friendly version:

```
Your comprehensive agents.md has been approved!

Before I finalize, I can create optional artifacts:

1. Human-Readable Developer Guide
   • Written for human developers to read
   • Explanations of WHY patterns exist
   • More narrative flow and context
   • Same technical content and examples
   • Saved to docs/{repo-name}-dev-guide.md
   • Time: ~10-15 minutes

Would you like me to create a human-readable guide? (yes/no)
```

**If yes:**
- Create `{ABSOLUTE_REPO_PATH}/docs/{repo-name}-dev-guide.md`
- Base it on the approved `.temp/agents_DRAFT.md`
- Convert to human-friendly format:
  - Remove "AI Guidance" or "For AI" sections
  - Add contextual explanations of why patterns exist
  - Keep all technical patterns and code examples
  - Use more natural, narrative tone
  - Expand terse rules into readable paragraphs where helpful
- Inform user when complete: "✅ Human guide created at docs/{repo-name}-dev-guide.md"

**If no:**
- Skip to Substep B

### Substep B: Extract Agent Templates (Optional)

If you noted potential templates during synthesis (Step 6), ask about extracting them:

```
2. Agent Templates (Copy-Paste Examples)
   • Extract {N} patterns into agent_templates/ folder
   • Full, runnable code examples
   • Referenced from compressed agents.md
   • Patterns identified: [list them]
   • Time: ~5-10 minutes

Would you like me to extract agent templates? (yes/no)
```

**If yes:**
1. Create `{ABSOLUTE_REPO_PATH}/agent_templates/` directory
2. For each template:
   - Extract the complete code example with full context
   - Include imports, error handling, exports
   - Add brief description at top
   - Name descriptively: `{pattern}_pattern.md` or `{pattern}_example.md`
3. Common templates (create as applicable):
   - `react_component_pattern.md`
   - `graphql_mutation_pattern.md`
   - `event_handler_pattern.md`
   - `validator_pattern.md`
   - `error_handling_pattern.md`
   - `i18n_pattern.md`
   - `test_pattern.md`
4. Inform user when complete: "✅ Created {N} agent templates in agent_templates/"

**If no:**
- Skip to Substep C

### Substep C: AI Optimization (Optional)

**IMPORTANT:** This should only happen AFTER human guide extraction (if requested). The comprehensive draft is valuable for humans.

Ask the user about optimization:

```
3. AI-Focused Optimization
   • Compress agents.md for token efficiency
   • Preserve all critical rules and patterns
   • Remove verbose/human-facing prose
   • Keep one best example per pattern (or reference templates)
   • Target: 50-80% token reduction
   • Time: ~5-15 minutes

Your comprehensive draft is {N} tokens / {N} lines.

Would you like me to optimize agents.md for AI consumption? (yes/no)
```

**If yes:**

**Use Task tool with general-purpose subagent:**

```markdown
Optimize the agents.md draft for AI consumption using the structured compression process.

**Input file:** {ABSOLUTE_REPO_PATH}/.temp/agents_DRAFT.md
**Optimization guide:** Read /Users/lievertz/.claude/skills/build-agents-md/resources/agent_optimization_guide.md for detailed instructions
**Agent templates:** {List any agent_templates/*.md files that were created in Substep B, or "None"}

Follow the guide exactly. Your objectives:
1. Reduce token count by 50-80% while preserving all critical rules
2. Keep one exemplary code example per pattern (or reference template files)
3. Remove verbose prose and human-facing explanations
4. Consolidate redundant sections
5. Maintain semantic completeness
6. Use terse, structured formatting (lists, tables)

**Output:**
1. Write optimized version to: {ABSOLUTE_REPO_PATH}/.temp/agents_OPTIMIZED.md
2. Provide comparison report showing:
   - Before/after token counts and reduction %
   - Summary of changes made
   - What was preserved
   - Any templates referenced

I will review the optimized version and present it to the user for approval.
```

**After subagent completes:**
1. Read `.temp/agents_OPTIMIZED.md`
2. Present the comparison report to user
3. Ask: "Would you like to use the optimized version, or keep the comprehensive version?"

**If user approves optimized version:**
- Use `.temp/agents_OPTIMIZED.md` as the final agents.md

**If user prefers comprehensive version:**
- Use `.temp/agents_DRAFT.md` as the final agents.md

**If no optimization requested:**
- Use `.temp/agents_DRAFT.md` as the final agents.md

### Substep D: Write Final Files

**If monolithic approach chosen in Step 8:**
- Copy final version to `{ABSOLUTE_REPO_PATH}/agents.md`
- Confirm to user: "✅ Final agents.md written ({N} tokens, {N} lines)"
- If human guide created: "✅ Human guide at docs/{repo-name}-dev-guide.md"
- If templates created: "✅ {N} agent templates in agent_templates/"

**If modular approach chosen in Step 8:**
- Note that modularization will happen in Step 11
- The approved draft (optimized or comprehensive) will be split into .mdc files
- Inform user: "Draft ready for modularization in next step"

## Step 11: Modularize into .mdc Files (Optional)

### When to Modularize

**Indicators:**
- agents.md is >3,000 lines
- Multiple distinct pattern categories
- Want DRY sharing between Cursor and Claude Code
- Need granular control over which rules load

### Ask User for Numbering Range

**Recommended Convention:**
- Global/shared rules: 00-19 (if you have company-wide rules shared across repos)
- Repo-specific rules: 20+ (increment by 20 per repo to avoid conflicts)
  - First repo: 20-32
  - Second repo: 40-52
  - Third repo: 60-72
  - Pattern: Continue incrementing by 20

**Ask user:** "What numbering range should I use for {REPO_NAME} rules?"
- If this is their first repo and they have no global rules: suggest starting at 00
- If they have global rules (00-19): suggest starting at 20
- If they have multiple repos: suggest the next available range (e.g., 40-52)

### Identify Logical Sections

**Common sections (adapt to repo):**
1. Repository Purpose (overview, stack, entrypoints)
2. Architecture (directory structure, patterns, integrations)
3. [Primary Pattern 1] (e.g., Command Pattern, Component Pattern)
4. [Primary Pattern 2] (e.g., Service Pattern, Hook Pattern)
5. [Primary Pattern 3] (e.g., GraphQL Layer, State Management)
6. Testing Philosophy (test types, patterns, coverage)
7. Error Handling (error types, patterns)
8. [Domain Specific] (e.g., Content Management, i18n)
9. Security & Vigilance (security checklist, OWASP)
10. Local Development & Validation (dev workflow, validation)
11. Review Checklist (pre-submission checklist)
12. Resources (external links)

**Naming convention:** `{NN}-{kebab-case-name}.mdc`

### Create .mdc Files

**Use the template:** `resources/mdc_file_template.mdc`

For each section:

1. **Create file:** `.cursor/rules/{NN}-{section-name}.mdc`
2. **Use template structure** from `mdc_file_template.mdc`
3. **Replace placeholders:**
   - `{{Section Title}}` → Actual section name (e.g., "Command Pattern")
   - `{{Subsection N}}` → Actual subsection names
   - `{{language}}` → Code language for syntax highlighting
4. **Extract content:** Copy relevant section from agents.md
5. **Preserve all code examples and formatting**

**Example structure** (assuming numbering range 20-32):
```
.cursor/rules/
├── 20-repository-purpose.mdc
├── 21-architecture.mdc
├── 22-primary-pattern-1.mdc
├── 23-primary-pattern-2.mdc
├── 24-primary-pattern-3.mdc
├── 25-testing-philosophy.mdc
├── 26-error-handling.mdc
├── 27-domain-specific.mdc
├── 28-security-vigilance.mdc
├── 29-local-development-validation.mdc
├── 30-review-checklist.mdc
├── 31-agent-templates.mdc      # (optional: if repo has template files)
└── 32-resources.mdc
```

### Replace agents.md with Import Index

**Use the template:** `resources/agents_modular_index_template.md`

1. Read the template file
2. Replace placeholders:
   - `{{REPOSITORY_NAME}}` → Repository name
   - `{{NN}}` → Starting number for this repo's rules
   - `{{NN+1}}`, `{{NN+2}}`, etc. → Sequential numbers
   - `{{pattern1-name}}`, `{{pattern2-name}}`, etc. → Actual pattern names in kebab-case
   - `{{domain-specific}}` → Domain-specific section name (e.g., "content-management")
3. Write to `{REPO_NAME}/agents.md`

### Update .cursor/settings.json

**Use the template:** `resources/cursor_settings_template.json`

1. Read the template file
2. Replace placeholders:
   - `{{NN}}` → Starting number for this repo's rules
   - `{{NN+1}}`, `{{NN+2}}`, etc. → Sequential numbers
   - `{{pattern1}}`, `{{pattern2}}`, etc. → Actual pattern names in kebab-case
   - `{{domain-specific}}` → Domain-specific section name
3. If `.cursor/settings.json` doesn't exist, create it with the template content
4. If it exists, add only the new repo-specific rules ({{NN}} onwards) to the existing "rules" object

### Verification

**Check that:**
- [ ] All .mdc files created in `.cursor/rules/`
- [ ] agents.md contains only imports (13-20 lines)
- [ ] `.cursor/settings.json` includes all new rules
- [ ] File numbering is sequential and within assigned range
- [ ] Headers in .mdc files are clear and descriptive
- [ ] All code examples preserved with correct formatting
- [ ] No content duplicated across files

### Benefits of Modular Approach

1. **Token efficiency:** Load only relevant sections
2. **DRY principle:** Cursor and Claude Code reference same files
3. **Maintainability:** Update single file vs. searching large doc
4. **Clarity:** Each file has focused, single responsibility
5. **Reusability:** Can reference specific rules across repos
6. **Version control:** Easier to track changes per section

## Success Criteria

A successful agents.md enables an AI to:

1. ✅ Generate new code matching the repo's style
2. ✅ Write tests following the testing philosophy
3. ✅ Avoid documented anti-patterns
4. ✅ Use correct utilities and patterns
5. ✅ Pass code review by the primary developer

Test by asking AI to:
- Generate a new [component/service/command]
- Write tests for an existing file
- Explain why a code snippet doesn't follow patterns

## Token Management Tips

### During Collection:
- Run scripts in **background** (0 tokens)
- Use **Explore agent** for architecture (efficient)
- **Sample** files, don't read all

### During Analysis:

**Priority order:**
1. **dev_code_patterns.md** (10-15k) - HIGHEST VALUE
2. **architecture_analysis.md** (5-10k)
3. **Filtered comments** (10-20k) - prescriptive only
4. **Sample 50-100 comments** (5-10k) - validation

**Don't read:**
- All comments (if 500+)
- All source files
- Generated/vendor code

### During Writing:
- **Target 2,000-4,000 tokens** for monolithic
- **Concrete examples** over theory
- **Tables/lists** over paragraphs
- **Reference** sections, don't repeat

## Troubleshooting

### Few or No Comments Fetched

**Check:**
- Project path is URL-encoded: `my-org%2Fmy-repo` (replace `/` with `%2F`)
- Username is exact match (case-sensitive)
- Time window isn't too narrow

**Try:**
- Broader time window (12 months instead of 6)
- Check if developer uses different git author name
- Look at a known MR to verify username format

### Comments Not Useful

**Filter for:**
- `type == "DiffNote"` (code review comments)
- Keywords: should, must, don't, always, never
- Repeated phrases (indicates pattern)

**Focus on:**
- Teaching comments (explanations)
- Corrections (what not to do)
- Ignore: "LGTM", "thanks", short approvals

### Conflicting Patterns

**Prioritize:**
- Most recent code (may have been refactored)
- Explicit comment guidance over code
- Repeated pattern over one-off

**Ask user:**
"I see pattern A in files X, Y and pattern B in file Z. Which is current?"

### Running Out of Tokens

**Immediate actions:**
1. Stop reading comments
2. Summarize findings to `.temp/quick_summary.md` (500 tokens)
3. Ask user: "What's most critical to document?"
4. Clear cache, load summary + code patterns only
5. Focus on critical patterns + testing

## Files Created

By end of this skill, these files should exist:

```
{REPO_PATH}/
├── .temp/                       # Temporary artifacts (KEEP THESE for re-runs!)
│   ├── fetch_dev_comments.sh   # Script to fetch GitLab comments
│   ├── identify_dev_files.sh   # Script to find developer's files
│   ├── filter_comments.sh      # Script to filter comments
│   ├── dev_comments.json       # Raw MR comments (can be reused)
│   ├── diffnotes.json          # Filtered code review comments
│   ├── prescriptive.json       # Filtered teaching comments
│   ├── testing_comments.json   # Filtered testing comments
│   ├── sample_100.json         # Sample comments for validation
│   ├── dev_source_files.txt    # List of source files (can be reused)
│   ├── dev_test_files.txt      # List of test files (can be reused)
│   ├── architecture_analysis.md # Codebase architecture (can be reused)
│   ├── dev_code_patterns.md    # Extracted code patterns
│   ├── synthesis_notes.md      # Synthesized findings
│   ├── agents_DRAFT.md         # Draft for user review
│   └── agents_OPTIMIZED.md     # (optional) AI-optimized version
├── agents.md                    # Final output (monolithic or index file)
├── docs/
│   └── {repo-name}-dev-guide.md # (optional) Human-readable developer guide
├── agent_templates/             # (optional) Copy-paste-ready pattern examples
│   ├── react_component_pattern.md
│   ├── graphql_mutation_pattern.md
│   ├── event_handler_pattern.md
│   ├── validator_pattern.md
│   ├── error_handling_pattern.md
│   ├── i18n_pattern.md
│   └── test_pattern.md
└── .cursor/
    ├── rules/                   # (optional) Modular rules
    │   ├── {NN}-repository-purpose.mdc
    │   ├── {NN+1}-architecture.mdc
    │   └── ...
    └── settings.json            # (optional) Updated with rule paths
```

**IMPORTANT:** Keep the `.temp/` directory! The artifacts enable idempotent re-runs and save significant time (especially the 10-15 minute comment fetch).

## Notes

- **First run:** Takes 2-4 hours of AI time (includes 10-15 min comment fetch)
  - Add 10-15 min for human guide (optional)
  - Add 5-10 min for agent templates (optional)
  - Add 5-15 min for AI optimization (optional)
  - Add 30-60 min for modularization (optional)
- **Subsequent runs:** Much faster with artifact reuse (can skip data collection entirely)
- Can spread over 2 days (background jobs overnight)
- Best results with 6+ months of developer history
- Update quarterly or after major refactors
- **KEEP `.temp/` artifacts!** They enable fast re-runs and iterations
- Idempotent design: Re-run skill safely to refine or update documentation
- **Optional artifacts** (human guide, templates, optimization) can be added later by re-running Step 10

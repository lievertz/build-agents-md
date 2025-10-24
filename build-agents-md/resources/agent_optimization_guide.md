# Agent Optimization Guide: AI-Focused Compression

**Purpose:**
Transform comprehensive, human-readable agents.md drafts into **AI-optimized, context-efficient documentation** while preserving all critical rules, patterns, and examples.

**When to use:** After user has reviewed and approved the comprehensive draft, and has opted to create an optimized AI-focused version.

---

## Objectives

- Transform verbose documentation into **machine-optimized rule sets**
- Preserve **all critical rules, heuristics, and dependencies**
- Keep **one exemplary code example per pattern** (remove redundant examples)
- Eliminate redundant prose, human-facing explanations, and verbose context
- Extract reusable patterns into `/agent_templates/` files (if applicable)
- Target: **50-80% token reduction** while maintaining semantic completeness

---

## Core Principles

1. **Completeness over brevity** - If choosing between losing a rule or keeping extra tokens, keep the rule
2. **Concrete over abstract** - One good example > three mediocre summaries
3. **No semantic drift** - Changes must preserve intent and nuance
4. **Pattern extraction** - Complex examples become template files, referenced via `/agent_templates/`
5. **LLM clarity** - Prefer lists, tables, and structured formatting over prose

---

## Optimization Process

### 1. Identify Compression Opportunities

**Scan for:**
- Repeated "rules / best practices / guidance" triplets that overlap
- Multiple similar examples for the same concept (keep best one)
- Human-facing context: "As mentioned earlier...", "You should know that..."
- Verbose explanations that can become terse bullet points
- Redundancy between "Summary" and "Checklist" sections (merge)
- Long examples that could become template files

**High-density regions to target:**
- Introductory/motivational paragraphs
- Repeated pattern structures
- Overlapping "Best Practices" and "AI Guidance" sections
- Multiple examples demonstrating the same point

### 2. Extract Agent Templates (If Applicable)

**Candidates for `/agent_templates/`:**
- Complete, copy-paste-ready code examples (>15 lines)
- Patterns used across multiple sections
- Examples that demonstrate full workflow (imports → logic → error handling → export)

**Common templates:**
- Component patterns (React, Vue, etc.)
- API/GraphQL mutation wrappers
- Event handler patterns
- Validation functions
- Error handling patterns
- i18n/localization usage
- Testing patterns

**When to extract:**
- Example is self-contained and executable
- Pattern is referenced in multiple places
- Example is >15 lines with full context
- Removing it would save >500 tokens

**Format:**
```
agent_templates/
├── react_component_pattern.md
├── graphql_mutation_pattern.md
├── validation_pattern.md
└── error_handling_pattern.md
```

### 3. Standardize Section Structure

**Use this canonical layout per topic:**

```markdown
## [Number]. [Topic Title]

### Core Rules
- Clear, prescriptive bullet list
- Include absolute requirements (use X, never Y)
- Keep critical do/don't statements

### Example
```language
// Single best example - minimal but complete
// Include imports and context
```

### Best Practices
- Non-critical but useful conventions
- Merge with "AI Guidance" if overlap

### Reference Templates
- `/agent_templates/[pattern].md` (if extracted)
```

**Merge overlapping sections:**
- "Best Practices" + "AI Guidance" → pick one heading
- "Summary" + "Critical Rules" → use "Core Rules"
- "Checklist" + "Review Process" → merge into "Checklist"

### 4. Apply Compression Strategies

| Strategy | Use Case | Example |
|----------|----------|---------|
| **Prose → bullets** | Convert paragraphs to terse bullet points | "When you implement hooks, make sure to wrap async operations..." → "• Wrap async in try/catch" |
| **Example curation** | Keep one per concept, remove similar ones | 3 Apollo examples → 1 best example |
| **Rule consolidation** | Merge duplicate rules from different sections | Remove repetition between intro and summary |
| **Template extraction** | Move long examples to `/agent_templates/` | 30-line component → `@agent_templates/component.md` |
| **Remove human context** | Delete explanatory prose for humans | "As we discussed...", "It's important to understand..." |
| **Flatten structure** | Reduce unnecessary nesting | #### Sub-sub-section → ### Section |

### 5. Preserve Critical Content

**Always keep:**
- ✅ All "must/never/always/critical" rules
- ✅ Anti-patterns and what to avoid
- ✅ Security requirements (Sentry, sanitization, OWASP)
- ✅ Testing requirements and patterns
- ✅ Technology stack specifics (versions, key dependencies)
- ✅ Links to official documentation
- ✅ At least one example per major pattern
- ✅ References to `/agent_templates/` files

**Safe to remove:**
- ❌ Motivational or introductory prose
- ❌ Redundant examples (keep best one)
- ❌ Verbose explanations of "why" (unless critical context)
- ❌ Conversational transitions
- ❌ Human-facing advice about "how to use this doc"
- ❌ Duplicate checklists

### 6. Maintain Semantic Structure

**Keep these sections:**
- Repository Overview (tech stack, entry points, architecture)
- Core Patterns (all major patterns with rules + example each)
- Testing Philosophy
- Error Handling & Logging
- Security & Vigilance
- Checklist/Summary (one consolidated version)
- Resources & Links

**Section order should match:**
1. Overview
2. Primary patterns (most to least important)
3. Cross-cutting concerns (testing, errors, security)
4. Checklist
5. Resources

---

## Example Transformation

### Before (Human-Facing, ~400 tokens)

> "When implementing Apollo GraphQL mutations in our application, it's really important to make sure you're following the established patterns. We've found that developers sometimes forget to include proper error handling, which can lead to uncaught exceptions. You should always wrap your mutations in custom hooks, and make sure to log any errors to Sentry with appropriate context tags. Also, don't forget that refetchQueries can cause performance issues, so we generally prefer to use cache updates instead. Here's an example of how we typically structure a mutation hook..."

### After (AI-Facing, ~80 tokens)

```markdown
### Apollo Mutations - Core Rules
- Always wrap in custom hooks
- Include try/catch with Sentry logging (tag with function name)
- Prefer cache updates over refetchQueries
- Always include `id` field in responses

### Example
See `/agent_templates/graphql_mutation_pattern.md`
```

**Token savings: ~75%** | **Information preserved: 100%**

---

## Quality Assurance Checklist

Before finalizing optimized version:

- [ ] **Semantic completeness** - All critical rules preserved
- [ ] **Example quality** - One clear example per major pattern (or template reference)
- [ ] **No contradictions** - Merged sections don't conflict
- [ ] **Template references** - All `/agent_templates/` paths valid
- [ ] **External links** - Official docs URLs still present
- [ ] **Security coverage** - Sentry, sanitization, OWASP checks remain
- [ ] **Token count** - Target 50-80% reduction from comprehensive version
- [ ] **Readability** - Still parseable by LLM, proper structure
- [ ] **Cross-references** - Template files and modular rules properly linked

---

## Output Specifications

**Target characteristics:**
- **Token count:** 20-50% of comprehensive draft size
- **Density:** Every section has rules + example/reference + guidance
- **Structure:** Consistent headings, minimal nesting, clear hierarchy
- **Templates:** Extracted to `/agent_templates/` with references
- **Completeness:** All major technical domains covered
- **Clarity:** Optimized for fast LLM pattern recognition

---

## Comparison Report Format

After optimization, provide this summary to user:

```markdown
## Optimization Results

**Before:** {N} tokens, {N} lines
**After:** {N} tokens, {N} lines
**Reduction:** {X}% tokens, {X}% lines

### Changes Made
- Extracted {N} patterns to `/agent_templates/`
- Consolidated {N} redundant sections
- Reduced {N} examples to {N} (kept best examples)
- Removed {N} tokens of human-facing prose
- Merged {N} overlapping checklists

### Preserved
✅ All critical rules and anti-patterns
✅ All security requirements
✅ All technology stack details
✅ {N} code examples (one per major pattern)
✅ All external documentation links

### Extracted Templates
{List any agent_templates/*.md files created}
```

---

## Edge Cases & Warnings

**If reduction is <30%:**
- Draft may already be terse
- Verify no semantic compression opportunities missed
- Check if examples can be extracted to templates

**If reduction is >85%:**
- Too aggressive - likely losing critical content
- Review removed examples - may need to restore some
- Check that all patterns still have at least one example or template reference

**If user objects to compression:**
- Offer to restore specific sections
- Show side-by-side comparison
- Explain token efficiency tradeoffs
- Consider lighter compression (target 40% instead of 70%)

---

**End of Guide**

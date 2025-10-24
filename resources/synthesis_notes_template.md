# Synthesis Notes - {{REPO_NAME}}

## Data Sources Analyzed
- ✅ {{N}} source files from {{DEVELOPER}}
- ✅ {{N}} test files from {{DEVELOPER}}
- ✅ {{N}} MR comments from {{DEVELOPER}}
- ✅ Architecture analysis (Explore agent)

---

## Validated Patterns (appeared in 2+ sources)

### {{Pattern Name 1}}
- **Found in:** [e.g., 5 code files + architecture analysis + 3 MR comments]
- **Description:** [Brief summary]
- **Critical:** Yes/No
- **Evidence:**
  - Code: [File examples]
  - Comments: [MR references or quotes]
  - Architecture: [Section reference]

### {{Pattern Name 2}}
- **Found in:** [Sources]
- **Description:** [Brief]
- **Critical:** Yes/No
- **Evidence:**
  - [Evidence]

[Repeat for each validated pattern]

---

## Testing Philosophy

[Summarize from code + comments + architecture]

**Critical points:**
- [Point 1 - e.g., "Always test happy path + error cases"]
- [Point 2 - e.g., "Mock external dependencies, not internal"]
- [Point 3 - e.g., "Integration tests for critical flows only"]

**Sources:**
- Code patterns: [Examples]
- Comments: [Quotes from testing_comments.json]
- Architecture: [Notes from analysis]

---

## Critical Anti-Patterns (NEVER do this)

1. **{{Anti-pattern Name}}**
   - **Found in:** [e.g., Comments MR!123, Code reviews]
   - **Why wrong:** [Explanation]
   - **Instead do:** [Correct approach]

2. **{{Anti-pattern Name 2}}**
   - **Found in:** [Sources]
   - **Why wrong:** [Explanation]
   - **Instead do:** [Correct approach]

[Continue list]

---

## Naming Conventions

[From code + architecture]

### Files
- [Pattern]: [Example] - [Found in: X files]

### Functions/Methods
- [Pattern]: [Example] - [Found in: X files]

### Variables
- [Pattern]: [Example] - [Found in: X files]

**Consistency:** [e.g., "100% consistent" or "Used in 85% of files"]

---

## Domain-Specific Patterns

[Unique to this repo - not general best practices]

### {{Domain Pattern 1}}
- **Description:** [What makes this unique to this repo]
- **Why exists:** [Business/technical reason]
- **Examples:** [Code examples]

### {{Domain Pattern 2}}
- [Same structure]

---

## Conflicting Patterns (need user clarification)

### {{Conflict 1}}
- **Pattern A:** [Description] - Found in: [files X, Y]
- **Pattern B:** [Description] - Found in: [file Z]
- **Question for user:** "I see pattern A in files X, Y and pattern B in file Z. Which is current?"

### {{Conflict 2}}
[Same structure]

---

## Priority Levels

### Critical (non-negotiable)
[Patterns with "must/never/always" in comments OR used 100% consistently]

1. [Pattern name] - [Why critical]
2. [Pattern name] - [Why critical]

### Important (best practices)
[Used >80% of the time OR mentioned in comments without "must"]

1. [Pattern name] - [Usage frequency]
2. [Pattern name] - [Usage frequency]

### Nice-to-have
[Optimization techniques OR rare advanced patterns]

1. [Pattern name] - [When to use]
2. [Pattern name] - [When to use]

---

## Open Questions for User

1. **{{Question about ambiguous pattern}}**
   - Context: [What you observed]
   - Need: [What clarification would help]

2. **{{Question about structure preference}}**
   - Context: [Options you see]
   - Need: [User's preference]

3. **{{Question about domain knowledge}}**
   - Context: [What you don't understand]
   - Need: [Business context or technical explanation]

---

## Coverage Analysis

### Well-Documented Patterns
- [Pattern 1] - Strong evidence from all sources
- [Pattern 2] - Strong evidence from all sources

### Gaps (patterns with weak evidence)
- [Pattern X] - Only found in 1 source, needs validation
- [Pattern Y] - Conflicting signals, needs user input

### Areas Needing More Investigation
- [Area 1] - Limited examples in sampled files
- [Area 2] - Comments mention but no code examples found

---

## Recommendations for agents.md

### Must Include (Critical)
1. [Pattern/section name] - [Why critical]
2. [Pattern/section name] - [Why critical]

### Should Include (Important)
1. [Pattern/section name] - [Why important]
2. [Pattern/section name] - [Why important]

### Can Skip (Low signal)
1. [Pattern/section name] - [Why low priority]
2. [Pattern/section name] - [Why low priority]

---

## Notes on Data Quality

**Strong signals:**
- [What had high quality/consistency]

**Weak signals:**
- [What was ambiguous or contradictory]

**Missing data:**
- [What couldn't be determined from available sources]

# {{REPOSITORY_NAME}}

## Purpose
[1-2 sentences from architecture analysis or README describing what this repository does]

## Technology Stack
- **Runtime:** {{Language}} {{Version}}
- **Framework:** {{Framework}} {{Version}}
- **Database:** {{Database}} (if applicable)
- **Testing:** {{Test Framework}}
- **Key Dependencies:** {{Top 3-5 dependencies}}

## Architecture

[High-level overview - condense from architecture_analysis.md]

```
[Directory structure or diagram]
src/
  pattern1/     # Description
  pattern2/     # Description
  utils/        # Description
```

### Key Patterns
- **{{Pattern Type}}**: [Brief description]
- **{{Pattern Type}}**: [Brief description]

---

## {{Pattern 1 Name}}

### Structure
[Template with actual code from dev_code_patterns.md]

```{{language}}
// Typical structure for this pattern
```

### Key Patterns
1. **[Pattern]:** [Description]
   ```{{language}}
   // Example
   ```

2. **[Pattern]:** [Description]
   ```{{language}}
   // Example
   ```

3. **[Pattern]:** [Description]
   ```{{language}}
   // Example
   ```

### Example
```{{language}}
// Full working example from actual codebase
// path/to/example/File.js
```

---

## {{Pattern 2 Name}}

[Same structure as Pattern 1]

---

## {{Pattern 3 Name}}

[Same structure as Pattern 1]

---

## Testing Philosophy

### General Principles
- [Principle from synthesis - e.g., "Always test happy path + error cases"]
- [Principle from synthesis - e.g., "Mock external dependencies only"]
- [Principle from synthesis - e.g., "Integration tests for critical flows"]

### {{Test Type 1}} (e.g., Unit Tests)

**Structure:**
```{{language}}
// Template from dev_code_patterns.md showing test structure
```

**Key patterns:**
1. [Pattern - e.g., how to mock dependencies]
2. [Pattern - e.g., how to structure assertions]
3. [Pattern - e.g., setup/teardown approach]

### {{Test Type 2}} (e.g., Integration Tests)

**Structure:**
```{{language}}
// Template showing structure
```

**Key patterns:**
1. [Pattern]
2. [Pattern]

### Example
```{{language}}
// Complete test example from actual codebase
// path/to/test/File.test.js
```

---

## Error Handling

[Pattern with examples from code]

```{{language}}
// Example of error handling approach
```

**Key points:**
- [Error handling approach 1]
- [Error handling approach 2]
- [When to throw vs. return errors]

---

## Naming Conventions

### Files
- [Pattern]: `example_file_name.js` - [Usage]
- [Pattern]: `AnotherExample.tsx` - [Usage]

### Functions/Methods
- [Pattern]: `functionName()` - [When used]
- [Pattern]: `anotherPattern()` - [When used]

### Variables
- [Pattern]: `variableName` - [Usage]
- [Pattern]: `CONSTANT_NAME` - [Usage]

---

## Common Utilities

**Frequently imported:**
```{{language}}
import { util1, util2, util3 } from 'utils/location';
```

**Usage patterns:**
1. **util1**: [When/how to use]
   ```{{language}}
   // Example usage
   ```

2. **util2**: [When/how to use]
   ```{{language}}
   // Example usage
   ```

3. **util3**: [When/how to use]
   ```{{language}}
   // Example usage
   ```

---

## Anti-Patterns to Avoid

1. ❌ **[Anti-pattern]**: [Why this is wrong]
   ```{{language}}
   // Bad example
   ```
   ✅ **Instead**:
   ```{{language}}
   // Good example
   ```

2. ❌ **[Anti-pattern]**: [Why this is wrong]
   ```{{language}}
   // Bad example
   ```
   ✅ **Instead**:
   ```{{language}}
   // Good example
   ```

[Continue numbered list]

---

## Code Review Checklist

**Before submitting PR:**

**General:**
- [ ] [Check 1 - e.g., follows naming conventions]
- [ ] [Check 2 - e.g., uses approved utilities]
- [ ] [Check 3 - e.g., proper error handling]
- [ ] [Check 4 - e.g., no magic values]

**{{Pattern Type}} Specific:**
- [ ] [Specific check for this pattern]
- [ ] [Another specific check]
- [ ] [Another specific check]

**Testing:**
- [ ] [Test requirement - e.g., unit tests for all services]
- [ ] [Coverage requirement - e.g., happy path + error cases]
- [ ] [Test structure follows template]
- [ ] [Mocking approach follows patterns]

---

## Resources
- [{{Documentation Name}}]({{url}})
- [{{Related Repo}}]({{path}})
- [{{Framework Docs}}]({{url}})

#!/bin/bash
# Filter developer comments into useful categories
# Run this after fetch_dev_comments.sh completes
# Usage: Run from repository root directory

cd .temp

echo "Filtering comments into categories..."

# Count comments by type
echo ""
echo "Comment types:"
jq '[.[] | .type] | group_by(.) | map({type: .[0], count: length})' dev_comments.json

# Extract DiffNote (code review) comments only
echo ""
echo "Extracting DiffNote comments..."
jq '[.[] | select(.type == "DiffNote")]' dev_comments.json > diffnotes.json
DIFFNOTE_COUNT=$(jq 'length' diffnotes.json)
echo "Found ${DIFFNOTE_COUNT} DiffNote comments"

# Find prescriptive/teaching comments (high signal)
echo ""
echo "Extracting prescriptive comments..."
jq '[.[] | select(.body | test("should|must|don'\''t|always|never|avoid|prefer|instead"; "i"))]' \
  dev_comments.json > prescriptive.json
PRESCRIPTIVE_COUNT=$(jq 'length' prescriptive.json)
echo "Found ${PRESCRIPTIVE_COUNT} prescriptive comments"

# Sample 100 random DiffNotes for validation
echo ""
echo "Creating sample of 100 DiffNotes..."
jq '[.[] | select(.type == "DiffNote")] | .[0:100]' dev_comments.json > sample_100.json
SAMPLE_COUNT=$(jq 'length' sample_100.json)
echo "Sampled ${SAMPLE_COUNT} comments"

# Find testing-related comments
echo ""
echo "Extracting testing-related comments..."
jq '[.[] | select(.body | test("test|mock|jest|unittest|spec"; "i"))]' \
  dev_comments.json > testing_comments.json
TESTING_COUNT=$(jq 'length' testing_comments.json)
echo "Found ${TESTING_COUNT} testing comments"

echo ""
echo "Filtering complete! Created:"
echo "  - diffnotes.json (${DIFFNOTE_COUNT} comments)"
echo "  - prescriptive.json (${PRESCRIPTIVE_COUNT} comments) ← READ THIS FIRST"
echo "  - testing_comments.json (${TESTING_COUNT} comments)"
echo "  - sample_100.json (${SAMPLE_COUNT} comments)"

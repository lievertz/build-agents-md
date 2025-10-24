#!/bin/bash
# Identify source and test files modified by a specific developer
# Usage: Replace placeholders with actual values before running

# PLACEHOLDER VALUES - Replace these before running
CUTOFF_DATE="{{CUTOFF_DATE}}"         # e.g., 2024-04-22 (YYYY-MM-DD format)
DEV_NAME="{{DEV_USERNAME}}"           # e.g., John Doe (git author name, may differ from GitLab username)

echo "Finding files modified by ${DEV_NAME} since ${CUTOFF_DATE}..."

# Get source files (exclude tests, node_modules)
git log --author="$DEV_NAME" --since="$CUTOFF_DATE" \
  --name-only --format='' --diff-filter=AM \
  | grep -E '\.(js|ts|jsx|tsx|py|go|java)$' \
  | grep -v 'node_modules' \
  | grep -v '__tests__' \
  | grep -v '.test.' \
  | grep -v '.spec.' \
  | sort -u \
  > .temp/dev_source_files.txt

# Get test files
git log --author="$DEV_NAME" --since="$CUTOFF_DATE" \
  --name-only --format='' --diff-filter=AM \
  | grep -E '\.(test|spec)\.(js|ts|jsx|tsx|py|go)$' \
  | grep -v 'node_modules' \
  | sort -u \
  > .temp/dev_test_files.txt

SOURCE_COUNT=$(wc -l < .temp/dev_source_files.txt | tr -d ' ')
TEST_COUNT=$(wc -l < .temp/dev_test_files.txt | tr -d ' ')

echo ""
echo "Found ${SOURCE_COUNT} source files"
echo "Found ${TEST_COUNT} test files"
echo ""
echo "Source files saved to: .temp/dev_source_files.txt"
echo "Test files saved to: .temp/dev_test_files.txt"

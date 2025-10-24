#!/bin/bash
# Fetch all comments from a specific developer in a GitLab repository
# Usage: Replace placeholders with actual values before running

# PLACEHOLDER VALUES - Replace these before running
PROJECT_PATH="{{PROJECT_PATH}}"       # e.g., my-org%2Fmy-repo (URL-encoded GitLab project path)
DEV_USERNAME="{{DEV_USERNAME}}"       # e.g., john.doe (GitLab username)
CUTOFF_DATE="{{CUTOFF_DATE}}"         # e.g., 2024-04-22T00:00:00Z (ISO 8601 format)
REPO_NAME="{{REPO_NAME}}"             # e.g., my-repo (repository name)
TIME_WINDOW="{{TIME_WINDOW}}"         # e.g., 6 months (human-readable)

OUTPUT_FILE=".temp/dev_comments.json"

# Initialize output file
echo "[]" > "$OUTPUT_FILE"
echo "Fetching MRs from ${REPO_NAME} since ${CUTOFF_DATE}..."

# Get all MR IIDs updated after cutoff date
MR_IIDS=$(glab api "/projects/${PROJECT_PATH}/merge_requests?updated_after=${CUTOFF_DATE}&per_page=100" \
  --paginate | jq -r '.[].iid')

MR_COUNT=$(echo "$MR_IIDS" | wc -l | tr -d ' ')
echo "Found ${MR_COUNT} MRs from last ${TIME_WINDOW}"
echo "Fetching ${DEV_USERNAME}'s comments from all ${MR_COUNT} MRs..."

# Fetch comments from each MR
for MR_IID in $MR_IIDS; do
  echo "Fetching comments for MR !$MR_IID..."

  NOTES=$(glab api "/projects/${PROJECT_PATH}/merge_requests/$MR_IID/notes" \
    --paginate 2>/dev/null)

  # Filter to only this developer's comments and extract relevant fields
  echo "$NOTES" | jq --arg mr "$MR_IID" \
    '[.[] | select(.author.username == "'$DEV_USERNAME'") |
     {mr_iid: $mr, body: .body, created_at: .created_at, type: .type}]' \
    | jq -s 'add' >> .temp/tmp_comments.json
done

# Combine all comments into single file
jq -s 'add' .temp/tmp_comments.json > "$OUTPUT_FILE"
rm -f .temp/tmp_comments.json

COMMENT_COUNT=$(jq 'length' "$OUTPUT_FILE")
echo ""
echo "Done! Found ${COMMENT_COUNT} comments from ${DEV_USERNAME}"
echo "Saved to ${OUTPUT_FILE}"

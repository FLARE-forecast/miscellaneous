#!/bin/bash

ORG="FLARE-forecast"            # Your GitHub organization name
TEAM="Developers" 		# Team slug (usually lowercase or hyphenated)
PERMISSION="push" 		# pull, triage, push, maintain, admin
TEAM_DESCRIPTION="Team with push access to development repositories"  # New description

# Common headers
HEADERS=(-H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28")

# Step 1: Update team description
echo "🔧 Updating description for team '$TEAM' in org '$ORG'..."
gh api -X PATCH "/orgs/$ORG/teams/$TEAM" \
  "${HEADERS[@]}" \
  -f description="$TEAM_DESCRIPTION"

# Step 2: Assign permission to all repositories
echo "🔁 Updating team repository access..."
REPOS=$(gh repo list "$ORG" --limit 1000 --json name -q '.[].name')

for REPO in $REPOS; do
  echo "👉 Giving $TEAM team $PERMISSION access to $REPO..."
  gh api -X PUT "/orgs/$ORG/teams/$TEAM/repos/$ORG/$REPO" \
    "${HEADERS[@]}" \
    -f permission="$PERMISSION"
done

echo "✅ All done!"


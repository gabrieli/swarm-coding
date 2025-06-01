#!/bin/bash

# GitHub Project Configuration
# Update these values if project structure changes

# Project and Repository Info
export PROJECT_ID="PVT_kwHOACofRM4A5PeM"
export REPO_OWNER="gabrieli"
export REPO_NAME="pulse-menu"

# Field IDs
export STATUS_FIELD_ID="PVTSSF_lAHOACofRM4A5PeMzguEr8I"
export WORK_ITEM_TYPE_FIELD_ID="PVTSSF_lAHOACofRM4A5PeMzguEu1Y"

# Status Option IDs
export BACKLOG_OPTION_ID="f75ad846"
export PM_REFINED_OPTION_ID="4bbaa247"
export DEV_READY_OPTION_ID="61e4505c"
export IN_PROGRESS_OPTION_ID="47fc9ee4"
export IN_REVIEW_OPTION_ID="df73e18b"
export DONE_OPTION_ID="98236657"

# Work Item Type Option IDs
export EPIC_OPTION_ID="c1460534"
export USER_STORY_OPTION_ID="d027d90e"

# How to update these values:
# 1. Run: gh api graphql -f query="$(cat scripts/github/get_project_fields.graphql)" -f projectId=$PROJECT_ID
# 2. Find the field you need and copy its ID
# 3. For single select fields, copy the option IDs you need
# 4. Update the values above

echo "Project configuration loaded for: $REPO_OWNER/$REPO_NAME"
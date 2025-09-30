---
argument-hint: [project_id] [issue_id]
description: Digest GitLab issue and comments into context
allowed-tools: Bash(curl:*)
---

- Issue details: !curl -s --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" "https://gitlab.com/api/v4/projects/$1/issues/$2"
- Issue comments: !curl -s --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" "https://gitlab.com/api/v4/projects/$1/issues/$2/notes?sort=asc&order_by=created_at"

After digesting the issue information into context, prompt the user for any additional context that you need
to fully understand the issue at hand. If the issue makes sense as is, do not prompt for any additional information.

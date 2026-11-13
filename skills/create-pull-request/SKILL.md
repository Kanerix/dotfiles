---
name: create-pull-request
description: Create GitHub pull requests using the gh CLI. Use this skill whenever the user asks to create, open, submit, or raise a PR or pull request for their changes, including draft PRs and requests to write a PR title and description. Do not use it for reviewing, merging, or closing existing PRs, or for creating issues.
compatibility: Requires Git, the GitHub CLI (gh), an authenticated GitHub account, and access to the target repository.
---

# Create a pull request

Use `gh` to create a pull request from the user's committed changes. Follow the
repository's agent instructions and PR conventions. Keep the scope to preparing
and creating the PR.

## Respect the requested action

- If the user asks only for a title, description, or preview, provide that text
  without pushing or creating a PR.
- A request to create a PR authorises creation, not staging, committing,
  pushing, rebasing, force-pushing, or creating a branch or fork. Ask for
  permission before any needed push unless the user explicitly requested it. Do
  not perform the other actions unless separately requested.
- Preserve uncommitted changes. Explain that they are excluded from the PR and
  continue with the committed changes when that matches the request. If the
  requested changes exist only in the working tree, stop and explain what needs
  committing.
- Honour an explicit draft or ready-for-review choice. Otherwise create a
  ready-for-review PR. Do not add reviewers, labels, assignees, projects, or
  milestones unless requested or required by repository instructions.
- Do not install tools or change authentication automatically. If a prerequisite
  is missing, report it and give the next step.

## Inspect the repository

Run commands in the relevant repository directory. Use non-interactive commands
and literal arguments. Resolve the values below from command output, not shell
substitutions.

1. Check prerequisites and local state:

    ```sh
    gh --version
    git --no-optional-locks status --short --branch
    git branch --show-current
    git remote -v
    ```

    Stop if HEAD is detached. Determine the intended GitHub repository from the
    remotes and the user's request. If multiple repositories are plausible, ask
    which one to use. Do not assume `origin` is the target or that the base is
    `main`.

2. Check authentication for the target host using `gh auth status --hostname HOST`.
   Do not print tokens or read credential files. If authentication is
   missing, suggest `gh auth login --hostname HOST` and stop.

3. Resolve repository metadata:

    ```sh
    gh repo view OWNER/REPO --json nameWithOwner,defaultBranchRef,url
    ```

    For GitHub Enterprise, use `HOST/OWNER/REPO` with `--repo` or the repository
    argument. Select the base from the user's request, then
    `branch.BRANCH.gh-merge-base` if configured, then the repository's default
    branch. Verify it exists. Stop if the head and base are the same branch in
    the same repository.

4. Resolve the head repository and remote branch. For a fork, distinguish the
   repository receiving the PR from the repository holding the head branch. Use
   `OWNER:BRANCH` when supported by `gh`; consult `gh pr create --help` if the
   fork ownership makes head selection unclear. Ask rather than creating a fork
   or guessing a destination.

5. Check for an open PR with the same head and base:

    ```sh
    gh pr list --repo OWNER/REPO --state open --head BRANCH --base BASE --json number,title,url,headRefName,headRepositoryOwner,baseRefName,isDraft
    ```

    Use the bare branch name for `gh pr list --head`; it does not accept
    `OWNER:BRANCH`. Verify the head repository owner as well as the branch name,
    especially for forks. Paginate if needed rather than assuming the first page
    covers every match. If a matching PR exists, return its URL instead of
    creating a duplicate. Do not edit it unless asked.

## Understand the changes

Read any applicable PR template and contribution guidance. Discover them in the
repository rather than assuming a file path. If multiple templates apply and the
choice is unclear, ask.

Ensure the base reference is available and current. Fetch the specific base
branch from the verified base remote when needed. Check the head remote branch
with `git ls-remote --heads` and compare its commit to local HEAD. If local
commits are unpublished, explain the remote and branch that need pushing and ask
permission. If permission was already given, push to the verified head remote
with an explicit branch refspec, without force. Recheck the remote head before
creation.

Inspect the commits and the actual diff against the base using resolved references:

```sh
git --no-pager log --oneline BASE_REF..HEAD
git --no-pager diff --stat BASE_REF...HEAD
git --no-pager diff BASE_REF...HEAD
```

Use targeted diffs for large changes, but cover all changed areas before
describing them. If there are no changes to propose, stop and report that. Base
the description on the diff, not only commit messages or earlier conversation.
Do not include credentials or sensitive content in the PR text.

## Write the title and body

Follow the repository's title conventions. If none are specified, use a short,
imperative title describing the change. Use a Conventional Commit prefix only
when the repository expects it.

Use the repository's PR template when present. Otherwise use this structure,
omitting sections that do not apply:

```markdown
## Summary

- Describe the change and its purpose.

## Validation

- State the checks actually run and their results, or say they were not run.
```

Keep the text short, direct, and written in British English. Do not use em
dashes or en dashes. Mention relevant behaviour changes, migration steps, or
known limitations. Do not invent test results or run a large test suite solely
to fill the description. Run focused checks when appropriate and allowed by the
repository instructions.

Link issues only when supplied by the user or verified in repository context.
Use `Closes #NUMBER` or `Fixes #NUMBER` only when the change resolves that
issue, since these phrases close issues on merge.

## Create and verify

If the user requested a preview or approval before submission, show the proposed
title, body, repository, base, and head, then wait. Otherwise proceed once the
target and permissions are clear.

Create the PR non-interactively with explicit repository, base, head, title, and body:

```sh
gh pr create --repo OWNER/REPO --base BASE --head HEAD --title TITLE --body BODY
```

Replace every argument with the verified literal value and quote shell arguments
safely. For a long or shell-sensitive body, write it to a temporary file outside
tracked content and use `--body-file` instead. Remove only temporary files you
created. Add `--draft` when requested and explicit metadata flags only as
authorised.

Always supply `--head` so `gh` does not implicitly push or offer to fork. Do not use `--fill`, `--web`, or `--editor`, since the title and body have already been prepared. Do not use `gh pr create --dry-run` as a read-only preview: it may push changes.

After creation, inspect the returned URL:

```sh
gh pr view PR_URL --json url,title,baseRefName,headRefName,isDraft
```

Confirm the repository, branches, title, and draft state match the request. If
creation fails or returns an uncertain result, check for a matching PR before
retrying to avoid duplicates. Report authentication, permission, or branch
errors rather than changing configuration or force-pushing.

Return the PR URL with its title and base/head branches. Mention draft status
when applicable and any validation not run or known blockers. If creation was
blocked, state the concrete next action instead of claiming success.

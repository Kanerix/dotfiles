---
name: skill-creator
description: >-
  Create new skills, modify and improve existing skills, and measure skill
  performance. Use when users want to create a skill from scratch, edit or
  optimise an existing skill, run evals to test a skill, benchmark skill
  performance with variance analysis, or optimise a skill's description for
  better triggering accuracy.
---

# Skill Creator

Create and improve skills through drafting, testing and user feedback:

- Decide what the skill should do and how it should work.
- Write a draft.
- Create realistic test prompts and run Claude with access to the skill.
- Help the user review the outputs and quantitative results.
    - Draft or review quantitative evaluations while the runs are in progress.
      Explain what they check.
    - Use `eval-viewer/generate_review.py` to present outputs and metrics.
- Revise the skill based on user feedback and benchmark findings.
- Repeat until the user is satisfied, then expand the test set if needed.

Start at the stage that fits the user's progress. For a new skill, clarify the
intent before drafting. For an existing draft, start with evaluation or
revision. If the user wants to work without evaluations, follow that
preference.

After finishing the skill, offer to optimise its description for triggering
accuracy.

## Communicating with the user

Match your language to the user's technical knowledge. Explain unfamiliar terms
briefly rather than assuming the user knows them.

- Use "evaluation" and "benchmark" with a short explanation if needed.
- Explain "JSON" and "assertion" unless the conversation shows familiarity with
  them.

## Creating a skill

### Capture intent

Start by understanding the user's intent. If the conversation already contains
a workflow to capture, extract the tools, steps, corrections, and input and
output formats from it. Ask the user to fill any gaps and confirm your
understanding before proceeding.

1. What should the skill enable Claude to do?
2. Which user phrases or contexts should trigger it?
3. What output format should it produce?
4. Should test cases verify its behaviour? Objectively verifiable outputs, such
   as file transformations, data extraction, code generation and fixed
   workflows,
   benefit from tests. Subjective outputs, such as writing or art, may not need
   them. Suggest an appropriate default and let the user decide.

### Interview and research

Ask about edge cases, input and output formats, example files, success criteria
and dependencies. Resolve these questions before writing test prompts.

Check available MCP tools for documentation, similar skills or relevant
practices. Research independent questions in parallel with subagents when
available, or directly otherwise. Gather context before asking the user for
information you can find yourself.

### Write the SKILL.md

Use the interview to write these components:

- `name`: the skill identifier.
- `description`: what the skill does and when to use it. This is the primary
  triggering mechanism. Put all usage conditions here rather than in the body.
  Claude can fail to invoke useful skills, so state triggering contexts
  explicitly. For example: "Build dashboards for internal Anthropic data. Use
  this skill when the user mentions dashboards, data visualisation, internal
  metrics or displaying company data, even without asking for a dashboard."
- `compatibility`: required tools and dependencies, if needed.
- Body: the instructions for carrying out the task.

### Skill writing guide

#### Anatomy of a skill

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description required)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/    - Executable code for deterministic/repetitive tasks
    ├── references/ - Docs loaded into context as needed
    └── assets/     - Files used in output (templates, icons, fonts)
```

#### Progressive disclosure

Skills use three levels of loading:

1. Metadata, the name and description, is always in context. Aim for about 100
   words.
2. The `SKILL.md` body enters context when the skill triggers. Aim for fewer
   than
   500 lines.
3. Bundled resources load as needed. Scripts can run without loading their
   contents into context.

These limits are approximate. Use more space when the task requires it.

- Keep `SKILL.md` under 500 lines where practical. Move detail into reference
  files when needed and explain when to read each one.
- Reference files clearly from `SKILL.md`.
- Include a table of contents in reference files longer than 300 lines.

For skills covering several domains or frameworks, organise references by
variant:

```
cloud-deploy/
├── SKILL.md (workflow + selection)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```

Claude reads only the relevant reference file.

#### Avoid surprising behaviour

Do not include malware, exploit code or content that compromises system
security. The skill's behaviour must match its stated purpose. Refuse requests
for misleading skills, unauthorised access, data exfiltration or other
malicious
activity. Harmless roleplay is acceptable.

#### Writing patterns

Use imperative instructions. Define output formats with a template:

```markdown
## Report structure

ALWAYS use this exact template:

# [Title]

## Executive summary

## Key findings

## Recommendations
```

Include examples when they clarify the expected output. Adapt the labels to the
skill:

```markdown
## Commit message format

**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

### Writing style

Explain the reasons behind important instructions rather than relying on
capitalised commands. Write guidance that applies across tasks, not only to the
examples. Review the draft with fresh eyes and revise it.

### Test cases

After drafting, propose two or three realistic user prompts. Ask the user to
confirm them or suggest additions before running them.

Save the prompts to `evals/evals.json`. Leave assertions for the next step,
while
runs are in progress.

```json
{
    "skill_name": "example-skill",
    "evals": [
        {
            "id": 1,
            "prompt": "User's task prompt",
            "expected_output": "Description of expected result",
            "files": []
        }
    ]
}
```

See `references/schemas.md` for the full schema, including the `assertions`
field.

## Running and evaluating test cases

Complete this sequence without stopping partway through. Do not use
`/skill-test` or another testing skill.

Put results in `<skill-name>-workspace/` beside the skill directory. Organise
results by iteration, such as `iteration-1/`, then by test case, such as
`eval-0/`. Create directories as needed rather than preparing them all upfront.

### Step 1: Spawn skill and baseline runs in the same turn

For each test case, spawn two subagents in the same turn: one with the skill
and
one with the baseline. Launch both sets together so they finish at similar
times.

For a run with the skill, use this prompt:

```
Execute this task:
- Skill path: <path-to-skill>
- Task: <eval prompt>
- Input files: <eval files if any, or "none">
- Save outputs to: <workspace>/iteration-<N>/eval-<ID>/with_skill/outputs/
- Outputs to save: <requested outputs, e.g., "the .docx file", "the final CSV">
```

Use the same task prompt for the baseline. Choose the baseline by context:

- For a new skill, provide no skill path and save to `without_skill/outputs/`.
- For an existing skill, snapshot it before editing with
  `cp -r <skill-path> <workspace>/skill-snapshot/`. Point the baseline subagent
  at
  the snapshot and save to `old_skill/outputs/`.

Write `eval_metadata.json` for each test case. Assertions can be empty at this
stage. Give each eval a descriptive name based on what it checks, rather than
only "eval-0", and use that name for its directory. Create metadata for every
new
or modified prompt in each iteration. Do not assume it carries over.

```json
{
    "eval_id": 0,
    "eval_name": "descriptive-name-here",
    "prompt": "The user's task prompt",
    "assertions": []
}
```

### Step 2: Draft assertions while runs are in progress

Draft quantitative assertions for each test case and explain them to the user.
If assertions already exist in `evals/evals.json`, review them and explain what
they check.

Use objectively verifiable assertions with descriptive names. The names should
make each check clear in the benchmark viewer. Evaluate subjective qualities,
such as writing style or design, through user feedback rather than forced
quantitative checks.

Add the assertions to `eval_metadata.json` and `evals/evals.json`. Explain that
the viewer will show both outputs for review and a quantitative benchmark.

### Step 3: Capture timing data as runs complete

Each completed subagent task sends a notification containing `total_tokens` and
`duration_ms`. Save these values immediately to `timing.json` in the run
directory:

```json
{
    "total_tokens": 84852,
    "duration_ms": 23332,
    "total_duration_seconds": 23.3
}
```

The notification is the only source of this data; it is not persisted
elsewhere.
Process each notification as it arrives rather than batching them.

### Step 4: Grade, aggregate and launch the viewer

Once all runs finish:

1. Grade each run. Spawn a grader subagent, or grade directly, using
   `agents/grader.md`. Evaluate each assertion against the outputs and save
   results to `grading.json` in the run directory. Its `expectations` array
   must
   use `text`, `passed` and `evidence`, not `name`, `met`, `details` or other
   variants. The viewer requires these exact fields. For programmatic checks,
   write and run a script rather than inspecting outputs by eye. Scripts are
   more reliable and can be reused across iterations.

2. Run the aggregation script from the skill-creator directory:

    ```bash
    python -m scripts.aggregate_benchmark <workspace>/iteration-N --skill-name <name>
    ```

    This produces `benchmark.json` and `benchmark.md` with `pass_rate`, time
    and
    tokens for each configuration, including mean, standard deviation and
    delta. If generating `benchmark.json` manually, follow the viewer schema in
    `references/schemas.md`. Put each `with_skill` version before its baseline.

3. Read the benchmark data for patterns hidden by aggregate statistics. See
   "Analyzing Benchmark Results" in `agents/analyzer.md`. Look for assertions
   that pass with or without the skill, high-variance evals that may be flaky,
   and trade-offs between time and token use.

4. Launch the viewer with outputs and quantitative data:

    ```bash
    nohup python <skill-creator-path>/eval-viewer/generate_review.py \
      <workspace>/iteration-N \
      --skill-name "my-skill" \
      --benchmark <workspace>/iteration-N/benchmark.json \
      > /dev/null 2>&1 &
    VIEWER_PID=$!
    ```

    From iteration
 2 onwards, also pass
    `--previous-workspace <workspace>/iteration-<N-1>`.

    In Cowork or headless environments, use `--static <output_path>` to write a
    standalone HTML file if `webbrowser.open()` is unavailable or there is no
    display. Clicking "Submit All Reviews" downloads `feedback.json`. Copy it
    into the workspace for the next iteration.

    Use `generate_review.py`; do not write a custom HTML viewer.

5. Tell the user where to review the results. Explain that "Outputs" shows each
   test case and accepts feedback, while "Benchmark" shows the quantitative
   comparison. Ask them to return when they have finished.

### What the user sees in the viewer

The "Outputs" tab shows one test case at a time:

- "Prompt": the task given to the agent.
- "Output": generated files, rendered inline where possible.
- "Previous Output": a collapsed section from the previous iteration, available
  from iteration 2 onwards.
- "Formal Grades": a collapsed section showing assertion results, if graded.
- "Feedback": a text box that saves as the user types.
- "Previous Feedback": comments from the previous iteration, shown below the
  text box from iteration 2 onwards.

The "Benchmark" tab shows pass rates, timing and token use for each
configuration, with per-eval breakdowns and analyst observations.

The user navigates with previous and next buttons or arrow keys. "Submit All
Reviews" saves the feedback to `feedback.json`.

### Step 5: Read the feedback

When the user finishes reviewing, read `feedback.json`:

```json
{
    "reviews": [
        {
            "run_id": "eval-0-with_skill",
            "feedback": "the chart is missing axis labels",
            "timestamp": "..."
        },
        { "run_id": "eval-1-with_skill", "feedback": "", "timestamp": "..." },
        {
            "run_id": "eval-2-with_skill",
            "feedback": "perfect, love this",
            "timestamp": "..."
        }
    ],
    "status": "complete"
}
```

Empty feedback means the user accepted the result. Focus revisions on cases
with
specific complaints.

Stop the viewer server when finished:

```bash
kill $VIEWER_PID 2>/dev/null
```

## Improving the skill

Use the reviewed outputs and feedback to revise the skill.

### How to approach improvements

1. Generalise from feedback. The test cases are a small sample of future tasks.
   Avoid changes that only fit those examples. For persistent problems, try a
   different explanation or working pattern rather than tighter commands.

2. Keep the prompt lean. Read transcripts as well as final outputs. Remove
   instructions that cause unproductive work and check whether results improve.

3. Explain why instructions matter. Understand the user's task and the reason
   for their feedback, even when it is terse. Convey that understanding in the
   skill. Replace rigid, capitalised commands with reasons where possible.

4. Look for repeated work. If subagents repeatedly write similar helpers, such
   as `create_docx.py` or `build_chart.py`, consider bundling the script in
   `scripts/`. Tell the skill to use it rather than recreating it for each
   task.

Review the revision with fresh eyes before rerunning it.

### The iteration loop

1. Apply the improvements.
2. Rerun all test cases, including baselines, in `iteration-<N+1>/`. For a new
   skill, keep `without_skill` as the baseline across iterations. For an
   existing
   skill, choose the original version or previous iteration as appropriate.
3. Launch the reviewer with `--previous-workspace` pointing to the previous
   iteration.
4. Wait for the user to finish reviewing.
5. Read the feedback and revise again.

Stop when the user is satisfied, all feedback is empty, or further iterations
make no meaningful progress.

## Advanced: Blind comparison

For a more rigorous comparison, read `agents/comparator.md` and
`agents/analyzer.md`. Give two outputs to an independent agent without
identifying their versions. Ask it to judge quality, then analyse why the
winner
performed better.

This requires subagents and is optional. User review is usually sufficient.

## Description optimisation

The `description` field in `SKILL.md` frontmatter determines whether Claude
invokes the skill. After creating or improving a skill, offer to optimise this
field for triggering accuracy.

### Step 1: Generate trigger eval queries

Create 20 queries mixing cases that should and should not trigger the skill.
Save them as JSON:

```json
[
    { "query": "the user prompt", "should_trigger": true },
    { "query": "another prompt", "should_trigger": false }
]
```

Write realistic requests a Claude Code or Claude.ai user would type. Include
concrete details, such as file paths, job context, column names, company names
and URLs. Vary length and tone. Some queries can contain lowercase text,
abbreviations or typos. Focus on edge cases and ask the user to approve them.

Poor examples: `"Format this data"`, `"Extract text from PDF"`, `"Create a
chart"`.

A useful example:

```text
ok so my boss just sent me this xlsx file (its in my downloads, called something like 'Q4 sales final FINAL v2.xlsx') and she wants me to add a column that shows the profit margin as a percentage. The revenue is in column C and costs are in column D i think
```

For the eight to ten queries that should trigger, vary the phrasing of the same
intent. Include requests that need the skill without naming it or the file
type,
uncommon use cases, and cases where it should be chosen over another skill.

For the eight to ten queries that should not trigger, use near misses. These
share terms or concepts with the skill but need something different. Include
adjacent domains, ambiguous wording and cases better handled by another tool.

Avoid obviously irrelevant negative cases. "Write a Fibonacci function" tells
you little about whether a PDF skill triggers correctly.

### Step 2: Review with the user

Present the eval set using the HTML template:

1. Read `assets/eval_review.html`.
2. Replace the placeholders:
    - `__EVAL_DATA_PLACEHOLDER__`: the JSON array of eval items. Do not quote
      it;
      it is a JavaScript variable assignment.
    - `__SKILL_NAME_PLACEHOLDER__`: the skill's name.
    - `__SKILL_DESCRIPTION_PLACEHOLDER__`: the current description.
3. Write a temporary file, such as `/tmp/eval_review_<skill-name>.html`, and
   open
   it with `open /tmp/eval_review_<skill-name>.html`.
4. Ask the user to edit queries, toggle triggering expectations, and add or
   remove entries before clicking "Export Eval Set".
5. Read `~/Downloads/eval_set.json`. If several versions exist, use the most
   recent download, such as `eval_set (1).json`.

Review the queries carefully. Poor queries lead to poor descriptions.

### Step 3: Run the optimisation loop

Tell the user that the loop will run in the background and that you will report
progress. Save the eval set to the workspace, then run:

```bash
python -m scripts.run_loop \
  --eval-set <path-to-trigger-eval.json> \
  --skill-path <path-to-skill> \
  --model <model-id-powering-this-session> \
  --max-iterations 5 \
  --verbose
```

Use the model ID from the system prompt so the triggering test matches the
user's session. Check the output periodically and report the current iteration
and scores.

The script splits the eval set into 60% training and 40% held-out testing. It
runs each query three times to measure the current description's trigger rate,
then asks Claude to propose improvements based on failures. It evaluates each
new description against both sets for up to five iterations.

On completion, it opens an HTML report and returns JSON containing
`best_description`. Selection uses the test score rather than the training
score
to reduce overfitting.

### How skill triggering works

Skills appear in Claude's `available_skills` list with their names and
descriptions. Claude uses the description to decide whether to read a skill.

One-step requests, such as "read this PDF", may not trigger a matching skill
because Claude can handle them with basic tools. Complex, multi-step or
specialised requests are more likely to trigger it.

Use queries that would benefit from the skill. Requests such as "read file X"
are poor tests because they may not trigger regardless of description quality.

### Step 4: Apply the result

Update the `SKILL.md` frontmatter with `best_description` from the JSON output.
Show the old and new descriptions and report the scores.

### Package and present

Skip this step if `present_files` is unavailable. Otherwise, package the skill:

```bash
python -m scripts.package_skill <path/to/skill-folder>
```

Present the resulting `.skill` file and its path so the user can install it.

## Claude.ai-specific instructions

Claude.ai has no subagents. Adapt the workflow as follows:

- Run test cases sequentially. Read the skill's `SKILL.md` and follow it for
  each
  prompt. Skip baselines. Running your own draft is less independent than using
  subagents, so rely on user review to check the results.
- If a browser is unavailable, show prompts and outputs in the conversation.
  Save files such as `.docx` or `.xlsx` outputs and give the user download
  paths.
  Ask for feedback directly.
- Skip quantitative benchmarking because baseline comparisons are not
  meaningful without subagents. Focus on qualitative feedback.
- Revise, rerun and ask for feedback without the browser reviewer. Organise
  results by iteration when a filesystem is available.
- Skip description optimisation. It requires the `claude` CLI, specifically
  `claude -p`, which is only available in Claude Code.
- Skip blind comparison because it requires subagents.
- Use `package_skill.py` when Python and a filesystem are available. The user
  can download the resulting `.skill` file.

When updating an existing skill:

- Preserve the directory name and `name` frontmatter field. For example,
  package
  `research-helper` as `research-helper.skill`, not `research-helper-v2.skill`.
- If the installed path is read-only, copy it to a writable location such as
  `/tmp/skill-name/`, edit the copy and package it from there.
- If packaging manually, stage in `/tmp/` before copying to the output
  directory.
  Direct writes may fail because of permissions.

## Cowork-specific instructions

- Use subagents for parallel test cases, baselines and grading. If timeouts
  prevent this, run the prompts sequentially.
- Use `--static <output_path>` to generate a standalone HTML viewer because
  Cowork has no browser or display. Give the user a link to the file.
- Generate the viewer with `generate_review.py` before evaluating the outputs
  yourself or revising the skill. The user must see the examples first. Do not
  write a custom viewer.
- "Submit All Reviews" downloads `feedback.json` rather than saving it through
  a server. Read the downloaded file, requesting access if needed.
- Use `package_skill.py` when Python and a filesystem are available.
- Description optimisation with `run_loop.py` and `run_eval.py` uses `claude
  -p`
  through a subprocess rather than a browser. Run it only after finishing the
  skill and getting the user's approval.
- For existing skills, follow the update guidance in the Claude.ai section.

## Reference files

Read the relevant subagent instructions when needed:

- `agents/grader.md`: evaluate assertions against outputs.
- `agents/comparator.md`: perform blind A/B comparisons.
- `agents/analyzer.md`: analyse why one version performed better.

See `references/schemas.md` for the JSON structures used by `evals.json`,
`grading.json` and related files.

If a task list is available, record the workflow steps there. In Cowork,
include
creating the eval JSON and running `eval-viewer/generate_review.py` for user
review.

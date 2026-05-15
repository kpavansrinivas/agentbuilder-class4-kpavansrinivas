# Agent Builder: NL-to-SQL Pipeline + ReAct Agent

Two notebooks. Run them in order. The first builds a fixed pipeline
that translates English to SQL. The second turns it into a real
ReAct agent that can choose between two tools.

## Architecture diagrams

**Class 1 - the pipeline** (`diagrams/pipeline_architecture.drawio.png`)

![Pipeline](diagrams/pipeline_architecture.drawio.png)

**Class 2 - the agent** (`diagrams/agent_architecture.drawio.png`)

![Agent](diagrams/agent_architecture.drawio.png)

Open the `.drawio` files in <https://app.diagrams.net> or the draw.io
desktop app to edit them.

## Notebooks

| Order | Notebook                | What it teaches                                           |
|-------|-------------------------|-----------------------------------------------------------|
| 1     | `nl_sql_pipeline.ipynb` | Fixed pipeline: question -> SQL -> answer. Three prompt versions measured against a test suite. The hard lesson on domain terms. |
| 2     | `agent.ipynb`           | Same data + a second source. Build a multi-tool ReAct agent by hand. The LLM picks the tool. |

## What's in this repo

```
nl_sql_pipeline.ipynb    Class 1 - the pipeline
agent.ipynb              Class 2 - the agent
spacex_launches.db       SQLite database (18 SpaceX missions) - used by both
seed.sql                 SQL to recreate the database
schema.md                schema description for the LLM
                         (column meanings + allowed values + domain terms + few-shot)
vehicle_specs.json       rocket specs (thrust, height, reusability...)
                         used as the agent's second data source
diagrams/                draw.io source + PNG exports for both architectures
pyproject.toml           uv project file (so `uv add ...` works)
README.md                this file
```

## Setup

You need:

1. **`uv`** to manage Python and packages. Install once:
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```
   Windows: see <https://docs.astral.sh/uv/getting-started/installation/>.

2. **An OpenAI API key** with at least a few cents of credit. Create
   one at <https://platform.openai.com/api-keys>. The notebooks prompt
   for it on first run (the input is hidden as you type).

## Run

```bash
git clone https://github.com/fnusatvik07/agentbuilder-class4-nlsql.git
cd agentbuilder-class4-nlsql

# install jupyter and the LangChain packages (one-time)
uv add jupyter langchain-openai langchain-core pandas

# class 1 - the pipeline
uv run jupyter lab nl_sql_pipeline.ipynb

# class 2 - the agent (run this AFTER class 1)
uv run jupyter lab agent.ipynb
```

## What you will learn

### From the pipeline notebook
- How an LLM uses a schema description to write SQL.
- Why `schema.md` (for the LLM) is separate from `seed.sql` (for SQLite).
- How to validate LLM output before executing it.
- How to build a **test suite** of (question, expected SQL, expected
  answer) tuples and measure prompt changes against it.
- The hard lesson: when business vocabulary collides with column
  values (`heavy launch` vs the literal `'Falcon Heavy'` enum), the
  LLM will confidently produce the wrong answer unless you write the
  term down.
- The limitations of a fixed-order pipeline.

### From the agent notebook
- Why a fixed pipeline cannot answer multi-source questions.
- How LangChain's `@tool` decorator and `bind_tools()` work.
- How to write the **ReAct loop** by hand: Thought -> Action ->
  Observation -> repeat -> Final Answer.
- How to read an agent's trace and spot bad tool choices.
- The new failure modes that come with agents (running in circles,
  premature termination, hallucinated facts).

## Optional: rebuild the database

```bash
rm -f spacex_launches.db
sqlite3 spacex_launches.db < seed.sql
```

## Questions and feedback

Bring them to class. Or open an issue on this repo.


## My Observation
1. Pipeline vs Agent Behavior
    The pipeline works best for simple single-source queries because it is predictable and efficient. The agent becomes useful when the question requires chaining multiple tools or data sources together, such as querying SQL first and then fetching rocket specifications from another tool.
2. Model Choice Affects Tool Usage
    Changing from a stronger model like GPT-4o mini to a weaker model like GPT-3.5 Turbo changed how the agent reasoned. Stronger models followed proper multi-step tool chains, while weaker models sometimes skipped tools entirely and answered from internal knowledge, which can silently bypass the real data layer.
3. Detailed Print Statements Help Debug Agent Reasoning
    Adding verbose print statements exposed the full agent workflow: message history, tool calls, arguments, intermediate observations, and response sizes. This made it easier to identify subtle failures such as wrong tool targets, unnecessary tool calls, memory growth, and how the agent chains reasoning across steps.

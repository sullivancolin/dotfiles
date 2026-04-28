# User-Level CLAUDE.md

## About Me

- Python developer, Data Scientist, and Applied AI engineer
- Computational linguistics background — expert in NLP, Information Retrieval, Information Extraction, and Deep Learning
- Deeply cares about how natural language is processed by computers; frequently thinks about the details of text processing, tokenization, representation, and evaluation
- Learning areas: async design patterns, Jax/numba, MLX, Rust + Python bindings, Wasm/Pyodide/Pyscript, Kubernetes, modern frontend (React/Redux/TypeScript)
- Novice in modern frontend — know some jQuery/Angular, open to learning React ecosystem
- Working knowledge of Docker, still learning K8s
- Prefer software engineering best practices over notebook-driven workflows (but use Jupyter/Marimo where appropriate)

## Python & Tooling

- **Python**: 3.14+ only
- **Project management**: `uv` (always — no pip, no poetry, no conda)
- **Command runner**: `just` with standard targets: `dev`, `test`, `lint`, `format`, `docs`, `build`, `ci`, `clean`
- **Formatting/linting**: `ruff` (format + check)
- **Type checking**: `ty`
- **Testing**: `pytest` + `pytest-cov` + `pytest-html`, heavy use of fixtures + `@pytest.mark.parametrize`
- **Pre-commit hooks**: Use Prek instead of classic pre-commit. kitchen sink — ruff format/lint, ty, commitlint (conventional commits), trailing whitespace, YAML lint, secrets detection, etc.
- **Project layout**: src-layout (`src/package_name/`)
- **Versioning**: Semantic versioning with conventional commits
- **Documentation**: Zensical with mkdocstrings for auto API documentation

## Code Style

- **Naming**: PEP 8 with pragmatic abbreviations (df, cfg, ctx, etc.) and ML conventions (X, y, n_samples)
- **Docstrings**: Google style
- **Comments**: Contextual — terse for familiar patterns (Pydantic, FastAPI, Typer), educational for areas I'm learning (Jax, async, numba, Rust, Wasm)
- **Type annotations**: Always. Prefer `Annotated[T, ...]` pattern over `= Field(...)`
- **Errors**: Lean on stdlib exceptions (ValueError, TypeError, etc.) with clear messages
- **Pydantic**: v2+ only. Use `Annotated` pattern. Strict mode where useful. Pydantic models for all API request/response validation.

## Preferred Libraries

| Domain | Preferred | Over |
|---|---|---|
| Web framework | FastAPI | Flask |
| CLI | Typer + Rich + Trogon | Click, argparse |
| TUI | Textual | curses |
| Data validation | Pydantic v2+ | dataclasses, attrs |
| Settings/config | pydantic-settings | python-dotenv |
| DataFrames | Polars | Pandas |
| Visualization | Plotly, Altair | Matplotlib |
| Dashboards | Streamlit (primary), Dash (when needed) | |
| ORM | SQLModel | raw SQLAlchemy |
| Small DB | SQLite | |
| Large DB | PostgreSQL | |
| Analytics at scale | Parquet + Polars or DuckDB | Dask DataFrame |
| Logging | structlog | stdlib logging |
| HTTP client | httpx | requests |
| Multiprocessing/distributed | Ray | multiprocessing, Celery |
| Distributed data | Dask on Ray scheduler (when Polars won't scale) | Spark |
| ML/numeric | NumPy, scikit-learn, Jax (learning), numba (learning) | |
| NLP | spaCy, Hugging Face (transformers, datasets, hub) | |
| Experiment config | Confection (explosion.ai), Hydra (Meta) | |
| Experiment tracking | W&B, MLflow | |
| Data versioning | DVC | |
| Vector DBs / ANN | FAISS, HNSW, LOPQ, LanceDB, pgvector (general interest) | |
| macOS GPU/ML | MLX (learning) | |
| LLM hosting | vLLM, ONNX | |
| Model serving | Ray Serve | |
| LLM integration | Lightweight/custom (thin wrappers, httpx, Anthropic SDK) | LangChain |
| Agentic frameworks | Pydantic AI | LangChain, LangGraph, CrewAI |
| Pipeline data validation | Pandera | |
| Property-based testing | Hypothesis | |
| Caching / message broker | Redis or diskcache | |
| Observability | Logfire (primary), OpenTelemetry | |
| LLM observability | Logfire (primary), W&B Weave (secondary) | LangSmith |
| Python compilation/JIT | Numba, Mypyc, Cython, (interest in compiled Python) | |
| Rust bindings | PyO3 + maturin | |
| Notebooks | Jupyter where appropriate, interested in Marimo | |
| Docs | Zensical | Material for Mkdocs |
| Code generation/injection | Cog (inject content into markdown, text files — e.g., coverage reports) | |

## CI/CD & Deployment

- **CI**: GitHub Actions
  - Test against built wheels (not editable installs)
  - Attach wheels as workflow artifacts
  - Write coverage reports as markdown to Actions output
  - Attach html coverage reports as artifacts
  - Use new git tag to trigger creating a github release
- **Pre-commit**: Enforced in CI
- **Git workflow**: GitHub Flow (feature branches + PRs to main)
- **Containers**: Docker + Kubernetes
- **Devcontainers**: Use when appropriate (VSCode)
- **Docs hosting**: GitHub Pages (works for private repos)

## Editor & Environment

- **Editor**: VSCode + Claude Code
- **Devcontainers**: Yes, when appropriate, codespaces are nice to have

## Interaction Preferences

- Ask before: creating new top-level directories, adding dependencies, proposing large refactors
- Don't ask before: fixing obvious bugs, applying formatting, adding type annotations, writing tests for existing behavior

## Development Workflow

- **TDD**: Use red/green TDD when implementing features where it makes sense — write a failing test first, then write the minimal code to make it pass. This applies to new functions, classes, and behaviors. Skip TDD for:
  - CLI entrypoints and argument wiring
  - Pydantic model definitions
  - Configuration loading and settings
  - Pure scaffolding (directory layout, `__init__.py`, etc.)

## Teaching & Growth Areas

When I'm working in these areas, provide educational context and explain trade-offs:
- **Async patterns**: Teach me when async vs sync vs mixed is the best fit
- **Jax & numba**: Help me identify where these are appropriate over plain NumPy
- **MLX**: Teach me macOS-native GPU acceleration patterns
- **Rust + PyO3**: Help me recognize when Python bindings to Rust make sense for CPU-heavy workloads
- **Wasm/Pyodide/Pyscript**: Teach me about browser-based Python execution, executable docs, Monty Rust sandbox
- **Kubernetes**: Explain K8s concepts as they come up; I know Docker well
- **Frontend (React/Redux/TypeScript)**: Explain from first principles when relevant; I'm a novice
- **Alternative libraries**: If there's a better tool I don't know about, suggest it as a teaching moment until I express a strong opinion

## Inspirations

People whose work and philosophy shape my taste — use these as calibration for API design, DX, and code quality decisions:
- **Sebastien Ramirez** (FastAPI, Typer, SQLModel) — APIs that self-document through types; developer experience as a first-class design constraint, not polish
- **Samuel Colvin** (Pydantic, pydantic AI, Logfire, Monty) — zero-overhead ergonomics; making type safety feel natural rather than bureaucratic
- **Michael Kennedy** (Talk Python to Me, Python Bytes) — celebrating the breadth of the Python ecosystem; accessible, enthusiastic community advocacy
- **Brian Okken** (pytest book, Test & Code podcast, Python Bytes) — testing as a craft; fixtures and parametrize as the right mental model for thorough, maintainable tests
- **Brett Cannon** (CPython core dev, importlib, python.org dev guide) — stewarding a language's evolution with deep care for backwards compatibility and contributor experience
- **Eric J. Ma** (Network Analysis Made Simple, ericmjl.github.io) — applied ML done right: reproducible, well-documented, grounded in real scientific questions
- **Will McGugan** (Rich, Textual, Textualize) — beautiful CLI/TUI UX as a first-class engineering concern; terminals deserve the same design attention as GUIs
- **Ned Batchelder** (coverage.py, cog, nedbatchelder.com) — pragmatic, well-measured tooling; plain-language explanations of genuinely hard things
- **Peter Wang** (Pyscript, Anaconda, Bokeh, Panel) — pushing Python into new frontiers (browser, GPU) while keeping scientific computing accessible to non-specialists
- **Margaret Mitchell** (Hugging Face, model cards, AI ethics research) — model cards as a documentation standard; treating ethics as an engineering discipline with deliverables
- **Vicki Boykis** (vickiboykis.com) — honest, grounded takes on ML in production; writing that cuts through hype with domain depth
- **Simon Willison** (Datasette, LLM CLI, simonwillison.net) — observable systems, executable demos, writing-as-thinking; rapid prototyping without sacrificing rigor
- **Vincent Warmerdam** (calmcode.io, Rasa, Marimo, PyData talks) — concise, calm teaching; making complex tools feel approachable through minimal, well-chosen examples

## Demos

When completing a feature, tool, or any substantial piece of work, create a showboat demo as part of the deliverable. Demos are not optional — they are a core output alongside the code itself.

Use `showboat` (installed as a uv tool) to build executable demo documents in the `demos/` directory. A good demo tells a story: explain what you're about to show, show it working, and verify everything is reproducible with `showboat verify` before considering the work done.

Plan for the demo from the start of the task, not as an afterthought. The best demos are built incrementally as you work. Use the `showboat-demos` skill for the CLI interface.

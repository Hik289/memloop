# Scripts

Scripts are compatibility launchers for batch and benchmark workflows. New
automation should prefer the `memloop` CLI directly, then use these scripts only
when reproducing an existing run layout.

| Script | Purpose |
| --- | --- |
| `launch_v6.sh` | Launch the dual-memory V6 wrapper. |
| `rerun_evals.sh` | Re-run evaluation jobs for existing answer files. |
| `run_erag_query.sh` | Run a single ERAG query workflow. |
| `run_erag_query_chain.sh` | Run chained ERAG query workflows. |
| `run_erag_tier.sh` | Run a tier-level ERAG workflow. |

Before using a script, inspect its environment variables and output paths. Keep
private manifests, generated answers, and logs outside Git.

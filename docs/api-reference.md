# API Reference

This page documents the supported public Python surface. Lower-level modules are
available for advanced users, but the objects below are the stable integration
points for applications, tests, and orchestration code.

## Memory Node Schema

```python
from memloop.methods import DualNode
```

`DualNode` represents one hierarchy node with both compact and detailed memory.

| Field | Purpose |
| --- | --- |
| `node_id` | Stable node identifier used by indexes and parent-child links. |
| `level` | Hierarchy level, for example L0 raw evidence or higher-level summaries. |
| `distilled_text` | Compact routing and answer-context text. |
| `detailed_text` | Source-level evidence used for grounded answering. |
| `children` | Child node ids in the hierarchy. |
| `metadata` | Optional operational metadata such as source type or title. |

## Node IO

```python
from memloop.methods import read_nodes_jsonl, write_nodes_jsonl, validate_one
```

Use JSONL node files when integrating MemLoop with external storage or test
fixtures.

```python
nodes = list(read_nodes_jsonl("results/hierarchy/nodes.jsonl"))
validate_one(nodes[0])
write_nodes_jsonl("results/hierarchy/export.jsonl", nodes)
```

## Promotion Control

```python
from memloop.methods import PromotionController
```

`PromotionController` manages which detailed evidence is allowed into the
answer context. Use it when a service needs a bounded promoted set rather than
dumping every retrieved source into the prompt.

```python
promotion = PromotionController(nodes_by_id, embedder=None, promotion_budget=20)
```

## Decay Control

```python
from memloop.methods import DecayController
```

`DecayController` ages out stale promoted state so long-running sessions do not
carry irrelevant evidence forever.

```python
decay = DecayController(nodes_by_id, decay_window=15)
```

## Token Accounting

```python
from memloop.methods import TokenLedger
```

`TokenLedger` records token use per run. Store it with answer artifacts so
latency, cost, and context budget can be audited later.

```python
ledger = TokenLedger(run_id="prod-2026-07-23", method="V5")
```

## CLI First

Use the CLI for production batch runs:

```bash
memloop build-hierarchy --help
memloop run --help
memloop evaluate --help
```

Use the Python API for service integration, custom orchestration, tests, and
adapters around existing storage systems.

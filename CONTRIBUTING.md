# Contributing

Thanks for improving MemLoop. Keep changes product-focused, documented, and
easy to test locally.

## Local Checks

```bash
pip install -e ".[dev]"
python -m compileall -q memloop
pytest
memloop doctor
```

## Pull Request Checklist

- Update README or docs when behavior changes.
- Add focused tests for new public behavior.
- Do not commit `.env`, generated outputs, parquet manifests, caches, or logs.
- Keep provider credentials in environment variables only.

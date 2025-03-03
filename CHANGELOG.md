# Changelog

## [8.5.0] - 2024-03-04

### Hotfix

A dependency update has been applied to resolve compatibility issues within the HeavyAI container. To apply this hotfix, run:

```bash
bash scripts/hotfix-8-5-0.sh
```

#### Changes
- Added `llama-index` to version 0.10.68
- Added `llama-index-embeddings-text-embeddings-inference` version 0.1.4
- Container restart is handled automatically by the hotfix script

#### Requirements
- Docker must be running
- HeavyAI container must be named `heavyiq`
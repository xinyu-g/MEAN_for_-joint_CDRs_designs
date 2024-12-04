

# Running Experiments with adapated MEAN on design of CDRs

This code originates from MEAN, with our modifications detailed in the change log.

This document describes how to run the three main experiments using the provided scripts:
1. Evaluation on SAbDab
2. Antigen-binding CDR-H3 Redesign
3. Affinity Optimization

## Common Setup

Before running any experiments:

1. Follow the setup instructions in the [original README.md](README_ORI.md):
   - Install dependencies using `bash scripts/setup.sh`
   - Download structure data from [SAbDab](http://opig.stats.ox.ac.uk/webapps/newsabdab/sabdab/search/?all=true#downloads)
   - Place the structure data in `all_structures/imgt`

## 1. K-fold Evaluation on SAbDab

This experiment involves training and evaluating models on different CDR combinations.

### Data Preparation

```bash
bash scripts/prepare_data_kfold.sh summaries/sabdab_summary.tsv all_structures/imgt
```

### Training
```bash
# Train all CDR combinations for each CDRH type
GPU=0 bash run_all_cdrs.sh
```

This will:
- Process CDRH1-3 directories
- Train models for all CDR combinations (1, 2, 3, 1-2, 1-3, 2-3, 1-2-3)
- Skip combinations where checkpoints already exist
- Save checkpoints in `summaries/cdrh{i}/CDR{combination}/ckpt/`

### Evaluation
```bash
# Evaluate all trained models
GPU=0 bash run_all_cdrs_eval.sh
```

This will:
- Evaluate each trained model
- Generate results for each CDR combination
- Save results in the corresponding output directories

## 2. Antigen-binding CDR-H3 Redesign

### prepare the RAbD data:
```bash
bash scripts/prepare_data_rabd.sh summaries/rabd_summary.jsonl all_structures/imgt summaries/sabdab_all.json
```

### run training and evaluation:
```bash
# Train and evaluate all CDR combinations
GPU=0 bash run_all_cdrs_rabd.sh
```

This will:
- Train models for each CDR combination
- Target CDRH3 for redesign
- Save results in `summaries/cdrh3/CDR{combination}/`

## 3. Affinity Optimization

### prepare the SKEMPI data:
```bash
bash scripts/prepare_data_skempi.sh summaries/skempi_v2_summary.jsonl all_structures/imgt summaries/sabdab_all.json
```

### run the optimization:
```bash
# Run pretraining, ITA training, and evaluation for all combinations
GPU=0 bash run_all_cdrs_opt.sh
```

This will:
- Run pretraining if needed
- Perform ITA training
- Generate and evaluate optimized sequences
- Save results in `summaries/CDR{combination}/`

## Notes

- All scripts support the `GPU` environment variable to specify which GPU to use
- Set `GPU=-1` to run on CPU
- Results and checkpoints are organized by:
  - CDR type (cdrh1/2/3)
  - CDR combination (1, 2, 3, 1-2, etc.)
  - Model type and mode
- Each script will skip combinations where checkpoints already exist
- Use `MODE=100` for heavy chain only, `MODE=111` for full context (default)

## Directory Structure

```
summaries/
├── cdrh1/
│   ├── CDR1/
│   ├── CDR1_2/
│   └── ...
├── cdrh2/
│   ├── CDR1/
│   ├── CDR1_2/
│   └── ...
└── cdrh3/
    ├── CDR1/
    ├── CDR1_2/
    └── ...
```

Each CDR combination directory contains:
- `ckpt/` - Model checkpoints
- Results and evaluation logs 
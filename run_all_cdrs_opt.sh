#!/bin/bash

MODE="111"
MODEL="mean"
DATA_DIR="summaries"  # Base directory containing the data

# Array of all CDR combinations to test
declare -a CDR_COMBINATIONS=(
    "1"
    "2"
    "3"
    "1 2"
    "1 3"
    "2 3"
    "1 2 3"
)

# Function to create a directory-safe name from CDR combination
make_dir_name() {
    echo $1 | tr ' ' '_'
}

echo "======================================"
echo "Processing Affinity Optimization"
echo "======================================"

# For each CDR combination
for cdr_combo in "${CDR_COMBINATIONS[@]}"; do
    echo "Running with CDR types: ${cdr_combo}"
    
    # Create a unique directory suffix based on CDR combination
    dir_suffix=$(make_dir_name "${cdr_combo}")
    
    # Create output directory
    output_dir="${DATA_DIR}/CDR${dir_suffix}"
    mkdir -p "${output_dir}"
    
    # Check if checkpoint exists
    checkpoint_path="${output_dir}/ckpt/${MODEL}_CDR${dir_suffix//_/}_${MODE}/version_0/checkpoint/epoch15_step2400.ckpt"
    
    echo "checkpoint: ${checkpoint_path}"
    if [ -f "${checkpoint_path}" ]; then
        echo "Checkpoint exists at ${checkpoint_path}, skipping pretraining"
    else
        # Run pretraining
        echo "Running pretraining"
        echo "Input data from: ${DATA_DIR}"
        echo "Output will be in: ${output_dir}"
        if [ -z "${GPU}" ]; then
            GPU=-1
        fi
        echo "Using GPU: ${GPU}"
        
        # Run pretraining with appropriate parameters
        GPU=${GPU} MODE=${MODE} DATA_DIR=${output_dir} CDR="${cdr_combo}" \
        bash train.sh ${MODEL} "3"  # Always use CDRH3 as target
    fi
    
    # Run ITA training
    echo "Running ITA training"
    CKPT_DIR="${output_dir}/ckpt/${MODEL}_CDR${dir_suffix//_/}_${MODE}/version_0" \
    GPU=${GPU} CDR="${cdr_combo}" \
    bash ita_train.sh
    
    # Run evaluation
    echo "Running evaluation"
    GPU=${GPU} DATA_DIR=${output_dir} CDR="${cdr_combo}" \
    bash ita_generate.sh "${output_dir}/ckpt/${MODEL}_CDR${dir_suffix//_/}_${MODE}/version_0/ita/iter_final.ckpt"
    
    echo "Finished CDR combination: ${cdr_combo}"
    echo "--------------------------------------"
done

echo "All CDR combinations completed!" 
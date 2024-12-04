#!/bin/bash

INPUT_DIR="summaries"  # Directory containing original data
MODE="111"
MODEL="mean"
PORT="9901"

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

# For each cdrh1/2/3 directory
for i in {1..3}; do
    echo "======================================"
    echo "Processing cdrh${i} directory"
    echo "======================================"
    
    base_dir="${INPUT_DIR}/cdrh${i}"
    
    # For each CDR combination
    for cdr_combo in "${CDR_COMBINATIONS[@]}"; do
        echo "Running with CDR types: ${cdr_combo}"
        
        # Create a unique directory suffix based on CDR combination
        dir_suffix=$(make_dir_name "${cdr_combo}")
        
        # Create output directory as a subdirectory of the current cdrh directory
        output_dir="${base_dir}/CDR${dir_suffix}"
        mkdir -p "${output_dir}"
        
        # Check if checkpoint exists
        

        checkpoint_path="${output_dir}/ckpt/${MODEL}_CDR${dir_suffix//_/}_${MODE}/version_0/checkpoint/epoch15_step2400.ckpt"

        echo "checkpoint: ${checkpoint_path}"
        if [ -f "${checkpoint_path}" ]; then
            echo "Checkpoint exists at ${checkpoint_path}, skipping this combination"
            continue
        fi
        
        # Run training
        echo "Input data from: ${base_dir}"
        echo "Output will be in: ${output_dir}"
        if [ -z "${GPU}" ]; then
            GPU=-1
        fi
        echo "Using GPU: ${GPU}"
        
        # Run training with input directory being the base directory
        LR=${LR} INPUT_DIR="${base_dir}" OUTPUT_DIR="${output_dir}" \
        GPU=${GPU} MODE=${MODE} PORT=${PORT} CDR="${cdr_combo}" \
        bash train.sh ${MODEL} ${i}
        
        echo "Finished CDR combination: ${cdr_combo} for cdrh${i}"
        echo "--------------------------------------"
    done
    echo "Finished all combinations for cdrh${i}"
    echo "======================================"
done

echo "All CDR combinations completed for all directories!" 

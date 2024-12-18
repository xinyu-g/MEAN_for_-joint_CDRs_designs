#!/bin/bash

INPUT_DIR="summaries"  # Directory containing original data
MODE="111"
MODEL="mean"
VERSION="0"

# Array of all CDR combinations to test
declare -a CDR_COMBINATIONS=(
    # "1"
    # "2"
    # "3"
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
        echo "Evaluating with CDR types: ${cdr_combo}"
        
        # Create a unique directory suffix based on CDR combination
        dir_suffix=$(make_dir_name "${cdr_combo}")
        
        # Create output directory as a subdirectory of the current cdrh directory
        output_dir="${base_dir}/CDR${dir_suffix}"
        mkdir -p "${output_dir}"
        
        # Run evaluation
        echo "Input data from: ${base_dir}"
        echo "Output will be in: ${output_dir}"
        if [ -z "${GPU}" ]; then
            GPU=0
        fi
        echo "Using GPU: ${GPU}"
        
        # Run evaluation with input directory being the base directory
        # Pass CDR without spaces for checkpoint directory naming
        INPUT_DIR="${base_dir}" OUTPUT_DIR="${output_dir}" \
        GPU=${GPU} MODE=${MODE} CDR="${cdr_combo//[ ,]/}" \
        bash scripts/k_fold_eval.sh "${output_dir}" "${MODE}" "${MODEL}" "${VERSION}"
        
        echo "Finished evaluating CDR combination: ${cdr_combo} for cdrh${i}"
        echo "--------------------------------------"
    done
    echo "Finished all combinations for cdrh${i}"
    echo "======================================"
done

echo "All CDR combinations evaluated for all directories!" 
#!/bin/bash

INPUT_DIR="summaries/cdrh3"  # Directory containing CDRH3 data
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

echo "======================================"
echo "Processing CDRH3 Redesign"
echo "======================================"

# For each CDR combination
for cdr_combo in "${CDR_COMBINATIONS[@]}"; do
    echo "Running with CDR types: ${cdr_combo}"
    
    # Create a unique directory suffix based on CDR combination
    dir_suffix=$(make_dir_name "${cdr_combo}")
    
    # Create output directory
    output_dir="${INPUT_DIR}/CDR${dir_suffix}"
    mkdir -p "${output_dir}"
    
    
    # Run training
    echo "Input data from: ${INPUT_DIR}"
    echo "Output will be in: ${output_dir}"
    if [ -z "${GPU}" ]; then
        GPU=0
    fi
    echo "Using GPU: ${GPU}"
    
    # Run training with input directory being the base directory
    LR=${LR} INPUT_DIR="${INPUT_DIR}" OUTPUT_DIR="${output_dir}" \
    GPU=${GPU} MODE=${MODE} PORT=${PORT} CDR="${cdr_combo}" \
    bash train.sh ${MODEL} "3"  # Always use CDRH3 as target
    
    # Run evaluation
    echo "Running evaluation"
    INPUT_DIR="${INPUT_DIR}" OUTPUT_DIR="${output_dir}" \
    GPU=${GPU} MODE=${MODE} CDR="${cdr_combo//[ ,]/}" \
    bash rabd_test.sh "0"
    
    echo "Finished CDR combination: ${cdr_combo}"
    echo "--------------------------------------"
done

echo "All CDR combinations completed!" 
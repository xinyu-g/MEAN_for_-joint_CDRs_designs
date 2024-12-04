#!/bin/bash

MODE="111"
MODEL="mean"
DATA_DIR="summaries/cdrh3"  # Directory for CDRH3 data

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
    output_dir="${DATA_DIR}/CDR${dir_suffix}"
    mkdir -p "${output_dir}"
    
    # Check if checkpoint exists
    
    # Run training
    echo "Input data from: ${DATA_DIR}"
    echo "Output will be in: ${output_dir}"
    if [ -z "${GPU}" ]; then
        GPU=-1
    fi
    echo "Using GPU: ${GPU}"
    
    # Run training with appropriate parameters
    GPU=${GPU} MODE=${MODE} DATA_DIR=${output_dir} \
    bash train.sh ${MODEL} "3"  # Always use CDRH3 as target
    
    echo "Finished CDR combination: ${cdr_combo}"
    echo "--------------------------------------"
done

echo "All CDR combinations completed!"

# Run evaluation for all combinations
echo "======================================"
echo "Running evaluation for all combinations"
echo "======================================"

for cdr_combo in "${CDR_COMBINATIONS[@]}"; do
    dir_suffix=$(make_dir_name "${cdr_combo}")
    output_dir="${DATA_DIR}/CDR${dir_suffix}"
    
    echo "Evaluating CDR combination: ${cdr_combo}"
    GPU=${GPU} MODE=${MODE} DATA_DIR=${output_dir} \
    bash rabd_test.sh "0"
    
    echo "Finished evaluating CDR combination: ${cdr_combo}"
    echo "--------------------------------------"
done

echo "All evaluations completed!" 
#!/bin/bash
PROJ_FOLDER=$(cd "$(dirname "$0")";cd ..;pwd)
echo "Locate project at ${PROJ_FOLDER}"

cd ${PROJ_FOLDER}

if [ $# != 4 ]; then
    echo "Usage: GPU=x bash $0 /directory/to/all_data <mode: (100, 111)> <model type> <version>"
    exit 1;
fi
ROOT_DIR=$1
_MODE=$2
_MODEL=$3
VERSION=$4

echo "Input data from: ${INPUT_DIR}"
echo "Output to: ${OUTPUT_DIR}"
echo "Model type ${_MODEL}"

if [ -z ${GPU} ]; then
    GPU=0
fi
echo "Using GPUs: ${GPU}"

# Run generation with input and output directories
GPU=${GPU} MODE=${_MODE} CDR="${CDR}" \
MODEL=${_MODEL} DATA_DIR=${OUTPUT_DIR} INPUT_DIR=${INPUT_DIR} \
RUN=1 bash generate.sh ${VERSION}

# Generate results log
LOG=${OUTPUT_DIR}/${_MODEL}_${_MODE}_version${VERSION}_results.txt
echo "LOG is: ${LOG}"
python evaluation/get_k_fold_res.py \
    --data_dir ${OUTPUT_DIR} \
    --cdr_type "${CDR}" \
    --model ${_MODEL} \
    --version ${VERSION} \
    --mode ${_MODE} | tee -a ${LOG}

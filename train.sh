#!/bin/bash

########## adjust configs according to your needs ##########
if [ -z "${INPUT_DIR}" ]; then
    INPUT_DIR=${DATA_DIR}  # Fallback to DATA_DIR if INPUT_DIR not set
fi
if [ -z "${OUTPUT_DIR}" ]; then
    OUTPUT_DIR=${DATA_DIR}  # Fallback to DATA_DIR if OUTPUT_DIR not set
fi

TRAIN_SET=${INPUT_DIR}/train.json
DEV_SET=${INPUT_DIR}/valid.json
SAVE_DIR=${OUTPUT_DIR}/ckpt
mkdir -p ${SAVE_DIR}  # Create the output directory

BATCH_SIZE=16  # need four 12G GPU
MAX_EPOCH=20
if [ -z ${LR} ]; then
	LR=1e-3
fi
######### end of adjust ##########

########## Instruction ##########
# This script takes three optional environment variables:
# GPU / ADDR / PORT
# e.g. Use gpu 0, 1 and 4 for training, set distributed training
# master address and port to localhost:9901, the command is as follows:
#
# GPU="0,1,4" ADDR=localhost PORT=9901 bash train.sh
#
# Default value: GPU=-1 (use cpu only), ADDR=localhost, PORT=9901
# Note that if your want to run multiple distributed training tasks,
# either the addresses or ports should be different between
# each pair of tasks.
######### end of instruction ##########

# set master address and port e.g. ADDR=localhost PORT=9901 bash train.sh
MASTER_ADDR=localhost
MASTER_PORT=9901
if [ $ADDR ]; then MASTER_ADDR=$ADDR; fi
if [ $PORT ]; then MASTER_PORT=$PORT; fi
echo "Master address: ${MASTER_ADDR}, Master port: ${MASTER_PORT}"

# set gpu, e.g. GPU="0,1,2,3" bash train.sh
if [ -z "$GPU" ]; then
    GPU="-1"  # use CPU
fi
export CUDA_VISIBLE_DEVICES=$GPU
echo "Using GPUs: $GPU"
if [ "$GPU" = "-1" ]; then
    export CUDA_VISIBLE_DEVICES=""  # Disable CUDA for CPU-only
else
    export CUDA_VISIBLE_DEVICES=$GPU  # Set specified GPUs
fi
GPU_ARR=(`echo $GPU | tr ',' ' '`)
echo "GPU_ARR: ${GPU_ARR[@]}"

if [ ${#GPU_ARR[@]} -gt 1 ]; then
	PREFIX="torchrun --nproc_per_node=${#GPU_ARR[@]} --master_addr=${MASTER_ADDR} --master_port=${MASTER_PORT}"
else
    PREFIX="python"
fi

if [ -z ${MODE} ]; then
    MODE=111
fi

MODEL=mean
if [ $1 ]; then
	MODEL=$1
fi

# CDR="[1, 2, 3]"  # Default CDR types as a list
# if [ $2 ]; then
#     CDR=[$(echo $2 | tr ' ' ',')]
# fi

 # Default CDR types
# if [ "$2" ]; then
#     CDR="$2"
# fi

if [ -z ${CDR} ]; then
	CDR="1 2 3" 
fi

# Create the model-specific directory under the output directory
SAVE_DIR=${SAVE_DIR}/${MODEL}_CDR${CDR//[ ,]/}_${MODE}
mkdir -p ${SAVE_DIR}  # Create the model-specific directory

echo "GPU_ARR: ${GPU_ARR[@]}"
echo "CDR: ${CDR}"
echo "Input from: ${INPUT_DIR}"
echo "Saving to: ${SAVE_DIR}"

${PREFIX} train.py \
    --train_set $TRAIN_SET \
    --valid_set $DEV_SET \
    --save_dir $SAVE_DIR \
    --batch_size ${BATCH_SIZE} \
    --max_epoch ${MAX_EPOCH} \
    --gpus ${GPU_ARR[@]} \
    --mode ${MODE} \
    --cdr_type "${CDR}" \
    --lr ${LR} \
    --alpha 0.8 \
    --anneal_base 0.95 \
    --n_iter 3


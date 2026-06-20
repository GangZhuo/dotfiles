#!/bin/bash

UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
MEM=$(nvidia-smi --query-gpu=utilization.memory --format=csv,noheader,nounits)

MODE=${1:-"UTIL"}

echo "{\"text\": \"${!MODE}\", \"tooltip\": \"GPU: ${UTIL}%\nMEM: ${MEM}%\nTemp: ${TEMP}°C\"}"


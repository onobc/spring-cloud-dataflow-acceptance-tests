#!/usr/bin/env bash
if [ "$TMC_CLUSTER" == "" ]; then
  echo "TMC_CLUSTER environmental variable not found" >&2
  exit 2
fi
tmc cluster delete "$TMC_CLUSTER"

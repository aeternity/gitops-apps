#!/bin/bash

for d in */ ; do
    echo "$d"
    git checkout ${ENV:?} -- ${d}values-${ENV:?}.yaml
done

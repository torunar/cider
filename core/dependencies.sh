#!/usr/bin/env bash

function checkDependencies() {
    local dependenciesList=( sed grep find markdown sort tr less echo )
    local failedDependenciesList=()

    for dependency in "${dependenciesList[@]}"; do
        hash $dependency 2>/dev/null || failedDependenciesList+=($dependency)
    done

    if [ ${#failedDependenciesList[@]} -gt 0 ]; then
        for dependency in "${failedDependenciesList[@]}"; do
            echo "Unsatisfied dependency: ${dependency}"
        done

        # failed dependencies exist
        return 1
    fi

    # all dependencies are satisfied
    return 0
}
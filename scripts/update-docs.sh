#!/bin/bash

# Script for updating Helm chart documentation using helm-docs
#   ./update-docs.sh              # Updates all charts
#   ./update-docs.sh complex      # Updates only complex chart
#   ./update-docs.sh prometheus-rules  # Updates only prometheus-rules chart

set -e

CHARTS=("complex" "prometheus-rules")
TARGET_CHART="${1:-all}"

echo "Checking for helm-docs installation..."
if ! command -v helm-docs &> /dev/null; then
    echo "helm-docs is not installed."
    echo "Install it with: brew install norwoodj/tap/helm-docs"
    echo "Or visit: https://github.com/norwoodj/helm-docs"
    exit 1
fi

update_chart_docs() {
    local chart=$1
    echo "Generating documentation for $chart chart..."
    helm-docs --chart-search-root="$chart" --template-files=_templates.gotmpl --template-files=README.md.gotmpl
    echo "$chart documentation updated successfully!"
}

if [ "$TARGET_CHART" = "all" ]; then
    echo "Updating documentation for all charts..."
    for chart in "${CHARTS[@]}"; do
        update_chart_docs "$chart"
    done
else
    if [[ " ${CHARTS[*]} " =~ " ${TARGET_CHART} " ]]; then
        update_chart_docs "$TARGET_CHART"
    else
        echo "Error: Unknown chart '$TARGET_CHART'"
        echo "Available charts: ${CHARTS[*]}"
        echo "Usage: $0 [chart-name|all]"
        exit 1
    fi
fi

echo ""
echo "Documentation updated successfully!"
echo "Run 'git add */README.md' and 'git commit' to save the changes." 

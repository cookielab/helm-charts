#!/bin/bash

# Script for updating Complex Helm chart documentation using helm-docs

set -e

echo "Checking for helm-docs installation..."
if ! command -v helm-docs &> /dev/null; then
    echo "helm-docs is not installed."
    echo "Install it with: brew install norwoodj/tap/helm-docs"
    echo "Or visit: https://github.com/norwoodj/helm-docs"
    exit 1
fi

echo "Generating documentation for Complex chart..."
helm-docs --chart-search-root=complex --template-files=_templates.gotmpl --template-files=README.md.gotmpl

echo "Documentation updated successfully!"
echo ""
echo "Run 'git add complex/README.md' and 'git commit' to save the changes." 

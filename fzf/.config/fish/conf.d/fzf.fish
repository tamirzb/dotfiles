set -l bindings \
    "ctrl-d:half-page-down" \
    "ctrl-u:half-page-up" \
    "ctrl-g:top"

set -x FZF_DEFAULT_OPTS "--bind="(string join "," $bindings)

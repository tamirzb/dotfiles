# Set the default options for FZF

set -l bindings \
    "ctrl-d:half-page-down" \
    "ctrl-u:half-page-up" \
    "ctrl-g:top"

set -x FZF_DEFAULT_OPTS \
    # Reverse lists results top to bottom with search bar on top
    "--layout=reverse" \
    # Take 50% of the window so it's still possible to see previous commands
    "--height=50%" \
    "--bind="(string join "," $bindings)

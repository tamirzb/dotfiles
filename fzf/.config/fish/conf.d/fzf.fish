# Set the default options for FZF

set -l bindings \
    "ctrl-d:half-page-down" \
    "ctrl-u:half-page-up" \
    "ctrl-g:top" \
    # Scroll the preview window with Alt+u/d
    "alt-u:preview-half-page-up" \
    "alt-d:preview-half-page-down" \
    # Ctrl+r to toggle preview between being on the right, being bottom or
    # being hidden
    "ctrl-r:change-preview-window\(bottom\|hidden\|right\)"

set -x FZF_DEFAULT_OPTS \
    # Reverse lists results top to bottom with search bar on top
    "--layout=reverse" \
    # Take 50% of the window so it's still possible to see previous commands
    "--height=50%" \
    "--bind="(string join "," $bindings)

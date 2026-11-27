#!/usr/bin/env bash
# Run a Tcl script in Vivado batch mode, or open a file in the GUI.
#
#   scripts/vivado.sh <script.tcl> [tcl args...]
#   scripts/vivado.sh --gui <file.dcp>
#
# Uses `vivado` from PATH.
# Runs from build/ so .Xil and logs stay out of the repo.
set -euo pipefail

if ! command -v vivado >/dev/null 2>&1; then
    echo "error: vivado not found, put it on your PATH" >&2
    exit 1
fi

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
mkdir -p "$root/build"

if [[ $1 == --gui ]]; then
    file=$(realpath "$2")
    cd "$root/build"
    exec vivado -nojournal -log gui.log "$file"
fi

script=$(realpath "$1")
shift
cd "$root/build"
exec vivado -mode batch -nojournal -notrace \
    -log "$(basename "$script" .tcl).log" \
    -source "$script" -tclargs "$@"

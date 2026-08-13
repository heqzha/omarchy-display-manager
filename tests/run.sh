#!/usr/bin/env bash
set -euo pipefail
project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
node "$project_dir/tests/model.test.js"
"$project_dir/tests/helper.test.sh"
omarchy plugin validate "$project_dir"

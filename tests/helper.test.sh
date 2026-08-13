#!/usr/bin/env bash
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
fixture_dir=$(mktemp -d)
trap 'rm -rf "$fixture_dir"' EXIT
mkdir -p "$fixture_dir/bin" "$fixture_dir/state"

cat >"$fixture_dir/monitors.json" <<'JSON'
[
  {"name":"eDP-1","description":"Internal","make":"BOE","model":"Panel","serial":"ABC","disabled":false,"focused":true,"width":1920,"height":1200,"refreshRate":60.001,"x":0,"y":0,"scale":1,"transform":0,"mirrorOf":"none","availableModes":["1920x1200@60.001","1280x800@60"]},
  {"name":"DP-1","description":"Desk","make":"Dell","model":"U2723QE","serial":"XYZ","disabled":false,"focused":false,"width":3840,"height":2160,"refreshRate":60,"x":1920,"y":0,"scale":2,"transform":0,"mirrorOf":"none","availableModes":["3840x2160@60","2560x1440@60"]}
]
JSON

cat >"$fixture_dir/bin/hyprctl" <<'SH'
#!/usr/bin/env bash
if [[ ${1:-} == -j && ${2:-} == monitors ]]; then cat "$TEST_MONITORS"; exit 0; fi
if [[ ${1:-} == keyword && ${2:-} == monitor ]]; then printf '%s\n' "$3" >>"$TEST_CALLS"; exit 0; fi
exit 1
SH
cat >"$fixture_dir/bin/systemd-run" <<'SH'
#!/usr/bin/env bash
exit 0
SH
cat >"$fixture_dir/bin/systemctl" <<'SH'
#!/usr/bin/env bash
exit 0
SH
chmod +x "$fixture_dir/bin/"*

export PATH="$fixture_dir/bin:$PATH"
export XDG_STATE_HOME="$fixture_dir/state"
export TEST_MONITORS="$fixture_dir/monitors.json"
export TEST_CALLS="$fixture_dir/calls"
helper="$project_dir/bin/display-manager"

state=$($helper state)
jq -e 'length == 2 and .[0].fingerprint == "BOE|Panel|ABC" and .[1].scale == 2' <<<"$state" >/dev/null
[[ $($helper topology) == '"BOE|Panel|ABC::Dell|U2723QE|XYZ"' ]]

config=$(jq -c '[.[0] + {x:3840,transform:1}, .[1] + {x:0}]' <<<"$state")
$helper preview "$config" >/dev/null
grep -q '^eDP-1,1920x1200@60.001,3840x0,1,transform,1$' "$TEST_CALLS"
$helper confirm >/dev/null

$helper profiles-save Desk "$config" true >/dev/null
$helper profiles-list | jq -e '.profiles[0].name == "Desk" and .profiles[0].automatic == true' >/dev/null
$helper profiles-match | jq -e '.matched == true and .name == "Desk"' >/dev/null
$helper profiles-delete Desk | jq -e '.profiles | length == 0' >/dev/null

if $helper preview '[]' >/dev/null 2>&1; then
  echo "Expected empty configuration to fail" >&2
  exit 1
fi

echo "display-manager helper tests passed"

#!/usr/bin/env bash
set -euo pipefail
INFILE=${1:-}
OUTMIN=${2:-}
if [ -z "$INFILE" ] || [ -z "$OUTMIN" ]; then
  echo "Usage: $0 input.js output.min.js"
  exit 1
fi
TRANSFORMED=$(
node - <<'NODE' "$INFILE"
const fs = require('fs');
const infile = process.argv[2];
const src = fs.readFileSync(infile, 'utf8');
global.Az = { value: src };
function encodeAz(){
	b=Az.value
	a=""
	for(i=0;i<b.length;i++)a+=String.fromCharCode(b.charCodeAt(i)+1e3)
	Az.value="Л=`"+a+'`;Ж="";for(Й=0;Й<Л.length;Й++)И=Л.charCodeAt(Й),900<И&&(Ж+=String.fromCharCode(И-1e3));eval(Ж)'
}
encodeAz();
process.stdout.write(Az.value);
NODE
)
tmp=$(mktemp --suffix=.js)
printf "%s" "$TRANSFORMED" > "$tmp"
esbuild "$tmp" --minify --outfile="$OUTMIN"
rm -f "$tmp"


#!/usr/bin/env bash
set -euo pipefail

OUTDIR="${OUTDIR:-tmp}"
DOC="${DOC:-book.tex}"

latexmk \
  -synctex=1 \
  -pdfxe \
  -shell-escape \
  -interaction=nonstopmode \
  -file-line-error \
  -outdir="$OUTDIR" \
  "$DOC"

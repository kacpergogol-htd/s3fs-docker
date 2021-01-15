#!/bin/bash

set -e

for ep in /etc/entrypoint.d/*; do
  ext="${ep##*.}"
  if [ "${ext}" = "env" ] && [ -f "${ep}" ]; then
    # source files ending in ".env"
    echo "Sourcing: ${ep} $@"
    set -a && . "${ep}" "$@" && set +a
  elif [ "${ext}" = "sh" ] && [ -x "${ep}" ]; then
    # run scripts ending in ".sh"
    echo "Running: ${ep} $@"
    "${ep}" "$@"
  fi
done

echo "Running CMD: $@"
exec "$@"


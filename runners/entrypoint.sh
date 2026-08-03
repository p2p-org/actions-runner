#!/bin/bash

# Job containers run via rootless podman with a user namespace built from the
# subordinate id mappings in the Containerfile (runner:1:1000 and
# runner:1002:64535): a job-container user like uid 1001 maps to host uid
# 1002, not to the runner (1001). Files the runner creates with the default
# umask (0644) — most importantly the file commands backing
# $GITHUB_OUTPUT/$GITHUB_ENV/$GITHUB_PATH under _work/_temp — are then not
# writable from inside job containers, and any workflow step doing
# `echo ... >> $GITHUB_OUTPUT` fails with "Permission denied" unless the job
# image runs as root. Relax the umask so runner-created files are writable by
# job containers regardless of their user mapping. Runner pods are ephemeral
# and single-job, and job containers only see the mounted _work directories,
# so this grants nothing beyond the job's own files.
umask 000

# Start podman socket
podman system service --time=0 &

if (! which "$1" 1>/dev/null 2>/dev/null ) && [ ! -x "$1" ]; then
  # expect script or bash commands
  set -- bash "$@"
fi

exec "$@"

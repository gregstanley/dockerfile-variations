#!/bin/bash
# Was originally -> !/bin/sh - changed as this doesn't have 'source' (did it ever work?)
# NOTE: To avoid this error: https://forums.docker.com/t/standard-init-linux-go-175-exec-user-process-caused-no-such-file/20025/5
# This file MUST use UNIX style line endings (LF not CRLF)

# Immediately active the vitrual environment

echo 'Welcome to the application'


# Dockerfile has set ENVIRONMENT variables for the three directories
DATADIR="/home/app-user/data"

DIR="$DATADIR/source"
if [ -d "$DIR" ]; then
  echo "Found ${DIR}..."

  # Attempt to write a file to the SOURCE directory
  touch "$DIR/write-test"

  if [ -f "${DIR}/write-test" ]; then
    rm "${DIR}/write-test"
    echo "Error: The ${DIR} directory must not be writable."
    echo "Please ensure the 'docker run' -v option ends with ':ro' e.g. X:Path\On\Host\To\Source:/home/app-user/data/source:ro"
    exit 1
  fi
  echo "GOOD - The ${DIR} directory is READ-ONLY."
else
  echo "Error: ${DIR} not found. Can not continue."
  echo "Please ensure the 'docker run' -v option exists for 'source' e.g. X:Path\On\Host\To\Source:/home/app-user/data/source"
  exit 1
fi

DIR="$DATADIR/intermediate"
if [ -d "$DIR" ]; then
  echo "Found ${DIR}..."
else
  echo "Error: ${DIR} not found. Can not continue."
  echo "Please ensure the 'docker run' -v option exists for 'intermediate' e.g. X:Path\On\Host\To\Intermediate:/home/app-user/data/intermediate"
  exit 1
fi

DIR="$DATADIR/output"
if [ -d "$DIR" ]; then
  echo "Found ${DIR}..."
else
  echo "Error: ${DIR} not found. Can not continue."
  echo "Please ensure the 'docker run' -v option exists for 'output' e.g. X:Path\On\Host\To\Output:/home/app-user/data/output"
  exit 1
fi

echo 'venv packages:'
venv/bin/pip freeze

# Specifically fire up gunicorn from the virtual environment
exec venv/bin/gunicorn -b :5000 --access-logfile - --error-logfile - the-app:app

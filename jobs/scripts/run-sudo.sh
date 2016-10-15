#!/bin/bash -ex
sudo -u jenkins -s bash -ex ${JOB_NAME:-./output.sh}

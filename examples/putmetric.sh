#!/usr/bin/env bash

set -eo pipefail

aws cloudwatch put-metric-data --namespace "Example/Metric" --metric-data file://exampleMetric.json --profile eab

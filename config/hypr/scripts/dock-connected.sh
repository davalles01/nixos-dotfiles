#!/usr/bin/env bash

sleep 2

./generate-workspace-conf.sh

sleep 2

solaar -w hide &

sleep 2

pkill solaar

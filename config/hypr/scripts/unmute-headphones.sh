#!/usr/bin/env bash

amixer -c 1 set Headphone 100% unmute > /home/dani/Desktop/test.txt 2>&1

echo "Done" >> /home/dani/Desktop/test.txt

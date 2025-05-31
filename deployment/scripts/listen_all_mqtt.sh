#!/bin/bash

echo "Listening to all MQTT topics..."

docker run --rm -it --network ditto-deployment eclipse-mosquitto mosquitto_sub \
  -h mosquitto -p 1883 \
  -t "#" -v

echo "Press Ctrl+C to stop listening."
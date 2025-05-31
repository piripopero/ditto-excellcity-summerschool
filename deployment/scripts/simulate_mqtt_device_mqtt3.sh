#!/bin/bash

# Thing ID (e.g., my.test:octopus)
THING_ID="my.test:octopus"

# Define topic base
TOPIC_BASE="excellcity/${THING_ID}/attr"

echo "Sending temperature and humidity every 5 seconds for thing: $THING_ID"
echo "Press Ctrl+C to stop."

while true; do
  # Generate random values for temperature and humidity (0–100)
  TEMPERATURE=$(shuf -i 0-100 -n 1)
  HUMIDITY=$(shuf -i 0-100 -n 1)

  # Send temperature message
  docker run --rm --network ditto-deployment eclipse-mosquitto mosquitto_pub \
    -h mosquitto -p 1883 \
    -t "${TOPIC_BASE}/temperature" \
    -m "{\"value\": $TEMPERATURE, \"thingId\": \"$THING_ID\"}"

  # Send humidity message
  docker run --rm --network ditto-deployment eclipse-mosquitto mosquitto_pub \
    -h mosquitto -p 1883 \
    -t "${TOPIC_BASE}/humidity" \
    -m "{\"value\": $HUMIDITY, \"thingId\": \"$THING_ID\"}"

  # Wait 5 seconds
  sleep 5
done

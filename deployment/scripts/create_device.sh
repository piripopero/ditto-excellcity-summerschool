#!/bin/bash

curl -u ditto:ditto -X PUT -H 'Content-Type: application/json' -d '{
  "thingId": "my.test:octopus",
  "attributes": {
    "name": "multisensor",
    "type": "multisensor"
  },
  "features": {
    "temperature": {
      "properties": {
        "value": 100.67
      }
    },
    "humidity": {
      "properties": {
        "value": 120.9
      }
    }
  }
}' 'http://localhost:8080/api/2/things/my.test:octopus'
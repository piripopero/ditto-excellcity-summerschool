


### Example of thing
```
[
    {
        "thingId": "my.test:octopus",
        "policyId": "my.test:policy",
        "attributes": {
            "name": "octopus",
            "type": "octopus board"
        },
        "features": {
            "temp_sensor": {
                "properties": {
                    "value": 100.67
                }
            },
            "altitude": {
                "properties": {
                    "value": 120.9
                }
            }
        }
    }
]
```
### Example of Policy

```
{
  "policyId": "my.test:policy",
  "imports": {},
  "entries": {
    "owner": {
      "subjects": {
        "nginx:ditto": {
          "type": "nginx basic auth user"
        }
      },
      "resources": {
        "thing:/": {
          "grant": [
            "READ",
            "WRITE"
          ],
          "revoke": []
        },
        "policy:/": {
          "grant": [
            "READ",
            "WRITE"
          ],
          "revoke": []
        },
        "message:/": {
          "grant": [
            "READ",
            "WRITE"
          ],
          "revoke": []
        }
      },
      "importable": "implicit"
    },
    "only-read-temp_sensor": {
      "subjects": {
        "nginx:demo1": {
          "type": "generated"
        }
      },
      "resources": {
        "thing:/features/temp_sensor": {
          "grant": [
            "READ",
            "WRITE"
          ],
          "revoke": []
        }
      },
      "importable": "implicit"
    },
    "only-read-altitude": {
      "subjects": {
        "nginx:demo2": {
          "type": "generated"
        }
      },
      "resources": {
        "thing:/features/altitude": {
          "grant": [
            "READ"
          ],
          "revoke": []
        }
      },
      "importable": "implicit"
    },
    "test_sse": {
      "subjects": {
        "nginx:demo3": {
          "type": "generated"
        }
      },
      "resources": {
        "thing:/features/temp_sensor": {
          "grant": [
            "READ"
          ],
          "revoke": []
        }
      },
      "importable": "implicit"
    }
  }
}
```
### Example of MQTT COnnection:

```
{
  "id": "ce0bf8c7-360d-40b5-bed4-7e196e715403",
  "name": "MQTT",
  "connectionType": "mqtt-5",
  "connectionStatus": "open",
  "uri": "tcp://mosquitto:1883",
  "sources": [
    {
      "addresses": [
        "eclipse-ditto-sandbox/#"
      ],
      "consumerCount": 1,
      "qos": 0,
      "authorizationContext": [
        "nginx:ditto"
      ],
      "headerMapping": {
        "content-type": "{{header:content-type}}",
        "reply-to": "{{header:reply-to}}",
        "correlation-id": "{{header:correlation-id}}"
      },
      "payloadMapping": [
        "javascript"
      ],
      "replyTarget": {
        "address": "{{header:reply-to}}",
        "headerMapping": {
          "content-type": "{{header:content-type}}",
          "correlation-id": "{{header:correlation-id}}"
        },
        "expectedResponseTypes": [
          "response",
          "error"
        ],
        "enabled": true
      }
    }
  ],
  "targets": [],
  "clientCount": 1,
  "failoverEnabled": true,
  "validateCertificates": true,
  "processorPoolSize": 1,
  "mappingDefinitions": {
    "javascript": {
      "mappingEngine": "JavaScript",
      "options": {
        "incomingScript": "function mapToDittoProtocolMsg(headers, textPayload, bytePayload, contentType) {\n    const jsonString = String.fromCharCode.apply(null, new Uint8Array(bytePayload));\n    const jsonData = JSON.parse(jsonString); \n    const thingId = jsonData.thingId.split(':'); \n    const topic_array = headers[\"mqtt.topic\"].split(\"/\");\n    const thing_id_from_topic = topic_array[1];\n    const attr_name_from_topic = topic_array[3];\n\n // Comprobar que el thingId y el thing_id_from_topic son iguales\n    if (jsonData.thingId !== thing_id_from_topic) {\n        throw new Error(`thingId from payload (${thingId}) does not match thing_id from topic (${thing_id_from_topic})`);\n    }\n\n    const value = { \n        properties: {                \n            value: jsonData.value,\n          \n        } \n    };\n\n    return Ditto.buildDittoProtocolMsg(\n        thingId[0], // your namespace \n        thingId[1], \n        'things', // we deal with a thing\n        'twin', // we want to update the twin\n        'commands', // create a command to update the twin\n        'modify', // modify the twin\n        '/features/' + attr_name_from_topic, // modify all features at once\n        headers, \n        value\n    );\n}\n"
      }
    }
  },
  "tags": []
}

```
###### Beauty map function
```

function mapToDittoProtocolMsg(headers, textPayload, bytePayload, contentType) {
    const jsonString = String.fromCharCode.apply(null, new Uint8Array(bytePayload));
    const jsonData = JSON.parse(jsonString); 
    const thingId = jsonData.thingId.split(':'); 
    const topic_array = headers["mqtt.topic"].split("/");
    const thing_id_from_topic = topic_array[1];
    const attr_name_from_topic = topic_array[3];

 // Comprobar que el thingId y el thing_id_from_topic son iguales
    if (jsonData.thingId !== thing_id_from_topic) {
        throw new Error(`thingId from payload (${thingId}) does not match thing_id from topic (${thing_id_from_topic})`);
    }

    const value = { 
        properties: {                
            value: jsonData.value,
          
        } 
    };

    return Ditto.buildDittoProtocolMsg(
        thingId[0], // your namespace 
        thingId[1], 
        'things', // we deal with a thing
        'twin', // we want to update the twin
        'commands', // create a command to update the twin
        'modify', // modify the twin
        '/features/' + attr_name_from_topic, // modify all features at once
        headers, 
        value
    );
}


```
### Example of HTTP Push connection

```
{
  "id": "ce39f59d-c748-4c92-89a9-62488b0059eb",
  "name": "HTTP 1.1",
  "connectionType": "http-push",
  "connectionStatus": "open",
  "uri": "http://nodered:1880",
  "sources": [],
  "targets": [
    {
      "address": "POST:/nodered/test",
      "topics": [
        "_/_/things/twin/events"
      ],
      "authorizationContext": [
        "nginx:ditto"
      ],
      "headerMapping": {
        "content-type": "{{ header:content-type }}"
      }
    }
  ],
  "clientCount": 1,
  "failoverEnabled": true,
  "validateCertificates": true,
  "processorPoolSize": 1,
  "specificConfig": {
    "parallelism": "1"
  },
  "tags": []
}
```


#### MQTT message:

##### Topic = eclipse-ditto-sandbox/my.test:octopus

```
/eclipse-ditto-sandbox/my.test:octopus/attr/altitude
{
    "value" : 120.9,
    "thingId": "my.test:octopus"
}
```
```
/eclipse-ditto-sandbox/my.test:octopus/attr/temp_sensor
{
    "value" : 120.9,
    "thingId": "my.test:octopus"
}
```# EclipseDitto-Testing

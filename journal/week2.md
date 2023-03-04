# Week 2 — Distributed Tracing

This week the team will be talking about observability and some tools such as honeycomb, aws xray and cloud watch.


## Observability vs Monitoring

Logging is how you identify the problem in your system.

Problem of logging
- Time-consuming
- Tons of data with no context for why of the security events
- Needles in a haystack to find things
- Increase alert fatigue for SOC team and application team

Why Observability?
- Decreased alert fatigue
- Visibility of end2end of logs, metrics and tracing
- troubleshoot and resolve things quickly
- Understand application health
- Accelerate team collaboration
- Reduce overall operational cost
- Increase customer satisfaction

### ***Observability vs Monitoring***

Monitoring is tooling or a technical solution that allows teams to watch and understand the state of their systems. Monitoring is based on gathering predefined sets of metrics or logs.

Observability is tooling or a technical solution that allows teams to actively debug their system. Observability is based on exploring properties and patterns not defined in advance.

Reference from [Google Architech](https://pages.github.com/)


Pillars of Observability
- Metrics
- Traces
- Logs

Obeservability services in AWS
- AWS Cloudwatch logs
- AWS Cloudwatch metrics
- AWS X Ray traces

![AWS Obeservability Tools](https://d2908q01vomqb2.cloudfront.net/972a67c48192728a34979d9a35164c1295401b71/2021/09/22/Figure2.jpg)



***Instrumentation*** is what helps you to create or produce logs metrics traces.

![AWS Obesvability options](https://static.us-east-1.prod.workshops.aws/public/6b1b482b-5ecd-4e4a-a136-ed0427c17586/static/images/intro/aws-observability.png)


### Central Obeservability Platform - Security

- AWS Security Hub with Amazon Event Bridge
- Open Source Dashboard
- SIEM (Security Icident and Event Management)
- Event Driven Architecture with AWS Services

## Install Honeycomb

On the backend-flask/requirements.text, add the following code
```
opentelemetry-api 
opentelemetry-sdk 
opentelemetry-exporter-otlp-proto-http 
opentelemetry-instrumentation-flask 
opentelemetry-instrumentation-requests
```

install the dependency. this will necessary just this time as it will be run via docker compose
```
pip install -r requirements.txt
```

Add the following on the app.py
```
# Honeycomb
from opentelemetry import trace
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# Honeycomb
# Initialize tracing and an exporter that can send data to Honeycomb
provider = TracerProvider()
processor = BatchSpanProcessor(OTLPSpanExporter())
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)
tracer = trace.get_tracer(__name__)

# Honeycomb
# Initialize automatic instrumentation with Flask
FlaskInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()
```



from the docker-compose.yml, add the following code for the env variables
```
OTEL_SERVICE_NAME: 'backend-flask'
OTEL_EXPORTER_OTLP_ENDPOINT: "https://api.honeycomb.io"
OTEL_EXPORTER_OTLP_HEADERS: "x-honeycomb-team=${HONEYCOMB_API_KEY}"
```

from honeycomb.io, grab the unique code and create the gitpod env var
```
gp env HONEYCOMB_API_KEY=""
```


To create span and attribute, add the following code on the home_activities.py
```
from opentelemetry import trace
tracer = trace.get_tracer("home.activities")
```

```
with tracer.start_as_current_span("home-activities-mock-data"):
    span = trace.get_current_span()
```
```
span.set_attribute("app.now", now.isoformat())
 ```
 at the end of the code, put the following
 ```
span.set_attribute("app.result_lenght", len(results))

 ```

## Install Cloudwatch


from the backend-flask requirements.text, insert the following
```
watchtower
```

install the dependency. this will necessary just this time as it will be run via docker compose
```
pip install -r requirements.txt
```

add the following code on the app.py on our backend-flask
```
# Cloudwatch
import watchtower
import logging
from time import strftime

# Configuring Logger to Use CloudWatch
LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.DEBUG)
console_handler = logging.StreamHandler()
cw_handler = watchtower.CloudWatchLogHandler(log_group='cruddur')
LOGGER.addHandler(console_handler)
LOGGER.addHandler(cw_handler)
LOGGER.info("test log")
```


```
@app.after_request
def after_request(response):
    timestamp = strftime('[%Y-%b-%d %H:%M]')
    LOGGER.error('%s %s %s %s %s %s', timestamp, request.remote_addr, request.method, request.scheme, request.full_path, response.status)
    return response
```

add code to the requirements.text on the backend-flask folder
```
opentelemetry-instrumentation-requests
```

add this on home_activities.py
```
LOGGER.info("HomeActivities")

```

from the docker-compose.yml, add the following code for the env variables

```
AWS_DEFAULT_REGION: "${AWS_DEFAULT_REGION}"
AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"
```

## Install Xray

 check the env var for the AWS region using the following command
 ```
 env | grep AWS_REGION
 ```

 If there is no result
 ```
export AWS_REGION="ca-central-1"
gp env AWS_REGION="ca-central-1"

 ```

from the backend-flask requirements.text, insert the following
```
aws-xray-sdk
```

install the dependency. this will necessary just this time as it will be run via docker compose
```
pip install -r requirements.txt
```

Insert the following code inside the app.py

```
# Xray
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.ext.flask.middleware import XRayMiddleware
```
```
# Xray
xray_url = os.getenv("AWS_XRAY_URL")
xray_recorder.configure(service='backend-flask', dynamic_naming=xray_url)
```

Create xray.json inside the folder of /aws/json/ and insert the following code

```
{
    "SamplingRule": {
        "RuleName": "Cruddur",
        "ResourceARN": "*",
        "Priority": 9000,
        "FixedRate": 0.1,
        "ReservoirSize": 5,
        "ServiceName": "backend-flask",
        "ServiceType": "*",
        "Host": "*",
        "HTTPMethod": "*",
        "URLPath": "*",
        "Version": 1
    }
  }
```

launch the following command from to create the group on xray from the backend-flask folder
```
aws xray create-group \
   --group-name "Cruddur" \
   --filter-expression "service(\"backend-flask")"
```

from the main folder type the following command to create the sample rule
```
aws xray create-sampling-rule --cli-input-json file://aws/json/xray.json
```

add this line for the dockercompose.yml
```
AWS_XRAY_URL: "*4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}*"
AWS_XRAY_DAEMON_ADDRESS: "xray-daemon:2000"
```
this code will create the daemon necessary for Xray
```
xray-daemon:
    image: "amazon/aws-xray-daemon"
    environment:
      AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
      AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"
      AWS_REGION: "eu-west-2"
    command:
      - "xray -o -b xray-daemon:2000"
    ports:
      - 2000:2000/udp
```

```
simple_processor = SimpleSpanProcessor(ConsoleSpanExporter())
provider.add_span_processor(simple_processor)
```

```
# xray
XRayMiddleware(app, xray_recorder)
```

## Install Rollbar

 Create a new project on Rollbar

 add this code on requirements.text
```
blinker
rollbar
```

install the dependency. this will necessary just this time as it will be run via docker composesimple_processor

```
pip install -r requirements.txt
```

create the env var, this will necessary just for this time
```
export ROLLBAR_ACCESS_TOKEN=""
gp env ROLLBAR_ACCESS_TOKEN=""
```

Add to backend-flask for docker-compose.yml
```
ROLLBAR_ACCESS_TOKEN: "${ROLLBAR_ACCESS_TOKEN}"
```

insert the following code to the backend-flask/app.py
```
import rollbar
import rollbar.contrib.flask
from flask import got_request_exception
```
```
# Rollbar
rollbar_access_token = os.getenv('ROLLBAR_ACCESS_TOKEN')
@app.before_first_request
def init_rollbar():
    """init rollbar module"""
    rollbar.init(
        # access token
        rollbar_access_token,
        # environment name
        'production',
        # server root directory, makes tracebacks prettier
        root=os.path.dirname(os.path.realpath(__file__)),
        # flask already sets up logging
        allow_logging_basic_config=False)

    # send exceptions from `app` to rollbar, using flask's signal system.
    got_request_exception.connect(rollbar.contrib.flask.report_exception, app)

@app.route('/rollbar/test')
def rollbar_test():
    rollbar.report_message('Hello World!', 'warning')
    return "Hello World!"
```

### Tools to troubleshooting
https://honeycomb-whoami.glitch.me/
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


### Tools to troubleshooting
https://honeycomb-whoami.glitch.me/
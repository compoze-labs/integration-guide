# Operations

Designing and building a series of Flows is one thing, ensuring that they are running smoothly is another. Compoze's monitoring platform is built in order to ensure that everything is running smoothly, and in the event something goes wrong, that the issue is found and corrected with an emphasis on minimizing business impact. In order to do this, the Compoze Monitoring Platform works with the following areas: Logging, Tracing, Metrics & Monitoring Dashboards, and Alerting.

## Definitions

### Alerting

Alerts are the mechanisms used to notify the team that something is going wrong with the system. Common forms of alerts are sms, email, and slack. The key to good alerts is to reduce the noise, by only alerting on critical issues that must be address immediately.

### Monitoring Dashboards

Metrics & Monitoring dashboards are where the team goes to understand what part of the system is malfunctioning.

### Metrics

While the Dashboard is responsible for the display of this data, Metrics are the data that is displayed. There are two types: Application and System level metrics. An application level metric is data that represents events happening in the system. For example, number of orders processes in the last hour, or number of invoices that have failed to create. Application level metrics, in AWS, are general [Custom Metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/publishingMetrics.html), meaning the developer must configure and publish them explicitly. System level metrics are low level metrics that monitor the system itself, for example, Queue depth, CPU usage, Memory usage, etc. AWS publishes these metrics by default, and therefore you can configure Alerts and Dashboards without needing to publish them explicitly.  The Application level metrics tell you what part of the system is failing, while System level metrics give you insight into why that part of the system is failing

### Logging

Logging is the lowest level of operational concerns. Logging gives insight into what exactly is happening for a given part of the system.

### Tracing

Tracing is used to visualize how data is moving through the system. For example, a tracing dashboard of a flow, will show what Actions are taken after a given Trigger.

Compoze uses these operational aspects to as part of their support workflow. Below is an example of an example troubleshooting workflow for invoicing system Flow

![workflow](img/workflow.png)

## How & when to implement

A Compoze integration project has 5 main types of components.

1. Web Portal
2. HTTP API
3. Event API
4. Queue
5. Database

Each of these must have System level metrics configured, where as Web Portal, HTTP API, and Event API should also have Application level metrics configured. Below is a detailed walkthrough of "sane" defaults for metrics.

## HTTP API

An http-based API can be neatly defined by the number of operations. An operation is defined as an HTTP Verb + a resource. For example, **POST /customer** & **GET /customers**. Each operation should have *some* metrics defined at the Application & System level. In addition, there are system level metrics that should be present at the overall API level.

### Operation System Metrics

HTTP based APIs have the benefit of adhering the HTTP spec. This means that we can easily collect data about the overall status codes that are being produced. Sane defaults should include:

1. Number of 4XX Level Status Codes: These will give you insight into issues when downstream clients are calling the operation incorrectly
2. Number of 5XX Level Status Codes: These will give you insight into issues with the operation itself is failing
3. Number of 2XX Level Status Codes: These will give you insight into the rate at which your API is being called
4. 90, 95, & 99 percentile of response time: These will give you insight into the overall performance of your api

### Operation Application Metrics

Application metrics are, as the name implies, depending on the operation and it's context within the overall application. For a given operation, it is somewhat context depend on whether or not you need to publish them. There are some rules of thumb you can use.

GET operations, generally, are for retrieval of data. If a GET operation follows that convention, a system level metric (such as number of 2XX response codes) is often good enough to be able to ask the question "how many customer lookups happen in the last 10 minutes".

POST operations, generally, are more transactional in nature. Let's take an example, where, a POST operation needs to check if a customer exists, if it does not create it, and then create an invoice. In this situation, a 2XX or 5XX response code only tells us that the overall transaction succeeded or failed. However, how do we know whether it was the customer creation that failed, or the creation of an invoice? In this case, we would recommend the following custom metrics:

Succuss:

1. Created customer
2. Created invoice

With these metrics, we will be able to know exactly how many operations resulted in creation of customers.

Failure:

1. Create customer failed
2. Create invocie failed.

With these metrics in place, we can be sure we know exactly what caused the failure of the operation.

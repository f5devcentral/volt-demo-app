# volt-demo-app

## About the repository

This repository creates a self-contained application running on Volterra Regional Edges
along with load generation pods. This allows for VoltConsole dashboards to be populated with 
realistic data in order to demonstrate key Volterra concepts (traffic and application visualizations, 
HTTP request telemetry, security event monitoring, virtual kubernetes abstraction, etc.).

## About the application

The demo application is v0.1.2 of the [GCP microservices demo](https://github.com/GoogleCloudPlatform/microservices-demo).
The app consists of 11 microservices that talk to each other over gRPC.

![demo arch](https://github.com/GoogleCloudPlatform/microservices-demo/blob/master/docs/img/architecture-diagram.png)

## About the architecture

The demo application's microservices are distributed across multiple [virtual sites](https://www.volterra.io/docs/ves-concepts/volterra-site#virtual-site).
Internet traffic ingresses through the nearest Volterra POP via an [HTTP loadbalancer](https://www.volterra.io/docs/how-to/app-networking/http-load-balancer). 
Traffic is routed to the "frontend" microservice which is running the "main" virtual site.


The "main" virtual site consists of 2 Regional Edges (the specific REs depend on the tenant/deployment). 
The "frontend" microservice routes to various secondary microservices in the same virtual site as needed.


The demo application keeps state in a redis database running in the second "state" virtual site.
The state service is presented to the other microservices through a [TCP loadbalancer](https://www.volterra.io/docs/how-to/app-networking/tcp-load-balancer).
![Home Assignments](https://github.com/maxaviberman/misc/blob/58ec260d51915b3c2a683f4498324456762b6bc6/Home%20Assignment.png)
# High Level Design
![High Level Diagarm](https://github.com/maxaviberman/misc/blob/58ec260d51915b3c2a683f4498324456762b6bc6/HighLevel.PNG)
1. Loadbalancer - AWS Application Load Balancer
2. Backend - Apache Server runs on ECS (Fragate), minimal of 2 instances
```
The Apache Server forwards logs to ES via awsfirelens
```
3. Elastic Cloud - ElesticSearch and Kiban
## Application LoadBalancer
![Application Loadbalancer](https://github.com/maxaviberman/misc/blob/58ec260d51915b3c2a683f4498324456762b6bc6/ALB.PNG)
The ALB is setup with two rules:
1. "/" path to be routed to one of the Apache servers
2. "/kibana/" path to be re-direct to Kibana

## Automatic Deployment
I'm using [Terraform](https://www.terraform.io/) to deploy on the AWS Cloud

##
[Elastic Cloud](https://maxaviberman.kb.us-central1.gcp.cloud.es.io:9243/)
User: operator
Pass: operator

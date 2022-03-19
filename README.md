# Bluevine
** Welcome to the home assignment for the DevOps engineer position at BlueVine
** This assignment purpose is to test your technical approach and attitude
> 1. Create a simple web application with the following components:
>  a. Backend - could be created using any high level language of your choice
* Apache httpd 2.4
>  b. Proxy / Load balancer - a simple router to serve requests to the backend
>     service, you may choose any solution to create it such as Nginx, Apache2, etc….
* AWS ALB
> 2. The Backend service should return a simple page with “Hello world!“ in it upon receiving requests on the root page
> 3. Deploy partial Elastic ( Free and Open Search: The Creators of Elasticsearch, ELK & Kibana | Elastic) stack deployment with:
* I'm using the Elastic Cloud Service
>  a. Elasticsearch (Database)
>  b. Kibana (Dashboard)
> 4. The Proxy / Load balancer will redirect the traffic by the following:
>  a. http://yourdomain/ → point to your application (backend)
* [my page](http://mberman.co.uk/)
>  b. http://yourdomain/kibana/ → point to the Kibana service
* [Kibana](http://mberman.co.uk/kibana/)
> 5. Send the application (backend) logs to Elasticsearch in a way of your choice
* my HTTPd docker is fwd the logs directly to the elasticsearch end point over tls
> 6. Discover the logs with Kibana
* Kibana Customization -
*  The logstash index is nice but ... it is better to use the Apache Access Log template. 
*  The ELK identifies and extarcts the apache access logs using a template and creates a DATA Stream.
*  You now go to "Kibana" -> "Data view" and add the logs-apache-access* as a view, and that will allow you to "discover" the Apache access logs with out the extra metadata provided as part of the logstash, ecs and etc.
> 7. Create a public repository (on Github/Gitlab…etc) , push you solution/code to it.
> TIPS:
> ● You can send logs with code or with 3 party application
> ● You can use any infrastructure to your solution
(docker,compose,kubrenetes…etc)
> ●
> Good luck!

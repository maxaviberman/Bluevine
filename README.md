# Bluevine
Welcome to the home assignment for the DevOps engineer position at BlueVine
This assignment purpose is to test your technical approach and attitude
1. Create a simple web application with the following components:
a. Backend - could be created using any high level language of your choice
b. Proxy / Load balancer - a simple router to serve requests to the backend
service, you may choose any solution to create it such as Nginx, Apache2
, etc….
2. The Backend service should return a simple page with “Hello world!“ in it upon
receiving requests on the root page
3. Deploy partial Elastic ( Free and Open Search: The Creators of Elasticsearch,
ELK & Kibana | Elastic) stack deployment with:
a. Elasticsearch (Database)
b. Kibana (Dashboard)
4. The Proxy / Load balancer will redirect the traffic by the following:
a. http://yourdomain/ → point to your application (backend)
b. http://yourdomain/kibana/ → point to the Kibana service
5. Send the application (backend) logs to Elasticsearch in a way of your choice
6. Discover the logs with Kibana
7. Create a public repository (on Github/Gitlab…etc) , push you solution/code to it.
TIPS:
● You can send logs with code or with 3 party application
● You can use any infrastructure to your solution
(docker,compose,kubrenetes…etc)
●
Good luck!

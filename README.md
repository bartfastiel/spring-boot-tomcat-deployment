# spring-boot-tomcat-deployment

Example project to deploy a spring boot application into a tomcat instance

## setup empty AWS EC2 instance

* create a new EC2 instance
* create/reuse a new security group with TPC port 8080 open
* create a new key pair and download the private key
* connect to the instance via SSH

```bash
curl -s https://raw.githubusercontent.com/bartfastiel/spring-boot-tomcat-deployment/main/provisioning.sh | bash -s
```

Afterwards:
```bash
curl --user admin:s3cret --upload-file backend-0.0.1-SNAPSHOT.war "http://ec2-16-171-61-147.eu-north-1.compute.amazonaws.com:8080/manager/text/deploy?path=/myapp" -v
```

🚀 The app is deployed to http://ec2-16-171-61-147.eu-north-1.compute.amazonaws.com:8080/myapp/

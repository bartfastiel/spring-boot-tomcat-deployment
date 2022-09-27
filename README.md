# spring-boot-tomcat-deployment

Example project to deploy a spring boot application into a tomcat instance

## setup empty AWS EC2 instance

* create a new EC2 instance
* create/reuse a new security group with TPC port 8080 open
* create a new key pair and download the private key
* connect to the instance via SSH

```bash
# download java and tomcat
wget -c https://download.oracle.com/java/19/latest/jdk-19_linux-x64_bin.tar.gz -O - | tar -xz
wget -c https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.67/bin/apache-tomcat-9.0.67.tar.gz -O - | tar -xz

# define user and password for tomcat-api-access
cat >apache-tomcat-9.0.67/conf/tomcat-users.xml <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd" version="1.0">
  <user username="admin" password="s3cret" roles="manager-gui"/>
</tomcat-users>
EOL

# enable tomcat-api-access from outside
cat >apache-tomcat-9.0.67/webapps/manager/META-INF/context.xml <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" >
  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
                   sameSiteCookies="strict" />
  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
</Context>
EOL

# restart tomcat
JAVA_HOME=`pwd`/jdk-19
apache-tomcat-9.0.67/bin/shutdown.sh
apache-tomcat-9.0.67/bin/startup.sh
tail -f apache-tomcat-9.0.67/logs/*

```

Afterwards:
```bash
curl --user admin:s3cret --upload-file backend-0.0.1-SNAPSHOT.war "http://ec2-16-171-61-147.eu-north-1.compute.amazonaws.com:8080/manager/text/deploy?path=/myapp" -v
```

🚀 The app is deployed to http://ec2-16-171-61-147.eu-north-1.compute.amazonaws.com:8080/myapp/

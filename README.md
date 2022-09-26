# spring-boot-tomcat-deployment

Example project to deploy a spring boot application into a tomcat instance

## setup empty AWS EC2 instance

* create a new EC2 instance
* create a new security group with port 22 open for SSH
* create a new key pair and download the private key
* connect to the instance via SSH

```bash
sudo su -
wget -c https://download.oracle.com/java/19/latest/jdk-19_linux-x64_bin.tar.gz -O - | tar -xz
wget -c https://downloads.apache.org/tomcat/tomcat-9/v9.0.65/bin/apache-tomcat-9.0.65.tar.gz -O - | tar -xz

cat >apache-tomcat-9.0.65/conf/tomcat-users.xml <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd" version="1.0">
  <user username="admin" password="s3cret" roles="manager-gui"/>
</tomcat-users>
EOL

cat >apache-tomcat-9.0.65/webapps/manager/META-INF/context.xml <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" >
  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
                   sameSiteCookies="strict" />
  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
</Context>
EOL

# sed -i "s/8080/80/" apache-tomcat-9.0.65/conf/server.xml

export JAVA_HOME=/root/jdk-19
apache-tomcat-9.0.65/bin/shutdown.sh
apache-tomcat-9.0.65/bin/startup.sh
tail -f apache-tomcat-9.0.65/logs/*

```

http://ec2-13-50-100-206.eu-north-1.compute.amazonaws.com:8080/


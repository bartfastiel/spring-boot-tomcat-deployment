export TOMCAT_USER=admin
export TOMCAT_PWD=`openssl rand -base64 12`
export INSTALLATION_DIR=/opt/webserver

# download java and tomcat
sudo mkdir /opt/webserver
sudo chown -R $USER:$USER $INSTALLATION_DIR
wget -c https://download.oracle.com/java/19/latest/jdk-19_linux-x64_bin.tar.gz -O - | tar -xz --directory $INSTALLATION_DIR
wget -c https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.67/bin/apache-tomcat-9.0.67.tar.gz -O - | tar -xz  --directory $INSTALLATION_DIR

export JAVA_HOME=$INSTALLATION_DIR/jdk-19
export TOMCAT_HOME=$INSTALLATION_DIR/apache-tomcat-9.0.67

# define user and password for tomcat-api-access
cat >$TOMCAT_HOME/conf/tomcat-users.xml <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd" version="1.0">
  <user username="$TOMCAT_USER" password="$TOMCAT_PWD" roles="manager-gui,manager-script"/>
</tomcat-users>
EOL

# enable tomcat-api-access from outside
cat >$TOMCAT_HOME/webapps/manager/META-INF/context.xml <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" >
  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
                   sameSiteCookies="strict" />
  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
</Context>
EOL

# redirect port 8080 to port 80 (both locally and for remote requests)
sudo iptables -t nat -p tcp --dport 80 -j REDIRECT --to-ports 8080 -I OUTPUT -d 127.0.0.1
sudo iptables -t nat -p tcp --dport 80 -j REDIRECT --to-ports 8080 -I PREROUTING

# restart tomcat
$TOMCAT_HOME/bin/startup.sh

printf "\n\n\nPlease use these credential to use the tomcat manager app:\nUsername: $TOMCAT_USER\nPassword: $TOMCAT_PWD\n\n\n"
read -p "Press any key to resume ..."

tail -f $TOMCAT_HOME/logs/*

# Use Tomcat 9 with JDK 17 as the base image
FROM tomcat:9.0-jdk17-openjdk-slim

# Remove the default Tomcat web apps to keep it clean
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your WAR file into the Tomcat webapps directory
# Based on your pom.xml, the artifact is 'NETFLIX' and version is '1.2.3'
COPY target/NETFLIX-1.2.3.war /usr/local/tomcat/webapps/ROOT.war

# Expose the default Tomcat port
EXPOSE 8080

CMD ["catalina.sh", "run"]

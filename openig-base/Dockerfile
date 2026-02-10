FROM tomcat:9-jdk11-openjdk

# Install curl for healthchecks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/tomcat

# Clean default apps
RUN rm -rf webapps/*

# Copy OpenIG WAR
COPY OpenIG.war webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
# Pull tomcat image from dockerhub
FROM tomcat
#Rename the webapps
WORKDIR /usr/local/tomcat/
RUN mv webapps webapps2
RUN mv webapps.dist webapps
# Maintainer
LABEL MAINTAINER = sundaylawal
# copy war file on to container
COPY $WORKSPACE/target/spring-petclinic-2.4.2.war /usr/local/tomcat/webapps
EXPOSE 8080
WORKDIR /usr/local/tomcat/webapps
ENTRYPOINT ["java", "-jar", "spring-petclinic-2.4.2.war"]

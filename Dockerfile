# Pull tomcat image from dockerhub
FROM tomcat
#Rename the webapps
WORKDIR /usr/local/tomcat/
RUN mv webapps webapps2
RUN mv webapps.dist webapps
# Maintainer
LABEL MAINTAINER = sundaylawal


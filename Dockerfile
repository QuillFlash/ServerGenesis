FROM debian
RUN apt-get update && apt-get -y upgrade && apt-get -y install apt-utils dialog
EXPOSE 22
EXPOSE 80
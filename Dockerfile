#Declare CentOS the latest
FROM centos

Maintainer Andrew J Krug

# UPDATE
RUN yum -y update

# INSTALL packages 
RUN yum -y install wget
RUN yum -y install tar
RUN yum -y install epel-release
RUN yum -y install pwgen

#Install Puppet
RUN yum -y install mysql-connector-java

ENV TOMCAT_VERSION 7.0.55
ENV CATALINA_HOME /opt/tomcat

# INSTALL TOMCAT
RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-7/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/catalina.tar.gz

# UNPACK
RUN tar xzf /tmp/catalina.tar.gz -C /opt
RUN ln -s /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat
RUN rm /tmp/catalina.tar.gz

# REMOVE APPS 
RUN rm -rf /opt/tomcat/webapps/examples /opt/tomcat/webapps/docs 

# SET CATALINE_HOME and PATH 
ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin

#SET FEDORA HOME
ENV FEDORA_HOME /opt/fedoracommons

#Randomize the TC Admin and write to container log
ADD create_tomcat_admin_user.sh /create_tomcat_admin_user.sh

ADD ./configuration/fedoracommons /root/fedoracommons

RUN adduser fcadmin

RUN mkdir -p /opt/fedoracommons

RUN mv /root/fedoracommons/files/fedora.sh /etc/profile.d/fedora.sh

RUN mv /root/fedoracommons/files/install.properties /home/fcadmin/install.properties

RUN mv /root/fedoracommons/files/fcrepo-installer-3.6.2.jar /home/fcadmin/

#RUN /bin/ln -s /usr/share/java/mysql-connector-java.jar $CATALINA_HOME/common/lib/mysql-connector-java-5.1.6.jar

RUN /usr/bin/java -jar /home/fcadmin/fcrepo-installer-3.6.2.jar /home/fcadmin/install.properties

RUN chmod 766 -R /opt/fedoracommons

EXPOSE 8080
EXPOSE 8443

ADD run.sh /run.sh
RUN chmod +x /*.sh

VOLUME ["/opt/fedoracommons"]

CMD ["/run.sh"]


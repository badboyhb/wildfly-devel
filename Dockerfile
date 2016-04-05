# Version 0.0.1

FROM jboss/wildfly

MAINTAINER HuBo <hubo@21cn.com>

RUN /opt/jboss/wildfly/bin/add-user.sh admin jboss --silent

USER root

RUN yum update -y && yum -y install openssh-server && yum clean all \
	&& ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
	&& ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
	&& ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key \
	&& echo "root:jboss" | chpasswd

ENV MYSQL_CONNECTOR mysql-connector-java-5.1.38

RUN curl -LO http://dev.mysql.com/get/Downloads/Connector-J/$MYSQL_CONNECTOR.tar.gz \
	&& tar xf $MYSQL_CONNECTOR.tar.gz \
	&& mkdir -p /opt/jboss/wildfly/modules/com/mysql/main \
	&& mv $MYSQL_CONNECTOR/$MYSQL_CONNECTOR-bin.jar /opt/jboss/wildfly/modules/com/mysql/main/ \
	&& rm -rf $MYSQL_CONNECTOR.tar.gz \
	&& rm -rf $MYSQL_CONNECTOR

RUN echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n" \
	"<module xmlns=\"urn:jboss:module:1.3\" name=\"com.mysql\">\n" \
	"\t<resources>\n" \
	"\t\t<resource-root path=\"$MYSQL_CONNECTOR-bin.jar\"/>\n" \
	"\t</resources>\n" \
	"\t<dependencies>\n" \
	"\t\t<module name=\"javax.api\"/>\n" \
	"\t\t<module name=\"javax.transaction.api\"/>\n" \
	"\t</dependencies>\n" \
	"</module>" \
	> /opt/jboss/wildfly/modules/com/mysql/main/module.xml \
	&& echo -e "\t\t\t<driver name=\"mysql\" module=\"com.mysql\">\n" \
	"\t\t\t\t<driver-class>com.mysql.jdbc.Driver</driver-class>\n" \
	"\t\t\t\t<xa-datasource-class>com.mysql.jdbc.jdbc2.optional.MysqlXADataSource</xa-datasource-class>\n" \
    "\t\t\t</driver>" \
    > mysql.driver \
    && sed -i '/<drivers>/r mysql.driver' \
    /opt/jboss/wildfly/standalone/configuration/standalone.xml \
    && rm mysql.driver

VOLUME /opt/jboss/wildfly/standalone/deployments

EXPOSE 22
EXPOSE 9990

CMD /usr/sbin/sshd -D

# Version 0.0.2

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
ENV JBOSS_CLI /opt/jboss/wildfly/bin/jboss-cli.sh -c

RUN curl -LO http://dev.mysql.com/get/Downloads/Connector-J/$MYSQL_CONNECTOR.tar.gz \
	&& tar xf $MYSQL_CONNECTOR.tar.gz

RUN /opt/jboss/wildfly/bin/standalone.sh --admin-only & \
	yum update -y \
	&& $JBOSS_CLI "module add --name=com.mysql --resources=$MYSQL_CONNECTOR/$MYSQL_CONNECTOR-bin.jar --dependencies=javax.api\,javax.transaction.api" \
	&& $JBOSS_CLI "/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql,driver-xa-datasource-class-name=com.mysql.jdbc.jdbc2.optional.MysqlXADataSource)" \
	&& $JBOSS_CLI command=:shutdown \
	&& rm -rf $MYSQL_CONNECTOR.tar.gz \
	&& rm -rf $MYSQL_CONNECTOR


VOLUME /opt/jboss/wildfly/standalone/deployments

EXPOSE 22
EXPOSE 9990

CMD /usr/sbin/sshd -D

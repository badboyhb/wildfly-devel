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

VOLUME /opt/jboss/wildfly/standalone/deployments

EXPOSE 22
EXPOSE 9990

CMD /usr/sbin/sshd -D

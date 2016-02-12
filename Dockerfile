FROM centos:7

# Jenkins will be running on a Mesos cluster, add mesos libs in addition to the usual packages
RUN rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-2.noarch.rpm && \
	curl http://pkg.jenkins-ci.org/redhat/jenkins.repo > /etc/yum.repos.d/jenkins.repo && \
	rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key && \
	yum -y install java-1.8.0-openjdk jenkins git mesos && \
	yum -y update && \
	yum clean all

# For the main web interface
EXPOSE 8080

# Used by build workers
EXPOSE 50000

ENV JENKINS_HOME=/var/lib/jenkins

COPY run-jenkins.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-jenkins.sh

ENTRYPOINT [ "/usr/local/bin/run-jenkins.sh" ]
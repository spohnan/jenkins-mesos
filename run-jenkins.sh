#!/usr/bin/env bash

# The NodeProvisioner settings influence the algorithm used to spin up new worker nodes.
# Defaults are weighted to the EC2 use-case to not spin up new instances conservatively
# The settings below are fairly aggressive as mentioned above we plan to use containers within Mesos
# https://cloudbees.zendesk.com/hc/en-us/articles/204690520-Why-do-slaves-show-as-suspended-while-jobs-wait-in-the-queue-
USE_DEFAULTS="-Dhudson.slaves.NodeProvisioner.MARGIN=40 -Dhudson.slaves.NodeProvisioner.MARGIN0=0.75 -Xms512m -Xmx2g -Djava.awt.headless=true -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/New_York"
JENKINS_JAVA_OPTIONS=${JENKINS_JAVA_OPTIONS-$USE_DEFAULTS}

java "${JENKINS_JAVA_OPTIONS}" -jar /usr/lib/jenkins/jenkins.war

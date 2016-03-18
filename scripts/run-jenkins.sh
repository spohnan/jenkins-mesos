#!/usr/bin/env bash

# Other scripts are in the same directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# The NodeProvisioner settings influence the algorithm used to spin up new worker nodes.
# Defaults are weighted to the EC2 use-case to not spin up new instances conservatively
# The settings below are fairly aggressive as mentioned above we plan to use containers within Mesos
# https://cloudbees.zendesk.com/hc/en-us/articles/204690520-Why-do-slaves-show-as-suspended-while-jobs-wait-in-the-queue-
USE_DEFAULTS="-Dhudson.slaves.NodeProvisioner.MARGIN=40 -Dhudson.slaves.NodeProvisioner.MARGIN0=0.75 -Xms512m -Xmx2g -Djava.awt.headless=true -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/New_York"
JENKINS_JAVA_OPTIONS=${JENKINS_JAVA_OPTIONS-$USE_DEFAULTS}
JENKINS_CMDLINE_OPTIONS=${JENKINS_CMDLINE_OPTIONS-}

# Ensure config is up to date and start Jenkins
$SCRIPT_DIR/bootstrap.py && \
$SCRIPT_DIR/init-plugins.sh && \
java "${JENKINS_JAVA_OPTIONS}" -jar /usr/lib/jenkins/jenkins.war "${JENKINS_CMDLINE_OPTIONS}"

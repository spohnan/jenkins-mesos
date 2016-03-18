#!/usr/bin/env python2
"""
Reconfigures a Jenkins master running in Docker at container runtime.
"""

from __future__ import print_function
import os
import shutil
import sys
import xml.etree.ElementTree as ET


def is_firstrun(jenkins_home_dir):
    """A small helper utility to determine if this is the first run of this
    bootstrap script. Checks to see if the 'jenkins_home_dir' directory
    is empty, or if it contains existing data.

    :param jenkins_home_dir: the path to $JENKINS_HOME on disk
    :return: boolean; True if $JENKINS_HOME isn't populated, false otherwise
    """
    return not os.path.isdir(os.path.join(jenkins_home_dir, 'plugins'))


def populate_jenkins_config_xml(config_xml, master, name, host, port):
    """Modifies a Jenkins master's 'config.xml' at runtime. Essentially, this
    replaces certain configuration options of the Mesos plugin, such as the
    framework name and the Jenkins URL that agents use to connect back to the
    master.

    :param config_xml: the path to Jenkins' 'config.xml' file
    :param name: the name of the framework, e.g. 'jenkins'
    :param host: the Mesos agent the task is running on
    :param port: the Mesos port the task is running on
    """
    tree = ET.parse(config_xml)
    root = tree.getroot()
    mesos = root.find('./clouds/org.jenkinsci.plugins.mesos.MesosCloud')

    mesos_master = mesos.find('./master')
    mesos_master.text = master

    mesos_frameworkName = mesos.find('./frameworkName')
    mesos_frameworkName.text = name

    mesos_jenkinsURL = mesos.find('./jenkinsURL')
    mesos_jenkinsURL.text = ''.join(['http://', host, ':', port])

    tree.write(config_xml)


def main():
    try:
        jenkins_home_dir = os.environ['JENKINS_HOME']
        jenkins_framework_name = os.environ['JENKINS_FRAMEWORK_NAME']
        marathon_host = os.environ['HOST']
        marathon_jenkins_port = os.environ['JENKINS_PORT']
        mesos_master = os.environ['JENKINS_MESOS_MASTER']
    except KeyError:
        print("ERROR: missing one or more required environment variables.")
        return 1

    if not is_firstrun(jenkins_home_dir):
        return 0

    shutil.copyfile(
        '/usr/local/src/jenkins-config.xml',
        os.path.join(jenkins_home_dir, 'config.xml'))

    populate_jenkins_config_xml(
        os.path.join(jenkins_home_dir, 'config.xml'),
        mesos_master,
        jenkins_framework_name,
        marathon_host, marathon_jenkins_port)

if __name__ == '__main__':
    sys.exit(main())

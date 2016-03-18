#!/usr/bin/env bash

JENKINS_PLUGINS_DIR="${JENKINS_PLUGINS_DIR-$JENKINS_HOME/plugins}"

# Jenkins plugins are specified here, following the format "pluginname/version"
JENKINS_PLUGINS=(
    "ace-editor/1.1"
    "ansicolor/0.4.2"
    "branch-api/1.4"
    "cloudbees-folder/5.4"
    "durable-task/1.8"
    "git/2.4.2"
    "git-client/1.19.6"
    "git-server/1.6"
    "greenballs/1.15"
    "jobConfigHistory/2.12"
    "jquery-detached/1.2.1"
    "mesos/0.11.0"
    "saferestart/0.3"
    "workflow-aggregator/1.15"
    "workflow-api/1.15"
    "workflow-cps/1.15"
    "workflow-job/1.15"
    "workflow-basic-steps/1.15"
    "workflow-cps-global-lib/1.15"
    "workflow-step-api/1.15"
    "workflow-support/1.15"
    "workflow-scm-step/1.15"
    "workflow-durable-task-step/1.15"
)

# Create $JENKINS_PLUGINS_DIR if it doesn't exist
if [ ! -d "$JENKINS_PLUGINS_DIR" ]; then
    mkdir -p "$JENKINS_PLUGINS_DIR"
fi

# If the first plugin is already present in the download directory we're not going to re-download
if [ -f "${JENKINS_PLUGINS_DIR}/${JENKINS_PLUGINS[0]%/*}.hpi" ]; then
    exit
fi

# Get the download information
JENKINS_PLUGINS_MIRROR="${JENKINS_PLUGINS_MIRROR-https://updates.jenkins-ci.org/download/plugins}"
JENKINS_UPDATE_CENTER="${JENKINS_UPDATE_CENTER-https://updates.jenkins-ci.org/update-center.json}"
JENKINS_UPDATE_CENTER_JSON=$(curl -sL $JENKINS_UPDATE_CENTER | sed '1d;$d')

# Check to see if there are updates available
function check_for_update {
    plugin_name=$1
    plugin_ver=$2

    latest_plugin_ver=$(echo $JENKINS_UPDATE_CENTER_JSON | jq -r ".plugins | .[\"${plugin_name}\"] | .version")
    if [[ $plugin_ver == $latest_plugin_ver ]]; then
        echo "${plugin_name} is up to date."
    else
        echo "WARNING: ${plugin_name} is not up to date. Pinned version: ${plugin_ver}. Latest version: ${latest_plugin_ver}"
    fi
}

# Download each of the plugins specified in $JENKINS_PLUGINS
for plugin in ${JENKINS_PLUGINS[@]}; do
    IFS='/' read -a plugin_info <<< "${plugin}"
    plugin_name=${plugin_info[0]}
    plugin_ver=${plugin_info[1]}

    plugin_remote_path="${plugin_name}/${plugin_ver}/${plugin_name}.hpi"
    plugin_local_path="${JENKINS_PLUGINS_DIR}/${plugin_name}.hpi"

    echo "Downloading ${plugin_name} ${plugin_ver} ..."
    check_for_update $plugin_name $plugin_ver
    curl -fSL "${JENKINS_PLUGINS_MIRROR}/${plugin_remote_path}" -o $plugin_local_path 2> /dev/null

    # All Jenkins .hpi/.jpi files are actually Zip files. Let's check their
    # integrity during the build process so we dont have any surprises at
    # container run time.
    zip --test $plugin_local_path

    echo
done

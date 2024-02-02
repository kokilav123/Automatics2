#!/bin/bash
##########################################################################
# If not stated otherwise in this file or this component's LICENSE
# file the following copyright and licenses apply:
#
# Copyright 2022 RDK Management
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

#Checking whether docker is already installed in the VM
if [[ $(which docker) && $(docker --version) ]]; then
    echo "Update docker"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
  else
    echo "Install docker"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
fi

echo -e "\n\n<-------------Docker Installtion Path-------------->"
which docker
echo -e "\n\n<-------------Docker Version-------------->"
docker --version

# Getting user name to add in the docker user group so that
# sudo command is not required for this corresponding user to 
# execute docker commands
echo -e "\n\nEnter the VM user who require the premission to run docker commands without sudo : "
read user

# creating new User group "docker" if there is an input received from user
if [ -z "$user" ]
then
      echo -e "\033[0;31mNo input received from \$user !!! Skipping docker group creation and user addition\033[0m"
else
	if [ $(getent group docker) ]; then
	  echo "Going to add ${user} to the user group Docker"
	  usermod -aG docker ${user}
	  echo "Added ${user} to the user group"
	  #newgrp docker
      echo -e "Successfully created usergroup docker and added $user to it !! \n\033[0;31mRestart of the VM is needed for this change to take effect\033[0m"
    else
	  groupadd docker
	  usermod -aG docker ${user}
	  #newgrp docker
      echo -e "Successfully created usergroup docker and added $user to it !! \n\033[0;31mRestart of the VM is needed for this change to take effect\033[0m"
    fi
fi

#Configuring Docker to start on boot
systemctl enable docker.service
systemctl enable containerd.service

#Getting jenkins docker image from docker hub and building custom Jenkins docker image for automatics
docker build -f ./jenkinsDockerFile -t automatics_jenkins:jdk17 . || handle_error

echo -e "\n\nSuccesfully built Automatics Jenkins Docker image"

mkdir -p /mnt/automatics/maven/maven-repo
mkdir -p /mnt/automatics/jenkins_home

chmod -R 777 /mnt/automatics

echo -e "\n\nEnter the port in which Jenkins server to be started : "
read port

# Check if the network exists
if docker network ls | grep -q "jenkins"; then
  echo "Network jenkins already exists"
else
  # Create the network
  docker network create jenkins
fi

#Starting the jenkins docker conatiner
docker run --name automatics_jenkins --restart=on-failure --detach \
  --network jenkins --publish ${port}:8080 --publish 50000:50000 \
  --volume /mnt/automatics/jenkins_home:/var/jenkins_home \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume jenkins-docker-certs:/certs/client:ro \
  -e JAVA_OPTS="-Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true -Dhudson.model.DirectoryBrowserSupport.CSP=" \
  automatics_jenkins:jdk17 || handle_error
  

echo -e "\n\nSuccesfully Started Automatics Jenkins Docker Conatiner"
echo -e "Jenkins server is started in port \033[0;31m${port}\033[0m"

#Creating the required jobs in jenkins
docker cp jobs/. automatics_jenkins:/var/jenkins_home/jobs/ || handle_error

echo -e "\033[0;31mJENKINS Docker Container Going for a Restart\033[0m"
docker restart automatics_jenkins

sleep 30

echo -e "\033[0;32mRestart Completed \033[0m"

#echo -e "\n\nMaven home directory seen in VM : \033[0;31m/mnt/automatics/maven\033[0m"
echo -e "\nMaven home directory inside DOCKER conatiner : \033[0;31m/usr/share/maven\033[0m"
echo -e "\nJenkins home location : \033[0;31m/mnt/automatics/jenkins_home\033[0m"

#Function to handle errors
function handle_error() {
  echo -e "\033[31mAn error occurred.\033[0m"
  echo "Error trace:"
  caller
  exit 1
}
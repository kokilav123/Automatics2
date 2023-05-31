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

echo "$DB_URL"
echo "$DB_USERNAME"
echo "$DOCKER_IMAGE_NAME"

sed -i -e "s|jdbc:mysql:\/\/localhost:3306\/automatics?autoReconnect=true|${DB_URL}|" "$CATALINA_HOME"/AutomaticsConfig/hibernate.cfg.xml

sed -i "/<property name=\"hibernate\.connection\.username\">[^<]*<\/property>/ s/>\([^<]*\)</>$DB_USERNAME</" "$CATALINA_HOME"/AutomaticsConfig/hibernate.cfg.xml

password=$(echo -n "$DB_PASSWORD" | base64)

sed -i "/<property name=\"hibernate\.connection\.password\">[^<]*<\/property>/ s/>\([^<]*\)</>${password//\//\\/}</" "$CATALINA_HOME"/AutomaticsConfig/hibernate.cfg.xml

sed -i 's#<Property name="FILE_NAME">../logs/traces</Property>#<Property name="FILE_NAME">/usr/local/tomcat/logs/traces</Property>#g' "$CATALINA_HOME"/AutomaticsConfig/log4j2-test.xml

mkdir -p "$CATALINA_HOME"/logs/traces/

chmod -R 777 "$CATALINA_HOME"/logs

echo '' > "$CATALINA_HOME"/bin/mainUI.jmd

echo '' > "$CATALINA_HOME"/bin/childUI.jmd

echo '' > "$CATALINA_HOME"/mainUI.jmd

echo '' > "$CATALINA_HOME"/childUI.jmd

chmod 777 "$CATALINA_HOME"/childUI.jmd "$CATALINA_HOME"/mainUI.jmd "$CATALINA_HOME"/bin/childUI.jmd "$CATALINA_HOME"/bin/mainUI.jmd

sh "$CATALINA_HOME"/bin/catalina.sh run

sleep 140

chmod -R 777 "$CATALINA_HOME"/logs

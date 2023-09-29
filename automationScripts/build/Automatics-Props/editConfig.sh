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

echo "$UI_USERNAME"
echo "$AUTOMATICS_PROPS_URL"
echo "$AUTOMATICS_ORCH_URL"
echo "$DEVICE_MANAGER_URL"

PROPS_PASSCODE="${UI_USERNAME}:${UI_PASSWORD}"
password=$(echo -n "$PROPS_PASSCODE" | base64)
echo "$password"

sed -i "/^\s*user\s*=/s/=.*/=${UI_USERNAME}/" "$CATALINA_HOME"/webapps/automatics/config.properties || echo "user=${UI_USERNAME}" >> "$CATALINA_HOME"/webapps/automatics/config.properties

sed -i "/^\s*pwd\s*=/s/=.*/=${UI_PASSWORD}/" "$CATALINA_HOME"/webapps/automatics/config.properties || echo "pwd=${UI_PASSWORD}" >> "$CATALINA_HOME"/webapps/automatics/config.properties

sed -i "/^\s*automatics.properties.passcode\s*=/s/=.*/=${password}/" "$CATALINA_HOME"/webapps/automatics/config.properties || echo "automatics.properties.passcode=${password}" >> "$CATALINA_HOME"/webapps/automatics/config.properties

mkdir -p "$CATALINA_HOME"/logs/traces/

chmod -R 777 "$CATALINA_HOME"/logs

sh "$CATALINA_HOME"/bin/catalina.sh run

sleep 140

chmod -R 777 "$CATALINA_HOME"/logs

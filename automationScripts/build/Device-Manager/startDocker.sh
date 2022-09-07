#!/bin/bash
##########################################################################
# If not stated otherwise in this file or this component's LICENSE
# file the following copyright and licenses apply:
#
# Copyright (c) 2022 Comcast Cable Communications Management, LLC.
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
# Copyright 2022 RDK Management
# Licensed under the Apache License, Version 2.0
##########################################################################

DB_PASSWORD=`echo -n $DB_PASSWORD | base64`

sh $CATALINA_HOME/bin/catalina.sh run

sleep 140

chmod -R 777 $CATALINA_HOME/logs
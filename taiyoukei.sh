#!/usr/bin/env bash

# Copyright (c) HARUYAMA Seigo
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cd `dirname $0`

. bin/_function.sh

TAIYOUKEI_HOME=$PWD

# if no args specified, show usage
if [ $# = 0 ]; then
    echo "Usage: taiyoukei.sh COMMAND"
    echo "where COMMAND is one of:"
    echo "  start    start cluster"
    echo "  stop     stop  cluster"
    exit 1
fi

# load parameters for cluster information
COMMAND=$1
shift

node_list=(`ruby bin/config_parser.rb -l -c conf/taiyoukei.conf.yaml`)

for node in $node_list; do
        host=`expr $node : '^\(.*\):'`
        port=`expr $node : '^.*:\(.*\)$'`
        ssh $host "bash $TAIYOUKEI_HOME/bin/taiyoukei-daemon.sh $COMMAND $host $port" || error "Taiyoukei remote execution failed: $host:$port $COMMAND [NG]"
        echo "$host:$port $COMMAND [OK]"
done

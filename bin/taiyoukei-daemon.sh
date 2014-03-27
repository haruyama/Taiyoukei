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

# workaround for garbled characters of log.
[ x"" != x"${LANG}" ] || LANG='en_US.UTF-8'

cd `dirname $0`/..

. bin/_function.sh
TAIYOUKEI_HOME=$PWD

# if no args specified, show usage
if [ $# = 0 ]; then
        echo "Usage: taiyoukei-daemon.sh COMMAND hostname port-number"
        echo "where COMMAND is one of:"
        echo "  start      start taiyoukei"
        echo "  stop       stop  taiyoukei"
        exit 1
fi

# get host name and base port if they are given.
if [ $# != 0 ] ; then
        TAIYOUKEI_COMMAND=$1
        shift
fi
if [ $# != 0 ] ; then
        TAIYOUKEI_HOST=$1
        shift
else
        error 'hostname not set!'
fi
if [ $# != 0 ] ; then
        TAIYOUKEI_PORT=$1
        shift
else
        error 'port-number not set!'
fi

java_opts=$(ruby bin/config_parser.rb -c conf/taiyoukei.conf.yaml -h $TAIYOUKEI_HOST -p $TAIYOUKEI_PORT)
if [ $? -ne 0 ] ; then
        error "failed to parse conf/taiyoukei.conf.yaml"
fi

# run COMMAND
if [ "$TAIYOUKEI_COMMAND"  = "start" ] ; then
        curl -s http://$TAIYOUKEI_HOST:$TAIYOUKEI_PORT/ > /dev/null
        if [ $? -ne 7 ] ; then
                error "Error: base port already in use?: $TAIYOUKEI_PORT"
        fi
        nohup java $java_opts -Djetty.port=$TAIYOUKEI_PORT -jar $TAIYOUKEI_HOME/lib/start.jar $TAIYOUKEI_HOME/conf/jetty.xml < /dev/null >& /dev/null &
        if [ $? -ne 0 ] ; then
                error "Error: Solr cannot start"
        fi
elif [ "$TAIYOUKEI_COMMAND" = "stop" ] ; then
        java $java_opts -Djetty.port=$TAIYOUKEI_PORT -jar $TAIYOUKEI_HOME/lib/start.jar --stop
        if [ $? -ne 0 ] ; then
                error "Error: Solr cannot stop"
        fi
else
        error "command not found: $TAIYOUKEI_COMMAND"
fi

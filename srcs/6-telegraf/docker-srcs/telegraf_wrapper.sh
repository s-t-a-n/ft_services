#!/bin/bash -e

source /config/* #|| exit 1
exec su-exec telegraf /usr/bin/telegraf

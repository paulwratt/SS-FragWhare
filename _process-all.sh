#!/bin/sh

cd "SSFWROOT/PREFIX_tools-dir"

./FILEPRE_process-logs.sh
./FILEPRE_process-haxs.sh
./FILEPRE_process-errors.sh
./FILEPRE_process-browsers.sh


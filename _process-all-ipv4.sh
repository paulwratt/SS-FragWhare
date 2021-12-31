#!/bin/sh

cd "SSFWROOT/PREFIX_tools-dir"

./FILEPRE_process-messages-sshd.sh;
./FILEPRE_block-ipv4-sshd.sh 1;
./FILEPRE_block-nginx-access.sh;


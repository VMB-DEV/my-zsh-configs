#!/bin/bash

wget "https://discord.com/api/download?platform=linux&format=deb" -O /tmp/discord.deb
sudo apt install /tmp/discord.deb
rm /tmp/discord.deb

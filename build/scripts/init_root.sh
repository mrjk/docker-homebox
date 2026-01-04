#!/bin/bash


if [ "$(id -u )" -ne 0 ]; then 
  echo "Skip root init script because run as non priviledged user"
  exit
fi

# Usually run as root user, or default user ...

echo "DOCKER IMAGE INIT SCRIPT"
echo $PWD
id -u
groups



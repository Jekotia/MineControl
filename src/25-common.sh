#!/bin/bash

safeworldbackup() {
  if [ "$1" == "" ]; then
    echo "You must enter a valid world name! This can be either 'all' or one of the following worlds:"
    for ((v=0;v<$numworlds;v++)); do
      echo ${worlds[$v]}
    done
  else
    if [ "$1" == "all" ]; then
      echo $1
      for ((v=0;v<$numworlds;v++)); do
        worldbackup ${worlds[$v]}
        worldlogbackup ${worlds[$v]}
      done
    else
      worldbackup $1
      worldlogbackup ${worlds[$v]}
    fi
  fi
}

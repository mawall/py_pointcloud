#!/usr/bin/env bash

export NOTEBOOK_DIR=/home/marcus/Documents/notebooks/
export PROJECT_DIR=/home/marcus/Documents/projects/
export DATA_DIR=/home/marcus/Documents/data/

docker run   \
    --privileged  \
    -it  \
    --rm  \
    --net=host \
    -v $NOTEBOOK_DIR:/notebooks/  \
    -v $PROJECT_DIR:/project/  \
    -v $DATA_DIR:/data/  \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -w /notebooks \
    --name pypc \
    py_pointcloud

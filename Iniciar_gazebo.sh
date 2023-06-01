#!/bin/bash
# -*- ENCODING: UTF-8 -*-

cd ./catkin_exo_ws


catkin_make
source devel/setup.bash

roslaunch urdf_ortesis ortesis_gazebo.launch

exit

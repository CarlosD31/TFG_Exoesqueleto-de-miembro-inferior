#!/bin/bash
# -*- ENCODING: UTF-8 -*-

mkdir catkin_exo_ws
cd catkin_exo_ws
mkdir src
cd ..

catkin_make

cp -r urdf_ortesis catkin_exo_ws/src

cd catkin_exo_ws
catkin_make

exit

#!/bin/bash

cd object_tracer/env
source g5_ot_robot2_rel.sh
cd ..

ln -s ../debian
sudo apt-get update
rosdep update
source /opt/ros/kinetic/setup.sh

sudo mk-build-deps -t 'apt-get -y -f' -i -r
debuild --preserve-env --prepend-path=/usr/lib/ccache -rfakeroot -us -uc -b -j`nproc`
#echo "Y" | sudo debi --with-depends

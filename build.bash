#!/bin/bash

cd object_tracer
source env/g5_ot_robot2_rel.sh
#sudo mkdir -p /mnt/grain5-dataset/Aeolus_ModelDataset/Object_tracer/model
#sudo cp -a ../model/* /mnt/grain5-dataset/Aeolus_ModelDataset/Object_tracer/model
cp -a ../deep_learning_framework $HOME


ln -s ../debian
sudo apt-get update
rosdep update
source /opt/ros/kinetic/setup.sh

sudo mk-build-deps -t 'apt-get -y -f' -i -r
debuild --preserve-env --prepend-path=/usr/lib/ccache -rfakeroot -us -uc -b -j`nproc`
#echo "Y" | sudo debi --with-depends

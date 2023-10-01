#!/bin/bash

# Exit script if any command fails
set -xe

# Version of OpenMPI to install
VERSION="22.05.9"
NAME="slurm"
INSTALL_DIR="/opt/shared/apps/${NAME}/$VERSION"
LMOD_DIR="/opt/shared/modules/${NAME}"
STORE_DIR="/opt/shared/store"


random_str=$(date +%s$RANDOM)
build_dir="build-$random_str"
mkdir $build_dir

# Download and unpack 
tar -xf ${STORE_DIR}/${NAME}-${VERSION}.tar.bz2 -C $build_dir/.

# Compile and install 

ml load pmix/4.1.4
cd $build_dir/${NAME}-${VERSION}
  ./configure --prefix=$INSTALL_DIR \
	      --enable-deprecated=yes \
              --with-cgroup-v2 \
              --enable-pam \
	      --with-pmix=$PMIX_ROOT 2>&1 | tee config.out
  make -j4 all 2>&1 | tee make.out
  make install 2>&1 | tee install.out
cd ..
cp -r ${NAME}-${VERSION}/* $INSTALL_DIR/.
cd ..
rm -rf $build_dir

cp files/*.conf ${INSTALL_DIR}/etc/.

chown -R pi: ${INSTALL_DIR}

ln -sf ${INSTALL_DIR}/bin/* /usr/bin/.
ln -sf ${INSTALL_DIR}/sbin/* /usr/sbin/.

echo "${NAME} $VERSION installation and module setup complete."

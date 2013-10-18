#!/bin/bash

#=====
# Build on Linux x64
#=====
# System Requirements
# GCC
# Bash
# Csh
# Zlib (dev)
# BZip2 (dev)
# Inkscape
# Doxygen
# LLVM (dev)
# Flex 
# Bison

CWD=`pwd`
TARBALL=`pwd`/tarballs
STAGING=${CWD}/staging
VFXLIBS=${CWD}/vfxlibs
CONFIG=/home/dan/code/vfxbits/cortex
mkdir -p ${STAGING}
mkdir -p ${VFXLIBS}
export PATH=${VFXLIBS}/bin:${PATH}
export LD_LIBRARY_PATH=${VFXLIBS}/lib

#=====
# CMake
cd ${STAGING}
tar zxvf ${TARBALL}/cmake-2.8.11.1.tar.gz
cd ${STAGING}/cmake-2.8.11.1
./configure --prefix=$VFXLIBS
make -j 8
make install

#=====
# Pkgconfig
cd ${STAGING}
tar zxvf ${TARBALL}/pkg-config-0.28.tar.gz
cd ${STAGING}/pkg-config-0.28; ./configure --prefix=${VFXLIBS} --with-internal-glib; make clean; make -j 8; make install

#=====
# Jpeg/Tiff/Png
cd ${STAGING}
tar jxvf ${TARBALL}/libpng-1.5.17.tar.bz2
tar zxvf ${TARBALL}/jpegsrc.v8d.tar.gz
tar zxvf ${TARBALL}/tiff-3.9.4.tar.gz
cd ${STAGING}/jpeg-8d; ./configure --prefix=${VFXLIBS} --enable-shared; make clean; make -j 8; make install
cd ${STAGING}/tiff-3.9.4; ./configure --prefix=${VFXLIBS} --enable-shared;  make clean; make -j 8; make install
cd ${STAGING}/libpng-1.5.17; ./configure --prefix=${VFXLIBS} --enable-shared; make clean; make -j 8; make install

#=====
# Freeglut
cd ${STAGING}
tar zxvf ${TARBALL}/freeglut-2.8.1.tar.gz
cd ${STAGING}/freeglut-2.8.1; ./configure --prefix=$VFXLIBS; make clean; make -j 8; make install

#=====
# Python
cd ${STAGING}
tar jxvf ${TARBALL}/Python-2.6.8.tar.bz2
cd ${STAGING}/Python-2.6.8
./configure --prefix=${VFXLIBS} --enable-shared --enable-unicode=ucs4
make clean; make -j 8; make install

#=====
# SCons
cd $STAGING
tar zxvf $TARBALL/scons-2.3.0.tar.gz
cd $STAGING/scons-2.3.0
$VFXLIBS/bin/python setup.py install --prefix=$VFXLIBS

#=====
# Freetype
cd ${STAGING}
tar jxvf ${TARBALL}/freetype-2.4.12.tar.bz2
cd ${STAGING}/freetype-2.4.12
./configure --prefix=${VFXLIBS}; make -j 8; make install

#=====
# Boost
cd $STAGING
tar jxvf $TARBALL/boost_1_51_0.tar.bz2
cd $STAGING/boost_1_51_0
./bootstrap.sh --prefix=$VFXLIBS --with-python=$VFXLIBS/bin/python --with-python-root=$VFXLIBS
./b2 -j8 include=$VFXLIBS/include threading=multi link=static,shared variant=release install

#=====
# Tbb
cd $STAGING
tar zxvf $TARBALL/tbb22_20090809oss_src.tgz
cd $STAGING/tbb22_20090809oss
make clean; make -j 8;
cp build/linux_*_release/libtbb* $VFXLIBS/lib; cp -r include/tbb $VFXLIBS/include

#=====
#Openexr
cd $STAGING
tar zxvf $TARBALL/ilmbase-1.0.3.tar.gz
tar zxvf $TARBALL/openexr-1.7.1.tar.gz
cd $STAGING/ilmbase-1.0.3
./configure --prefix=$VFXLIBS; make clean; make -j 8; make install
cd $STAGING/openexr-1.7.1
./configure --prefix=$VFXLIBS; make clean; make -j 8; make install

#=====
# Fonts
cd $STAGING
tar jxvf $TARBALL/ttf-bitstream-vera-1.10.tar.bz2
mkdir -p $VFXLIBS/fonts
cp $STAGING/ttf-bitstream-vera-1.10/*.ttf $VFXLIBS/fonts

# =====
# Glew
cd $STAGING
tar zxvf $TARBALL/glew-1.9.0.tgz
cd $STAGING/glew-1.9.0
make clean; make install GLEW_DEST=$VFXLIBS LIBDIR=$VFXLIBS/lib

#=====
# Ocio
cd $STAGING
tar zxvf $TARBALL/ocio-1.0.8.tar.gz
tar zxvf $TARBALL/ocio-configs-1.0r2.tar.gz
cd $STAGING/OpenColorIO-1.0.8
$VFXLIBS/bin/cmake -DCMAKE_INSTALL_PREFIX=$VFXLIBS -DCMAKE_LIBRARY_PATH=$VFXLIBS -DOCIO_BUILD_TRUELIGHT==OFF -DOCIO_BUILD_APPS=OFF -DOCIO_BUILD_NUKE=OFF
make clean; make -j 8; make install
mkdir -p $VFXLIBS/openColorIO
cp $STAGING/OpenColorIO-Configs-1.0_r2/spi-vfx/config.ocio $VFXLIBS/openColorIO
cp -r $STAGING/OpenColorIO-Configs-1.0_r2/spi-vfx/luts $VFXLIBS/openColorIO

#=====
# Oiio
cd $STAGING
tar zxvf $TARBALL/oiio-1.1.11.tar.gz
cd $STAGING/oiio-Release-1.1.11
make clean
make -j 8 MY_CMAKE_FLAGS="-DCMAKE_INCLUDE_PATH=$VFXLIBS/include -DCMAKE_LIBRARY_PATH=$VFXLIBS/lib" THIRD_PARTY_TOOLS_HOME=$VFXLIBS OCIO_PATH=$VFXLIBS USE_OPENJPEG=0
cp -r dist/linux64/* $VFXLIBS
cp $VFXLIBS/lib/libOpenImageIO.so $VFXLIBS/lib/libOpenImageIO-1.so

#=====
# HDF5
cd $STAGING
tar jxvf $TARBALL/hdf5-1.8.11.tar.bz2
cd $STAGING/hdf5-1.8.11
./configure --prefix=$VFXLIBS --enable-threadsafe --with-pthread=/usr/include
make clean; make -j 8; make install

#=====
# Alembic
cd $STAGING
tar zxvf $TARBALL/Alembic_1.5.1_2013091900.tgz
cd $STAGING/Alembic_1.5.1_2013091900
rm -rf examples; mkdir examples; touch examples/CMakeLists.txt # for some reason at least one of the examples doesn't build
cmake -DCMAKE_INSTALL_PREFIX=$VFXLIBS -DBOOST_ROOT=$VFXLIBS -DGLUT_glut_LIBRARY=$VFXLIBS/lib/libglut.so -DUSE_PYALEMBIC=0 -DUSE_PYILMBASE=0 -DILMBASE_ROOT=$VFXLIBS
make clean; make -j 8; make install

#=====
# PyOpenGL
cd $STAGING
tar zxvf $TARBALL/PyOpenGL-3.0.2.tar.gz
cd $STAGING/PyOpenGL-3.0.2
python setup.py install --prefix $VFXLIBS --install-lib $VFXLIBS/python

#=====
# Open Shading Language
cd $STAGING
tar zxvf $TARBALL/OpenShadingLanguage-Release-1.3.3.tar.gz
cd $STAGING/OpenShadingLanguage-Release-1.3.3
make -j 8 ILMBASE_HOME=$VFXLIBS BOOST_ROOT=$VFXLIBS OPENIMAGEIOHOME=$VFXLIBS
cp -r dist/linux64/* $VFXLIBS

#=====
# QT
cd $STAGING
tar zxvf $TARBALL/qt-everywhere-opensource-src-4.8.5.tar.gz
cd $STAGING/qt-everywhere-opensource-src-4.8.5
# Annoying... you'll get prompted to accept the FOSS license by configure
./configure -opensource -prefix $VFXLIBS -no-rpath -no-declarative -no-qt3support -I $VFXLIBS/include -L $VFXLIBS/lib -I $VFXLIBS/include/freetype2
make -j 8
make install

#=====
# PySide
cd $STAGING
tar jxvf $TARBALL/apiextractor-0.10.10.tar.bz2
tar jxvf $TARBALL/generatorrunner-0.6.16.tar.bz2
tar jxvf $TARBALL/shiboken-1.1.2.tar.bz2
 tar jxvf $TARBALL/pyside-qt4.8+1.1.2.tar.bz2
cd $STAGING/apiextractor-0.10.10
$VFXLIBS/bin/cmake -DQT_QMAKE_EXECUTABLE=$VFXLIBS/bin/qmake -DCMAKE_INSTALL_PREFIX=$VFXLIBS
make clean; make -j 8; make install
cd $STAGING/generatorrunner-0.6.16
$VFXLIBS/bin/cmake -DQT_QMAKE_EXECUTABLE=$VFXLIBS/bin/qmake -DCMAKE_INSTALL_PREFIX=$VFXLIBS
make clean; make -j 8; make install
cd $STAGING/shiboken-1.1.2
mkdir -p build
cd build
$VFXLIBS/bin/cmake .. -DQT_QMAKE_EXECUTABLE=$VFXLIBS/bin/qmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS='-w' -DCMAKE_INSTALL_PREFIX=$VFXLIBS -DPYTHON_EXECUTABLE=$VFXLIBS/bin/python -DPYTHON_LIBRARY=$VFXLIBS/lib/libpython2.6.so -DPYTHON_INCLUDE_DIR=$VFXLIBS/include/python2.6
make -j 8
make install
cd $STAGING/pyside-qt4.8+1.1.2
mkdir -p build
cd build
$VFXLIBS/bin/cmake .. -DQT_QMAKE_EXECUTABLE=$VFXLIBS/bin/qmake -DCMAKE_BUILD_TYPE=Release -DALTERNATIVE_QT_INCLUDE_DIR=$VFXLIBS/include -DCMAKE_CXX_FLAGS='-w' -DCMAKE_INSTALL_PREFIX=$VFXLIBS
make -j 8
make install

#=====
# Cortex
cd $STAGING
git clone https://github.com/ImageEngine/cortex.git
cd $STAGING/cortex
scons install installDoc -j 8 OPTIONS=$CONFIG/cortex_linux.options
scons test OPTIONS=$CONFIG/cortex_linux.options

#======
# Gaffer
cd $STAGING
git clone https://github.com/ImageEngine/gaffer.git
cd $STAGING/gaffer
scons OPTIONS=$CONFIG/gaffer_linux.options

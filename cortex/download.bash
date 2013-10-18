#!/usr/bin/env bash
CWD=`pwd`
TARBALL=`pwd`/tarballs
mkdir -p ${TARBALL}
cd ${TARBALL}

# cmake
wget -c http://www.cmake.org/files/v2.8/cmake-2.8.11.1.tar.gz

# scons
wget -c http://prdownloads.sourceforge.net/scons/scons-2.3.0.tar.gz

# tiff
wget -c ftp://ftp.remotesensing.org/libtiff/tiff-3.9.4.tar.gz

# png
wget -c ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng15/libpng-1.5.17.tar.bz2

# jpeg
wget -c http://www.ijg.org/files/jpegsrc.v8d.tar.gz

# glut
wget -c http://downloads.sourceforge.net/project/freeglut/freeglut/2.8.1/freeglut-2.8.1.tar.gz

# freetype
wget -c http://download.savannah.gnu.org/releases/freetype/freetype-2.4.12.tar.bz2

# python
wget -c http://www.python.org/ftp/python/2.6.8/Python-2.6.8.tar.bz2

# ilmbase/openexr
wget -c https://github.com/downloads/openexr/openexr/ilmbase-1.0.3.tar.gz
wget -c https://github.com/downloads/openexr/openexr/openexr-1.7.1.tar.gz

# tbb
wget -c https://distfiles.macports.org/tbb/tbb22_20090809oss_src.tgz

# Boost
wget -c http://downloads.sourceforge.net/project/boost/boost/1.51.0/boost_1_51_0.tar.bz2

# glew
wget -c http://downloads.sourceforge.net/project/glew/glew/1.9.0/glew-1.9.0.tgz

# opencolorio
wget -c http://github.com/imageworks/OpenColorIO/archive/v1.0.8.tar.gz -O ocio-1.0.8.tar.gz
wget -c http://github.com/imageworks/OpenColorIO-Configs/archive/v1.0_r2.tar.gz -O ocio-configs-1.0r2.tar.gz

# openimageio
wget -c https://github.com/OpenImageIO/oiio/archive/Release-1.1.11.tar.gz -O oiio-1.1.11.tar.gz

# osl
wget -c https://github.com/imageworks/OpenShadingLanguage/archive/Release-1.3.3.tar.gz

# hdf5
wget -c http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.11.tar.bz2

# alembic
wget -c https://alembic.googlecode.com/files/Alembic_1.5.1_2013091900.tgz

# pkg-config
wget -c http://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz

# pyopengl
wget --no-check-certificate -c https://pypi.python.org/packages/source/P/PyOpenGL/PyOpenGL-3.0.2.tar.gz

# qt
wget -c http://download.qt-project.org/official_releases/qt/4.8/4.8.5/qt-everywhere-opensource-src-4.8.5.tar.gz

# pyside
wget -c https://distfiles.macports.org/apiextractor/apiextractor-0.10.10.tar.bz2
wget -c https://distfiles.macports.org/generatorrunner/generatorrunner-0.6.16.tar.bz2
wget -c https://distfiles.macports.org/py-pyside/pyside-qt4.8+1.1.2.tar.bz2
wget -c https://distfiles.macports.org/py-shiboken/shiboken-1.1.2.tar.bz2

# ttf fonts
wget -c http://ftp.gnome.org/pub/GNOME/sources/ttf-bitstream-vera/1.10/ttf-bitstream-vera-1.10.tar.bz2

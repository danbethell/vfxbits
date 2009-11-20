#==========
#
# Copyright (c) 2009, Dan Bethell.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
#     * Neither the name of Dan Bethell nor the names of any
#       other contributors to this software may be used to endorse or
#       promote products derived from this software without specific prior
#       written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#==========
#
# Variables defined by this module:
#   OpenImageIO_FOUND    
#   OpenImageIO_INCLUDE_DIR
#   OpenImageIO_LIBRARY
#
# Usage: 
#   FIND_PACKAGE( OpenImageIO )
#   FIND_PACKAGE( OpenImageIO REQUIRED )
#
# Note:
# OpenImageIO is often not installed in a system location. 
# If this is the case, set the OpenImageIO_INSTALL_PATH before
# calling FIND_PACKAGE.
# 
# E.g. 
#   SET( OpenImageIO_INSTALL_PATH "/path/to/oiio/dist/linux64" )
#   FIND_PACKAGE( OpenImageIO REQUIRED )
#
#==========

# try to find header
FIND_PATH( OpenImageIO_INCLUDE_DIR 
  NAMES
  OpenImageIO/imageio.h
  PATHS
  /usr/include
  /usr/local/include
  /usr/openwin/share/include
  /usr/openwin/include
  /usr/X11R6/include
  /usr/include/X11
  ${OpenImageIO_INSTALL_PATH}/include
  )

# try to find libs
FIND_LIBRARY( OpenImageIO_LIBRARY 
  NAMES
  OpenImageIO
  PATHS
  /usr/lib
  /usr/local/lib
  /usr/openwin/lib
  /usr/X11R6/lib
  ${OpenImageIO_INSTALL_PATH}/lib
  )

# did we find everything?
SET( OpenImageIO_FOUND "NO" )
IF( OpenImageIO_INCLUDE_DIR )
  IF( OpenImageIO_LIBRARY )
    SET( OpenImageIO_FOUND "YES" )
    MESSAGE(STATUS "Found OpenImageIO: ${OpenImageIO_LIBRARY}" )
  ENDIF( OpenImageIO_LIBRARY)
ENDIF( OpenImageIO_INCLUDE_DIR )

IF( OpenImageIO_FIND_REQUIRED )
  IF( NOT OpenImageIO_FOUND )
    MESSAGE(FATAL_ERROR "Could not find REQUIRED OpenImageIO!" )
  ENDIF( NOT OpenImageIO_FOUND )
ENDIF( OpenImageIO_FIND_REQUIRED )

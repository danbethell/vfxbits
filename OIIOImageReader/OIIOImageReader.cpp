//////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2007-2009, Image Engine Design Inc.
//                           Dan Bethell.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are
//  met:
//
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//
//     * Neither the name of Image Engine Design nor the names of any
//       other contributors to this software may be used to endorse or
//       promote products derived from this software without specific prior
//       written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
//  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//////////////////////////////////////////////////////////////////////////

#include "OIIOImageReader.h"

#include <IECore/SimpleTypedData.h>
#include <IECore/VectorTypedData.h>
#include <IECore/ImagePrimitive.h>
#include <IECore/FileNameParameter.h>
#include <IECore/BoxOps.h>
#include <IECore/MessageHandler.h>

#include <boost/format.hpp>

#include <imageio.h>

#include <algorithm>
#include <fstream>
#include <iostream>
#include <cassert>
#include <cmath>

using namespace IECore;
using namespace OpenImageIO;
using namespace std;
using Imath::Box2i;

IE_CORE_DEFINERUNTIMETYPED( OIIOImageReader );

const Reader::ReaderDescription<OIIOImageReader> OIIOImageReader::g_readerDescription("oiio");

OIIOImageReader::OIIOImageReader() :
    ImageReader( "OIIOImageReader", "Reads a variety of file formats using the OIIO library." ),
    m_inputFile( 0 ),
    m_imageCache( 0 )
{
}

OIIOImageReader::OIIOImageReader(const string &fileName) :
    ImageReader( "OIIOImageReader", "Reads ILM OpenEXR file format." ),
    m_inputFile( 0 ),
    m_imageCache( 0 )
{
	m_fileNameParameter->setTypedValue( fileName );
}

OIIOImageReader::~OIIOImageReader()
{
    // cleanup our oiio file handle
    if ( m_inputFile )
        m_inputFile->close();
	delete m_inputFile;
    m_inputFile = 0;
   
    // clean up our image cache
    delete [] m_imageCache;
    m_imageCache = 0;
}

bool OIIOImageReader::canRead( const string &fileName )
{
	return true; // TODO: need to check file is readable with OIIO
}

void OIIOImageReader::channelNames( vector<string> &names )
{
	open( true );
    names = m_imageSpec.channelnames;
}

bool OIIOImageReader::isComplete()
{
	if( !open() )
		return false;
	return true;
}

Imath::Box2i OIIOImageReader::dataWindow()
{
	open( true );
    ImageSpec &spec = m_imageSpec;
    Imath::Box2i window;
    window.min = Imath::V2i( spec.x, spec.y );
    window.max = Imath::V2i( spec.x+spec.width-1, spec.y+spec.height-1 );
	return window;
}

Imath::Box2i OIIOImageReader::displayWindow()
{
	open( true );
    ImageSpec &spec = m_imageSpec;
    Imath::Box2i window;
    window.min = Imath::V2i( spec.full_x, spec.full_y );
    window.max = Imath::V2i( spec.full_x+spec.full_width-1, spec.full_y+spec.full_height-1 );
	return window;
}

std::string OIIOImageReader::sourceColorSpace() const
{
    std::string result = "";
    const ImageSpec &is = m_imageSpec;

    switch ( is.linearity )
    {
    case ImageSpec::Linear:
        result = "linear";
        break;
    case ImageSpec::GammaCorrected:
        result = "gamma"; // is this valid to cortex?
        break;
    case ImageSpec::sRGB:
        result = "srgb";
        break;
    default:
        result = "linear";
        break;
    }
    return result;        
}

bool OIIOImageReader::open( bool throwOnFailure )
{
    if ( m_inputFile ) // true if we already have an open image
    {
        return true;
    }

    try
    {    
        // our OIIO imageInput object
        m_inputFile = ImageInput::create( fileName().c_str());

        // get the imageSpec object from the file
        m_inputFile->open(fileName().c_str(), m_imageSpec);

        // store an index for each channel, will speed up finding the channel later
        std::vector<std::string>::iterator it = m_imageSpec.channelnames.begin();
        unsigned int pos = 0;
        for( ; it!=m_imageSpec.channelnames.end(); ++it )
            m_channelOffsets[*it] = pos++;
    }
    catch( ... )
    {
        delete m_inputFile;
        m_inputFile = 0;
        if( !throwOnFailure )
        {
            return false;
        }
        else
        {
            throw IOException( string( "Failed to open file \"" ) + fileName() + "\"" );
        }
    }

    return true;
}

template<class T>
DataPtr OIIOImageReader::readTypedChannel( const std::string &name, const Imath::Box2i &dataWindow, bool convert_from_uint8 )
{
    Imath::V2i pixelDimensions = dataWindow.size() + Imath::V2i( 1 );
    unsigned numPixels = pixelDimensions.x * pixelDimensions.y;

    typedef TypedData<vector<T> > DataType;
    typename DataType::Ptr data = new DataType;
    data->writable().resize( numPixels );

    Imath::Box2i fullDataWindow = this->dataWindow();
    unsigned int width = fullDataWindow.size().x + 1;
    unsigned int height = fullDataWindow.size().y + 1;
    unsigned int num_channels = m_imageSpec.nchannels;

    // AFAICT oiio can't read individual channels from an image
    // so we read the entire image and store it for subsequent
    // channel reads.
    if ( !m_imageCache )
    {
        BOOST_STATIC_ASSERT( sizeof( char ) == 1 );
        size_t data_size = sizeof(T);
        if ( convert_from_uint8 ) // special case for uchar data - convert to float
            data_size = sizeof( unsigned char );
        m_imageCache = new char[ width * height * num_channels * data_size ];
        m_inputFile->read_image( m_imageSpec.format, m_imageCache );
    }

    if( fullDataWindow.min.x==dataWindow.min.x && fullDataWindow.max.x==dataWindow.max.x )
    {
        // the width we want to read matches the width in the file, 
        // so we can copy straight from the cache into the result buffer
        T *buffer00 = data->baseWritable();
        unsigned int x=0;
        if ( convert_from_uint8 )
        {
            unsigned char *moving_ptr = reinterpret_cast<unsigned char*>(m_imageCache) + m_channelOffsets[name];
            for ( ; x<numPixels; ++x )
                *(buffer00++) = (*(moving_ptr+=num_channels)/255.f); // copy data into our buffer and post-increment pointers
        }
        else // copy everything else as-is
        {
            T *moving_ptr = reinterpret_cast<T*>(m_imageCache) + m_channelOffsets[name];
            for ( ; x<numPixels; ++x )
                *(buffer00++) = *(moving_ptr+=num_channels); // copy data into our buffer and post-increment pointers
        }
    }
    else
    {
        // widths don't match so we only copy a sub-section of the image
        // into the result buffer
        T *buffer00 = data->baseWritable();
        unsigned int xend = dataWindow.max.x;
        unsigned int yend = dataWindow.max.y;
        unsigned int x=0, y=0;

        if ( convert_from_uint8 )
        {
            unsigned char *moving_ptr = 0;
            for( y=dataWindow.min.y; y<=yend; ++y )
            {
                moving_ptr = reinterpret_cast<unsigned char*>(m_imageCache) + 
                    ( y * m_imageSpec.width * m_imageSpec.nchannels ) + 
                    ( dataWindow.min.x * m_imageSpec.nchannels ) + m_channelOffsets[name]; // move to the start of this scanline
                
                for ( x=dataWindow.min.x; x<=xend; ++x )
                    *(buffer00++) = (*(moving_ptr+=num_channels)/255.f); // copy data into our buffer and post-increment pointers
            }
        }
        else // copy everything else as-is
        {
            T *moving_ptr = 0;
            for( y=dataWindow.min.y; y<=yend; ++y )
            {
                moving_ptr = reinterpret_cast<T*>(m_imageCache) + 
                    ( y * m_imageSpec.width * m_imageSpec.nchannels ) + 
                    ( dataWindow.min.x * m_imageSpec.nchannels ) + m_channelOffsets[name]; // move to the start of this scanline
                
                for ( x=dataWindow.min.x; x<=xend; ++x )
                    *(buffer00++) = *(moving_ptr+=num_channels);
            }
        }        
    }

    return data;
}

DataPtr OIIOImageReader::readChannel( const string &name, const Imath::Box2i &dataWindow )
{
    open( true );

    try
    {
        TypeDesc fmt = m_imageSpec.format;

        if ( fmt==TypeDesc::UINT8 )
        {
            BOOST_STATIC_ASSERT( sizeof( unsigned char ) == 1 );
            return readTypedChannel<half>( name, dataWindow, true );
        }
        else if ( fmt==TypeDesc::HALF )
        {
            return readTypedChannel<half>( name, dataWindow );
        }
        else if ( fmt==TypeDesc::FLOAT )
        {
            BOOST_STATIC_ASSERT( sizeof( float ) == 4 );
            return readTypedChannel<float>( name, dataWindow );
        }
        else if ( fmt==TypeDesc::UINT )
        {
            BOOST_STATIC_ASSERT( sizeof( unsigned int ) == 4 );
            return readTypedChannel<unsigned int>( name, dataWindow );
        }
        else
            throw IOException( ( boost::format( "OIIOImageReader : Unsupported data type for channel \"%s\"" ) % name ).str() );
    }
    catch ( Exception &e )
    {
        throw;
    }
    catch ( std::exception &e )
    {
        throw IOException( ( boost::format( "OIIOImageReader : %s" ) % e.what() ).str() );
    }
    catch ( ... )
    {
        throw IOException( "OIIOImageReader : Unexpected error" );
    }
}

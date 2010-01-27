/*
Copyright (c) 2010, Dan Bethell.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of Dan Bethell nor the names of any
      other contributors to this software may be used to endorse or
      promote products derived from this software without specific prior
      written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
Implements a RenderMan shader which renders a scene to a latlong map using 
a "nonideal" lense. Refer to section 16.2 in Advanced RenderMan for more 
details.
*/
surface latlong()
{
    // our ndc-space point
    point _Pndc = transform( "NDC", P );
 
    // our parametric coordinates
    float _u = xcomp( _Pndc );
    float _v = ycomp( _Pndc );
 
    // our vector components
    float rayx = -cos( _u * PI * 2 ) * sin( _v * PI );
    float rayy = cos( _v * PI );
    float rayz = sin( _u * PI * 2 ) * sin( _v * PI );
 
    // our trace point/vector
    point _Pt = point "object" ( 0, 0, 0 );
    vector _It = vector "world" ( rayx, rayy, rayz );
 
    // trace a colour
    Ci = trace( _Pt, _It );
    Oi = Os;
    Ci *= Oi;
}

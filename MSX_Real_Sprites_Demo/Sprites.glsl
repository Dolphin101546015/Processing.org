/*

Copyright (c) 2020 Dolphin_Soft #101546015, Vladivostok 2020

Permission  is  hereby  granted,  free  of  charge, to  any  person  obtaining
a  copy  of this software and associated documentation files (the "Software"),
to  deal in  the Software without  restriction, including  without  limitation
the rights  to  use,  copy,  modify,  merge,  publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software
is furnished to do so, subject to the following conditions:

The  above  copyright  notice  and  this  permission  notice shall be included
in all copies or substantial portions of the Software.

THE  SOFTWARE  IS  PROVIDED  "AS  IS",  WITHOUT  WARRANTY OF ANY KIND, EXPRESS
OR  IMPLIED,  INCLUDING  BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS  FOR  A  PARTICULAR  PURPOSE  AND  NONINFRINGEMENT.  IN NO EVENT SHALL
THE AUTHORS  OR  COPYRIGHT HOLDERS  BE LIABLE FOR ANY CLAIM,  DAMAGES OR OTHER
LIABILITY,  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT  OF  OR  IN  CONNECTION  WITH  THE  SOFTWARE  OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.



 		      MSX2 SM2 Sprites Engine Shader v3.0

 - 64 16x16 Sprites, 16 colors with palette
 - OR attributes per line
 - Shift attributes per line
 - PAT (Pattern Table, 64 entries total) Format per array element:
  [0]   S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 - 32 bit of  1th pattern string for sprites 0 and 1
  [1]   S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 - 32 bit of  2nd pattern string for sprites 0 and 1
	. . . 
 [15]   S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S1 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 S0 - 32 bit of 16th pattern string for sprites 0 and 1
 [16]   S3 S3 S3 S3 S3 S3 S3 S3 S3 S3 S3 S3 S3 S3 S3 S3 S2 S2 S2 S2 S2 S2 S2 S2 S2 S2 S2 S2 S2 S2 S2 S2 - 32 bit of  1th pattern string for sprites 2 and 3
	. . . etc.

 - SCT (Color Table, 32 entries total) Format per array element:
  [0]   S3 S3 S3 S3 S3 S3 S3 S3 S2 S2 S2 S2 S2 S2 S2 S2 S1 S1 S1 S1 S1 S1 S1 S1 S0 S0 S0 S0 S0 S0 S0 S0 - 32 bit of  1th color code string for sprites 0, 1, 2, 3
  [1]   S3 S3 S3 S3 S3 S3 S3 S3 S2 S2 S2 S2 S2 S2 S2 S2 S1 S1 S1 S1 S1 S1 S1 S1 S0 S0 S0 S0 S0 S0 S0 S0 - 32 bit of  2nd color code string for sprites 0, 1, 2, 3
 [15]   S3 S3 S3 S3 S3 S3 S3 S3 S2 S2 S2 S2 S2 S2 S2 S2 S1 S1 S1 S1 S1 S1 S1 S1 S0 S0 S0 S0 S0 S0 S0 S0 - 32 bit of 16th color code string for sprites 0, 1, 2, 3
 [16]   S7 S7 S7 S7 S7 S7 S7 S7 S6 S6 S6 S6 S6 S6 S6 S6 S5 S5 S5 S5 S5 S5 S5 S5 S4 S4 S4 S4 S4 S4 S4 S4 - 32 bit of 16th color code string for sprites 4, 5, 6, 7
	. . . etc.

 - SAT (Attribute Table, 32 entries total) Format:
  [0]   Y of Sprite 0 (32 bit)
  [1]   X of Sprite 0 (32 bit)
  [2]   (Pattern Num of Sprite 0)*4 (32 bit)
  [3]   NC (32 bit)
  [0]   Y of Sprite 1 (32 bit)
  [1]   X of Sprite 1 (32 bit)
  [2]   (Pattern Num of Sprite 1)*4 (32 bit)
  [3]   NC (32 bit)
	. . . etc.

  Shader show all 64 at once, when MSX capable show only 32. Therefore last 32 Sprites use same SCT order, as first 32.
  Shader use float coordinates system, for convinient using in programs outside MSX2.
  Shader use SM2 mode format for patterns coding, only for sprites 16x16.
  Shader not emulate MSX2 restrictions, like 8 sprites per line and interrupt bit.
  Shader not emulate undoccumented MSX2 registers abilities.

*/

#version 400
#ifdef GL_ES
precision highp float;
precision highp int;
#endif
#define PROCESSING_TEXTURE_SHADER
uniform sampler2D texture;
uniform vec2 texOffset;
varying vec4 vertTexCoord;
uniform	int	flipX=0;	// Default Flip X state ( 0 - no flip,15 - flipped, 7 - half flipped)
uniform	int	flipY=0;	// Default Flip Y state ( 0 - no flip,15 - flipped, 7 - half flipped)
uniform int 	scale=4;	// Sprites scale factor
uniform	float	SAT[256];	// Sprites Attribute Table
uniform	int	SCT[128];	// Sprites Color     Table
uniform	int	PAT[512];	// Sprites Pattern   Table
uniform int 	PAL[16]={	0x000000, 0x000000, 0x20D020, 0x60FF60, 0x2020FF, 0x4060FF, 0xD02020, 0x40D0FF, 
				0xFF2020, 0xFF6060, 0xD0D020, 0xD0D080, 0x208020, 0xD040B0, 0xB0B0B0, 0xFFFFFF	};	// Default MSX Palette
void main( void ) {
	uint	x = uint(gl_FragCoord.x/scale), y = uint((1080 - gl_FragCoord.y)/scale);// Screen coordinates (Y reversed, on MSX sprites from upper coner)
	int 	pal=0, res_color=0, lastnum=0;	 			                // Palette from index, Color Accumulator, index store
	for (int i= 63; i>=0; i--) {							// Proceed 64 sprites
		uint dy		= ( y - uint( SAT[ i<<2 ] ) );				// Get dy
		if (dy > 15) continue;							// Test Sprite range by Y
		uint sp_x	= uint( SAT[ 1 + ( i<<2 ) ] );				// Get Sprite X
		uint sp_c 	=  112 & ( i<<2 );					// Get Sprite Color   Table Offset
		uint sp_coffs	= ( 12 & ( i<<2 ) ) << 1;				// Get Sprite Color Shifter 0, 8, 16, 24
		uint sp_poffs	= ( uint( SAT[ 2 + ( i<<2 ) ] ) &   4 ) << 2;		// Get Sprite Pattern Shifter 0, 16
		uint sp_p	= ( uint( SAT[ 2 + ( i<<2 ) ] ) & 248 ) << 1;		// Get Sprite Pattern Table Offset
		int color	= ( SCT[ sp_c + dy ] >> sp_coffs ) & 255;		// Get Sprite Color Table Value
		if ( (color & 128) > 0 ) sp_x  -= 32;					// if Shift Attribute, move sprite line to 32-pix left
		uint dx		= ( x - sp_x ) ^ 15;		              		// Get dx
		if ( dx > 15 ) continue;                     				// Sprite in range by X
		if ( (PAT[ sp_p + dy ] & uint( 1 << dx + sp_poffs ) ) > 0 ) {		// Test Sprite Pattern bit
			res_color= (lastnum-i==1) ? res_color | color : color;		// do OR, else write last color
			if ( (color &  64) > 0 ) lastnum = i;				// Store index for collor summ
	}	}
	if (res_color==0) discard;                                                      // if Index color == transparent, Exit
	pal  = PAL[ res_color & 15 ];							//  Get palette by Index (64 colors range)
	gl_FragColor.rgb = vec3((pal >> 16) & 255, (pal >> 8) & 255, pal & 255 ) / 255.0;
}
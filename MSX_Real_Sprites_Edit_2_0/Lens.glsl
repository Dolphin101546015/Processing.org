/*

		       Copyright (c) Dolphin_Soft #101546015, Vladivostok 2020

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
uniform int 	clr_l=3;	// Active color for left sprite
uniform int 	clr_r=3;	// Active color for right sprite
uniform int 	sellect=3;	// Sprites sellector
uniform int 	scale=40;	// Sprites scale factor
uniform	float	lx;		// Lens X
uniform	float	ly;		// Lens X
uniform	int	SCT[32];	// Sprites Color     Table
uniform	int	PAT[32];	// Sprites Pattern   Table
uniform int 	PAL[16]={	0x000000, 0x000000, 0x20D020, 0x60FF60, 0x2020FF, 0x4060FF, 0xD02020, 0x40D0FF, 
				0xFF2020, 0xFF6060, 0xD0D020, 0xD0D080, 0x208020, 0xD040B0, 0xB0B0B0, 0xFFFFFF	};	// Default MSX Palette
void main( void ) {
	int 	color=0;
	int 	msk=0xFFFFFFF, pal=0, pal2=0, res_color=0, lastnum=0;	 			        // Palette from index, Color Accumulator, index store
	uint	x = uint(gl_FragCoord.x), y = uint(1080 - gl_FragCoord.y);	// Screen coordinates (Y reversed, on MSX sprites from upper coner)
	float 	tstx=(x-lx);
	float 	tsty=(y-ly);
	float	fx=tstx/scale;
	float	fy=tsty/scale;

//	Draw Lens Frame
	if ((fx >=0.8 )&&(fx <=15.2))
		if ((fy ==-0.6 )||(fy ==-0.4 )){ 	gl_FragColor.rgb = vec3(0.4,0.4,0.8); 	return; }

	if ((fx >=0.2 )&&(fx <=15.8)&&((fy ==-0.5 ))){	gl_FragColor.rgb = vec3(0.6);		return;	}


	if ((((fx ==-0.2 )||(fx ==16.2))&&(((fy >=-0.2 )&&(fy <= 16.2))))||(((fx >=-0.2 )&&(fx <=16.2))&&(((fy ==-0.2 )||(fy == 16.2))))){
			gl_FragColor.rgb = vec3(0.3);
			return;
	}

	if ((fx >-0.2 )&&(fx <=16.2)){
		if (fy ==-0.8 ){
			pal=0x606060;
			gl_FragColor.rgb = vec3(0.4);
			return;
		}
		if ((fy >-0.8 )&&(fy <-0.2)){
			pal=0x0000FF;
			gl_FragColor.rgb = vec3(0,0,1);
			return;
		}
	}


	int	dx=int((x-lx)/scale);
	int	dy=int((y-ly)/scale);

	int	s1p=PAT[ dy ] & int( 1 << (dx^15));
	int	s1c=SCT[ dy ];
	int	s2p=PAT[ dy + 16 ] & int( 1 << (dx^15));
	int	s2c=SCT[ dy+16 ];

	if ((tstx==(dx*scale)) || (tsty==(dy*scale))) msk=0;

	if ((fy >=0)&&(fy < 16)) {

//	Draw Sprite Line colors
		if ((fx <-1 )&&(fx >-2)) {
			if ((sellect&1)>0) color=s1c; else color|=s2c;
			if (((sellect)==3)&&(s2c&64)>0) color|=s2c;
			pal  = PAL[ color & 15 ];
			pal&=msk;
			gl_FragColor.rgb = vec3((pal >> 16) & 255, (pal >> 8) & 255, pal & 255 ) / 255.0;
			return;
		}

//	Draw OR Codes
		if ((fx <18 )&&(fx >17)) {
			if (((sellect&2)>0)&&((s2c&64)>0)) pal=0xFFFFFF; else pal=0x2C2C2C;
			pal&=msk;
			gl_FragColor.rgb = vec3((pal >> 16) & 255, (pal >> 8) & 255, pal & 255 ) / 255.0;
			return;
		}

//	Draw Sprites in Lens
		if ((fx >=0 )&&(fx < 16)) {
			if (s1p==0) s1c=0;
			if (s2p==0) s2c=0;
			pal=0x202020;
			color=s1c;
			if ((s2c>0)&&((s2c&64)>0)) color|=s2c;
			color&=15;
			if (color>0) pal=PAL[color];
			pal&=msk;
			pal2=pal;
			if (sellect==3) {
				gl_FragColor.rgb = vec3((pal >> 16) & 255, (pal >> 8) & 255, pal & 255 ) / 255.0;
			} else {
				if (((sellect==1)&&(s1p==0)&&(s2p>0))||((sellect==2)&&(s2p==0)&&(s1p>0))) pal2=0;
				gl_FragColor.rgb = mix( vec3((pal   >> 16) & 255, (pal  >> 8) & 255, pal  & 255 ) / 255.0,
							vec3((pal2  >> 16) & 255, (pal2 >> 8) & 255, pal2 & 255 ) / 255.0, 0.7);
			}

			return;
		}
	}

//	Draw Palette
	if ((fx >=0 )&&(fx <16)&&(fy >17)&&(fy < 18)) {
		pal  |= PAL[ dx & 15 ];
		pal&=msk;
		gl_FragColor.rgb = vec3((pal >> 16) & 255, (pal >> 8) & 255, pal & 255 ) / 255.0;
		return;
	}

//	Draw Sellected Colors
	if ((sellect&1)>0)
		if (((fx >= (clr_l+0.3))&&(fx <= (clr_l+0.7)))&&((fy == 16.9)||(fy == 18.1))) {
			pal  |= PAL[ dx & 15 ];
			gl_FragColor.rgb = mix(vec3((pal >> 16) & 255, (pal >> 8) & 255, pal & 255 ) / 255.0, vec3(0.5),0.5);
			return;
		}

	if ((sellect&2)>0)
		if (((fx >= (clr_r+0.3))&&(fx <= (clr_r+0.7)))&&((fy == 16.9)||(fy == 18.1))) {
			pal  |= PAL[ dx & 15 ];
			gl_FragColor.rgb = mix(vec3((pal >> 16) & 255, (pal >> 8) & 255, pal & 255 ) / 255.0, vec3(0.5),0.5);
			return;
		}
	
//	Draw Sellected Colors OR resulting color
	pal=clr_l|clr_r;
	if (((fx >= (pal+0.3))&&(fx <= (pal+0.7)))&&((fy == 16.9)||(fy == 18.1))) {
		pal  |= PAL[ dx & 15 ];
		gl_FragColor.rgb = mix(vec3((pal >> 16) & 255, (pal >> 8) & 255, pal & 255 ) / 255.0, vec3(0.5),0.5);
		return;
	}

//	Draw Sprites Preview
	fx*=5;
	fy=(fy+4.5)*5;
	dx=int(fx);
	dy=int(fy);

	if ((fx>0)&&(fy>0)&&(fx<16)&&(fy<16)) {
		s1p=PAT[ dy ] & int( 1 << (dx^15));
		s1c=SCT[ dy ];
		s2p=PAT[ dy + 16 ] & int( 1 << (dx^15));
		s2c=SCT[ dy + 16 ];
		if (((sellect&1)>0)&&(s1p>0)) color=s1c;
		if (((sellect&2)>0)&&(s2p>0)&&((s2c&64)>0)) color|=s2c;
		pal  |= PAL[ color & 15 ];
		gl_FragColor.rgb = vec3((pal >> 16) & 255, (pal >> 8) & 255, pal & 255 ) / 255.0;
		return;
	}

	discard;
}
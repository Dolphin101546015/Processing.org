#ifdef GL_ES
precision highp float;
precision highp int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
varying vec4 vertTexCoord;

void main(void) {
	int iR=0;
	int iG=0;
	int iB=0;
	vec3 dest = texture2D( texture, vertTexCoord.st).rgb*255.0;
	iR=int(dest.r)&0xE0;
	iG=int(dest.g)&0xE0;
	iB=int(dest.b)&0xE0;
	dest= vec3(iR, iG, iB) / 255.0;
	gl_FragColor = vec4(dest,1.0);
}
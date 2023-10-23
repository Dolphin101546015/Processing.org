#ifdef GL_ES
precision highp float;
precision highp int;
precision highp int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
varying vec4 vertTexCoord;

uniform int inPAL[16]={0x00000000,0x00000000,0x0020C020,0x0060E060,0x002020E0,0x004060E0,0x00A02020,0x0040C0E0,
            	       0x00E02020,0x00E06060,0x00C0C020,0x00C0C080,0x00208020,0x00C040A0,0x00A0A0A0,0x00E0E0E0};       	// Default MSX Palette
int sorted[16];



void main(void) {
   int iR=0;
   int iG=0;
   int iB=0;
   int tR=0;
   int tG=0;
   int tB=0;
   int tmp=0;
	
   float minL=0;
   float tmc=0;
   int nm=0;
        
	for(int i=0;i<16;i++) {
		sorted[i]=inPAL[i]&0xE0E0E0;
	}
	for(int t=0;t<15;t++)
	   for(int i=t+1;i<16;i++)
		if (sorted[t]>sorted[i]){
			tmp=sorted[t];
			sorted[t]=sorted[i];
			sorted[i]=tmp;
		}

   vec3 dest = texture2D( texture, vertTexCoord.st).rgb;
   vec3 srt;
	minL=9999.0;
	for(int i=0;i<16;i++){
		srt = dest - vec3((sorted[i]>>16) & 0xE0, (sorted[i]>>8) & 0xE0, sorted[i] & 0xE0) / 224.0;
		srt = sqrt( srt * srt );
		tmc = srt.r + srt.g + srt.b;
		if (tmc<minL) { minL=tmc; nm=i; }
	}
	tR=(sorted[nm] >>16) & 0xE0;
	tG=(sorted[nm] >> 8) & 0xE0;
	tB=(sorted[nm]     ) & 0xE0;
	dest=vec3(tR, tG, tB);
  gl_FragColor = vec4(dest/255.0,1.0);
}
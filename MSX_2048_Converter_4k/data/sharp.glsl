#ifdef GL_ES
precision highp float;
precision highp int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
varying vec4 vertTexCoord;
//uniform float colors : hint_range(1.0, 16.0);

uniform  float tst[25]={  0.0,  0.0,  0.0,  0.0,  0.0,  
	      	   	  0.0, -1.0, -1.0, -1.0,  0.0,  
		          0.0, -1.0,  9.0, -1.0,  0.0,  
	                  0.0, -1.0, -1.0, -1.0,  0.0,  
		          0.0,  0.0,  0.0,  0.0,  0.0  };

/*
uniform  float tst[25]={  0.0,  0.0,  0.0,  0.0,  0.0,  
	      	   	  0.0,  0.0, -1.0,  0.0,  0.0,  
		          0.0, -1.0, 11.0, -1.0,  0.0,  
	                  0.0,  0.0, -1.0,  0.0,  0.0,  
		          0.0,  0.0,  0.0,  0.0,  0.0  };
uniform  float tst[25]={ -1.0, -1.0, -1.0, -1.0, -1.0,
			 -1.0,  3.0,  4.0,  3.0, -1.0,
			 -1.0,  4.0,  1.0,  4.0, -1.0,
			 -1.0,  3.0,  4.0,  3.0, -1.0,
			 -1.0, -1.0, -1.0, -1.0, -1.0  };
*/

uniform  float val = 1.0;

void main(void) {
  int i = 0;
  int j = 0;
  int k = 0;
    
  float divisor=0.0;
    
  vec3 dest = vec3(0.0);
  vec3 src = texture2D( texture, vertTexCoord.st).rgb;
 
  for (j=-2; j<=2; j++)
	for (i=-2; i<=2; i++){
		dest+=texture2D( texture, vertTexCoord.st + vec2(i, j)*texOffset.st).rgb*tst[k];
		divisor+=tst[k];//*val;
		k++;
	}
	if (dest.r<0) dest.r=0;
	if (dest.g<0) dest.g=0;
	if (dest.b<0) dest.b=0;
	dest=src+(dest-src)*(val/2.0);
//	dest *= val;//divisor;
  gl_FragColor = vec4(dest,1.0);
}
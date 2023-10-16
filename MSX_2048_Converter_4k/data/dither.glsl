#ifdef GL_ES
precision highp float;
precision highp int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
varying vec4 vertTexCoord;

uniform  float val = 0.0;
//float scale = 1.0;
/*
float DITHER_THRESHOLDS[16] =
    {
         1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
         4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
    };
*/
float DITHER_THRESHOLDS[64] =
    {
        -1.0,  3.0, -2.0,  2.0, -3.0,  1.0, -2.0,  2.0,
         1.0, -2.0,  3.0, -2.0,  1.0, -1.0,  2.0, -2.0,
        -3.0,  1.0, -2.0,  3.0, -1.0,  3.0, -2.0,  1.0, 
         1.0, -1.0,  1.0, -2.0,  2.0, -2.0,  3.0, -2.0,
        -1.0,  3.0, -2.0,  1.0, -3.0,  1.0, -2.0,  3.0,
         2.5, -2.0,  3.0, -2.0,  1.5, -2.0,  2.0, -1.0,
        -3.0,  1.0, -2.0,  3.0, -1.0,  3.0, -2.0,  1.0, 
         1.5, -1.0,  2.0, -1.0,  2.0, -2.0,  1.5, -2.0
    };

void main(void) {
  vec3  dest = texture2D( texture, vertTexCoord.st).rgb;
  uint index = ((uint(gl_FragCoord.x) % 8) * 8) + uint(gl_FragCoord.y) % 8; //+val*8.0 +val*4.0
  dest = dest+DITHER_THRESHOLDS[index]*val/15.0;
  gl_FragColor = vec4(dest,1.0);
}

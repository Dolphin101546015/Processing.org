#ifdef GL_ES
precision highp float;
precision highp int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
varying vec4 vertTexCoord;

uniform  float val = 0.0;

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float rnd(vec2 co){
   float sg=1.0;
   if (rand(vec2(gl_FragCoord.x,rand(vec2(gl_FragCoord.y,gl_FragCoord.x))))>0.5) sg=-sg;
   return sg*fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
	
}

void main(void) {
  vec3  dest = texture2D( texture, vertTexCoord.st).rgb;
  dest = dest+rnd(vec2(gl_FragCoord.x,rand(vec2(gl_FragCoord.y,gl_FragCoord.x))))*val/10.0;
  gl_FragColor = vec4(dest,1.0);
}

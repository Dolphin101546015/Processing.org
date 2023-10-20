#ifdef GL_ES
precision highp float;
precision highp int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
varying vec4 vertTexCoord;
uniform  float val = 0.0;

void main(void) {
 
  vec3 src = texture2D( texture, vertTexCoord.st + vec2( 0, 0)*texOffset.st).rgb;
  vec3 dest=texture2D( texture, vertTexCoord.st + vec2(-1,-1)*texOffset.st).rgb;
  dest -=   texture2D( texture, vertTexCoord.st + vec2( 1, 1)*texOffset.st).rgb;
  dest *= val;
  dest += src;
  gl_FragColor = vec4(dest,1.0);
}
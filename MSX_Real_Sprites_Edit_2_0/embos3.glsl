#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
varying vec4 vertTexCoord;

void main(void) {
  int i = 0;
  int j= 0;
  float r=0,g=0,b=0;
  vec3 dest  = texture2D( texture, vertTexCoord.st + vec2( 0, 0)*texOffset.st).rgb;
  dest+=(texture2D( texture, vertTexCoord.st + vec2(-1,-1)*texOffset.st).rgb-texture2D( texture, vertTexCoord.st + vec2( 1, 1)*texOffset.st).rgb)*1.5;
  gl_FragColor = vec4(dest,1.0);
}
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
  vec3  dest = texture2D( texture, vertTexCoord.st).rgb;
  vec3  newval = vec3(1.0);
  float midpoint = pow(0.5, 2.2);
  dest = (dest-midpoint)*val+midpoint;
  gl_FragColor = vec4(dest,1.0);
}
#ifdef GL_ES
precision highp float;
precision highp int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
varying vec4 vertTexCoord;

uniform  float val = 0.1;

void main(void) {
  vec3 dest = texture2D( texture, vertTexCoord.st).rgb;
  gl_FragColor = vec4(pow(dest, vec3(1.0/val)),1.0);
}
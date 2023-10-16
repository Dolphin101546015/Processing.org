#ifdef GL_ES
precision highp float;
precision highp int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
varying vec4 vertTexCoord;

uniform  float val = 0.0;

float czm_luminance(vec3 rgb)
{
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    return dot(rgb, W);
}

void main(void) {
  vec3 dest = texture2D( texture, vertTexCoord.st).rgb;
	dest.r += czm_luminance(dest)*val;
	dest.g += czm_luminance(dest)*val;
	dest.b += czm_luminance(dest)*val;

  gl_FragColor = vec4(dest,1.0);
}
#ifdef GL_ES
precision highp float;
precision highp int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
varying vec4 vertTexCoord;

uniform  float val = 1.00;

vec3 czm_saturation(vec3 rgb, float adjustment)
{
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    vec3 intensity = vec3(dot(rgb, W));
    return mix(intensity, rgb, adjustment);
}

void main(void) {
  vec3 dest = texture2D( texture, vertTexCoord.st).rgb;
  float luma = dot(dest, const vec3(0.2126729, 0.7151522, 0.0721750));
  dest=luma + val*(dest-luma);
  gl_FragColor = vec4(dest, 1.0);
}

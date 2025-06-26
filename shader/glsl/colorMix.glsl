#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

vec3 colorA = vec3(0.149, 0.141, 0.912);
vec3 colorB = vec3(1.000, 0.833, 0.224);

void main() {
    vec3 color = vec3(0.0);

    float pct = abs(sin(u_time));

    // mix函数以百分比混合两个值，百分比的取值范围为0.0到1.0
    color = mix(colorA, colorB, pct);

    gl_FragColor = vec4(color, 1.0);
}

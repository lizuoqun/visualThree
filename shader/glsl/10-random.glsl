#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// 利用sin、dot计算一个很大的随机数，再通过fract()函数获取小数部分
float random (vec2 st) {
    return fract(sin(dot(st.xy, vec2(78.69, 69.78)))* 4569.05896);
}

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;

    gl_FragColor = vec4(vec3(random(st)), 1.0);
}

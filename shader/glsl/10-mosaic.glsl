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

    st *= 20.0;
    vec2 ipos = floor(st);// floor() 查找小于或等于参数的最接近整数
    vec2 fpos = fract(st);


    vec3 color = vec3(random(ipos));

    //     color = vec3(fpos,0.0);

    gl_FragColor = vec4(color, 1.0);
}

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265358979323846

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// 利用sin、dot计算一个很大的随机数，再通过fract()函数获取小数部分
float random (vec2 st) {
    return fract(sin(dot(st.xy, vec2(78.69, 69.78)))* 4569.05896);
}

vec2 truchetPattern(in vec2 _st, in float _index){
    _index = fract(((_index-0.5)*2.0));
    if (_index > 0.75) {
        _st = vec2(1.0) - _st;
    } else if (_index > 0.5) {
        _st = vec2(1.0-_st.x, _st.y);
    } else if (_index > 0.25) {
        _st = 1.0-vec2(1.0-_st.x, _st.y);
    }
    return _st;
}

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st *= 10.0;

    // 缩放和平移
    // st = (st-vec2(5.0))*(abs(sin(u_time*0.2))*5.);
    // st.x += u_time*3.0;

    vec2 ipos = floor(st);
    vec2 fpos = fract(st);

    vec2 tile = truchetPattern(fpos, random(ipos));

    float color = 0.0;

    // Maze
    color = smoothstep(tile.x-0.3, tile.x, tile.y) - smoothstep(tile.x, tile.x+0.3, tile.y);

    // 把直线都变成曲线
    // color = (step(length(tile),0.6) -
    //          step(length(tile),0.4) ) +
    //         (step(length(tile-vec2(1.)),0.6) -
    //          step(length(tile-vec2(1.)),0.4) );

    gl_FragColor = vec4(vec3(color), 1.0);
}

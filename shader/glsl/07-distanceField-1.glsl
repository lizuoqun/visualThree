#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float circle(in vec2 _st, in float _radius){
    // 把中心点移动到屏幕中心
    vec2 dist = _st - vec2(0.5);
    /**
    * 1.0 - 的作用是将颜色进行反转
    *
    * dot() 函数计算两个向量的点积。如果 x 和 y 相同，则点积的平方根等于向量的长度
    */
    return 1.0 - smoothstep(_radius * 0.99, _radius * 1.01, dot(dist, dist) * 10.0);
}

void main(){
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(vec3(circle(st, 0.9)), 1.0);
}

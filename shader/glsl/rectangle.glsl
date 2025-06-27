#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main(){
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    vec3 color = vec3(0.0);

    /**
    * step() 用于比较两个值，返回一个阶跃函数的结果
    * @param1 临界值（边界值），当 x < edge 时返回 0.0，否则返回 1.0
    * @param2 x
    */

    // 用smoothstep()函数创造的边就是光滑的具有过渡效果的

    //    vec2 bl = step(vec2(0.05), st);
    vec2 bl = smoothstep(vec2(0.05), vec2(0.1), st);
    float pct = bl.x * bl.y;

    //    vec2 tr = step(vec2(0.05), 1.0-st);
    vec2 tr = smoothstep(vec2(0.05), vec2(0.1), 1.0-st);
    pct *= tr.x * tr.y;

    color = vec3(pct);

    gl_FragColor = vec4(color, 1.0);
}

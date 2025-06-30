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


// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    // u = smoothstep(0.,1.,f);

    /**
    * a, b, c, d：分别是当前格子四个角点的随机值（通过 random() 函数生成）。
    *   a: 左下角点值
    *   b: 右下角点值
    *   c: 左上角点值
    *   d: 右上角点值
    * u.x 和 u.y：是小数部分经过插值函数处理后的权重值（通常使用 f * f * (3.0 - 2.0 * f) 或 smoothstep 实现平滑过渡）。
    * mix(a, b, u.x)：在左下 (a) 和右下 (b) 角点之间沿 x 方向进行线性插值。
    * (c - a) * u.y * (1.0 - u.x)：从左下到左上方向的插值贡献。
    * (d - b) * u.x * u.y：从右下到右上方向的插值贡献
    */

    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;

    vec2 pos = vec2(st*5.0);

    float n = noise(pos);

    gl_FragColor = vec4(vec3(n), 1.0);
}

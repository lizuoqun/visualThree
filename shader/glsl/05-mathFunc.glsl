#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float plot(vec2 st) {
    // smoothstep 在两个值之间执行 Hermite 插值
    return smoothstep(0.02, 0.0, abs(st.y - st.x));
}

float plot2(vec2 st, float pct){
    return smoothstep(pct - 0.02, pct, st.y) - smoothstep(pct, pct + 0.02, st.y);
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution;

    // float y = st.x;


    // 此时 y = x^5
    // float y =  pow(st.x, 5.0);

    float y = exp(st.x * -1.0);

    vec3 color = vec3(y);

    // pct 是一个0到1之间的插值因子
    // float pct = plot(st);

    float pct = plot2(st, y);

    // 1.0 - pct 将插值因子反转，当 pct 接近 0（远离直线）时，1.0 - pct 接近 1.0；而当 pct 接近 1.0（靠近直线）时，1.0 - pct 接近 0.0
    color = (1.0 - pct) * color + pct * vec3(0.0, 1.0, 0.0);
    gl_FragColor = vec4(color, 1.0);
}

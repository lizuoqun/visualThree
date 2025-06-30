#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    st.x *= u_resolution.x / u_resolution.y;

    vec3 color = vec3(.0);

    // Cell positions
    vec2 point[5];
    point[0] = vec2(0.83,0.75);
    point[1] = vec2(0.60,0.07);
    point[2] = vec2(0.28,0.64);
    point[3] =  vec2(0.31,0.26);
    point[4] = u_mouse / u_resolution;

    float m_dist = 1.; 

    for (int i = 0; i < 5; i++) {
        float dist = distance(st, point[i]);
        m_dist = min(m_dist, dist);
    }

    color += m_dist;

    // color -= step(0.7,abs(sin(100.0 * m_dist)))*.3;

    gl_FragColor = vec4(color,1.0);
}

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main() {
    // 对坐标进行了规范化。这样做是为了使所有的值落在 0.0 到 1.0 之间
    vec2 st = gl_FragCoord.xy/u_resolution;
    // 扩展：根据时间改变颜色
    // st.x = abs(sin(u_time));

    /**
    * 扩展：通过鼠标位置改变颜色
    * u_mouse.y 是鼠标在屏幕上的 Y 坐标，通常是以像素为单位的值。
    * u_resolution.y 是画布的高度，通过将 u_mouse.y 除以 u_resolution.y，我们将鼠标位置归一化到 [0, 1] 的范围，这样可以与 st 坐标对齐
    */
    st.y = u_mouse.y/u_resolution.y;
    gl_FragColor = vec4(st.x, st.y, 0.0, 1.0);
}

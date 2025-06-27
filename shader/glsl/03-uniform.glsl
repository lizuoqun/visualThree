#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;

// 通过改变时间来控制颜色变化（渐变）
void main() {
	// gl_FragColor = vec4(1.0,0.0,0.0,abs(sin(u_time)));
	gl_FragColor = vec4(abs(sin(u_time)),abs(cos(u_time)),abs(tan(u_time)),abs(sin(u_time)));
}

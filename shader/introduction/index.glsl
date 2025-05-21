#ifdef GL_ES
precision mediump float;
#endif

void main(){
    gl_FragColor = vec4(0.1, 0.4, 0.5, 1.0) * vec4(1, 1, 0.5, 1.0);
}
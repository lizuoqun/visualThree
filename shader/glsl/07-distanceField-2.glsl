#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main(){
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    st.x *= u_resolution.x / u_resolution.y;
    vec3 color = vec3(0.0);
    float d = 0.0;

    st = st *2.-1.;

    //计算0.3到四象限的距离
    d = length(abs(st)-.3);

    // min、max 返回两个值的最小值或最大值
    //  d = length( min(abs(st)-.3,0.) );
    // d = length( max(abs(st)-.3,0.) );


    /**
    * fract() 计算参数的小数部分
    */
    gl_FragColor = vec4(vec3(fract(d*10.0)), 1.0);

    // gl_FragColor = vec4(vec3( step(.3,d) ),1.0);
    // gl_FragColor = vec4(vec3( step(.3,d) * step(d,.4)),1.0);
    // gl_FragColor = vec4(vec3( smoothstep(.3,.4,d)* smoothstep(.6,.5,d)) ,1.0);
}

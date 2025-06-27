#ifdef GL_ES
precision mediump float;
#endif

#define TWO_PI 6.28318530718

uniform vec2 u_resolution;
uniform float u_time;

vec3 hsb2rgb(in vec3 c){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0, 4.0, 2.0), 6.0)-3.0)-1.0, 0.0, 1.0);
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

void main(){
    vec2 st = gl_FragCoord.xy / u_resolution;
    vec3 color = vec3(0.0);

    vec2 toCenter = vec2(0.5)-st;
    /**
    * atan() 返回参数的反正切值
    * @param1 y指定要返回其 arctangent 的分数的分子
    * @param2 x 指定要返回其 arcTangent 的分数的分母
    * @param3 y_over_x 指定要返回其 arctangent 的分数
    */
    float angle = atan(toCenter.y, toCenter.x);
    // length(param) 指定要计算其长度的向量
    float radius = length(toCenter)*2.0;

    color = hsb2rgb(vec3((angle/TWO_PI)+0.5, radius, 1.0));

    gl_FragColor = vec4(color, 1.0);
}

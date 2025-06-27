#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main(){
    vec2 st = gl_FragCoord.xy/u_resolution;
    float pct = 0.0;

    /**
    * 方案一
    * distance() 计算两点之间的距离
    * @param1 起点
    * @param2 终点
    * @return 返回两个点之间的距离
    */
    //    pct = distance(st, vec2(0.5));


    /**
    * 方案二
    * length() 指定要计算其长度的向量
    */
    //    vec2 toCenter = vec2(0.5) - st;
    //    pct = length(toCenter);

    /**
    * 方案三
    * sqrt() 计算平方根
    * @param1 x 指定要计算其平方根的数字
    * @return 返回 x 的平方根
    */
    vec2 tC = vec2(0.5) - st;
    pct = sqrt(tC.x * tC.x + tC.y * tC.y);


    gl_FragColor = vec4(vec3(pct), 1.0);
}

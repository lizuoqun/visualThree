#ifdef GL_ES
precision mediump float;
#endif

// 声明一个uniform变量，用于接收窗口的分辨率
uniform vec2 u_resolution;

void main(){
       // 将当前片段坐标归一化并居中，以较短边为基准进行缩放
       vec2 p=(gl_FragCoord.xy*2.-u_resolution)/min(u_resolution.x,u_resolution.y);
       
       // 初始化三种颜色
       vec3 color1=vec3(0);
       vec3 color2=vec3(0);
       vec3 color3=vec3(0);
       
       // 如果当前片段坐标在指定圆心和半径范围内，则设置color1为蓝色
       if(distance(vec2(0,0.2),vec2(p.xy))<=0.4)
       {
              color1=vec3(0,0,1);
       }
       
       // 如果当前片段坐标在指定圆心和半径范围内，则设置color2为红色
       if(distance(vec2(-0.2,-0.2),vec2(p.xy))<=0.4)
       {
              color2=vec3(1,0,0);
       }
       
       // 如果当前片段坐标在指定圆心和半径范围内，则设置color3为绿色
       if(distance(vec2(0.2,-0.2),vec2(p.xy))<=0.4)
       {
              color3=vec3(0,1,0);
       }
       
       // 将三种颜色叠加，得到最终的颜色
       vec3 color=vec3(0,0,0)+color1+color2+color3;
       
       // 设置片段的最终颜色，alpha值为1
       gl_FragColor=vec4(color,1);
}
#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;

void main(){
       vec2 p=(gl_FragCoord.xy*2.-u_resolution)/min(u_resolution.x,u_resolution.y);
       vec3 color1=vec3(0);
       vec3 color2=vec3(0);
       vec3 color3=vec3(0);
       if(distance(vec2(0.,.2),vec2(p.xy))<=0.4)
       {
              color1=vec3(0,0,1);
       }
       
       if(distance(vec2(-0.2,-0.2),vec2(p.xy))<=0.4)
       {
              color2=vec3(1,0,0);
       }
       if(distance(vec2(0.2,-0.2),vec2(p.xy))<=0.4)
       {
              color3=vec3(0,1,0);
       }
       
       vec3 color=vec3(0,0,0)+color1+color2+color3;
       
       gl_FragColor=vec4(color,1);
}
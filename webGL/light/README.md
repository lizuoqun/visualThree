# 光照

> 现实世界中的物体被光线照射时，会反射一部分光。只有当反射光线进人你的眼睛时，你才能够看到物体并辩认出它的颜色。

## 光源类型

- 平行光（Directional
  Light）：光线是相互平行的，平行光具有方向。平行光可以看作是无限远处的光源（比如太阳）发出的光。因为太阳距离地球很远，所以阳光到达地球时可以认为是平行的。平行光很简单，可以用<font color="red">
  **一个方向**</font>和<font color="red">**一个颜色**</font>来定义
- 点光源（Point
  Light）：是从一个点向周围的所有方向发出的光。点光源光可以用来表示现实中的灯泡、火焰等。我们需要指定点光源的<font color="red">
  **位置和颜色**</font>。光线的方向将根据点光源的位置和被照射之处的位置计算出来，因为点光源的光线的方向在场景内的不同位置是不同的。
- 环境光（Ambient
  Light）：环境光（间接光）是指那些经光源（点光源或平行光源）发出后，被墙壁等物体多次反射，然后照到物体表面上的光。环境光从各个角度照射物体，其强度都是致的。比如说，在夜间打开冰箱的门，整个厨房都会有些微微亮，这就是环境光的作用。环境光不用指定位置和方向，只需要指定<font color="red">
  **颜色**</font>即可。

## 反射类型

- 漫反射（Diffuse
  Reflection）：是针对平行光或点光源而言的。漫反射的反射光在各个方向上是均匀的，如果物体表面像镜子一样光滑，那么光线就会以特定的角度反射出去；但是现实中的大部分材质，比如纸张、岩石、塑料等，其表面都是粗糙的，在这种情况下反射光就会以不固定的角度反射出去。
- 环境反射（Ambient Reflection）：环境反射是针对环境光而言的。在环境反射中，反射光的方向可以认为就是人射光的反方向。由于环境光照射物体的方式就是各方向均匀、强度相等的，所以反射光也是各向均匀的。

### 漫反射颜色公式

> 漫反射颜色 = 入射光颜色 * 表面基底色 * cos A

式子中，入射光颜色指的是点光源或平行光的颜色，乘法操作是在颜色矢量上逐分量（R、G、B）进行的。因为漫反射光在各个方向上都是“均匀”的，所以从任何角度看上去其强度都相等。

### 环境反射颜色公式

> 环境反射颜色 = 环境光颜色 * 表面基底色

当漫反射和环境反射同时存在时，将两者加起来，就会得到物体最终被观察到的颜色

### 计算入射角

根据入射光的方向和物体表面的朝向（即法线方向）来计算出入射角。在创建三维模型的时候，无法预先确定光线将以怎样的角度照射到每个表面上
但是可以确定每个表面的朝向。在指定光源的时候，再确定光的方向，就可以用这两项信息来计算出入射角了。

> 在线性代数当中，对矢量n和1作点积运算，公式为：n·1 = |n||1|cosA，其中||符号表示向量的模（长度）。如果两个矢量长度都是1，则点积运算结果为
> cosA。

那么就可以对前面漫反射颜色公式进行调整：
> 漫反射颜色 = 入射光颜色 * 表面基底色 * (光线方向 * 法线方向)
>
> - 光线方向矢量和表面法线矢量的长度必须为1（单位向量）
> - 光线方向，实际上是入射方向的反方向，即从入射点指向光源方向

**法线：表面朝向**

物体表面的朝向，即垂直于表面的方向，又称法线或法向量。法向量有三个分量，向量（Nx，Ny，Nz）表示从（0,0,0）到（Nx,Ny,Nz）的方向。

- 矢量n为（Nx,Ny,Nz）则其长度为|n| = sqrt(Nx^2 + Ny^2 + Nz^2)
- 对矢量进行归一化后的结果是（Nx/m,Ny/m,Nz/m）,其中m是n的的模。如矢量(2.0,2.0,1.0)的长度|n|=sqrt(2.0^2+2.0^2+1.0^2)=sqrt(9)
  =3.0，那么归一化后的结果是（2.0/3.0,2.0/3.0,1.0/3.0）

## 平行光

### 角度的余弦值

首先来补充一下数学知识，看一下各个角度的余弦值：（这里一起把正弦和正切都加上了）

| 角度 (°) | 余弦值 (Cos) | 正弦值 (Sin) | 正切值 (Tan) |
|--------|-----------|-----------|-----------|
| 0      | 1         | 0         | 0         |
| 30     | √3/2      | 1/2       | √3/3      |
| 45     | √2/2      | √2/2      | 1         |
| 60     | 1/2       | √3/2      | √3        |
| 90     | 0         | 1         | 无定义 (∞)   |
| 120    | -1/2      | √3/2      | -√3       |
| 135    | -√2/2     | √2/2      | -1        |
| 150    | -√3/2     | 1/2       | -√3/3     |
| 180    | -1        | 0         | 0         |
| 210    | -√3/2     | -1/2      | √3/3      |
| 225    | -√2/2     | -√2/2     | 1         |
| 240    | -1/2      | -√3/2     | √3        |
| 270    | 0         | -1        | 无定义 (-∞)  |
| 300    | 1/2       | -√3/2     | -√3       |
| 315    | √2/2      | -√2/2     | -1        |
| 330    | √3/2      | -1/2      | -√3/3     |
| 360    | 1         | 0         | 0         |

那么再根据前面的入射角的公式，那么我们简单计算一下几个案例，在反射之后的颜色值

> 漫反射颜色 = 入射光颜色 * 表面基底色 * (光线方向 * 法线方向) = 入射光颜色 * 表面基底色 * cos A

| 入射光颜色            | 表面基底色       | 角度 | 角度余弦值 | 计算RGB                                             | 漫反射颜色   |
|------------------|-------------|----|-------|---------------------------------------------------|---------|
| (1.0,1.0,1.0) 白色 | (1.0,0,0)红色 | 0  | 1.0   | R=(1 * 1 * 1)<br/>G=(1 * 0 * 1)<br/>B=(1 * 0 * 1) | (1,0,0) |
| (1.0,1.0,1.0) 白色 | (1.0,0,0)红色 | 90 | 0     | R=(1 * 1 * 0)<br/>G=(1 * 0 * 0)<br/>B=(1 * 0 * 0) | (0,0,0) |

### 平行光案例

补充：前面都是采用drawArray方法绘制的正方体，这样的话数组对象太多内容了，看的头都晕了，还可以采用drawElements对前面的代码进行重构优化一下。

数据对象可以进行一个拆分。boxArray数组表示的是每一个面的四个顶点的坐标位置，以第一行为例，就是从v0-v1-v2-v3的位置。那么对应的index就表示顶点位置的索引（因为一个正方形要拆分成两个三角形，这也是这里的index一行为什么是6个数据的原因）。

```js
    //    v6----- v5
    //   /|      /|
    //  v1------v0|
    //  | |     | |
    //  | |v7---|-|v4
    //  |/      |/
    //  v2------v3

let boxArray = [
  1.0, 1.0, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, -1.0, -1.0, 1.0, 1.0, 1.0, -1.0, 1.0, 1.0, // v0-v1-v2-v3
  1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, -1.0, -1.0, 1.0, 1.0, 1.0, -1.0, 1.0, // v0-v3-v4-v5
  1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0, -1.0, 1.0, -1.0, 1.0, -1.0, 1.0, 1.0, 1.0, // v0-v5-v6-v1
  -1.0, 1.0, 1.0, 1.0, -1.0, 1.0, -1.0, 1.0, -1.0, -1.0, -1.0, 1.0, -1.0, -1.0, 1.0, 1.0, // v1-v6-v7-v2
  -1.0, -1.0, -1.0, 1.0, 1.0, -1.0, -1.0, 1.0, 1.0, -1.0, 1.0, 1.0, -1.0, -1.0, 1.0, 1.0, // v7-v4-v3-v2
  1.0, -1.0, -1.0, 1.0, -1.0, -1.0, -1.0, 1.0, -1.0, 1.0, -1.0, 1.0, 1.0, 1.0, -1.0, 1.0 // v4-v7-v6-v5
];

let index = [
  0, 1, 2, 0, 2, 3,    // front
  4, 5, 6, 4, 6, 7,    // right
  8, 9, 10, 8, 10, 11,    // up
  12, 13, 14, 12, 14, 15,    // left
  16, 17, 18, 16, 18, 19,    // down
  20, 21, 22, 20, 22, 23     // back
];

```

后面进行数据组合的方法和之前是一样的。注意一下绑定的着色器的变量即可，以及最后drawElements方法，

```js
let pointPosition = new Float32Array(boxArray);
let aPsotion = webGL.getAttribLocation(program, 'a_position');
let triangleBuffer = webGL.createBuffer();
webGL.bindBuffer(webGL.ARRAY_BUFFER, triangleBuffer);
webGL.bufferData(webGL.ARRAY_BUFFER, pointPosition, webGL.STATIC_DRAW);
webGL.enableVertexAttribArray(aPsotion);
webGL.vertexAttribPointer(aPsotion, 4, webGL.FLOAT, false, 4 * 4, 0);

let indexBuffer = webGL.createBuffer();
let indices = new Uint8Array(index);
webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, indexBuffer);
webGL.bufferData(webGL.ELEMENT_ARRAY_BUFFER, indices, webGL.STATIC_DRAW);

webGL.drawElements(webGL.TRIANGLES, 36, webGL.UNSIGNED_BYTE, 0);
```

平行光案例实现：调整着色器代码，看一下整个着色器代码调整的完整流程。

```mermaid
graph TB
    subgraph 顶点着色器 by modify
        A(顶点坐标 a_position)
        B(透视投影 u_formMatrix)
        C(法向量 a_Normal)
        D(光照方向 u_LightDirection)
        E(漫射光 u_DiffuseLight)
        F(环境光 u_AmbientLight)
        G(颜色 v_Color)
    end

    subgraph 片元着色器
        Z(v_Color)
    end

    C --> C1(归一化法向量 normalize)
    D --> D1(归一化光线方向 normalize)
    C1 -- dot计算点积、max取最大值 --> H(法向量与光线方向的点积)
    D1 --> H
    E --> I(计算漫反射颜色)
    H --> I
    F --> F1(计算环境光颜色)
    F1 -- 相加 --> J(颜色合并)
    I -- 相加 --> J
    G -- 利用varying变量传值 --> 片元着色器
    J --> 片元着色器

```

通过这个流程图也就结合了前面计算漫反射公式得到了漫反射的颜色，所以最后在片元着色器中利用varying变量传值，进行颜色合并。那么也就渲染到了物体上。

```js
let vertexString = `
  attribute vec4 a_position;
  uniform mat4 u_formMatrix;
  attribute vec4 a_Normal;
  uniform vec3 u_LightDirection;
  uniform vec3 u_DiffuseLight;
  uniform vec3 u_AmbientLight;
  varying vec4 v_Color;
  void main(void){
    gl_Position = u_formMatrix * a_position;
    vec3 normal = normalize(a_Normal.xyz);
    vec3 LightDirection = normalize(u_LightDirection.xyz);
    float nDotL = max(dot(LightDirection, normal), 0.0);
    vec3 diffuse = u_DiffuseLight * vec3(1.0,0,1.0)* nDotL;
    vec3 ambient = u_AmbientLight * vec3(1.0,0,1.0);
    v_Color = vec4(diffuse + ambient, 1);
  }`;
let fragmentString = `
  precision mediump float;
  varying vec4 v_Color;
  void main(void){
    gl_FragColor =v_Color;
  }
  `;
```

第二步就是设置法向量和光线方向，以及漫反射和环境光。而后结合前面的通过drawElements进行绘制。那也就完成了平行光案例。

```js
let normals = new Float32Array([
  0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0,  // v0-v1-v2-v3 front
  1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0,  // v0-v3-v4-v5 right
  0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0,  // v0-v5-v6-v1 up
  -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0,  // v1-v6-v7-v2 left
  0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0,  // v7-v4-v3-v2 down
  0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0   // v4-v7-v6-v5 back
]);
let aNormal = webGL.getAttribLocation(program, 'a_Normal');
let normalsBuffer = webGL.createBuffer();
let normalsArr = new Float32Array(normals);
webGL.bindBuffer(webGL.ARRAY_BUFFER, normalsBuffer);
webGL.bufferData(webGL.ARRAY_BUFFER, normalsArr, webGL.STATIC_DRAW);
webGL.enableVertexAttribArray(aNormal);
webGL.vertexAttribPointer(aNormal, 3, webGL.FLOAT, false, 3 * 4, 0);

let u_DiffuseLight = webGL.getUniformLocation(program, 'u_DiffuseLight');
webGL.uniform3f(u_DiffuseLight, 1.0, 1.0, 1.0);
let u_LightDirection = webGL.getUniformLocation(program, 'u_LightDirection');
webGL.uniform3fv(u_LightDirection, [0, 0, 10.0]);
let u_AmbientLight = webGL.getUniformLocation(program, 'u_AmbientLight');
webGL.uniform3f(u_AmbientLight, 0.2, 0.2, 0.2);
```

## 点光源

> 漫反射光颜色 = 入射光颜色 * 表面基底色 * cos A
>
> cos A = 光线方向 * 法线方向

在点光源是没有光照方向的，光照方向需要通过光源位置-顶点位置来计算。两者相减就会得到入射光方向向量。这样就需要调整一下着色器代码。

- 新增变量：u_PointLightPosition，u_NormalMatrix（法线变换矩阵）
- 计算normal，将法线向量从模型空间转换到视图空间或世界空间
- 计算入射光方向向量

```js
let vertexString = `
  attribute vec4 a_position;
  uniform mat4 u_formMatrix;
  attribute vec4 a_Normal;
  uniform vec3 u_PointLightPosition;
  uniform vec3 u_DiffuseLight;
  uniform vec3 u_AmbientLight;
  varying vec4 v_Color;
  uniform mat4 u_NormalMatrix;
  void main(void){
    gl_Position = u_formMatrix * a_position;
    vec3 normal = normalize(vec3(u_NormalMatrix * a_Normal));
    vec3 LightDirection = normalize(vec3(gl_Position.xyz) - u_PointLightPosition);
    float nDotL = max(dot(LightDirection, normal), 0.0);
    vec3 diffuse = u_DiffuseLight * vec3(1.0,0,1.0)* nDotL;
    vec3 ambient = u_AmbientLight * vec3(1.0,0,1.0);
    v_Color = vec4(diffuse + ambient, 1);
  }`;
```

接着就是在js当中设置u_PointLightPosition，u_NormalMatrix。

```js
let u_PointLightPosition = webGL.getUniformLocation(program, 'u_PointLightPosition');
webGL.uniform3fv(u_PointLightPosition, [10, 0, 0]);

let uniformNormalMatrix = webGL.getUniformLocation(program, 'u_NormalMatrix');
let normalMatrix = mat4.create();
mat4.identity(normalMatrix);
mat4.invert(normalMatrix, ModelMatrix);
mat4.transpose(normalMatrix, ModelMatrix);
webGL.uniformMatrix4fv(uniformNormalMatrix, false, normalMatrix);
```

## 环境光

环境光相对于平行光和点光源来说，相对简单些，不用再去计算漫反射光了，只需要计算环境光。那么其着色器代码调整如下：只需要传递一个环境光进来，然后直接和基底色相乘就是渲染后的颜色了。

```js
let vertexString = `
  attribute vec4 a_position;
  uniform mat4 u_formMatrix;
  uniform vec3 u_AmbientLight;
  varying vec4 v_Color;
  void main(void){
    gl_Position = u_formMatrix * a_position;
    vec3 ambient = u_AmbientLight * vec3(1.0,1.0,1.0);
    v_Color = vec4(ambient, 1);
  }`;
```

传值也将其他的都进行删去，设置u_AmbientLight即可。那么这里的值就是（0.8,0.1,0）颜色值就是 (255*0.8, 255*0, 255*0.1) = (
204,0,51) 橙红色。

```js
let u_AmbientLight = webGL.getUniformLocation(program, 'u_AmbientLight');
webGL.uniform3f(u_AmbientLight, 0.8, 0.1, 0);
```

## 逐片元光照

再来先回顾一下webGL整个渲染的流程

```mermaid
graph LR
    A(js) --> B(缓冲区对象) --> C(顶点着色器) --> D(顶点坐标) --> E(图形装配) --> F(光栅化) --> G(片元着色器) --> H(浏览器)
```

### 逐顶点着色

在逐顶点渲染中，前面讲的光照或颜色的计算是在顶点着色器中进行的，顶点着色器运行结束后，每一个顶点都有一个颜色值，在片元着色器执行前，webGL会对这些顶点的颜色数据进行线性插值，从而得到每个片元处的颜色。这就是webGL绘制三角形的原理，为什么只给了3个顶点的颜色值就能得到一个彩色的三角形的缘故，即三角形中其他点(
片元)的颜色值都是通过这给定的3个顶点的颜色值通过线性插值得到的。

### 逐片元着色

每个像素都被填充了光栅化处理后的颜色，并写入颜色缓冲区，直到最后一个片元被处理完成，浏览器就会显示出最终的彩色三角形

逐片元的计算光照条件：

- 片元在世界坐标系下的坐标。
- 片元处表面的法向量。可以在顶点着色器中，将顶点的世界坐标和法向量以varying变量的形式传人片元着色器，片元着色器中的同名变量就已经是内插后的逐片元值了。

### 绘制球

#### 球体任意一点点坐标

在前面绘制立体图形都是长方体这种可以确定具体的顶点坐标，那么绘制球体的时候我们怎么拿到对应的坐标再进行绘制呢？

如下图所示，这是一个球，现在已知半径为r，求球上一点P的坐标，其中该点与中心点连线与z轴的夹角为θ，该点往平面做投影，投影到中心点连线和x轴的夹角为φ。

那么就可以得到p点的xyz坐标：并且现在只需要将φ转360度，θ转180度，即可得到球上任意一点的xyz坐标。

- x=rsinθcosφ
- y=rsinθsinφ
- z=rcosθ

#### webGL渲染球体（逐顶点着色）

在webGL当中所有的图形都是通过很多个三角形进行组成的，下面开始计算球体的顶点坐标：也就是将上面的数学公式转成js代码。（在前面所有学习和实现的效果都是采用的逐顶点着色，也就是js将颜色值传递到顶点着色器当中，顶点着色器将所有的颜色都处理好了之后再通过varying传递给片元着色器）

```js
let positions = [];
const SPHERE_DIV = 10;

let i, ai, si, ci;
let j, aj, sj, cj;


for (j = 0; j <= SPHERE_DIV; j++) {
  aj = j * Math.PI / SPHERE_DIV;
  sj = Math.sin(aj);
  cj = Math.cos(aj);
  for (i = 0; i <= SPHERE_DIV; i++) {
    ai = i * 2 * Math.PI / SPHERE_DIV;
    si = Math.sin(ai);
    ci = Math.cos(ai);

    positions.push(ci * sj);  // X
    positions.push(cj);       // Y
    positions.push(si * sj);  // Z
  }
}

webgl.drawArrays(webgl.TRIANGLES, 0, positions.length / 3);
```

使用drawArrays进行渲染，直接根据顶点缓冲区的数据顺序绘制。这里的顶点数量不够，因为只计算了一些点，并且这些点没有复用，组成的三角形不能完全覆盖球体，所以就是这种效果
改用drawElements进行渲染，需要再加上计算点索引的数组的代码。

```js
let p1, p2;

for (j = 0; j < SPHERE_DIV; j++) {
  for (i = 0; i < SPHERE_DIV; i++) {
    p1 = j * (SPHERE_DIV + 1) + i;
    p2 = p1 + (SPHERE_DIV + 1);

    indices.push(p1);
    indices.push(p2);
    indices.push(p1 + 1);

    indices.push(p1 + 1);
    indices.push(p2);
    indices.push(p2 + 1);
  }
}

webGL.drawElements(webGL.TRIANGLES, indices.length, webGL.UNSIGNED_BYTE, 0);
```

#### webGL渲染球体（逐片元着色）

逐片元着色和逐顶点着色的区别就是，逐片元着色是在片元着色器中计算光照，逐顶点着色是在顶点着色器中计算光照。那么就调整一下着色器代码

```js
let vertexString = `
  attribute vec4 a_position;
  uniform mat4 u_formMatrix;
  attribute vec4 a_Normal;
  varying vec4 v_Normal;
  varying vec4 v_position;
  void main(void){
    gl_Position = u_formMatrix * a_position;
    v_position = gl_Position;
    v_Normal= a_Normal;
  }`;
let fragmentString = `
  precision mediump float;
   
  varying vec4 v_Normal;
  varying vec4 v_position;
  uniform vec3 u_PointLightPosition;
  uniform vec3 u_DiffuseLight;
  uniform vec3 u_AmbientLight;
  void main(void){
    vec3 normal = normalize(v_Normal.xyz);
    vec3 lightDirection = normalize(u_PointLightPosition - vec3(v_position.xyz));
    float nDotL = max(dot(lightDirection, normal), 0.0);
    vec3 diffuse = u_DiffuseLight * vec3(1.0,0,1.0) * nDotL;
    vec3 ambient = u_AmbientLight * vec3(1.0,0,1.0);
    gl_FragColor = vec4(diffuse + ambient, 1);
  }`;
```
# 颜色 & 纹理

## 传递非坐标数据到顶点着色器

在前面的例子中，我们传递了顶点坐标到顶点着色器，然后由顶点着色器计算出顶点在屏幕上的位置。然后例子当中也有一个大小的值。下面用来实现传递大小值给点

修改顶点着色器代码

```js
let vertexString = `
    attribute vec4 a_position;
    attribute float size1;
    uniform float size2;
    void main(){
      gl_Position = a_position;
      gl_PointSize = size1;
    }`;
```

这里可以用 attribute 和 uniform 定义大小的值，然后传递给顶点着色器，那么对应他的 js 赋值的代码如下：

利用 attribute 传递变量需要以下五个步骤、

- 创建缓冲区对象
- 绑定 buffer
- 将数据写入到缓冲区对象
- 将缓冲区对象分配给 attribute 变量
- 开启 attribute 变量

而同时使用 uniform 传递变量就可以直接获取进行赋值效果是一样的，都可以把值传递进去（但是这里 uniform
传值设置的是随机数，但是设置的所有顶点的值都是同一个）

```js
// attribute
const sizeArray = new Float32Array([60, 100, 80, 30]);
let sizeBuffer = webGL.createBuffer();
webGL.bindBuffer(webGL.ARRAY_BUFFER, sizeBuffer);
webGL.bufferData(webGL.ARRAY_BUFFER, sizeArray, webGL.STATIC_DRAW);
let aSize = webGL.getAttribLocation(program, "size");
// 参数说明：attribute变量，传递值个数、数据类型，是否要归一化，跨度，偏移量
webGL.vertexAttribPointer(aSize, 1, webGL.FLOAT, false, 4, 0);
webGL.enableVertexAttribArray(aSize);

// uniform
let uSize = webGL.getUniformLocation(program, "size2");
webGL.uniform1f(uSize, Math.random() * 100);
```

### 拓展 attribute 和 uniform 的使用

| 特性    | attribute                   | uniform            |
|-------|-----------------------------|--------------------|
| 作用范围  | 逐顶点（每个顶点不同）                 | 全局（所有顶点共享）         |
| 数据来源  | 顶点缓冲区（如顶点坐标数组）              | 直接通过 JavaScript 设置 |
| 更新频率  | 每个顶点处理时更新                   | 一次绘制调用中保持不变        |
| 典型用途  | 顶点位置、颜色、纹理坐标                | 变换矩阵、全局参数          |
| WebGL | 设置方法 gl.vertexAttribPointer | gl.uniform\* 系列函数  |

如何选择？

- 用 attribute：当数据需要为每个顶点单独指定时（例如顶点坐标、颜色）
- 用 uniform：当数据对所有顶点一致时（例如变换矩阵、全局光照参数）

## 修改颜色

现在已经知道了将其他非坐标数据传递给顶点着色器了，同样的方法可以将颜色数据传递过去，但是处理颜色是在片元着色器当中，接下来看怎么将数据从顶点着色器传到片元着色器

先搞点传递给顶点着色器（在顶点着色器里面定义一个 attribute 的 a_color 值）

```js
const colorArray = new Float32Array([
  1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0,
]);
let aColor = webGL.getAttribLocation(program, "a_color");
let colorBuffer = webGL.createBuffer();
webGL.bindBuffer(webGL.ARRAY_BUFFER, colorBuffer);
webGL.bufferData(webGL.ARRAY_BUFFER, colorArray, webGL.STATIC_DRAW);
webGL.vertexAttribPointer(aColor, 4, webGL.FLOAT, false, 4 * 4, 0);
webGL.enableVertexAttribArray(aColor);
```

将顶点着色器的值共享给片元着色器只需要有一个 varying 修饰的相同变量即可，这个时候的顶点和片元的代码如下：表示将js当中赋值的a_color给到v_color，
同时由于v_color是varying修饰的所以可以共享v_color给片元着色器

```js
// 顶点着色器
const vertexString = `
    attribute vec4 a_position;
    uniform mat4 proj;
    attribute float size;
    attribute vec4 a_color;
    varying vec4 v_color;
    void main(){
        gl_Position = proj * a_position;
        gl_PointSize = size;
        v_color = a_color;
    }`;

// 片元着色器
const fragmentString = `
    varying vec4 v_color;
    void main(){
        gl_FragColor = v_color;
    }`;
```

> 注：报错：<span style="color:red">ERROR: 0:2: '' : No precision specified for (float)</span>
>
> 原因是：片元着色器中未声明浮点型（float）变量的默认精度。GLSL ES规范要求片元着色器必须显式定义浮点类型的精度，否则编译器会报错‌
>
> 解决：在片元着色器中声明精度，如：precision mediump float;

### 拓展 precision mediump float

precision：用于声明着色器中浮点数或整数的计算精度

**为什么片元着色器必须声明？‌**

- 顶点着色器默认支持 highp。顶点着色器中的 float 默认是 highp，无需显式声明
- 片元着色器无默认精度‌。片元着色器中的 float 精度必须手动指定，否则编译器报错（No precision specified）

**精度对性能和效果的影响**

| 精度等级    | 	性能 | 	适用场景               | 	典型问题                |
|---------|-----|---------------------|----------------------|
| float   | 高   | 一般计算（如颜色、阴影、纹理采样）   | 移动设备可能不支持或性能差        |
| highp   | 低   | 需要高精度的计算（如复杂光照、抗锯齿） | 移动设备可能不支持或性能差        |
| mediump | 中   | 大多数颜色计算（纹理采样、颜色混合）  | 极小数（如 < 0.0001）可能被截断 |
| lowp    | 高   | 简单颜色计算（如纯色、低精度渐变）   | 颜色过渡可能出现断层           |

## 渐变三角形

在顶点着色器和片元着色器之间还有两个步骤

- 图形装配过程：将孤立的顶点坐标装配成几何图形。几何图形 的类别由gl.drawArrays()函数的第一个参数决定
- 光栅化：装配好的几何图形转化为片元

在光栅化过程生成的片元都是带有坐标信息的，调用片元着色器时这些坐标信息也随着片元传了进去，我们可以通过片元着色器中的内置变量来访问片元的坐标

在前面已经有一个创建三角形的案例，然后也知道怎么把颜色赋值进去了，修改片元着色器

> vec4 gl_FragCoord 该内置变量的第1个和第2个分量表示片元在<canvas>坐标系统（窗口坐标系统）中的坐标值

```js
const fragmentString = `
  precision mediump float;
  uniform float u_width;
  uniform float u_height;
  void main(){
    gl_FragColor = vec4(gl_FragCoord.x / u_width, 0.0, gl_FragCoord.y / u_height, 1.0);
  }`;
```

然后在js当中给片元着色器传递一个 u_width 和 u_height 的值，然后就可以得到一个渐变的三角形了（传递的值就是canvas的宽高）

```js
let uniformWidth = webGL.getUniformLocation(program, 'u_width');
webGL.uniform1f(uniformWidth, 1024.0);

let uniformHeight = webGL.getUniformLocation(program, 'u_height');
webGL.uniform1f(uniformHeight, 768.0);
```
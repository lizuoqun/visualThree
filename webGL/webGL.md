> 前言：在学习 threejs 3D 开发的时候以及后续效果制作的时候，最开始还是有些吃力的，并且在其中运用到一些着色器，一步步试坑过来，还是回到最开始的地方来补一下基础，就有了这一个 webGL 的笔记。

> 其中，教程来自于 bilibili【2022 年 WebGL 入门教程（完结）】 https://www.bilibili.com/video/BV1Kb4y1x72q/?p=4&share_source=copy_web&vd_source=41d2dced76db87052ab1d8a28194bd8f

> github 仓库地址：https://github.com/lizuoqun/visualThree/tree/main/webGL

# webGL 概述及点绘制

## WebGL 容器（坐标系）

WebGL 使用的是正交右手坐标系，且每个方向都有可使用的值的区间，超出该矩形区间的图像不会绘制
x，y，z 的区间都是-1 到 1
注：这些值与 Canvas 的尺寸无关，无论 Canvas 的长宽比是多少，WebGL 的区间值都是一致的

<image src="./blog/webgl坐标系.png"/>

## WebGL 渲染管线

```mermaid
graph LR

    subgraph 测试
        归属测试-->模版测试
        模版测试-->深度测试
    end

    subgraph 片元数据
        uniform数据 --> 片元着色器
        纹理缓冲区 --> 片元着色器
    end

顶点缓冲区 -- uniform数据 --> 顶点着色器
顶点着色器 --> 图元装配
图元装配 --> 光栅器
光栅器 --> 片元着色器
片元着色器--> 归属测试
深度测试-->深度缓冲区
深度测试-->融合
融合-->抖动
抖动-->颜色缓冲区
```

### 顶点着色器

顶点着色器是 GPU 渲染管线上一个可以执行着色器语言的功能单元，具体执行的就是顶点着色器程序，WebGL 顶点着色器程序在 Javascript 中以字符串的形式存在，通过编译处理后传递给顶点着色器执行。 顶点着色器主要作用就是执行顶点着色器程序对顶点进行变换计算，比如顶点位置坐标执行进行旋转、平移等矩阵变换，变换后新的顶点坐标然后赋值给内置变量 gl_Position，作为顶点着色器的输出，图元装配和光栅化环节的输入。

```mermaid
graph LR
uniform数据 --> 顶点着色器
顶点数据 --> 顶点着色器
顶点着色器程序 --> 顶点着色器
顶点着色器 --> varying变量插值数据
顶点着色器 --> 内置变量
```

varying 变量插值数据

- attribute 存储限定符，必须声明为全局变量，数据将从着色器外部传给该变量。
- uniform 是用来从 js 向顶点、片元着色器传输一致的数据
  - 两者的定义是一样的<存储限定符><类型><变量名> uniform vec4 u_color;
  - 约定：attribute 变量以 a*开头，uniform 变量以 u*开头

内置变量

- gl_Position vec4 表示定点位置
- gl_PointSize float 表示点的尺寸（像素版）默认值为 1.0，类型限制，如可以赋值为 40.0，但是不能是 40。
- gl_FrontFacing

### 图元装配

顶点变换后的操作是图元装配(primitive assembly)，从程序的角度来看，就是绘制函数 drawArrays()或 drawElements()第一个参数绘制模式 mode 控制顶点如何装配为图元， gl.LINES 的定义的是把两个顶点装配成一个线条图元，gl.TRIANGLES 定义的是三个顶点装配为一个三角面图元，gl.POINTS 定义的是一个点域图元。

### 光栅化

简单理解就是将上一步的图元装配划分成一小块，这里的一小块就是光栅

### 片元着色器

片元着色器和顶点着色器一样是 GPU 渲染管线上一个可以执行着色器程序的功能单元，顶点着色器处理的是逐顶点处理顶点数据，片元着色器是逐片元处理片元数据。通过给内置变量 gl_FragColor 赋值可以给每一个片元进行着色， 值可以是一个确定的 RGBA 值，可以是一个和片元位置相关的值，也可以是插值后的顶点颜色。除了给片元进行着色之外，通过关键字 discard 还可以实现哪些片元可以被丢弃，被丢弃的片元不会出现在帧缓冲区，自然不会显示在 canvas 画布上。

```mermaid
graph LR
纹理缓冲区 --> 片元着色器

    subgraph 属性
	片元着色器 --> 着色
	片元着色器 --> discard
    end

    subgraph 数据来源
	片元坐标 --> 片元着色器
	顶点颜色和纹理坐标等插值数据 --> 片元着色器
	end

片元着色器程序 --> 片元着色器
片元着色器-->系列测试
系列测试-->颜色缓冲区
系列测试-->深度缓冲区
```

## 案例：绘制一个点

以 html 为例，先添加一个目标 canvas 到页面上，并且添加一个 init 方法调用，页面加载完成之后会执行 init 方法

这里还引入了一个 glMatrix.js（用于高性能 WebGL 应用程序的 JavaScript 矩阵和矢量库）[官网在这，这个 JS 可以在这下载](https://glmatrix.net/)。

```html
<script src="./glMatrix-0.9.6.min.js"></script>
<body onload="init()">
  <canvas id="webgl" width="1024" height="768" />
</body>
```

在 init 方法当中拆分几个方法进行实现，首先是初始化 WebGL。[WebGL 的 API 文档](https://developer.mozilla.org/zh-CN/docs/Web/API/WebGLRenderingContext)

- 通过 getContext 来获取 canvas 元素的 WebGL 绘图上下文
- viewport 方法设置视口，即指定从标准设备到窗口坐标的 x、y 仿射变换
  - 参数分别 x，y，width，height（左下角坐标以及视口宽高）
- mat4.ortho

```js
var webGL;

function init() {
  initWebGL();
  initShader();
  initBuffer();
  draw();
}

function initWebGL() {
  let webGLdiv = document.getElementById("webgl");
  webGL = webGLdiv.getContext("webgl");
  webGL.viewport(0, 0, webGLdiv.clientWidth, webGLdiv.clientHeight);
  mat4.ortho(
    0,
    webGLdiv.clientWidth,
    webGLdiv.clientHeight,
    0,
    -1,
    1,
    projMat4
  );
}
```

初始化 shader 着色器，其中关于着色器的代码可以先略过，然后就是创建 shader 的流程，其中引入的 mat4 的 proj，再一次通过 proj\*a_position 得到的 gl_Position 会被重新应用到 webGL 的坐标系，也就把 webGL 坐标系又变成了传统的 canvas 左上角坐标系

```mermaid
graph TB
createShader-->shaderSource
shaderSource --> compileShader
compileShader-->attachShader
createProgram-->attachShader
attachShader-->linkProgram
linkProgram-->useProgram
```

```js
var program;
// 顶点着色器
var vertexString = `
    attribute vec4 a_position;
    uniform mat4 proj;
    void main(){
        gl_Position = proj * a_position;
        gl_PointSize = 60.0;
    }`;

// 片元着色器
var fragmentString = `
    void main(){
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }`;

function initShader() {
  // 创建着色器对象（顶点、片元）
  let vsShader = webGL.createShader(webGL.VERTEX_SHADER);
  let fsShader = webGL.createShader(webGL.FRAGMENT_SHADER);

  // 绑定着色器源代码
  webGL.shaderSource(vsShader, vertexString);
  webGL.shaderSource(fsShader, fragmentString);

  // 编译着色器对象
  webGL.compileShader(vsShader);
  webGL.compileShader(fsShader);

  // 创建程序对象和shader对象进行绑定
  program = webGL.createProgram();
  webGL.attachShader(program, vsShader);
  webGL.attachShader(program, fsShader);

  // webGL和项目中间进行绑定和使用
  webGL.linkProgram(program);
  webGL.useProgram(program);
}
```

- 创建单个点对象，注明为 Float32Array 类型
- getAttribLocation 返回了给定 WebGLProgram 对象中某属性的下标指向位置，前面的着色器的 a_position，就是这个属性的下标位置
- vertexAttrib4fv 是给顶点进行赋值，也就是顶点着色器中的 gl_Position = proj \* a_position
  - 参数一：是指定了待修改顶点 attribute 变量的存储位置
  - 参数二：是用于设置顶点 attibute 变量的向量值
  - 拓展：同族函数 vertexAttrib1fv、vertexAttrib2fv、vertexAttrib3fv（其中数字代表几个参数、f 表示 float）
- getUniformLocation 是返回 uniform 变量的指针位置
- uniformMatrix4fv 为 uniform 变量指定矩阵值
  - 参数一：是指定待修改 uniform 变量的存储位置
  - 参数二：指定是否转置矩阵
  - 参数三：序列值

```js
function initBuffer() {
  // 创建一个x=100,y=100的点
  let pointPosition = new Float32Array([100, 100, 0, 1]);
  let aPosition = webGL.getAttribLocation(program, "a_position");

  webGL.vertexAttrib4fv(aPosition, pointPosition);

  let uniformProj = webGL.getUniformLocation(program, "proj");
  webGL.uniformMatrix4fv(uniformProj, false, projMat4);
}
```

最后一步进行绘制

- clearColor 方法用于设置清空颜色缓冲时的颜色值，参数为 rgba 值（取值在 0-1 之间）
- clear 方法使用预设值来清空缓冲（参数可选）
  - gl.COLOR_BUFFER_BIT 颜色缓冲区
  - gl.DEPTH_BUFFER_BIT 深度缓冲区
  - gl.STENCIL_BUFFER_BIT 模板缓冲区
- drawArrays 方法为渲染数组中的原始数据
  - mode：[可选值](https://developer.mozilla.org/zh-CN/docs/Web/API/WebGLRenderingContext/drawArrays#%E5%8F%82%E6%95%B0)
  - first：指定从哪个点开始绘制
  - count：指定绘制的点的数量

```js
function draw() {
  webGL.clearColor(0, 0, 0, 1);
  webGL.clear(webGL.COLOR_BUFFER_BIT);
  webGL.drawArrays(webGL.POINTS, 0, 1);
}
```

## 案例拓展：鼠标单击后绘制点

思路在于需要监听鼠标的单击事件，而后获取鼠标的坐标，将每一次点击的坐标记录在一个数组当中，之后再调用 draw 方法进行绘制即可

修改 initBuffer() 方法

- 创建一个全局存坐标的 POINTS 数组变量
- 添加鼠标点击事件，这里需要进行数据处理，原因在于鼠标点击的是基于左上角的 px 位置，而在 webGL 当中需要转换成-1 到 1 之间的值。（求出 targetX 和 targetY，这里偷个懒，里面的 1024 和 768 是 canvas 的宽高，按道理来说应该获取一下，这里就直接写死了）
- 在前面顶点着色器定义的是 vec4 四维变量，所以将 z 设置为 0 表示在平面，并且 a 的值设置为 1 表示不透明
- 覆盖单个点的 pointPosition
- 创建缓冲区：createBuffer()方法是用于储存顶点数据或着色数据的 WebGLBuffer 对象
- 绑定缓冲区：bindBuffer()方法是把 WebGLBuffer 对象绑定到指定目标上
  - 参数一：gl.ARRAY_BUFFER: 包含顶点属性的 Buffer，如顶点坐标，纹理坐标数据或顶点颜色数据。
  - 参数二：buffer 对象
- 更新缓冲数据：bufferData()方法是创建并初始化了 Buffer 对象的数据存储区
  - 参数一：指定 Buffer 绑定点（目标）
    - gl.ARRAY_BUFFER: 包含顶点属性的 Buffer，如顶点坐标，纹理坐标数据或顶点颜色数据
    - gl.ELEMENT_ARRAY_BUFFER: 用于元素索引的 Buffer。
  - 参数二：设定 Buffer 对象的数据存储区大小
  - 参数三：指定数据存储区的使用方法
    - gl.STATIC_DRAW: 缓冲区的内容可能经常使用，而不会经常更改。内容被写入缓冲区，但不被读取
    - gl.DYNAMIC_DRAW: 缓冲区的内容可能经常被使用，并且经常更改。内容被写入缓冲区，但不被读取
    - gl.STREAM_DRAW: 缓冲区的内容可能不会经常使用。内容被写入缓冲区，但不被读取
- enableVertexAttribArray()方法是在给定的位置，启用顶点 attribute 数组
- vertexAttribPointer()方法是指定一个顶点 attributes 数组中，顶点 attributes 变量的数据格式和位置
  - 参数一：指定要修改的顶点属性的索引
  - 参数二：指定每个顶点属性的组成数量，必须是 1，2，3 或 4
  - 参数三：指定数组中每个元素的数据类型可能是，可取【gl.BYTE、gl.SHORT、gl.UNSIGNED_BYTE、gl.UNSIGNED_SHORT、gl.FLOAT】
  - 参数四：当转换为浮点数时是否应该将整数数值归一化到特定的范围
  - 参数五：以字节为单位指定连续顶点属性开始之间的偏移量
  - 参数六：指定顶点属性数组中第一部分的字节偏移量
- 再最后调用 draw 方法进行绘制

```js
const POINTS = [];
function initBuffer() {
  // 创建一个x=100,y=100的点

  let aPosition = webGL.getAttribLocation(program, "a_position");

  document.addEventListener("mousedown", (e) => {
    // 将canvas的点转换成webGL的点
    const targetX = (e.clientX - 1024 / 2) / (1024 / 2);
    const targetY = (768 / 2 - e.clientY) / (768 / 2);
    console.log(targetX, targetY);

    POINTS.push(targetX);
    POINTS.push(targetY);
    POINTS.push(0);
    POINTS.push(1);

    let pointPosition = new Float32Array(POINTS);

    let pointBuffer = webGL.createBuffer();

    webGL.bindBuffer(webGL.ARRAY_BUFFER, pointBuffer);

    webGL.bufferData(webGL.ARRAY_BUFFER, pointPosition, webGL.STATIC_DRAW);

    webGL.enableVertexAttribArray(aPosition);

    webGL.vertexAttribPointer(aPosition, 4, webGL.FLOAT, false, 4 * 4, 0 * 4);

    webGL.vertexAttrib4fv(aPosition, pointPosition);

    let uniformProj = webGL.getUniformLocation(program, "proj");
    webGL.uniformMatrix4fv(uniformProj, false, projMat4);

    draw();
  });
}
```

修改 draw()方法，只用修改绘制的目标为 POINTS 并且设置长度

注：因为在 initBuffer 当中重新调整了坐标位置也就是现在的坐标位置是-1 到 1 之间，所以在顶点着色器当中的 gl_Position = a_position 而不是
gl_Position = proj \* a_position

```js
function draw() {
  webGL.clearColor(0, 0, 0, 1);
  webGL.clear(webGL.COLOR_BUFFER_BIT | webGL.DEPTH_BUFFER_BIT);
  webGL.drawArrays(webGL.POINTS, 0, POINTS.length);
}
```

# 绘制&变化三角形

## 绘制线

现在已经知道怎么去绘制一个点对象了，并且还知道了绘制多个点可以添加到缓冲区当中进行绘制，现在绘制一些线到 webgl 当中

只需要修改 initBuffer 方法，添加一些线到缓冲区当中，

并且修改 draw 绘制方法，修改绘制目标为线，并且设置绘制的点的数量

- webGL.LINES 在一对顶点之间画一条线
- webGL.LINE_STRIP 画一条直线到下一个顶点
- webGL.LINE_LOOP 绘制一条直线到下一个顶点，并将最后一个顶点返回到第一个顶点

```js
function initBuffer() {
  // 创建一个x=100,y=100到x=200,y=200到x=200,y=300到x=300,y=200的线
  let linePositionArray = [
    100, 100, 0, 1.0, 200, 200, 0, 1.0, 200, 300, 0, 1.0, 300, 200, 0, 1.0,
  ];
  let linePosition = new Float32Array(linePositionArray);
  let aPosition = webGL.getAttribLocation(program, "a_position");

  let lineBuffer = webGL.createBuffer();
  webGL.bindBuffer(webGL.ARRAY_BUFFER, lineBuffer);
  webGL.bufferData(webGL.ARRAY_BUFFER, linePosition, webGL.STATIC_DRAW);
  webGL.enableVertexAttribArray(aPosition);
  webGL.vertexAttribPointer(aPosition, 4, webGL.FLOAT, false, 4 * 4, 0 * 4);

  let uniformProj = webGL.getUniformLocation(program, "proj");
  webGL.uniformMatrix4fv(uniformProj, false, projMat4);

  draw(linePositionArray.length / 4);
}

function draw(size) {
  webGL.clearColor(0, 0, 0, 1);
  webGL.clear(webGL.COLOR_BUFFER_BIT);
  // webGL.drawArrays(webGL.LINES, 0, size)
  // webGL.drawArrays(webGL.LINE_STRIP, 0, size)
  webGL.drawArrays(webGL.LINE_LOOP, 0, size);
}
```

## 绘制三角形

举一反三，线的绘制也是加在了缓冲区，那么三角也是同样的，只需要修改一个 drawArrays 方法，其中类型可选

- TRIANGLE_STRIP 绘制一个三角带
- TRIANGLE_FAN 绘制一个三角扇
- TRIANGLES 绘制一个三角形

```js
webGL.drawArrays(webGL.TRIANGLE_STRIP, 0, size);
```

## 绘制五角星

绘制五角星也就是将五角星的十个顶点的位置弄出来，如下 fivePointArray 变量，这里是基于 webgl 的坐标系了，那么在前面顶点着色器的地方就需要去掉 `gl_Position = proj * a_position` 而是改为 `gl_Position = a_position`，最后选择绘制 LINE_LOOP 类型的线也就完成了五角星的绘制

```js
let fivePointArray = [
  0, 0.5, 0, 1, 0.17, 0.17, 0, 1, 0.5, 0, 0, 1, 0.17, -0.17, 0, 1, 0.33, -0.67,
  0, 1,

  0, -0.33, 0, 1, -0.33, -0.67, 0, 1, -0.17, -0.17, 0, 1, -0.5, 0, 0, 1, -0.17, 0.17,
  0, 1,
];
```

## 补充 drawArrays & drawElements

前面已经使用过了 drawArrays 方法了，下面同样的补充使用 drawElements 方法

```js
// 创建elementBuffer
let indexPositionArray = [0, 1, 2, 2, 3, 0];
let indexArray = new Uint16Array(indexPositionArray);
let indexBuffer = webGL.createBuffer();
webGL.bindBuffer(webGL.ELEMENT_ARRAY_BUFFER, indexBuffer);
webGL.bufferData(webGL.ELEMENT_ARRAY_BUFFER, indexArray, webGL.STATIC_DRAW);

webGL.drawElements(webGL.LINE_LOOP, 6, webGL.UNSIGNED_SHORT, 0);
```

在 WebGL 中，`drawArrays`和`drawElements`是两种主要的绘制方法，它们各有优缺点，适用于不同场景。以下是它们的对比总结：

---

**gl.drawArrays(mode, first, count)**

- 优点：

  - 简单直接：直接根据顶点缓冲区的数据顺序绘制，无需额外索引数据。
  - 适合简单几何体：当顶点数据没有重复（如粒子系统或完全独立的三角形）时更高效。
  - 动态数据友好：如果顶点数据频繁变化（如实时生成几何体），直接操作顶点缓冲区可能更简单。
  - 内存占用低：无需存储索引数据，节省内存

- 缺点：
  - 数据冗余：若顶点被多个图元共享（如立方体、复杂网格），会重复存储相同顶点，增加内存和带宽开销。
  - 性能限制：重复顶点导致 GPU 多次处理相同数据，可能降低渲染效率（尤其是复杂模型）

---

**gl.drawElements(mode, count, type, offset)**

- 优点：
  - 顶点复用：通过索引数组引用顶点，共享顶点仅存储一次，减少内存占用和 GPU 处理次数。
  - 适合复杂模型：对共享顶点多的模型（如网格、角色模型）效率更高，尤其适合静态或低频更新的数据。
  - 带宽优化：传输到 GPU 的数据量更小（索引通常用`Uint16Array`或`Uint32Array`，体积远小于顶点属性）。
- 缺点：
  - 复杂度增加：需要额外维护索引缓冲区，对动态顶点数据的管理更复杂（需同步更新顶点和索引）。
  - 额外绑定步骤：必须绑定`ELEMENT_ARRAY_BUFFER`（索引缓冲）。
  - 索引类型限制：索引类型（`UNSIGNED_SHORT`/`UNSIGNED_INT`）可能限制最大顶点数量。

---

**对比总结**

| **场景**               | **推荐方法**   | **理由**                            |
| ---------------------- | -------------- | ----------------------------------- |
| 顶点无共享（如粒子）   | `drawArrays`   | 无需索引，避免冗余开销。            |
| 顶点大量共享（如网格） | `drawElements` | 复用顶点显著减少数据量和 GPU 计算。 |
| 动态顶点数据频繁更新   | `drawArrays`   | 索引同步复杂，直接操作顶点更简单。  |
| 静态或低频更新数据     | `drawElements` | 索引复用优势明显，长期性能更优。    |

---

**实际建议**

- 优先考虑`drawElements`：大多数 3D 模型（如游戏角色、场景物体）通过索引复用顶点能显著优化性能。
- 仅在必要时用`drawArrays`：当顶点复用率低或数据频繁动态变化时使用。
- 注意索引类型：根据顶点数量选择`Uint16Array`（最多 65535 顶点）或`Uint32Array`（更多顶点，但兼容性需检查）

## 平移、旋转、缩放

### 数学层面变化###

平移：从(x,y,z)平移到(x1,y1,z1)的位置

```js
x1 = x + Tx;
y1 = y + Ty;
z1 = z + Tz;
```

旋转：(旋转轴、旋转方向、旋转角度)

```js
// 最开始利用三角函数和半径来表示两个点的位置
x = r cos a
y = r sin a


x1 = r cos(a + b)
y1 = r sin(a + b)

// 三角函数两角和公式
sin(a + b) = sina * cosb + cosa * sinb
cos(a + b) = cosa * cosb - sina * sinb

// 那么对x1和y1进行化简就得到
x1 = r cos(a + b) = r cosa * cosb - r sina * sinb
y1 = r sin(a + b) = r cosa * sinb + r sina * cosb

// 再用x和y进行替换
x1 = x cosb - y sinb
y1 = x sinb + y cosb
```

缩放：

```js
x1 = x * scale;
y1 = y * scale;
z1 = z * scale;
```

### webGL 中变换

以旋转为例：修改顶点着色器当中的 position 定位坐标，将旋转对应的数学公式带入到 x 和 y，其中 z 为 0 表示在当前平面

利用 uniform 传入一个角度变量，然后通过 uniform 传入到顶点着色器中，然后通过 glsl 语言进行计算

```js
/**
 * 就是将这个计算得来的公式赋值给gl_Position，并且这个类型是vec4，所以要用vec4这个包一层
 * x1 = x cosb - y sinb
 * y1 = x sinb + y cosb
 */
var vertexString = `
  attribute vec4 a_position;
  uniform float angle;
  void main(){
      gl_Position = vec4(a_position.x * cos(angle) - a_position.y * sin(angle), a_position.x * sin(angle) + a_position.y * cos(angle),0,1);
      gl_PointSize = 40.0;
  }`;
```

之后利用前面用过的 webGL 当中的方法去传递一个 angle 给到顶点着色器就完成了旋转

- 获取 uniform 变量
- 传递角度值，表示 90 度的角度，也就是 1/2 PI
- 给顶点着色器设置 angle
- 绘制

```js
let uAngle = webGL.getUniformLocation(program, "angle");
angle = (90 * Math.PI) / 180;
webGL.uniform1f(uAngle, angle);
draw();
```

那么在这里我们还可以让他一直转圈圈，利用定时器去给角度做累加，每加一次角度变大一次也就完成了旋转

```js
let uAngle = webGL.getUniformLocation(program, "angle");
let count = 0;

setInterval(() => {
  count++;
  angle = (count * Math.PI) / 180;
  webGL.uniform1f(uAngle, angle);
  draw(triangleArray.length / 4);
}, 20);
```

那么同样的举一反三，平移和缩放的代码也很简单了，修改顶点着色器的代码，

```js
// 平移
var vertexString = `
  attribute vec4 a_position;
  uniform float translation;
  void main(){
      gl_Position = vec4(a_position.x + translation, a_position.y + translation, 0 ,1);
      gl_PointSize = 40.0;
  }`;

// 缩放
var vertexString = `
  attribute vec4 a_position;
  uniform float scales;
  void main(){
      gl_Position = vec4(a_position.x * scale, a_position.y * scale, 0 ,1);
      gl_PointSize = 40.0;
  }`;
```

## 事件控制变换

在 webGL 当中绘制了一个三角形，添加键盘监听事件从而改变其位置

修改顶点着色器，其中设定 x 和 y 移动的位置（translateX、translateY），然后更新位置

```js
var vertexString = `
        attribute vec4 a_position;
        uniform float translateX;
        uniform float translateY;
        void main(){
            gl_Position = vec4(a_position.x + translateX, a_position.y + translateY, 0, 1);
            gl_PointSize = 40.0;
        }`;
```

监听键盘事件去改变全局变量，改变 countX 和 countY，这里还添加了一个速度，也可以去修改

```js
let countX = 0;
let countY = 0;
let speed = 0.1;

function initEvent() {
  document.onkeydown = handleKeyDown;
}

function handleKeyDown(e) {
  console.log(e.code);
  const angle = e.code;
  if (angle === "ArrowUp" || angle === "KeyW") {
    countY += speed;
  } else if (angle === "ArrowDown" || angle === "KeyS") {
    countY -= speed;
  } else if (angle === "ArrowLeft" || angle === "KeyA") {
    countX -= speed;
  } else if (angle === "ArrowRight" || angle === "KeyD") {
    countX += speed;
  } else if (angle === "Space") {
    speed += 0.1;
  }
}
```

最后就是和前面一样，将顶点着色器当中的 translateX 和 translateY 进行更新，然后绘制

```js
let uTranslateX = webGL.getUniformLocation(program, "translateX");
let uTranslateY = webGL.getUniformLocation(program, "translateY");
let translateX = countX;
let translateY = countY;
webGL.uniform1f(uTranslateX, translateX);
webGL.uniform1f(uTranslateY, translateY);

// 这个方法是在initBuffer当中的，可以添加requestAnimationFrame进行实时更新，
requestAnimationFrame(initBuffer);
```

## Shader 概述&开发环境配置

### 着色器

用来实现图像渲染的，用来替代固定渲染管线的可编辑程序

- VertexShader（顶点着色器）主要负责顶点的几何关系等的运算
- FragmentShader（片元着色器）主要负责片源颜色等的计算

**顶点着色器**

是对顶点进行一系列操作的着色器。顶点除了有最基本的位置属性，还可能包含很多其他属性，比如纹理，法线等等。通过顶点着色器，显卡就知道顶点应该绘制在具体什么位置。顶点着色器是非常重要的着色器，且必须要我们自己去定义。

顶点着色器作用于每个顶点，可以生成每个顶点的最终位置。针对每个顶点，它都会执行一次，一旦每个顶点的最终位置确定了 GPU 就可以把这些可见顶点的集合组装成点、直线以及三角形，从而提高渲染场景和模型的速度。

**片元着色器**

如果你已经有使用电脑绘图的经验，你就会知道在这个过程中你会画一个圆，然后是一个矩形、一条线、一些三角形，直到你组成你想要的图像。这个过程与手写一封信或一本书非常相似——它是一组执行一项又一项任务的指令。着色器也是一组指令，但指令是针对屏幕上的每个像素一次性执行的。这意味着您编写的代码必须根据屏幕上像素的位置表现出不同的行为。就像打字机一样，您的程序将作为一个接收位置并返回颜色的函数
工作，并且当它被编译时，它会运行得非常快。

### 开发环境配置

在 vscode 当中安装插件【Shader languages support for VS Code、GLSL Lint、glsl-canvas】，其中 GLSL Lint 插件安装完成之后，在 github 上下载[ 执行独立包装器 ](https://github.com/KhronosGroup/glslang/releases/tag/main-tot)在插件设置当中配置指定 Glslang Validator Path 的路径值

之后简单编写一个 glsl 文件，然后在 vscode 当中用 Ctrl+Shift+P 打开命令面板，输入 Show glslCanvas 就可以运行这个 glsl 文件预览了

```glsl
#ifdef GL_ES
precision mediump float;
#endif

void main(){
    gl_FragColor = vec4(0.0431, 0.4235, 0.7294, 1.0);
}
```

## 颜色

- 颜色分为红绿蓝透明度四个值，组合为四维向量(r,g,b,a)
- 每个分量的范围是 0->1 的浮点数，即颜色值/255
- 可以每个分量进行加减乘除计算，也可对整个颜色向量进行运算
- 常用颜色值
  - 黑色 (0,0,0,1)
  - 白色 (1,1,1,1)
  - 红色 (1,0,0,1)
  - 绿色 (0,1,0,1)
  - 蓝色 (0,0,1,1)

颜色计算：这里的颜色值都是变量，都可以通过运算得到

```glsl
gl_FragColor = vec4(0.1, 0.4, 0.5, 1.0) * vec4(1, 1, 0.5, 1.0);
```

### 三原色混合案例

首先通过 u_resolution 统一变量获取窗口分辨率，并对当前片段坐标进行归一化处理，以适配不同屏幕尺寸。根据片段位置，分别判断其是否位于三个圆形区域内，若在则赋予对应颜色（蓝色、红色、绿色）。最终将三种颜色叠加输出。

```glsl
#ifdef GL_ES
precision mediump float;
#endif

// 声明一个uniform变量，用于接收窗口的分辨率
uniform vec2 u_resolution;

void main(){
       // 将当前片段坐标归一化并居中，以较短边为基准进行缩放
       vec2 p = (gl_FragCoord.xy*2.-u_resolution)/min(u_resolution.x, u_resolution.y);

       // 初始化三种颜色
       vec3 color1 = vec3(0);
       vec3 color2 = vec3(0);
       vec3 color3 = vec3(0);

       // 如果当前片段坐标在指定圆心和半径范围内，则设置color1为蓝色
       if(distance(vec2(0,0.2), vec2(p.xy)) <= 0.4)
       {
              color1 = vec3(0,0,1);
       }

       // 如果当前片段坐标在指定圆心和半径范围内，则设置color2为红色
       if(distance(vec2(-0.2,-0.2), vec2(p.xy)) <= 0.4)
       {
              color2 = vec3(1,0,0);
       }

       // 如果当前片段坐标在指定圆心和半径范围内，则设置color3为绿色
       if(distance(vec2(0.2,-0.2), vec2(p.xy)) <= 0.4)
       {
              color3 = vec3(0,1,0);
       }

       // 将三种颜色叠加，得到最终的颜色
       vec3 color = vec3(0,0,0) + color1 + color2 + color3;

       // 设置片段的最终颜色，alpha值为1
       gl_FragColor = vec4(color,1);
}
```

<image src="../assets/三原色混合.png">
### 坐标系

用到的变量

| gl_Position                      | gl_FragCoord                                     | gl_PointCoord                                                                                            |
| -------------------------------- | ------------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| 描述的是顶点在世界坐标系中的坐标 | 描述的是片元在以 Canvas 画布窗口坐标系统中的坐标 | 描述的是点域图元（点精灵/PointSprite）光栅化后的片元，表示的坐标就是 gl_PointSize 定义的区域内的片元坐标 |
| 根据坐标比例来设定               | 默认是画布的长和宽                               | 区间是[0.1]                                                                                              |

顶点坐标系：gl_Position，在 webGL 当中渲染，将顶点数据置为 000，并且计算片元着色器每个点的颜色值，那么颜色值也就是和点的坐标值是一样的。

```js
// 顶点着色器
const vertexString = `
        attribute vec4 a_Position;
        void main(){
            gl_Position = a_Position;
            gl_PointSize = 512.0;
        }`;

// 片元着色器
const fragmentString = `
        precision mediump float;
        uniform vec2  resolution;
        void main(){
            vec2 p = gl_FragCoord.xy / resolution;
            gl_FragColor = vec4(p.xy, 0.0, 1.0);
        }`;

function initBuffer() {
  let data = new Float32Array([0, 0, 0]);

  let vertexTexCoordBuffer = webGL.createBuffer();
  webGL.bindBuffer(webGL.ARRAY_BUFFER, vertexTexCoordBuffer);
  webGL.bufferData(webGL.ARRAY_BUFFER, data, webGL.STATIC_DRAW);
  let aPosition = webGL.getAttribLocation(program, "a_Position");
  let modelMatrix = mat4.create();

  let resolution = webGL.getUniformLocation(program, "resolution");
  webGL.uniform2fv(resolution, [512, 512]);

  webGL.vertexAttribPointer(
    aPosition,
    3,
    webGL.FLOAT,
    false,
    data.BYTES_PER_ELEMENT * 3,
    0
  );
  webGL.enableVertexAttribArray(aPosition);

  let uniformProj = webGL.getUniformLocation(program, "proj");
  webGL.uniformMatrix4fv(uniformProj, false, projMat4);
}
```

<image src="../assets/顶点坐标000.png">

gl_FragCoord：将原点移动到画布中心点，坐标轴向右为 x 轴，向下为 y 轴，坐标轴原点为画布中心点。这个时候需要-=0.5，让中心点位于画布中心点。

```js
const fragmentString = `
       precision mediump float;
       uniform vec2  resolution;
       void main() {
            vec2 uv = gl_FragCoord.xy / resolution.xy;
            uv-=0.5;   
            gl_FragColor = vec4(uv.xy, 0.0, 1.0);
       }`;
```

gl_PointCoord：根据当前绘制的点精灵（Point Sprite）内部坐标 gl_PointCoord 来输出颜色值，用于可视化点精灵的坐标分布。将 gl_PointCoord.xy 的值作为颜色的红绿通道。这两个案例只需要修改片元着色器即可，这里就不贴运行图了，观察采用不同的坐标系其渲染的颜色值变换。

```js
const fragmentString = `
       precision mediump float;
       void main(){
            gl_FragColor = vec4(gl_PointCoord.xy, 0.0, 1.0);
       }`;
```

### 输出与打印

在 GLSL（OpenGL Shading Language）中，没有像 C/C++ 或 JavaScript 那样的 print 或 console.log 输出机制，因为着色器运行在 GPU 上，不具备直接输出文本的能力。

readPixels 是 WebGL 中用于从帧缓冲区读取像素数据的 API，常用于调试、图像处理或获取渲染结果。

```js
gl.readPixels(x, y, width, height, format, type, pixels);
```

参数说明
|参数| 类型| 描述|
|--|--|--|
|x |int| 读取区域左下角在画布上的 X 坐标（像素）|
|y |int| 读取区域左下角在画布上的 Y 坐标（像素）|
|width |int |要读取的像素矩形的 宽度（通常为 1 表示单个像素）|
|height| int| 要读取的像素矩形的 高度（通常为 1 表示单个像素）|
|format| enum| 像素数据的颜色格式，常用值：gl.RGBA、gl.RGB|
|type |enum |数据类型，常用值：gl.UNSIGNED_BYTE（0~255）、gl.FLOAT（浮点数）|
|pixels| TypedArray |用来存储读取结果的数组，如 Uint8Array(4)|

使用：

```js
let pixel = new Uint8Array(4);
webGL.readPixels(200, 200, 1, 1, webGL.RGBA, webGL.UNSIGNED_BYTE, pixel);
console.log(pixel);
```

## Shader 语法

### 变量

| 变量类型 | 说明                                                 |
| -------- | ---------------------------------------------------- |
| bool     | 布尔类型，该类型的变量表示一个布尔值即 true 或 false |
| int      | 整型，该类的变量表示一个整数                         |
| float    | 单精度浮点数类型，该类型的变量表示一个单精度的浮点数 |

基本类型的赋值和类型转换

|              | 转换函数    | 描述                               |
| ------------ | ----------- | ---------------------------------- |
| 转换为整型数 | int(float)  | 去掉浮点数小数部分，转换为整型数   |
|              | int(bool)   | true 转换为 1，false 转换为 0      |
| 转换为浮点点 | float(int)  | 将整型数转换为浮点数               |
|              | float(bool) | true 转换为 1.0，false 转换为 0.0  |
| 转换为布尔值 | bool(int)   | 0 转换为 false，非 0 转换为 true   |
|              | bool(float) | 0.0 转换为 false，非 0 转换为 true |

### 矢量

| 变量类型            | 说明                            |
| ------------------- | ------------------------------- |
| vec2、vec3、vec4    | 具有 2、3、4 个浮点数元素的矢量 |
| ivec2、ivec3、ivec4 | 具有 2、3、4 个整形元素的矢量   |
| bool2、bool3、bool4 | 具有 2、3、4 个布尔值元素的矢量 |

**矢量赋值**

```glsl
vec3 v3 = vec3(1.0, 2.0, 3.0);

// 将三维向量的值赋给二维向量，会截取前面的两个元素
vec2 v2 = vec2(v3);

// 可以传单个的值，会重复赋值给所有元素
vec4 v4 = vec4(1.0);

// 但是不能传两个值给四维向量
vec4 v4 = vec4(1.0, 2.0);
```

**取值**：可以通过`.`或者`[]`访问矢量的元素

- x、y、z、w：用来获取顶点坐标的分量
- r、g、b、a：用来获取颜色分量
- s、t、p、q：用来获取纹理坐标分量

```glsl
vec4 v4 = vec4(1.0, 2.0, 3.0, 4.0);
float x = v4.x;
float g = v4.g;
float p = v4[2];
```

**矢量的常见用法**

```glsl
归一化：normalize()
加减法：vec2 v2 += ec2(1.0, 2.0);
点乘：float f = dot(vec2 v1, vec2 v2);
叉乘：vec2 v3 = cross(vec2 v1, vec2 v2);
```

### 矩阵

**存储顺序**

- 矩阵的存储顺序分为 行主序（Row-Major） 和 列主序（Column-Major）：
- GLSL 默认是列主序：矩阵按列存储在内存中，例如 mat4 是 4 列，每列包含 4 个分量。

**类型**

- mat2：2x2 矩阵
- mat3：3x3 矩阵
- mat4：4x4 矩阵
- mat2x3：2 列 3 行的矩阵（其他类似）

**初始化和取值**

```glsl
// 列主序初始化：每列单独赋值
mat4 modelMatrix = mat4(
    1.0, 0.0, 0.0, 0.0,  // 第一列
    0.0, 1.0, 0.0, 0.0,  // 第二列
    0.0, 0.0, 1.0, 0.0,  // 第三列
    0.0, 0.0, 0.0, 1.0   // 第四列
);

float m10 = modelMatrix[1][0]; // 第二列，第一行的元素
```

### GLSL ES 结构体

在 Shader 编程中，结构体（Struct） 是一种组织和管理数据的工具，它可以将多个相关的变量（如顶点坐标、法线、纹理坐标等）打包成一个逻辑单元。结构体的使用可以显著提高代码的可读性和复用性，尤其在复杂的着色器（如顶点着色器、片元着色器或光照计算）中非常常见。

**基本语法**

在定义结构体之前使用 struct 关键字，然后使用大括号 {} 来定义结构体的成员。并且可以定义完成之后添加变量作为 struct 对象

```glsl
// 定义结构体（通常在着色器顶部声明）
struct VertexInput {
    vec3 position;  // 顶点位置（无语义，通过 location 绑定）
    vec2 uv;        // 纹理坐标
    vec3 normal;    // 法线方向
};

struct VertexOutput {
    vec4 clipPos;   // 裁剪空间位置
    vec2 uv;        // 传递给片元着色器的 UV
    vec3 worldNormal; // 世界空间法线
} vertexOutput1;
```

**使用**

```glsl
// 定义过了的就可以直接访问
vertexOutput1.clipPos = vec4(2.0, 1.0, 1.0, 1.0);

// 和其他语言的区别在于不需要使用new关键字
VertexInput v1 = VertexInput(vec3(0.0, 0.0, 1.0), vec2(0.0, 0.0), vec3(0.0, 0.0, 1.0));

VertexInput v2 = VertexInput(vec3(1.0, 2.0, 3.0), vec2(0.0, 0.0), vec3(0.0, 0.0, 1.0));

// v1 != v2
```

### 数组

在 GLSL 当中只支持一维数组

**基本语法&初始化**

```glsl
// 声明一个固定长度的数组
float positions[10];       // 10 个 float 元素
vec3 colors[5];            // 5 个 vec3 元素
sampler2D textures[4];     // 4 个纹理采样器（需注意硬件限制）

// 静态初始化
float values[3] = float[3](1.0, 2.0, 3.0);
vec2 points[2] = vec2[2](vec2(0.0), vec2(1.0));

// 运行时赋值
for (int i = 0; i < 5; i++) {
    colors[i] = vec3(float(i) * 0.2);
}
```

数组本身只支持`[]`运算符，但数组元素能够参与其自身类型支持的任意运算，

```glsl
// 将float f 赋值为 Array的第2个元素乘以3.14
float f = Array[1] * 3.14;

// 将vec4 v4 赋值为 Array的第1个元素乘以vec4
vec4 v4 = vec4Array[0] * vec4(1.0, 2.0, 3.0, 4.0);
```

### 函数

构成函数的语法：GLSL 的函数不能递归，不能嵌套。

```glsl
返回类型 函数名 (type0 arg0, type1 arg1, ..., typen argn) {
    函数计算
    return 返回值;
}
```

### 限定词

为了提高运行效率，减少内存开销

**参数限定词**

用来限制函数参数的，根据参数不同的行为可以将它们分为以下几类

- 只向函数中传值
- 在函数中被赋值
- 既向函数中传值也在函数中被赋值

| 列别     | 规则                                                     | 说明                                                                                 |
| -------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| in       | 向函数中传入值                                           | 内部运算变化不影响外部                                                               |
| const in | 向函数中传入值                                           | 参数传入函数，函数内可以使用参数值， 但<span style="color:red">不能修改</span>参数值 |
| out      | 在函数中被赋值，并被传出                                 | 内部运算变化影响外部变化并且传参到储存过程时默认初始化参数为 null                    |
| inout    | 表示参数将在函数内外保持一致（引用传递，会影响原来的值） | 与 out 类型相比不同是默认初始化参数不为 null，传的是什么就是什么                     |
| 无       | 将一个值传给函数                                         | 和限定词 in 一样                                                                     |

**存储限定词**

- attribute 变量只能出现在顶点着色器中，只能被声明为全局变量，被用来表示逐顶点的信息
- uniform 变量可以用在顶点着色器和片元着色器中，且必须是全局变量。uniform 变量是只读的，不支持数组和结构体类型
- varying 变量只能被声明为全局变量，被用来表示逐像素的信息

**精度限定词**

| 精度限定词 | 描述                                                                                      | 默认数值范围和精度 Float | 默认数值范围和精度 Int |
| ---------- | ----------------------------------------------------------------------------------------- | ------------------------ | ---------------------- |
| highp      | 满足顶点语言的最低要求（使用 highp 可以获得最大的范围和精度，但是也有可能会降低运行速度） | (-2^62,2^62)精度 2^-16   | (-2^16,2^16)           |
| mediump    | 范围和精度介于 highp 和 lowp 之间（通常用于储存高范围的颜色数据和低精度的几何数据）       | (-2^14,2^14)精度 2^-10   | (-2^10,2^10)           |
| lowp       | 范围和精度比 meduimp 小，但是足以储存所有 8-bit 颜色数据。                                | (-2,2)精度 2^-8          | (-2^8,2^8)             |

通常会使用 precision 关键字为某一类型的变量设置默认精度，这个设置必须放置在程序的顶部。使用方式如下：

```glsl
precision <精度限定词> <类型名称>
```

默认精度限定参照表：

| 着色器类型 | 数据类型    | 默认精度 |
| ---------- | ----------- | -------- |
| 顶点着色器 | int         | highp    |
| 顶点着色器 | float       | highp    |
| 顶点着色器 | sampler2D   | lowp     |
| 顶点着色器 | samplerCube | lowp     |
| 片元着色器 | int         | mediump  |
| 片元着色器 | float       | 无       |
| 片元着色器 | sampler2D   | lowp     |

### 流程控制

**分支 if-else**

```glsl
if (条件表达式1) {}
else if (条件表达式2) {}
else {}
```

**for 循环**

```glsl
for (初始化表达式;条件表达式;循环步进表达式){
    重复执行的语句;
}
```

**continue、break、discard**

- continue： 中止包含该语句的最内层循环和执行循环表达式(递增/递减循环变量)，然后执行下一次循环。
- break：中止包含该语句的最内层循环，并不再继续执行循环。
- discard： 丢弃当前片段，不进行后续的渲染。

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

这里可以用attribute和uniform定义大小的值，然后传递给顶点着色器，那么对应他的js赋值的代码如下：

利用attribute传递变量需要以下五个步骤、

- 创建缓冲区对象
- 绑定buffer
- 将数据写入到缓冲区对象
- 将缓冲区对象分配给attribute变量
- 开启attribute变量

而同时使用uniform传递变量就可以直接获取进行赋值效果是一样的，都可以把值传递进去（但是这里uniform传值设置的是随机数，但是设置的所有顶点的值都是同一个）

```js
// attribute
const sizeArray = new Float32Array([60, 100, 80, 30]);
let sizeBuffer = webGL.createBuffer();
webGL.bindBuffer(webGL.ARRAY_BUFFER, sizeBuffer);
webGL.bufferData(webGL.ARRAY_BUFFER, sizeArray, webGL.STATIC_DRAW);
let aSize = webGL.getAttribLocation(program, 'size');
// 参数说明：attribute变量，传递值个数、数据类型，是否要归一化，跨度，偏移量
webGL.vertexAttribPointer(aSize, 1, webGL.FLOAT, false, 4, 0);
webGL.enableVertexAttribArray(aSize);

// uniform
let uSize = webGL.getUniformLocation(program, 'size2');
webGL.uniform1f(uSize, Math.random() * 100);
```

### 拓展 attribute 和 uniform 的使用

| 特性    | attribute                   | uniform            |
|-------|-----------------------------|--------------------|
| 作用范围  | 逐顶点（每个顶点不同）                 | 全局（所有顶点共享）         |
| 数据来源  | 顶点缓冲区（如顶点坐标数组）              | 直接通过 JavaScript 设置 |
| 更新频率  | 每个顶点处理时更新                   | 一次绘制调用中保持不变        |
| 典型用途  | 顶点位置、颜色、纹理坐标                | 变换矩阵、全局参数          |
| WebGL | 设置方法 gl.vertexAttribPointer | gl.uniform* 系列函数   |

如何选择？

- 用 attribute：当数据需要为每个顶点单独指定时（例如顶点坐标、颜色）
- 用 uniform：当数据对所有顶点一致时（例如变换矩阵、全局光照参数）
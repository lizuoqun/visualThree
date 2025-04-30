## 层次结构模型

> 三维模型和现实中的人类或机器人不一样，它的部件并没有真正连接在一起。如果直接转动上臂，那么肘部以下的部分，包括前臂、手掌和手指，只会留在原地，这样手臂就断开了。
>
> 所以，当上臂绕肩关节转动时，需要在代码中实现“肘部以下部分跟随上臂转动“的逻辑。具体地，上臂绕肩关节转动了多少度，肘部以下的部分也应该绕肩关节转动多少度。

### 简单情况

实现“部件A转动带动部件B转动”可以很直接，只要对部件B也施以部件A的旋转矩阵即可。比如，使用模型矩阵使上臂绕肩关节转动30度，然后在绘制肘关节以下的各部位时，为它们施加同一个模型矩阵，也令其绕肩关节转动30度，这样，肘关节以下的部分就能自动跟随上臂转动了。

### 复杂情况

比如先使上臂绕肩关节转动30度，然后使前臂绕肘关节转动10度，那么对肘关节以下的部分，你就得先施加上臂绕肩关节转动30度的矩阵（可称为“肩关节模型矩阵”），然后再施加前臂绕肘关节转动10度的矩阵。将这两个矩阵相乘，其结果可称为“肘关节模型矩阵”，那么在绘制肘关节以下部分的时候，直接应用这个所谓的“肘关节模型矩阵”（而不考虑肩关节，因为肩关节的转动信息已经包含在该矩阵中了）作为模型矩阵就可以了。

## 单关节模型

> 单关节完整代码案例在这：[singleNode.html]()

### 绘制长方体作为上臂

还是采用drawElement的方法，绘制长方体，和之前绘制正方体的绘制方式一样。只是调整了一个顶点坐标的值。

```js
function initBuffer() {

  var vertices = new Float32Array([
    1.5, 10.0, 1.5, -1.5, 10.0, 1.5, -1.5, 0.0, 1.5, 1.5, 0.0, 1.5, // v0-v1-v2-v3 front
    1.5, 10.0, 1.5, 1.5, 0.0, 1.5, 1.5, 0.0, -1.5, 1.5, 10.0, -1.5, // v0-v3-v4-v5 right
    1.5, 10.0, 1.5, 1.5, 10.0, -1.5, -1.5, 10.0, -1.5, -1.5, 10.0, 1.5, // v0-v5-v6-v1 up
    -1.5, 10.0, 1.5, -1.5, 10.0, -1.5, -1.5, 0.0, -1.5, -1.5, 0.0, 1.5, // v1-v6-v7-v2 left
    -1.5, 0.0, -1.5, 1.5, 0.0, -1.5, 1.5, 0.0, 1.5, -1.5, 0.0, 1.5, // v7-v4-v3-v2 down
    1.5, 0.0, -1.5, -1.5, 0.0, -1.5, -1.5, 10.0, -1.5, 1.5, 10.0, -1.5  // v4-v7-v6-v5 back
  ]);

  // Normal
  var normals = new Float32Array([
    0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, // v0-v1-v2-v3 front
    1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, // v0-v3-v4-v5 right
    0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, // v0-v5-v6-v1 up
    -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, // v1-v6-v7-v2 left
    0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, // v7-v4-v3-v2 down
    0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0  // v4-v7-v6-v5 back
  ]);

  // Indices of the vertices
  indices = new Uint8Array([
    0, 1, 2, 0, 2, 3,    // front
    4, 5, 6, 4, 6, 7,    // right
    8, 9, 10, 8, 10, 11,    // up
    12, 13, 14, 12, 14, 15,    // left
    16, 17, 18, 16, 18, 19,    // down
    20, 21, 22, 20, 22, 23     // back
  ]);


  let pointPosition = new Float32Array(vertices);
  let aPsotion = webgl.getAttribLocation(webgl.program, 'a_position');
  let triangleBuffer = webgl.createBuffer();
  webgl.bindBuffer(webgl.ARRAY_BUFFER, triangleBuffer);
  webgl.bufferData(webgl.ARRAY_BUFFER, pointPosition, webgl.STATIC_DRAW);
  webgl.enableVertexAttribArray(aPsotion);
  webgl.vertexAttribPointer(aPsotion, 3, webgl.FLOAT, false, 0, 0);

  let aNormal = webgl.getAttribLocation(webgl.program, 'a_Normal');
  let normalsBuffer = webgl.createBuffer();
  let normalsArr = new Float32Array(normals);
  webgl.bindBuffer(webgl.ARRAY_BUFFER, normalsBuffer);
  webgl.bufferData(webgl.ARRAY_BUFFER, normalsArr, webgl.STATIC_DRAW);
  webgl.enableVertexAttribArray(aNormal);
  webgl.vertexAttribPointer(aNormal, 3, webgl.FLOAT, false, 0, 0);

  let indexBuffer = webgl.createBuffer();
  let indices1 = new Uint8Array(indices);
  webgl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, indexBuffer);
  webgl.bufferData(webgl.ELEMENT_ARRAY_BUFFER, indices1, webgl.STATIC_DRAW);
}
```

### 添加光照

直接添加光照的代码是放在initBuffer当中，现在将其抽离成一个单独的函数，数据都是传递给着色器的，不影响绘制。

```js
function initLight() {
  let u_DiffuseLight = webGL.getUniformLocation(program, 'u_DiffuseLight');
  webGL.uniform3f(u_DiffuseLight, 1.0, 1.0, 1.0);
  let u_LightDirection = webGL.getUniformLocation(program, 'u_PointLightPosition');
  webGL.uniform3fv(u_LightDirection, [3.0, 3.0, 4.0]);
  let u_AmbientLight = webGL.getUniformLocation(program, 'u_AmbientLight');
  webGL.uniform3f(u_AmbientLight, 0.8, 0.8, 0.8);
}
```

### 设置矩阵

现在已经准备好了绘制的数据，之后就是通过设置透视投影矩阵和模型矩阵来绘制了。也单独抽离成一个方法。

那么在这里返回了一个模型矩阵的目的是，第一次绘制长方体时是上臂，这个时候调用initTransformation会拿到上臂的模型矩阵，那么通过上臂再去绘制小臂的时候用大臂的模型矩阵再作为小臂变换的顶点矩阵，也就完成了大臂和小臂的联动

```js
  function initTransformation(angele, rotateArr, ModelMatrix = mat4.create()) {
  let ProjMatrix = mat4.create();
  mat4.identity(ProjMatrix);
  mat4.perspective(ProjMatrix, angle * Math.PI / 180, webGLdiv.clientWidth / webGLdiv.clientHeight, 1, 1000); //修改可视域范围

  let uniformMatrix1 = webGL.getUniformLocation(program, 'u_formMatrix');

  mat4.rotate(ModelMatrix, ModelMatrix, (angele * Math.PI) / 180.0, rotateArr);
  let ViewMatrix = mat4.create();
  mat4.identity(ViewMatrix);
  mat4.lookAt(ViewMatrix, [50, 50, 50], [0, 0, 0], [0, 1, 0]);

  let mvMatrix = mat4.create();
  mat4.identity(mvMatrix);
  mat4.multiply(mvMatrix, ViewMatrix, ModelMatrix);

  let mvpMatrix = mat4.create();
  mat4.identity(mvpMatrix);
  mat4.multiply(mvpMatrix, ProjMatrix, mvMatrix);
  webGL.uniformMatrix4fv(uniformMatrix1, false, mvpMatrix);
  return ModelMatrix;
}
```

### 绘制

这里就是上一步所说的联动，先绘制上臂，再绘制小臂，小臂的模型矩阵是上臂的模型矩阵。

```js
function draw() {
  let modelArr = initTransformation(jointAngle, [0, 1, 0]);
  webGL.drawElements(webGL.TRIANGLES, indices.length, webGL.UNSIGNED_BYTE, 0);

  initTransformation(armAngle, [0, 0, 1], modelArr);
  webGL.drawElements(webGL.TRIANGLES, indices.length, webGL.UNSIGNED_BYTE, 0);
}

function clear() {
  webGL.clearColor(0, 0, 0, 1);
  webGL.clear(webGL.COLOR_BUFFER_BIT | webGL.DEPTH_BUFFER_BIT);
  webGL.enable(webGL.DEPTH_TEST);
}
```

### 添加键盘控制事件

添加键盘事件控制jointAngle、armAngle来控制大臂和小臂的旋转角度。

```js
function initEvent() {
  document.onkeydown = keydown;
}

function keydown(ev) {
  switch (ev.keyCode) {
    case 38:
      if (jointAngle < 135.0) jointAngle += ANGLE_STEP;
      break;
    case 40:
      if (jointAngle > -135.0) jointAngle -= ANGLE_STEP;
      break;
    case 39:
      armAngle += ANGLE_STEP;
      break;
    case 37:
      armAngle -= ANGLE_STEP;
      break;
    default:
      return;
  }
  clear();
  draw();
}
```

## 多节点模型

那么上一步完成了大臂和小臂的联动，如果现在需要绘制一个简单的有头有手的机器人模型，下面简单的说一下实现步骤：

- 先绘制头部，用头部的模型矩阵来绘制上半身，完成头部、上半身联动。
- 用上半身的模型矩阵绘制左大臂，再通过大臂的模型矩阵来绘制小臂，
- 再通过小臂的模型矩阵来绘制手指1和手指2，这样就完成了大臂、小臂、手指的联动。

> **不管他有多少个节点，只要有节点的模型矩阵，就可以通过这个模型矩阵来绘制节点，完成联动。**

## 着色器对象 initShader

在前面已经简单解释了一下initShader是用来干啥的，这个后续都没有做过修改。现在来深入探究一下。

initShader函数的作用是：编译GLSLES代码，创建和初始化着色器供WebGL使用。具体地，分为以下7个步骤：

- 创建着色器对象(gl.createShader())
- 向着色器对象中填充着色器程序的源代码（gl.shaderSource())
- 编译着色器（gl.compileShader())
- 创建程序对象(gl.createProgram())
- 为程序对象分配着色器(gl.attachShader())
- 连接程序对象（gl.linkProgram())
- 使用程序对象(gl.useProgram())

这里出现了两个对象：着色器对象、程序对象

- 着色器对象：着色器对象管理一个顶点着色器或一个片元着色器。每一个着色器都有一个着色器对象
- 程序对象：程序对象是管理着色器对象的容器。WebGL中，一个程序对象必须包含一个顶点着色器和一个片元着色器

### 创建着色器对象

所有的着色器对象都是以gl.createShader()创建的，这个函数接收一个参数，这个参数是gl.VERTEX_SHADER或gl.FRAGMENT_SHADER，分别表示顶点着色器和片元着色器。

如果不需要这个着色器，可以通过gl.deleteShader()删除这个着色器对象。

### 指定着色器代码

通过gl.shaderSource()指定着色器的源代码，这个函数接收两个参数，第一个参数是着色器对象，第二个参数是着色器的源代码。

### 编译着色器

GLSL
ES语言和JavaScript不同而更接近C或C++，在使用之前需要编译成二进制的可执行格式，WebGL系统真正使用的是这种可执行格式。使用gl.compileShader()
函数进行编译。

当对着色器编译之后，如果编译失败，可以通过gl.getShaderParameter()
函数获取着色器的编译状态，如果编译失败，可以通过gl.getShaderInfoLog()函数获取着色器的编译信息。

```js
if (!webGL.getShaderParameter(vsShader, webGL.COMPILE_STATUS)) {
  console.log('vsShader error =====', webGL.getShaderInfoLog(vsShader));
  return;
}
if (!webGL.getShaderParameter(fsShader, webGL.COMPILE_STATUS)) {
  console.log('fsShader error =====', webGL.getShaderInfoLog(fsShader));
  return;
}
```

### 创建程序对象

调用gl.createProgram()创建程序对象，这个函数返回一个程序对象。类似的，可以通过gl.deleteProgram()
删除程序对象。一旦程序对象被创建之后，需要向程序附上两个着色器

### 为程序对象分配着色器

WebGL系统要运行起来，必须要有两个着色器：一个顶点着色器和一个片元着色器。可以使用gl.attachShader()函数为程序对象分配这两个着色器。

着色器在附给程序对象前，并不一定要为其指定代码或进行编译（也就是说，把空的着色器附给程序对象也是可以的）。类似地，可以使用gl.detachShader()
函数来解除分配给程序对象的着色器。

### 连接程序对象

在为程序对象分配了两个着色器对象后，还需要将（顶点着色器和片元）着色器连接起来。使用gl.1inkProgram()函数来进行这一步操作。

程序对象进行着色器连接操作，目的是保证：

- 顶点着色器和片元着色器的varying变量同名同类型，且一一对应
- 顶点着色器对每个varying变量赋了值
- 顶点着色器和片元着色器中的同名uniform变量也是同类型的（无需一一对应，即某些uniform变量可以出现在一个着色器中而不出现在另一个中）
- 着色器中的attribute变量、uniform变量和varying变量的个数没有超过着色器的上限

### 使用程序对象

通过调用gl.useProgram()告知WebGL系统绘制时使用哪个程序对象
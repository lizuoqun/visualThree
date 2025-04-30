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
## 调试工具

### NVIDIA Nsight Systems

[NVIDIA Nsight Systems](https://developer.nvidia.com/nsight-systems/get-started) 这个工具帮助开发者深入了解应用程序在
CPU、GPU 和网络通信等各个层面的运行情况，从而有效地识别性能瓶颈并进行优化

### WebGL-Inspector

插件的地址在这：[WebGL-Inspector chrome插件](https://benvanik.github.io/WebGL-Inspector/)
但是在这里已经无法下载，在chrome商店里面没有，在其[GitHub仓库 WebGL-Inspector ](https://github.com/benvanik/WebGL-Inspector/tree/master)
也没有找到。
然后在[ 百度网盘 ](https://pan.baidu.com/s/1US-z_rp0c3FKhckIYEAVtQ)
找到一个下载地址。下载下来的crx扩展文件直接拖拽安装的时候报错了，这时可以将crx改为zip压缩文件。然后再解压，然后在chrome:
//extensions/里面找到刚刚解压的目录，点击加载已解压扩展程序安装即可。

调试说明：可以用这个[水族馆](https://webglsamples.org/aquarium/aquarium.html)或者拿一个webgl写的案例来试一下

### WebGL lint

[WebGL lint](https://www.npmjs.com/package/webgl-lint) 是一个脚本，您可以将其放入 WebGL 项目中，以检查常见的 WebGL 错误。

可以直接通过script标签引入或者通过import引入

```js
<script src="https://greggman.github.io/webgl-lint/webgl-lint.js" crossorigin></script>;

import 'https://greggman.github.io/webgl-lint/webgl-lint.js';
```

## 类型化数组

## 提升webGL效率

### 数据方面（数据组织）

绘制一个带有颜色的三角形，我们通常需要定义两个数组，然后再读取数据传到着色器代码当中。

- 顶点坐标xyz数组
- 颜色数组

但是在CPU和GPU在读写数据的时候，会消耗大量的时间，所以尽量减少数据的读写次数，尽量减少数据在CPU和GPU之间的传输。所以在前面我们通常在数据融合在同一个数组当中，再通过vertexAttribPointer去取偏移量。

```js
webGL.vertexAttribPointer(aPsotion, 4, webGL.FLOAT, false, 8 * 4, 0);
webGL.vertexAttribPointer(aColor, 4, webGL.FLOAT, false, 8 * 4, 4 * 4);
```

### 绘制方面（可视化）

核心在于drawArray和drawElements（调用的次数越少、性能越高）

> 退化三角形：表面上看起来是在绘制三角形，但是当webGL正要绘制的时候发现提供的顶点无法绘制，webGL会检测并且删除该三角形

### 不同的绘制方法消耗的性能

在webGL当中绘制平面都是基于三角形来绘制的，现在假设需要绘制8个三角形，然后有三个绘制三角形的API和两个绘制方法。其中顶点坐标用Float32Array类型，index数用Uint16Array类型。

- Float32Array需要4个字节，Uint16Array需要2个字节

|                    | drawArray                                                | drawElements                                        |
|--------------------|----------------------------------------------------------|-----------------------------------------------------|
| 绘制三角形API           | 不需要index索引数组                                             | 需要index索引数组                                         |
| TRIANGLES 三角形      | 8个三角形，每个三角形需要3个顶点 <br> 24 * 4 * 4 = 384                  | 只需要九个不同的顶点以及3*8个索引位置<br/> 9 * 4 * 4 + 24 * 2 = 192  |
| TRIANGLE_FAN 三角扇   | 上面需要6个点、下面也是6个点外加中间连接的两个点 <br> (6 + 6 + 2) * 4 * 4 = 224 | 同样的需要九个顶点但是只需要14个索引位置<br/> 9 * 4 * 4 + 14 * 2 = 172 |                                            |
| TRIANGLE_STRIP 三角带 | 同上                                                       | 同上                                                  |

>
总结：这是一个只包含8个三角形的小网格，而且只考虑了顶点位置，所以需要的内存相对来说还算小。如果面对的是一个很的网格，而且还需要包括法线和纹理坐标，则使用drawElements()
方法+TRIANGLE_STRIP图元的组合可以节省更多的内存。
>
> 重要的是，不要毫无必要地浪费内存，但是从性能角度来看，内存并不是唯一重要的因素。从性能角度来看，三角形绘制的顺序以及项点数据的组织形式也是很重要的因素。
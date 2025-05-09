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
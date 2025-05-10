let buffer = new ArrayBuffer(16);

let view = new Uint32Array(buffer);

// 每个整数占4字节
console.log('Uint32Array.BYTES_PER_ELEMENT =====', Uint32Array.BYTES_PER_ELEMENT);

console.log('Uint8Array.BYTES_PER_ELEMENT =====', Uint8Array.BYTES_PER_ELEMENT);

console.log('Float32Array.BYTES_PER_ELEMENT =====', Float32Array.BYTES_PER_ELEMENT);

// ArrayBuffer的长度是16，view.length = 16/4 = 4
console.log('view.length =====', view.length);

// 每个整数占4字节，所以byteLength = 4 * 4 = 16
console.log('view.byteLength =====', view.byteLength);

view[0] = 123456;

// 初始化的值为0，其中改变了第一个值
for (let num of view) {
  console.log(' =====', num);
}

console.log('===================================================================================================================');

let array16 = new Uint16Array([1, 1000]);
// 1000 转成二进制 1111101000
let array8 = new Uint8Array(array16);
// 10位的整数存不下，从后往前截取八位即11101000，再转换成十进制即232
console.log(' =====', array8[0], array8[1]);
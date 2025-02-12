<template>
  <div ref="body" class="w-full h-full">
    <canvas id="myCanvas"></canvas>
  </div>
</template>

<script>
export default {
  data() {
    return {};
  },
  mounted() {
    this.init();
  },

  methods: {
    init() {
      // 定义球形及初速度
      class Star {
        constructor(x, y, radius) {
          // x，y是坐标，r是半径
          this.x = x;
          this.y = y;
          this.r = radius;
          // speed参数，在  -3 ~ 3 之间取值 随机速度初始化:
          this.speedX = Math.random() * 3 * Math.pow(-1, Math.round(Math.random()));
          this.speedY = Math.random() * 3 * Math.pow(-1, Math.round(Math.random()));
        }

        // 绘制圆球
        draw() {
          ctx.beginPath();
          ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
          ctx.fill();
          ctx.closePath();
        }

        // 设置边界反弹
        move() {
          this.x -= this.speedX;
          this.y -= this.speedY;
          // 碰到边界时，反弹，只需要把speed取反就行
          if (this.x < 0 || this.x > aw) this.speedX *= -1;
          if (this.y < 0 || this.y > ah) this.speedY *= -1;
        }

        // 绘制连线
        drawLine(startX, startY, endX, endY) {
          ctx.beginPath();
          ctx.moveTo(startX, startY);
          ctx.lineTo(endX, endY);
          ctx.stroke();
          ctx.closePath();
        }
      }

      const body = this.$refs.body;
      const canvas = document.getElementById('myCanvas');

      canvas.width = body.clientWidth;
      canvas.height = body.clientHeight;

      let aw = canvas.width;
      let ah = canvas.height;

      const ctx = canvas.getContext('2d');
      // 自适应宽高
      window.addEventListener('resize', () => {
        canvas.width = body.clientWidth;
        canvas.height = body.clientHeight;
        aw = canvas.width;
        ah = canvas.height;
        const ctx = canvas.getContext('2d');
      });

      const getMouse = element => {
        let mouse = {x: 0, y: 0};
        element.addEventListener('mousemove', e => {
          mouse.x = e.clientX - element.getBoundingClientRect().left; // 使用clientX和getBoundingClientRect计算鼠标位置
          mouse.y = e.clientY - element.getBoundingClientRect().top;
        });

        return mouse;
      };

      canvas.addEventListener('click', e => {
        let x = e.clientX - canvas.getBoundingClientRect().left; // 使用clientX和getBoundingClientRect计算鼠标位置
        let y = e.clientY - canvas.getBoundingClientRect().top;

        for (let i = 0; i < 10; i++) {
          let newStar = new Star(x, y, 3);
          stars.push(newStar);
        }
        stars.splice(0, 10);
      });

      // 定义颜色，色调都是白色
      ctx.fillStyle = 'white';
      ctx.strokeStyle = 'white';
      // 获取鼠标创造鼠标点球
      let mouse = getMouse(canvas);
      let mouseStar = new Star(0, 0, 3);
      let stars = [];
      for (let index = 0; index < 300; index++) {
        stars.push(new Star(Math.random() * aw, Math.random() * ah, 3));
      }
      ;(function frame() {
        window.requestAnimationFrame(frame);
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        //鼠标点绘制
        mouseStar.x = mouse.x;
        mouseStar.y = mouse.y;
        mouseStar.draw();
        // 散点球绘制
        stars.forEach(star => {
          star.draw();
          star.move();
        });
        stars.forEach((star, i) => {
          stars.forEach((otherStar, j) => {
            // 对比每一个圆球，如果当前x,y与另一个圆球x,y间距小于50，就绘制连线
            // Math.abs 是一个数学函数，用于计算一个数的绝对值永远是正数
            if (i !== j && Math.abs(star.x - otherStar.x) < 50 && Math.abs(star.y - otherStar.y) < 50) {
              star.drawLine(star.x, star.y, otherStar.x, otherStar.y);
            }
            // 判断鼠标星星连线
            if (Math.abs(mouseStar.x - star.x) < 50 && Math.abs(mouseStar.y - star.y) < 50) {
              mouseStar.drawLine(mouseStar.x, mouseStar.y, star.x, star.y);
            }
          });
        });
      })();
    }
  }
};
</script>
<style scoped>
canvas {
  border: 1px solid black;
  background-color: #f0f0f0;
  margin-right: 10px;
  background: url('https://img2.baidu.com/it/u=2966362877,3794426626&fm=253&fmt=auto&app=138&f=JPEG?w=1920&h=2080') no-repeat;
  background-size: 100% 100%;
}
</style>


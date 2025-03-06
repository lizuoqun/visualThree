<script setup lang="ts">
import * as THREE from 'three';
import WORLD_ZH from '@/assets/mapJson/world.zh.json';
import InitThree, {ThreeObjectInterface} from '@/pages/initThree';
import {defaultCameraPosition} from '@/pages/car/constent';

const it = new InitThree(defaultCameraPosition, false);
let threeObject: ThreeObjectInterface = it.allThreeObject;

onMounted(() => {
  animate();
  const ele = document.getElementById('earth') as HTMLElement;
  ele.appendChild(threeObject.renderer.domElement);
});


const animate = () => {
  const {renderer, scene, camera, labelRenderer} = threeObject;
  scene.add(createEarth());
  renderer.render(scene, camera);
  labelRenderer.render(scene, camera);
  requestAnimationFrame(animate);
};

const canvasOptions = {
  bg: '#000080',
  borderColor: '#1E90FF',
  blurColor: '#1E90FF',
  borderWidth: 1,
  blurWidth: 5,
  fillColor: 'rgb(30 ,144 ,255,0.3)'
};

function drawRegion(ctx: CanvasRenderingContext2D, c: any[]) {
  ctx.beginPath();
  c.forEach((item, i) => {
    // 转换经纬度坐标为canvas坐标点
    let pos = [(item[0] + 180) * 10, (-item[1] + 90) * 10];
    if (i == 0) {
      ctx.moveTo(pos[0], pos[1]);
    } else {
      ctx.lineTo(pos[0], pos[1]);
    }
  });
  ctx.closePath();
  ctx.fill();
  ctx.stroke();
}


const createCanvas = () => {
  let canvas = document.createElement('canvas');

  canvas.width = 3600;
  canvas.height = 1800;

  let ctx = canvas.getContext('2d') as CanvasRenderingContext2D;
  // 背景颜色
  ctx.fillStyle = canvasOptions.bg;
  ctx.rect(0, 0, canvas.width, canvas.height);
  ctx.fill();


  // 设置地图样式
  ctx.strokeStyle = canvasOptions.borderColor;
  ctx.lineWidth = canvasOptions.borderWidth;

  ctx.fillStyle = canvasOptions.fillColor;
  if (canvasOptions.blurWidth) {
    ctx.shadowBlur = canvasOptions.blurWidth;
    ctx.shadowColor = canvasOptions.blurColor;
  }

  WORLD_ZH.features.forEach((a) => {
    if (a.geometry.type == 'MultiPolygon') {
      // 多个区块组成
      a.geometry.coordinates.forEach((b) => {
        b.forEach((c) => {
          drawRegion(ctx, c);
        });
      });
    } else {
      // 单个区块
      a.geometry.coordinates.forEach((c) => {
        drawRegion(ctx, c);
      });
    }
  });

  const app = document.getElementById('app') as HTMLElement;
  app.appendChild(canvas);

  return canvas;
};

const createEarth = () => {

  const canvas = createCanvas();
  // 地球用canvas贴图
  const map = new THREE.CanvasTexture(canvas);
  map.wrapS = THREE.RepeatWrapping;
  map.wrapT = THREE.RepeatWrapping;

  const geometry = new THREE.SphereGeometry(4, 128, 128);

  const material = new THREE.MeshBasicMaterial({map: map, transparent: true});

  return new THREE.Mesh(geometry, material);
};


</script>

<template>
  <div id="earth" class="w-full h-full bg-black"/>
</template>
<script setup lang="ts">
import * as THREE from 'three';
import WORLD_ZH from '@/assets/mapJson/world.zh.json';
import WORLD_POINT from '@/assets/mapJson/world-point.json';
import InitThree, {ThreeObjectInterface} from '@/pages/initThree';
import {defaultCameraPosition} from '@/pages/car/constent';

// https://v.antfin.com/zh-cn/l7/1.x/demo/bubble/point_color.html

const it = new InitThree(defaultCameraPosition, false);
let threeObject: ThreeObjectInterface = it.allThreeObject;

onMounted(() => {
  animate();
  const {scene} = threeObject;
  scene.add(createEarth());
  addObject3D(scene);
  const ele = document.getElementById('earth') as HTMLElement;
  ele.appendChild(threeObject.renderer.domElement);
});


const animate = () => {
  const {renderer, scene, camera, labelRenderer} = threeObject;
  // scene.add(createEarth());
  // scene.add(addObject3D());
  // scene.add(createBar());
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

let max: number = 0, min: number = 0, range: number = 0;

const addObject3D = (scene: THREE.Scene) => {
  const lonHelper = new THREE.Object3D(); // 经度旋转辅助对象

  const latHelper = new THREE.Object3D(); // 维度旋转辅助对象
  lonHelper.add(latHelper);

  const positionHelper = new THREE.Object3D(); // 最终位置辅助对象
  positionHelper.position.z = 4; // 球体半径是4,让变换位置在球体表面，需z坐标向外偏移1
  latHelper.add(positionHelper);


  WORLD_POINT.forEach((item) => {
    const g = Number(item.mag);
    if (g > max) {
      max = g;
    }
    if (g < min) {
      min = g;
    }
  });

  range = max - min;

  WORLD_POINT.forEach((item) => {
    const boxGeometry = new THREE.BoxGeometry(2, 2, 6);
    boxGeometry.applyMatrix4(new THREE.Matrix4().makeTranslation(0, 0, 2));
    createBar(Number(item.lon), Number(item.lat), item.mag, boxGeometry, lonHelper, latHelper, positionHelper, scene);
  });

  scene.add(lonHelper);
};


const createBar = (lon: number, lat: number, value: number, boxGeometry: THREE.BoxGeometry, lonHelper: THREE.Object3D, latHelper: THREE.Object3D, positionHelper: THREE.Object3D, scene: THREE.Scene) => {
  // 给材质添加随机颜色
  const material = new THREE.MeshBasicMaterial({
    // color: new THREE.Color(
    //     `rgb(${Math.floor(Math.random() * 255)},${Math.floor(Math.random() * 255)},${Math.floor(Math.random() * 255)})`
    // )
  });

  // material.color.setRGB(
  //     Math.random(),
  //     Math.random(),
  //     Math.random()
  // );

  const mesh = new THREE.Mesh(boxGeometry, material);
  scene.add(mesh);


  lonHelper.rotation.y = THREE.MathUtils.degToRad(lon) + Math.PI * 0.5;
  latHelper.rotation.x = THREE.MathUtils.degToRad(-lat);
  // console.log(' =====', lon, lat, lonHelper.rotation);

  positionHelper.updateWorldMatrix(true, false);
  mesh.applyMatrix4(positionHelper.matrixWorld);

  const amount = (value - min) / range;
  mesh.scale.set(0.01, 0.01, THREE.MathUtils.lerp(0.01, 0.5, amount));
};


</script>

<template>
  <div id="earth" class="w-full h-full bg-black"/>
</template>
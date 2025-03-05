<!-- 3D地球 -->
<script setup lang="ts">
import * as THREE from 'three';
import InitThree, {ThreeObjectInterface} from '../initThree';

import World_Image from '@/assets/image/world.png';
import {THREE_WHITE_COLOR} from '@/pages/car/constent';

const it = new InitThree();

let threeObject: ThreeObjectInterface = it.allThreeObject;

onMounted(() => {
  animate();
  const ele = document.getElementById('earth') as HTMLElement;
  ele.appendChild(threeObject.renderer.domElement);
  addRedCube(threeObject.scene);
});

const animate = () => {
  const {renderer, scene, camera, labelRenderer} = threeObject;
  renderer.render(scene, camera);
  labelRenderer.render(scene, camera);
  requestAnimationFrame(animate);
};

const addRedCube = (scene: THREE.Scene) => {

  const geometry = new THREE.SphereGeometry(4, 128, 128);
  const texture = new THREE.TextureLoader().load(World_Image);
  texture.wrapS = THREE.RepeatWrapping;
  texture.wrapT = THREE.RepeatWrapping;

  const texture1 = new THREE.TextureLoader().load(World_Image);
  texture1.wrapS = THREE.RepeatWrapping;
  texture1.wrapT = THREE.RepeatWrapping;

  const material = new THREE.MeshStandardMaterial({
    map: texture,
    bumpMap: texture,
    bumpScale: 1
  });
  const sphere = new THREE.Mesh(geometry, material);
  scene.add(sphere);

  scene.add(addAmbientLight());
};

// 添加环境光
const addAmbientLight = () => {
  const ambientLight = new THREE.AmbientLight(THREE_WHITE_COLOR, 1); // 添加环境光
  return ambientLight;
};
</script>

<template>
  <div id="earth" class="w-full h-full bg-black"/>
</template>

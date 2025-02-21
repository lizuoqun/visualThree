<!-- 3D地球 -->
<script setup lang="ts">
import * as THREE from 'three';
import InitThree, {ThreeObjectInterface} from '../initThree';

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
  const geometry = new THREE.BoxGeometry();
  const material = new THREE.MeshBasicMaterial({color: 0xff0000});
  const cube = new THREE.Mesh(geometry, material);
  scene.add(cube);
};
</script>

<template>
  <div id="earth" class="w-full h-full"/>
</template>

<!-- 3D地球 -->
<script setup lang="ts">
import * as THREE from 'three';
import InitThree, {ThreeObjectInterface} from '../initThree';

import World_Image from '@/assets/image/world2.png';
import {defaultCameraPosition, THREE_WHITE_COLOR} from '@/pages/car/constent';

const it = new InitThree(defaultCameraPosition, false);

let threeObject: ThreeObjectInterface = it.allThreeObject;

onMounted(() => {
  animate();
  const ele = document.getElementById('earth') as HTMLElement;
  ele.appendChild(threeObject.renderer.domElement);
  addEarth(threeObject.scene);
  addShell(threeObject.scene);
});

const animate = () => {
  const {renderer, scene, camera, labelRenderer} = threeObject;
  animateAction();
  renderer.render(scene, camera);
  labelRenderer.render(scene, camera);
  requestAnimationFrame(animate);
};

const addEarth = (scene: THREE.Scene) => {
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

let shellMaterial: THREE.ShaderMaterial;

const addShell = (scene: THREE.Scene) => {
  const geometry = new THREE.SphereGeometry(4.5, 128, 128);
  // const material = new THREE.MeshBasicMaterial({
  //   color: 0xffffff,
  //   transparent: true,
  //   opacity: 0.2
  // });
  shellMaterial = new THREE.ShaderMaterial({
    uniforms: {
      iTime: {value: 0.0},
      uColor: {value: new THREE.Color('#dddddd')}
    },
    transparent: true,
    vertexShader: `
      varying vec2 vUv;
      void main(){
        vUv=uv;
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
      }`,
    fragmentShader: `
      float PI = acos(-1.0);
      uniform vec3 uColor;
      uniform float iTime;
      varying vec2 vUv;
      void main(){
        vec2 uv = vUv + vec2(0.0, iTime);
        float current = abs(sin(uv.y * PI));
        gl_FragColor.rgb= uColor;
        gl_FragColor.a = mix(0.8, 0.0, current);
      }
    `
  });
  const sphere = new THREE.Mesh(geometry, shellMaterial);
  scene.add(sphere);
};

const animateAction = () => {
  if (shellMaterial) {
    if (shellMaterial.uniforms.iTime.value > 1) {
      shellMaterial.uniforms.iTime.value = 0;
    } else {
      shellMaterial.uniforms.iTime.value += 0.005;
    }
  }
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

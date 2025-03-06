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

  const material = new THREE.MeshStandardMaterial({
    map: texture,
    bumpMap: texture,
    bumpScale: 1
  });

  const sphere = new THREE.Mesh(geometry, material);
  scene.add(sphere);

  scene.add(addAmbientLight());
};

let material: THREE.ShaderMaterial;

const addShell = (scene: THREE.Scene) => {
  const geometry = new THREE.SphereGeometry(4.5, 128, 128);
  // const material = new THREE.MeshBasicMaterial({
  //   color: 0xffffff,
  //   transparent: true,
  //   opacity: 0.2
  // });
  // material = createShellMaterial();
  material = createPointMaterial();
  const sphere = new THREE.Mesh(geometry, material);
  scene.add(sphere);
};

const animateAction = () => {
  if (material) {
    updateTime();
  }
};

const updateTime = () => {
  if (material.uniforms.iTime.value > 1) {
    material.uniforms.iTime.value = 0;
  } else {
    material.uniforms.iTime.value += 0.005;
  }
};

// 添加环境光
const addAmbientLight = () => {
  const ambientLight = new THREE.AmbientLight(THREE_WHITE_COLOR, 2); // 添加环境光
  return ambientLight;
};

// 创建外围壳发光material
const createShellMaterial = () => {
  return new THREE.ShaderMaterial({
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
        gl_FragColor.a = mix(1.0, 0.0, current);
      }
    `
  });
};

// 创建点运动的material
const createPointMaterial = () => {
  return new THREE.ShaderMaterial({
    uniforms: {
      iTime: {value: 0.0},
      pointNum: {value: new THREE.Vector2(32, 16)},
      uColor: {value: new THREE.Color('#FFFFFF')}
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
      uniform vec2 pointNum;
      uniform float iTime;
      varying vec2 vUv;
      void main(){
        vec2 uv = vUv+ vec2(0.0, iTime);
        float current = abs(sin(uv.y * PI) );
        if(current < 0.996) {
          current = current*0.5;
        }
        float d = distance(fract(uv * pointNum*2.0), vec2(0.5, 0.5));

        if(d > current * 0.2) {
          discard;
        } else {
          gl_FragColor =vec4(uColor,current);
        }
      }
      `
  });
};
</script>

<template>
  <div id="earth" class="w-full h-full bg-black"/>
</template>

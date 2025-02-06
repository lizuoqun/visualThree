<script setup lang="ts">
/**
 * su7 模型下载：https://sketchfab.com/3d-models/su7-7296a91633d74c6eb113010e2ed75eda#download
 *
 * */
import * as THREE from 'three';
import gsap from 'gsap';
import {OrbitControls} from 'three/examples/jsm/controls/OrbitControls';
import {GLTFLoader} from 'three/examples/jsm/loaders/GLTFLoader';


const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
camera.position.set(5, 1.5, 0);
// 相机辅助器
// const cameraHelper = new THREE.CameraHelper(camera);
// scene.add(cameraHelper);
scene.add(camera);

const axesHelper = new THREE.AxesHelper(10);
scene.add(axesHelper);

// 设置antialias抗锯齿、设备像素比
const renderer = new THREE.WebGLRenderer({antialias: true});
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(window.devicePixelRatio);

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;

const render = () => {
  renderer.render(scene, camera);
  requestAnimationFrame(render);
};

onMounted(() => {
  document.getElementById('home')?.appendChild(renderer.domElement);
  addLight();
  addModel();
  render();
});

const addLight = () => {
  const ambientLight = new THREE.AmbientLight(0xffffff, 1);
  scene.add(ambientLight);
};

let model: any;
// 添加SU7模型
const addModel = () => {
  const gltfLoader = new GLTFLoader();
  gltfLoader.load('./src/assets/glb/SU7.glb', (gltf: any) => {
    model = gltf.scene;
    model.traverse((child) => {
      console.log('child =====', child.name);
    });
    scene.add(model);
  });
};

const viewFromInside = () => {
  // 设置相机位置到汽车内部
  gsap.to(camera.position, {
    x: -0.2,
    y: 0.9,
    z: -0.3,
    duration: 2,
    ease: 'power2.inOut',
    onUpdate: () => {
      // 在动画过程中更新相机的视角
      camera.lookAt(controls.target);
    }
  });

  gsap.to(controls.target, {
    x: -2,
    y: 1.2,
    z: -5,
    duration: 2,
    ease: 'power2.inOut'
  });
};


const openCarDoor = () => {
  model.traverse((child) => {
    console.log('child =====', child.isMesh, child.name);
    if (child.name === 'DOOR3') {
      gsap.to(child.rotation, {
        x: -Math.PI / 4,
        y: -Math.PI / 4,
        duration: 2,
        ease: 'power2.out'
      });
    }
  });
};

const reFreshScene = () => {
  // 重置相机位置
  gsap.to(camera.position, {
    x: 5,
    y: 1.5,
    z: 0,
    duration: 1,
    ease: 'power2.inOut',
    onUpdate: () => {
      // 在动画过程中更新相机的视角
      camera.lookAt(controls.target);
    }
  });
};
</script>

<template>
  <div id="home" class="w-full h-full"/>

  <div class="absolute  top-[10px] left-[10px]">
    <el-icon class="w-[24px] h-[24px] bg-white cursor-pointer rounded-[4px]">
      <Refresh @click="reFreshScene()"/>
    </el-icon>
  </div>
</template>

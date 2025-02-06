<script setup lang="ts">
import type {Group, Texture, TextureLoader} from 'three';
/**
 * su7 模型下载：https://sketchfab.com/3d-models/su7-7296a91633d74c6eb113010e2ed75eda#download
 *
 * */
import * as THREE from 'three';
import {LIGHT_INTENSITY, THREE_WHITE_COLOR} from './constent';
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
  addRectangle();
  addModel();
  render();
});

const addLight = () => {
  // 创建上方矩形的四个顶点的光照位置进行照射
  createLight(6, 6, 0);
  createLight(-6, 6, 0);
  createLight(0, 6, 6);
  createLight(0, 6, -6);
};

const createLight = (x: number, y: number, z: number) => {
  const light = new THREE.DirectionalLight(THREE_WHITE_COLOR, LIGHT_INTENSITY);
  light.position.set(x, y, z);
  scene.add(light);
};

let model: Group;
// 添加SU7模型
const addModel = () => {
  const gltfLoader = new GLTFLoader();
  gltfLoader.load('./src/assets/glb/SU7.glb', (gltf: any) => {
    model = gltf.scene;
    model.traverse((child) => {
      if (child.name.includes('Wheel')) {
        // 让四个车轮旋转起来，不对，旋转的中心轴不是车轮的轴
        // gsap.to(child.rotation, {
        //   z: Math.PI * 2,
        //   duration: 2,
        //   ease: 'power2.inOut'
        // });
      }
    });

    const textureLoader: TextureLoader = new THREE.TextureLoader();
    textureLoader.load(
        './src/assets/image/su7/Wheel1.png',
        (texture) => {
          applyTextureToWheels(model, texture, 'Wheel');
        }
    );
    scene.add(model);
  });
};

/**
 * 给car的每一部分添加对应的贴图
 * @param model 模型
 * @param texture 贴图
 * @param meshName 贴图对应的物体名称
 * */
function applyTextureToWheels(model: Group, texture: Texture, meshName: string) {
  model.traverse((child: any) => {
    if (child.isMesh && child.name && child.name.includes(meshName)) {
      child.material.map = texture;
      child.material.transparent = true;
      child.material.side = THREE.DoubleSide;
      child.material.needsUpdate = true;
    }
  });
}

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
  model.traverse((child: any) => {
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

// 创建顶部的发光矩形
const addRectangle = () => {
  const geometry = new THREE.PlaneGeometry(3, 5);
  const material = new THREE.MeshStandardMaterial({
    color: THREE_WHITE_COLOR,
    emissive: THREE_WHITE_COLOR,
    emissiveIntensity: 1
  });
  const rectangle = new THREE.Mesh(geometry, material);
  rectangle.position.x = 0;
  rectangle.position.y = 3;
  rectangle.position.z = 0;
  rectangle.rotation.x = Math.PI / 2;
  scene.add(rectangle);
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

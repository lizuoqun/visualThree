<script lang="ts" setup>
import * as THREE from 'three';
import {OrbitControls} from 'three/examples/jsm/controls/OrbitControls';
import {GLTFLoader} from 'three/examples/jsm/loaders/GLTFLoader';
import TextureImage from '@/assets/image/wall.png';

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.001, 2000);
camera.position.set(2, 2, 2);
scene.add(camera);

const addLight = () => {
  const ambientLight = new THREE.AmbientLight(0xffffff, 2);
  scene.add(ambientLight);
  const directionalLight = new THREE.DirectionalLight(0xffffff, 0.2);
  directionalLight.position.set(0, 10, 5);
  const directionalLight2 = directionalLight.clone();
  directionalLight2.position.set(0, 10, -5);
  const directionalLight3 = directionalLight.clone();
  directionalLight3.position.set(5, 10, 0);
  const directionalLight4 = directionalLight.clone();
  directionalLight4.position.set(-5, 10, 0);
  scene.add(directionalLight);
  scene.add(directionalLight2);
  scene.add(directionalLight3);
  scene.add(directionalLight4);
};


const renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight);

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;


// const axesHelper = new THREE.AxesHelper(1);
// scene.add(axesHelper);

// 加载模型
let model: THREE.Object3D;

const addCity = () => {
  const gltfLoader = new GLTFLoader();
  gltfLoader.load('./src/assets/glb/shanghai_city.glb', (gltf: any) => {
    model = gltf.scene.children[0];
    toCenter();
    model.traverse((item: any) => {
      console.log(' =====', item.name);
      if (item.name.includes('dongfangmingzhu')) {
        item.material = colorMaterial('#f40', null);
      } else if (item.name.includes('shanghaizhongxin')) {
        item.material = colorMaterial('#d90000', null);
      } else if (item.name.includes('huanqiujinrongzhongxin')) {
        item.material = colorMaterial('#008000', null);
      } else if (item.name.includes('jinmaodasha')) {
        item.material = colorMaterial('#0000ff', null);
      } else if (item.name.includes('Floor')) {
        item.material = colorMaterial(getRandomColor(), null);
      } else if (item.name.includes('city')) {
        item.material = colorMaterial('#ffffff', texture);
      }
    });
    scene.add(model);
  });
};

const getRandomColor = () => {
  return '#' + Math.floor(Math.random() * 16777215).toString(16);
};

const toCenter = () => {
  const box = new THREE.Box3();
  box.expandByObject(model);
  const size = new THREE.Vector3();
  const center = new THREE.Vector3();
  // 获取包围盒的中心点和尺寸
  box.getCenter(center);
  box.getSize(size);
  // 将Y轴置为0
  model.position.copy(center.negate().setY(0));
};


// 图片加载器
const ImageLoader = new THREE.ImageLoader();
let texture: { needsUpdate: boolean; };
const textureOption = {
  wraps: THREE.RepeatWrapping,
  repeat: new THREE.Vector2(10, 10),
  wrapT: THREE.RepeatWrapping
};
ImageLoader.load(TextureImage, function (img: any) {
  texture = new THREE.Texture(img, textureOption);
  texture.needsUpdate = true;
});

const colorMaterial = (color: string, texture: any) => {
  let options = {};
  if (texture) {
    options = {
      map: texture,
      alphaMap: texture,
      aoMapIntensity: 0,
      bumpMap: texture,
      bumpScale: 0
    };
  } else {
    options = {
      color,
      shininess: 100,
      flatShading: true
    };
  }
  return new THREE.MeshPhongMaterial(options);
};


// 渲染
const render = () => {
  renderer.render(scene, camera);
  requestAnimationFrame(render);
};

onMounted(() => {
  document.getElementById('home')?.appendChild(renderer.domElement);
  addLight();
  addCity();
  render();
});
</script>

<template>
  <div id="home" class="w-full h-full"/>
</template>

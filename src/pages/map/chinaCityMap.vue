<template>
  <div id="map" class="w-full h-full"/>
  <el-button @click="colorLight()">添加光源</el-button>
</template>

<script lang="ts" setup>
import * as THREE from 'three';
import {OrbitControls} from 'three/examples/jsm/controls/OrbitControls.js';
import {CSS2DObject, CSS2DRenderer} from 'three/examples/jsm/renderers/CSS2DRenderer.js';
import * as d3 from 'd3';
import ChinaData from '@/assets/mapJson/chinaCity.json';
import mapTextureImage from '@/assets/image/map-texture.png';
import {EffectComposer} from 'three/examples/jsm/postprocessing/EffectComposer';
import {OutputPass} from 'three/examples/jsm/postprocessing/OutputPass';
import {RenderPass} from 'three/examples/jsm/postprocessing/RenderPass';
import {UnrealBloomPass} from 'three/examples/jsm/postprocessing/UnrealBloomPass';
// import mapTextureImage from '@/assets/image/wall.png';

// 创建场景
const scene = new THREE.Scene();

// 添加坐标轴
const axesHelper = new THREE.AxesHelper(5);
scene.add(axesHelper);

// 如果用金属反光材质就用这个光
const colorLight = () => {
  const ambientLight = new THREE.AmbientLight(0xd4e7fd, 4);
  scene.add(ambientLight);
  const directionalLight = new THREE.DirectionalLight(0xe8eaeb, 0.2);
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

// 创建相机
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 2000);
camera.position.y = 64;
camera.position.z = 64;

// 如果用地图纹理就用这个光
const mapTextureLight = () => {
  const ambientLight = new THREE.AmbientLight('white', 0.5);
  ambientLight.position.set(5, 10, 5);
  scene.add(ambientLight);

  const light = new THREE.DirectionalLight('#fff', 1);
  light.position.set(5, 10, 5);
  camera.add(light);
};

// 创建渲染器
const labelRenderer = new CSS2DRenderer();
const addRenderer = () => {
  labelRenderer.domElement.style.position = 'absolute';
  labelRenderer.domElement.style.top = '0px';
  labelRenderer.domElement.style.pointerEvents = 'none';
  labelRenderer.setSize(window.innerWidth, window.innerHeight);
  const ele = document.getElementById('map') as HTMLElement;
  ele.appendChild(labelRenderer.domElement);
};

// 窗口大小变化监听器
const renderer = new THREE.WebGLRenderer({alpha: true});
renderer.setSize(window.innerWidth, window.innerHeight);

// 控制器
const controls = new OrbitControls(camera, renderer.domElement);
controls.update();

const animate = () => {
  controls.update();

  // 渲染器是否在渲染每一帧之前自动清除其输出
  renderer.autoClear = false;
  // 让渲染器清除颜色、深度或模板缓存
  renderer.clear();

  baseCompass.render();

  baseLineBorderMaterialArray.forEach((item: THREE.Material) => {
    item.visible = true;
  });

  renderer.render(scene, camera);
  labelRenderer.render(scene, camera);
  requestAnimationFrame(animate);
};

onMounted(() => {
  addRenderer();
  initBloom();
  animate();
  document.getElementById('map')?.appendChild(renderer.domElement);
  mapTextureLight();
  createMap(ChinaData);
});

// 矫正坐标
const offsetXY = d3.geoMercator();

// 根据省市的json数据创建地图
const createMap = (data: any) => {
  const map = new THREE.Object3D();
  const center = data.features[0].properties.centroid;
  offsetXY.center(center).translate([0, 0]);
  data.features.forEach((feature: any) => {
    const unit = new THREE.Object3D();
    const {centroid, center, name, adcode} = feature.properties;
    const {coordinates, type} = feature.geometry;
    const depth = 1;
    // 绘制每个市的名称和图标
    const label = createLabel(name, centroid || center || [0, 0], depth);
    coordinates.forEach((coordinate: any) => {
      if (type === 'MultiPolygon') coordinate.forEach((item: any) => fn(item));
      if (type === 'Polygon') fn(coordinate);

      function fn(coordinate: any) {
        // 添加自定义属性，点击的时候可以打印出来
        unit.name = name + ' --- ' + adcode;
        // 绘制每个市的区域（传入颜色和深度）
        const mesh = createMesh(coordinate, '#63bbd0', depth, name);
        // 绘制每个市的边界
        const line = createLine(coordinate, depth);
        // @ts-ignore
        unit.add(...mesh, ...line);
      }
    });
    map.add(unit, label);
  });
  setCenter(map);
  scene.add(map);
};

const mapTexture = new THREE.TextureLoader().load(mapTextureImage);
mapTexture.wrapS = THREE.RepeatWrapping;
mapTexture.wrapT = THREE.RepeatWrapping;
mapTexture.needsUpdate = true;

let baseLineBorderMaterialArray: THREE.ShaderMaterial[] = [];
/**
 * 绘制每个市的区域
 * @param data 坐标数据
 * @param color 颜色
 * @param depth 深度
 * @param name 区域名称
 * */
const createMesh = (data: any, color: string, depth: number, name: string) => {

  const shape = new THREE.Shape();
  data.forEach((item: any, idx: number) => {
    const [x, y] = offsetXY(item) as number[];

    if (idx === 0) shape.moveTo(x, -y);
    else shape.lineTo(x, -y);
  });

  const extrudeSettings = {
    depth: depth,
    bevelEnabled: false
  };
  // 图片纹理贴图配置
  const materialSettings = {
    map: mapTexture,
    bumpMap: mapTexture,
    bumpScale: 1,
    transparent: true,
    opacity: 0.8,
    side: THREE.DoubleSide
  };
  // 金属反射配置
  const materialSettings1 = {
    color: color,
    emissive: 0x000000,
    roughness: 0.45,
    metalness: 0.8,
    transparent: true,
    side: THREE.DoubleSide
  };
  const geometry = new THREE.ExtrudeGeometry(shape, extrudeSettings);
  const material = new THREE.MeshStandardMaterial(materialSettings);
  console.log(' =====', materialSettings1);
  const mesh = new THREE.Mesh(geometry, material);
  material.name = name;

  let shaderMesh: THREE.Mesh | null = null;
  return [mesh, shaderMesh];
};

const baseMaterialArray: THREE.ShaderMaterial[] = [];
// 绘制每个市的边界
const createLine = (data: any, depth: number) => {
  const points: any[] = [];
  // baseMaterialArray = [];
  data.forEach((item: any) => {
    const [x, y] = offsetXY(item) as number[];
    points.push(new THREE.Vector3(x, -y, 0));
  });
  // 默认的白色线省份边界
  const lineGeometry = new THREE.BufferGeometry().setFromPoints(points);
  const upLineMaterial = new THREE.LineBasicMaterial({color: '#ffffff'});

  baseMaterialArray.push(upLineMaterial);

  const downLineMaterial = new THREE.LineBasicMaterial({color: '#ffffff'});

  const upLine = new THREE.Line(lineGeometry, upLineMaterial);
  const downLine = new THREE.Line(lineGeometry, downLineMaterial);
  downLine.position.z = -0.1;
  upLine.position.z = depth + 0.1;
  return [upLine, downLine];
};

// 绘制每个市的名称
const createLabel = (name: string, point: any, depth: number) => {
  const div = document.createElement('div');
  div.style.color = '#fff';
  div.style.fontSize = '14px';
  div.textContent = name;
  const label = new CSS2DObject(div);
  label.scale.set(0.01, 0.01, 0.01);
  const [x, y] = offsetXY(point) as number[];
  label.position.set(x, -y, depth);
  return label;
};

// 设置地图中心
const setCenter = (map: THREE.Object3D) => {
  map.rotation.x = -Math.PI / 2;
  const box = new THREE.Box3().setFromObject(map);
  const center = box.getCenter(new THREE.Vector3());
  map.position.x = map.position.x - center.x;
  map.position.z = map.position.z - center.z;
};

// 初始化泛光
let baseCompass: EffectComposer;
const initBloom = () => {
  const renderScene = new RenderPass(scene, camera);
  const bloomPass = new UnrealBloomPass(
      new THREE.Vector2(window.innerWidth, window.innerHeight),
      0.5,
      0.5,
      0
  );
  const composer = new EffectComposer(renderer);
  composer.addPass(renderScene);
  composer.addPass(bloomPass);
  const outputPass = new OutputPass();
  composer.addPass(outputPass);

  baseCompass = composer;
};


</script>


<!-- 组件 -->
<script lang="ts" setup>
import * as THREE from 'three';
import {OrbitControls} from 'three/examples/jsm/controls/OrbitControls';
import {GLTFLoader} from 'three/examples/jsm/loaders/GLTFLoader';

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 2000);
camera.position.set(10, 10, 10);
scene.add(camera);


const ambientLight = new THREE.AmbientLight(0xffffff, 1);
scene.add(ambientLight);

const light = new THREE.DirectionalLight(0xffffff, 3);
scene.add(light);

const renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight - 100);

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;

// xyz指示器
// const axesHelper = new THREE.AxesHelper(5);
// scene.add(axesHelper);


// 建筑颜色
const buildColor = new THREE.Color(0x22B7F2);
// 建筑线框颜色
const buildLineColor = new THREE.Color(0x2381CA);
// 非主要建筑颜色
const otherBuildColor = new THREE.Color(0x7C7C7D);
// 非主要建筑线框颜色
const otherBuildLineColor = new THREE.Color(0x656566);

// 渲染线条时，相邻面的法线之间的角度，达到这个角度就会渲染线条
const buildLineDeg = 0.001;
const buildLineOpacity = 1;
const buildOpacity = 0.85;

// 加载模型
const addGltf = () => {
  const gltfLoader = new GLTFLoader();

  gltfLoader.load('./src/assets/glb/shanghai_city.glb', gltf => {
    const group = gltf.scene;
    const scale = 10;
    group.scale.set(scale, scale, scale);

    // 删除多余模型
    const mesh1 = group.getObjectByName('Text_test-base_0');
    if (mesh1 && mesh1.parent) mesh1.parent.remove(mesh1);

    const mesh2 = group.getObjectByName('Text_text_0');
    if (mesh2 && mesh2.parent) mesh2.parent.remove(mesh2);

    // 重命名模型
    // 环球金融中心
    const hqjrzx = group.getObjectByName('02-huanqiujinrongzhongxin_huanqiujinrongzhongxin_0');
    if (hqjrzx) {
      hqjrzx.name = 'hqjrzx';
      changeModelMaterial(hqjrzx, otherBuildingMaterial(buildColor, buildOpacity), otherBuildingLineMaterial(buildLineColor, buildLineOpacity), buildLineDeg);
    }

    // 上海中心
    const shzx = group.getObjectByName('01-shanghaizhongxindasha_shanghaizhongxindasha_0');
    if (shzx) {
      shzx.name = 'shzx';
      changeModelMaterial(shzx, otherBuildingMaterial(buildColor, buildOpacity), otherBuildingLineMaterial(buildLineColor, buildLineOpacity), buildLineDeg);
    }
    // 金茂大厦
    const jmds = group.getObjectByName('03-jinmaodasha_jjinmaodasha_0');
    if (jmds) {
      jmds.name = 'jmds';
      changeModelMaterial(jmds, otherBuildingMaterial(buildColor, buildOpacity), otherBuildingLineMaterial(buildLineColor, buildLineOpacity), buildLineDeg);
    }
    // 东方明珠塔
    const dfmzt = group.getObjectByName('04-dongfangmingzhu_dongfangmingzhu_0');
    if (dfmzt) {
      dfmzt.name = 'dfmzt';
      changeModelMaterial(dfmzt, otherBuildingMaterial(buildColor, buildOpacity), otherBuildingLineMaterial(buildLineColor, buildLineOpacity), buildLineDeg);
    }

    toSceneCenter(group);
    scene.add(group);

    group.traverse((mesh) => {
      if (mesh.isMesh && (mesh.name.indexOf('Shanghai') !== -1 || mesh.name.indexOf('Object') !== -1)) {
        if (mesh.name.indexOf('Floor') !== -1) {
          mesh.material = new THREE.MeshLambertMaterial({
            color: 0x0f1418,
            wireframe: true
          });
        } else {
          changeModelMaterial(mesh, otherBuildingMaterial(otherBuildColor, 0.8), otherBuildingLineMaterial(otherBuildLineColor, 0.4), buildLineDeg);
        }
      }
    });
  });
};


// 获取包围盒
const getBoxInfo = (mesh) => {
  const box3 = new THREE.Box3();
  box3.expandByObject(mesh);
  const size = new THREE.Vector3();
  const center = new THREE.Vector3();
  // 获取包围盒的中心点和尺寸
  box3.getCenter(center);
  box3.getSize(size);
  return {
    size, center
  };
};

// 把模型的位置移动到中心点
const toSceneCenter = (mesh) => {
  const {center} = getBoxInfo(mesh);
  // 将Y轴置为0
  mesh.position.copy(center.negate().setY(0));
};


// 建筑材质
const otherBuildingMaterial = (color: string, opacity = 1) => {
  return new THREE.MeshLambertMaterial({
    color,
    transparent: true,
    opacity
  });
};
// 建筑线条材质
const otherBuildingLineMaterial = (color: string, opacity = 1) => {
  return new THREE.LineBasicMaterial(
      {
        color,
        depthTest: true,
        transparent: true,
        opacity
      }
  );
};
/**
 *
 * @param mesh
 * @param meshMaterial 模型材质
 * @param lineMaterial 线材质
 * @param deg
 */
const changeModelMaterial = (mesh, meshMaterial, lineMaterial, deg = 1) => {
  if (mesh.isMesh) {
    if (meshMaterial) mesh.material = meshMaterial;
    // 以模型顶点信息创建线条
    const line = getLine(mesh, deg, lineMaterial);
    line.name = mesh.name + '_line';
    mesh.add(line);
  }
};
// 通过模型创建线条
const getLine = (object, thresholdAngle = 1, lineMaterial) => {
  // 创建线条，参数为 几何体模型，相邻面的法线之间的角度，
  var edges = new THREE.EdgesGeometry(object.geometry, thresholdAngle);
  var line = new THREE.LineSegments(edges);
  if (lineMaterial) line.material = lineMaterial;
  return line;
};
// 创建场景背景
const createScene = () => {
  const width = window.innerWidth;
  const height = window.innerHeight;
  // scene.background = new THREE.Color('#f29040');
  // return;
  const drawingCanvas = document.createElement('canvas');
  const context = drawingCanvas.getContext('2d');

  if (context) {
    // 设置canvas的尺寸
    drawingCanvas.width = width;
    drawingCanvas.height = height;

    // 创建渐变
    const gradient = context.createRadialGradient(width / 2, height, 0, width / 2, height / 2, Math.max(width, height));

    // 为渐变添加颜色
    gradient.addColorStop(0, '#29b7cb');
    gradient.addColorStop(0.6, '#2775b6');

    // 使用渐变填充矩形
    context.fillStyle = gradient;
    context.fillRect(0, 0, drawingCanvas.width, drawingCanvas.height);
    scene.background = new THREE.CanvasTexture(drawingCanvas);
    scene.fog = new THREE.Fog(0x000000, 0, 200);
  }
};

// 渲染
const render = () => {
  renderer.render(scene, camera);
  requestAnimationFrame(render);
};

onMounted(() => {
  document.getElementById('home').appendChild(renderer.domElement);
  addGltf();
  createScene();
  render();
});
</script>

<template>
  <div id="home" class="w-full h-full"/>
</template>

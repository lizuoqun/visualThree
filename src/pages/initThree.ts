/**
 * @author: modify
 * @description 把初始化Three场景封装到一个公共类当中
 * */
import * as THREE from 'three';
import {CSS2DRenderer} from 'three/examples/jsm/renderers/CSS2DRenderer.js';
import {OrbitControls} from 'three/examples/jsm/controls/OrbitControls';
// 创建场景
const scene = new THREE.Scene();

// 创建相机
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 2000);
camera.position.y = 8;
camera.position.z = 8;

// 创建渲染器
const labelRenderer = new CSS2DRenderer();
const addRenderer = () => {
  labelRenderer.domElement.style.position = 'absolute';
  labelRenderer.domElement.style.top = '0px';
  labelRenderer.domElement.style.pointerEvents = 'none';
  labelRenderer.setSize(window.innerWidth, window.innerHeight);
};

// 窗口大小变化监听器
const renderer = new THREE.WebGLRenderer({alpha: true});
renderer.setSize(window.innerWidth, window.innerHeight);

// 控制器
const controls = new OrbitControls(camera, renderer.domElement);
controls.update();

// 添加坐标轴
const axesHelper = new THREE.AxesHelper(5);
scene.add(axesHelper);

class initThree {
  // 通过初始化对象创建场景
  constructor() {
    addRenderer();
  }

  // 调用这个属性将返回场景
  get allThreeObject() {
    return {
      scene,
      camera,
      renderer,
      controls,
      labelRenderer
    } as ThreeObjectInterface;
  }
}

export default initThree;

export interface ThreeObjectInterface {
  scene: THREE.Scene;
  camera: THREE.PerspectiveCamera;
  renderer: THREE.WebGLRenderer;
  controls: OrbitControls;
  labelRenderer: CSS2DRenderer;
}
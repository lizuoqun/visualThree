/**
 * @author: modify
 * @description 把初始化Three场景封装到一个公共类当中
 * */
import * as THREE from 'three';
import {CSS2DRenderer} from 'three/examples/jsm/renderers/CSS2DRenderer.js';
import {OrbitControls} from 'three/examples/jsm/controls/OrbitControls';
import {defaultCameraPosition} from './car/constent';

export interface ThreeObjectInterface {
  scene: THREE.Scene;
  camera: THREE.PerspectiveCamera;
  renderer: THREE.WebGLRenderer;
  controls: OrbitControls;
  labelRenderer: CSS2DRenderer;
}

class InitThree {
  // 添加了readonly声明一个属性为只读属性。这意味着一旦该属性被赋值后，就不能再被修改
  private readonly scene: THREE.Scene;
  private readonly camera: THREE.PerspectiveCamera;
  private readonly renderer: THREE.WebGLRenderer;
  private readonly controls: OrbitControls;
  private readonly labelRenderer: CSS2DRenderer;

  constructor(cameraPosition = defaultCameraPosition, showAxesHelper = true) {
    this.scene = new THREE.Scene();
    this.camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 2000);
    this.camera.position.set(cameraPosition.x, cameraPosition.y, cameraPosition.z);

    this.renderer = new THREE.WebGLRenderer({alpha: true});
    this.renderer.setSize(window.innerWidth, window.innerHeight);

    this.labelRenderer = new CSS2DRenderer();
    this.labelRenderer.domElement.style.position = 'absolute';
    this.labelRenderer.domElement.style.top = '0px';
    this.labelRenderer.domElement.style.pointerEvents = 'none';
    this.labelRenderer.setSize(window.innerWidth, window.innerHeight);

    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.controls.update();

    if (showAxesHelper) {
      const axesHelper = new THREE.AxesHelper(5);
      this.scene.add(axesHelper);
    }

    window.addEventListener('resize', this.onWindowResize.bind(this));
  }

  private onWindowResize() {
    this.camera.aspect = window.innerWidth / window.innerHeight;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.labelRenderer.setSize(window.innerWidth, window.innerHeight);
  }

  get allThreeObject(): ThreeObjectInterface {
    return {
      scene: this.scene,
      camera: this.camera,
      renderer: this.renderer,
      controls: this.controls,
      labelRenderer: this.labelRenderer
    };
  }
}

export default InitThree;

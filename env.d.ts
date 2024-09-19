declare module '*.vue' {
  import type {DefineComponent} from 'vue';
  const component: DefineComponent<{}, {}, any>;
  export default component;
}


declare module 'three'
declare module 'three/examples/jsm/objects/Water2';
declare module 'three/examples/jsm/controls/OrbitControls';
declare module 'three/examples/jsm/loaders/RGBELoader';
declare module 'three/examples/jsm/loaders/GLTFLoader';
<template>
  <div id="map" class="w-full h-full"/>
</template>

<script lang="ts" setup>
import * as THREE from 'three';
import {OrbitControls} from 'three/examples/jsm/controls/OrbitControls.js';
import {CSS2DObject, CSS2DRenderer} from 'three/examples/jsm/renderers/CSS2DRenderer.js';
import * as d3 from 'd3';
import ChinaData from '@/assets/mapJson/china.json';
import CityImage from '@/assets/image/city.png';
import mapTextureImage from '@/assets/image/map-texture.png';
// import mapTextureImage from '@/assets/image/wall.png';

const HU_NAN = '湖南省';
const GUANG_XI = '广西壮族自治区';

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
  baseMaterialArray.forEach((item) => {
    animateAction(item);
  });
  // animateAction(baseMaterial);
  controls.update();
  renderer.render(scene, camera);
  labelRenderer.render(scene, camera);
  requestAnimationFrame(animate);
};

onMounted(() => {
  addRenderer();
  animate();
  document.getElementById('map')?.appendChild(renderer.domElement);
  mapTextureLight();
  createMap(ChinaData);
  createFlyLine();

  setTimeout(() => {
    // 因为这里是全国地图，是遍历得到的，看最终拿到的baseMaterial的自定义name属性是哪个？
    console.log('baseMaterial =====', baseMaterial);
  }, 3000);
});

// 矫正坐标
const offsetXY = d3.geoMercator();

// 随机颜色
const getRandomColor = () => {
  return '#' + Math.floor(Math.random() * 16777215).toString(16);
};

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
    const icon = name ? createIcon(centroid || center || [0, 0], 1.11) : null;
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
    icon ? unit.add(icon) : null;
  });
  setCenter(map);
  scene.add(map);

  window.addEventListener('click', (event) => {
    const mouse = new THREE.Vector2();
    mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
    mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;
    const raster = new THREE.Raycaster();
    raster.setFromCamera(mouse, camera);
    const intersects = raster
        .intersectObjects(map.children)
        .filter((item) => item.object.type !== 'Line');
    if (intersects.length > 0) {
      // 点击市
      if (intersects[0].object.type === 'Mesh') {
        console.log(intersects[0]);
      }
      // 点击icon
      if (intersects[0].object.type === 'Sprite') {
        console.log(intersects[0]);
      }
    }
  });
};

const mapTexture = new THREE.TextureLoader().load(mapTextureImage);
mapTexture.wrapS = THREE.RepeatWrapping;
mapTexture.wrapT = THREE.RepeatWrapping;
mapTexture.repeat.set(1, 1);
mapTexture.needsUpdate = true;

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
    bumpScale: 0.1,
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
  const mesh = new THREE.Mesh(geometry, material);

  let shaderMesh: THREE.Mesh | null = null;
  if ([HU_NAN, GUANG_XI].includes(name)) {
    const material = new THREE.ShaderMaterial({
      side: THREE.DoubleSide,
      transparent: true,
      depthTest: false,
      uniforms: {
        color1: {value: new THREE.Color('#00FFFF')}
      },
      vertexShader: `
          varying vec2 vUv;
          varying vec3 vNormal;

          void main() {
            vUv=uv;
            vNormal=normal;

            gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
          }`,
      fragmentShader: `uniform vec3 color1;
                      varying vec2 vUv;
                      varying vec3 vNormal;
                void main() {
                  if(vNormal.z==1.0||vNormal.z==-1.0||vUv.y ==0.0){
                    discard;
                  } else{
                    gl_FragColor =vec4(color1,mix(1.0,0.0, vUv.y)) ;
                  }
                }`
    });

    const extrudeSettings = {
      depth: 1,
      bevelEnabled: false
    };

    const geometry = new THREE.ExtrudeGeometry(shape, extrudeSettings);

    shaderMesh = new THREE.Mesh(geometry, material);
    shaderMesh.position.z = 1;
  }

  return [mesh, shaderMesh];
};

let baseMaterial: THREE.ShaderMaterial | null = null;
let baseMaterialArray: THREE.ShaderMaterial[] = [];
// 绘制每个市的边界
const createLine = (data: any, depth: number) => {
  const points: any[] = [];
  // baseMaterialArray = [];
  data.forEach((item: any) => {
    const [x, y] = offsetXY(item) as number[];
    points.push(new THREE.Vector3(x, -y, 0));
  });
  // 默认的白色线省份边界
  // const lineGeometry = new THREE.BufferGeometry().setFromPoints(points);
  // const upLineMaterial = new THREE.LineBasicMaterial({color: '#ffffff'});

  const curve = new THREE.CatmullRomCurve3(points, true, 'catmullrom', 0);
  const lineGeometry = new THREE.TubeGeometry(
      curve,
      Math.round(points.length * 0.5),
      0.001,
      8,
      true
  );
  const upLineMaterial = new THREE.ShaderMaterial({
    name: data[0],
    uniforms: {
      time: {value: 0},//运动时间
      len: {value: 0.05},//运动点距离范围
      size: {value: 0.2},//管道增加宽度
      color1: {value: new THREE.Color('#FFFFFF')},
      color2: {value: new THREE.Color('yellow')}
    },
    vertexShader: `uniform float time;
uniform float size;
uniform float len;
uniform vec3 color1;
uniform vec3 color2;
varying vec3 vColor;
void main() {
    vColor = color1;
    vec3 newPosition = position;
    float d = uv.x - time;

    if(abs(d) < len) {
        newPosition = newPosition + normal * size;
        vColor = color2;
    }
    gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);
}`,
    fragmentShader: `
varying vec3 vColor;
void main() {
  gl_FragColor =vec4(vColor, 1.0);
}`
  });

  // 把这个经纬度数据加上边界运动效果
  if (data[0][0] === 110.379257) {
    baseMaterial = upLineMaterial;
  }

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

// 创建图标
const createIcon = (point: any, depth: number) => {
  const texture = new THREE.TextureLoader().load(CityImage);
  const material = new THREE.SpriteMaterial({
    map: texture,
    transparent: true
  });
  const sprite = new THREE.Sprite(material);
  const [x, y] = offsetXY(point) as number[];
  sprite.position.set(x, -y, depth + 0.5);
  sprite.renderOrder = 1;
  return sprite;
};

// 创建线
const createFlyLine = () => {
  // const points = [];
  // for (let i = 0; i < 20; i++) {
  //   points.push(new THREE.Vector3(Math.random() * 10 - 5, 1.1, Math.random() * 10 - 5));
  // }

  const curve = new THREE.SplineCurve([
    new THREE.Vector2(-10, 0),
    new THREE.Vector2(-5, 5),
    new THREE.Vector2(0, 0),
    new THREE.Vector2(5, -5),
    new THREE.Vector2(10, 0)
  ]);

  const points = curve.getPoints(50);

  const geometry = new THREE.BufferGeometry().setFromPoints(points);
  const lineMaterial = new THREE.LineBasicMaterial({color: '#fff'});
  const line = new THREE.Line(geometry, lineMaterial);
  scene.add(line);
};

// 设置地图中心
const setCenter = (map: THREE.Object3D) => {
  map.rotation.x = -Math.PI / 2;
  const box = new THREE.Box3().setFromObject(map);
  const center = box.getCenter(new THREE.Vector3());
  map.position.x = map.position.x - center.x;
  map.position.z = map.position.z - center.z;
};

// 改变着色器的时间来控制省边界移动
let time = 1;
const animateAction = (material: any) => {
  if (material) {
    if (time >= 1.0) {
      time = 0.0;
    }
    time = time + 0.000005;
    material.uniforms.time.value = time;
  }
};
</script>


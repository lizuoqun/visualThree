import {createRouter, createWebHashHistory} from 'vue-router';

export const routes = [
  {path: '/', name: '首页', component: () => import('@/pages/index.vue')},
  {path: '/chinaMap', name: '3D地图', component: () => import('@/pages/map/chinaMap.vue')},
  {path: '/city', name: '3D城市', component: () => import('@/pages/map/city.vue')},
  {path: '/city2', name: '3D城市-2', component: () => import('@/pages/map/city2.vue')},
  {path: '/su7', name: 'SU7', component: () => import('@/pages/car/su7.vue')}
];

const router = createRouter({
  history: createWebHashHistory(),
  routes
});

export default router;
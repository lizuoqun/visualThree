import {createMemoryHistory, createRouter} from 'vue-router';

const routes = [
  {
    path: '/', name: 'Index', component: () => import('@/pages/index.vue')
  }
];

const router = createRouter({
  history: createMemoryHistory(),
  routes
});

export default router;
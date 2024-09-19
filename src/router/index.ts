import {createMemoryHistory, createRouter} from 'vue-router';

const routes = [
  {
    path: '/', component: () => {
      () => import('@/pages/vue3/father.vue')
    }
  }
];

const router = createRouter({
  history: createMemoryHistory(),
  routes
});

export default router;
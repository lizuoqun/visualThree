import {defineConfig} from 'vite';
import vue from '@vitejs/plugin-vue';

const path = require('path');
export default defineConfig(() => {
  return {
    base: '/visualThree/',
    plugins: [vue()],
    server: {
      host: '0.0.0.0',
      port: 5174
    },
    resolve: {
      alias: {
        //别名配置
        '~': path.resolve(__dirname, './'),
        '@': path.resolve(__dirname, './src')
      }
    }
  };
});
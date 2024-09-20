import {defineConfig} from 'vite';
import vue from '@vitejs/plugin-vue';
import AutoImport from 'unplugin-auto-import/vite';

const path = require('path');
export default defineConfig(() => {
  return {
    base: '/visualThree/',
    plugins: [vue(), AutoImport({
      imports: ['vue', 'vue-router'], // 路径下自动生成文件夹存放全局指令
      dts: 'src/auto-import.d.ts'
    })],
    server: {
      host: '0.0.0.0', port: 5174
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
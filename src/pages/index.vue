<template>
  <el-space class="w-full p-2" size="100" wrap>
    <el-card v-for="item in routes" :key="item.path" class="box-card h-[300px] w-[300px]" shadow="hover">
      <template #header>
        <div class="card-header">
          <div class="text-lg font-bold">{{ item.name }}</div>
        </div>
      </template>
      <div class="text-sm mb-2.5">
        访问地址：
        <el-link :href="'#'+item.path" target="_blank" type="primary"> {{ '#' + item.path }}</el-link>
      </div>
    </el-card>
  </el-space>
</template>

<script setup>
import {routes} from '@/router';
</script>

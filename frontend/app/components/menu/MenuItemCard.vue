<template>
  <button
    @click="$emit('add', item)"
    class="flex gap-3 w-full text-left bg-white dark:bg-neutral-900 rounded-2xl p-3 border border-neutral-200/50 dark:border-neutral-800/50 hover:border-primary-300 dark:hover:border-primary-700 hover:shadow-lg hover:shadow-primary-500/5 transition-all active:scale-[0.98] group relative overflow-hidden"
  >
    <div class="absolute inset-0 bg-gradient-to-r from-transparent via-primary-50/0 to-transparent group-hover:via-primary-50/30 dark:group-hover:via-primary-900/10 transition-all duration-700 pointer-events-none" />

    <!-- Image -->
    <div class="w-24 h-24 rounded-xl overflow-hidden bg-neutral-100 dark:bg-neutral-800 flex-shrink-0 relative">
      <img
        v-if="item.imageUrl"
        :src="item.imageUrl"
        :alt="item.name"
        class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
        loading="lazy"
      />
      <div v-else class="w-full h-full flex items-center justify-center text-2xl text-neutral-300 dark:text-neutral-600">
        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
      </div>
    </div>

    <!-- Info -->
    <div class="flex-1 min-w-0 py-0.5 flex flex-col justify-between relative z-10">
      <div>
        <h3 class="font-semibold text-neutral-900 dark:text-white text-sm leading-tight line-clamp-2">
          {{ trans(item, 'name') }}
        </h3>
        <p v-if="item.categoryName" class="text-xs text-neutral-400 dark:text-neutral-500 mt-0.5">
          {{ trans(item, 'categoryName') }}
        </p>
        <p v-if="item.variants && item.variants.length > 0" class="text-xs text-neutral-500 dark:text-neutral-400 mt-1">
          {{ item.variants.map((v: any) => v.size).join(' · ') }}
        </p>
      </div>
      <div class="flex items-center justify-between mt-auto">
        <span class="text-sm font-bold text-primary-600 dark:text-primary-400">
          <template v-if="item.variants && item.variants.length > 0">
            from ${{ Math.min(...item.variants.map((v: any) => v.price)).toFixed(2) }}
          </template>
          <template v-else>
            ${{ item.basePrice.toFixed(2) }}
          </template>
        </span>

        <!-- Add button with cart badge -->
        <div class="relative">
          <span
            class="flex items-center justify-center w-9 h-9 rounded-full transition-all duration-300"
            :class="cartQty > 0
              ? 'bg-primary-600 text-white shadow-md shadow-primary-500/30'
              : 'bg-primary-50 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400 group-hover:bg-primary-600 group-hover:text-white group-hover:shadow-md group-hover:shadow-primary-500/30'"
          >
            <svg v-if="cartQty > 0" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 100 4 2 2 0 000-4z"/></svg>
            <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
          </span>
          <span
            v-if="cartQty > 0"
            class="absolute -top-1.5 -right-1.5 bg-error-500 text-white text-[10px] font-bold w-5 h-5 rounded-full flex items-center justify-center shadow-lg shadow-error-500/40 animate-scale-in"
          >
            {{ cartQty }}
          </span>
        </div>
      </div>
    </div>
  </button>
</template>

<script setup lang="ts">
import { useTrans } from '~/composables/useTrans'
const { trans } = useTrans()

defineProps<{
  item: {
    menuItemId: number
    name: string
    nameKh?: string
    basePrice: number
    imageUrl?: string
    categoryName?: string
    categoryNameKh?: string
    variants?: { variantId: number; size: string; price: number }[]
  }
  cartQty?: number
}>()

defineEmits(['add'])
</script>

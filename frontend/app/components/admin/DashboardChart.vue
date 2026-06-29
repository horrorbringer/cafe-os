<template>
  <div class="relative w-full h-full min-h-[260px] flex flex-col">
    <div class="flex-1 relative flex pt-6 pb-8">
      <!-- Y-axis labels -->
      <div class="flex flex-col justify-between mr-3 text-[10px] font-medium text-neutral-400 dark:text-neutral-500 pointer-events-none">
        <span>{{ formatCurrency(maxRevenue) }}</span>
        <span>{{ formatCurrency(maxRevenue * 0.75) }}</span>
        <span>{{ formatCurrency(maxRevenue * 0.5) }}</span>
        <span>{{ formatCurrency(maxRevenue * 0.25) }}</span>
        <span>0</span>
      </div>

      <!-- Chart Area -->
      <div class="flex-1 relative">
        <!-- Grid Lines -->
        <div class="absolute inset-0 flex flex-col justify-between pointer-events-none">
          <div v-for="i in 4" :key="i" class="border-b border-neutral-100 dark:border-neutral-800 w-full h-0"></div>
        </div>

        <!-- Bars -->
        <div class="absolute inset-0 flex items-end justify-between gap-1.5 pb-0">
          <div
            v-for="(item, index) in data"
            :key="index"
            class="group relative flex-1 flex flex-col items-center justify-end h-full"
          >
            <!-- Tooltip -->
            <div class="absolute -top-9 left-1/2 -translate-x-1/2 bg-neutral-900 dark:bg-neutral-800 text-white text-[11px] px-2.5 py-1.5 rounded-lg opacity-0 group-hover:opacity-100 transition-all duration-200 whitespace-nowrap z-20 pointer-events-none shadow-lg translate-y-1 group-hover:translate-y-0">
              <div class="font-bold">{{ formatCurrency(item.revenue) }}</div>
              <div class="text-neutral-400 text-[10px]">{{ item.orderCount }} orders</div>
              <div class="absolute -bottom-1 left-1/2 -translate-x-1/2 w-2 h-2 bg-neutral-900 dark:bg-neutral-800 rotate-45"></div>
            </div>

            <!-- Bar -->
            <div
              class="relative w-full max-w-[44px] rounded-t-lg overflow-hidden cursor-pointer animate-bar-grow"
              :style="{
                height: `${(item.revenue / maxRevenue) * 100}%`,
                animationDelay: `${index * 80}ms`
              }"
            >
              <!-- Gradient fill -->
              <div
                class="absolute inset-0 bg-gradient-to-t from-primary-600 via-primary-500 to-primary-400 dark:from-primary-700 dark:via-primary-600 dark:to-primary-500 opacity-90 group-hover:opacity-100 transition-opacity"
              ></div>
              <!-- Shimmer overlay -->
              <div class="absolute inset-0 bg-gradient-to-t from-transparent via-white/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity"></div>
            </div>

            <!-- Label -->
            <span class="absolute -bottom-6 text-[10px] font-medium text-neutral-400 dark:text-neutral-500 truncate max-w-full text-center">
              {{ formatDate(item.date) }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface DailySales {
  date: string
  revenue: number
  orderCount: number
}

const props = defineProps<{
  data: DailySales[]
}>()

const maxRevenue = computed(() => {
  const max = Math.max(...props.data.map(d => d.revenue), 0)
  return max === 0 ? 100 : max * 1.25
})

const formatCurrency = (val: number) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(val)
}

const formatDate = (dateStr: string) => {
  try {
    const date = new Date(dateStr)
    const today = new Date()
    const yesterday = new Date(today)
    yesterday.setDate(yesterday.getDate() - 1)

    if (date.toDateString() === today.toDateString()) return 'Today'
    if (date.toDateString() === yesterday.toDateString()) return 'Yesterday'
    return date.toLocaleDateString('en-US', { weekday: 'short' })
  } catch {
    return dateStr
  }
}
</script>

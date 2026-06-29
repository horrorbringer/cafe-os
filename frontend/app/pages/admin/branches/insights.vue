<template>
  <NuxtLayout name="admin">
    <div class="space-y-6">
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbLink href="/admin/branches">Branches</BreadcrumbLink>
          </BreadcrumbItem>
          <BreadcrumbSeparator />
          <BreadcrumbItem>
            <BreadcrumbPage>Insights</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>

      <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 class="text-2xl font-bold text-neutral-900 dark:text-white tracking-tight">Branch Comparison</h2>
          <p class="text-neutral-500 text-sm">Performance analytics across all locations</p>
        </div>

        <Tabs v-model="selectedRange">
          <TabList>
            <TabTrigger v-for="r in ranges" :key="r.value" :value="r.value">{{ r.label }}</TabTrigger>
          </TabList>
        </Tabs>
      </div>

      <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <Card v-for="i in 3" :key="i">
          <CardContent class="p-6">
            <div class="h-48 bg-neutral-100 dark:bg-neutral-800 rounded-2xl animate-pulse"></div>
          </CardContent>
        </Card>
      </div>

      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <Card v-for="branch in comparison" :key="branch.branchId" class="overflow-hidden relative group">
          <CardContent class="p-6">
            <div class="flex justify-between items-start mb-6">
              <div class="w-12 h-12 rounded-2xl bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center">
                <Building2Icon class="w-6 h-6 text-primary-500" />
              </div>
              <span class="text-[10px] bg-neutral-100 dark:bg-neutral-800 text-neutral-500 px-2 py-0.5 rounded-full font-bold uppercase tracking-widest">ID: {{ branch.branchId }}</span>
            </div>

            <h3 class="text-xl font-black text-neutral-900 dark:text-white mb-1">{{ branch.branchName }}</h3>
            <p class="text-xs text-neutral-500 font-medium uppercase tracking-widest mb-6">Overall Performance</p>

            <div class="space-y-4">
              <div class="flex justify-between items-center bg-neutral-50 dark:bg-neutral-800/50 p-3 rounded-2xl">
                <div>
                  <span class="text-[10px] text-neutral-500 font-bold uppercase tracking-wider">Total Sales</span>
                  <span class="text-lg font-black text-neutral-900 dark:text-white block">${{ (branch.totalSales || 0).toLocaleString() }}</span>
                </div>
                <div class="w-10 h-10 rounded-full bg-success-500/10 flex items-center justify-center">
                  <DollarSignIcon class="w-5 h-5 text-success-500" />
                </div>
              </div>

              <div class="grid grid-cols-2 gap-3">
                <div class="bg-neutral-50 dark:bg-neutral-800/50 p-3 rounded-2xl">
                  <span class="text-[10px] text-neutral-500 font-bold uppercase tracking-wider block mb-1">Orders</span>
                  <span class="text-base font-black text-neutral-900 dark:text-white">{{ branch.orderCount }}</span>
                </div>
                <div class="bg-neutral-50 dark:bg-neutral-800/50 p-3 rounded-2xl">
                  <span class="text-[10px] text-neutral-500 font-bold uppercase tracking-wider block mb-1">ATV</span>
                  <span class="text-base font-black text-neutral-900 dark:text-white">${{ (branch.avgTransactionValue || 0).toFixed(2) }}</span>
                </div>
              </div>

              <div class="bg-neutral-50 dark:bg-neutral-800/50 p-3 rounded-2xl flex items-center justify-between group/item">
                <div>
                  <span class="text-[10px] text-neutral-500 font-bold uppercase tracking-wider block">Top Selling Item</span>
                  <span class="text-xs font-bold text-neutral-900 dark:text-white">{{ branch.topMenuItem }}</span>
                </div>
                <StarIcon class="w-5 h-5 text-warning-500 opacity-50 group-hover/item:scale-110 transition-all" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { Building2Icon, DollarSignIcon, StarIcon } from '@lucide/vue'

definePageMeta({
  layout: false
})

const { get } = useApi()

const ranges = [
  { label: 'Today', value: 'TODAY' },
  { label: 'Week', value: 'WEEK' },
  { label: 'Month', value: 'MONTH' },
]

const selectedRange = ref('TODAY')
const comparison = ref<any[]>([])
const loading = ref(true)

const fetchComparison = async () => {
  loading.value = true
  try {
    const data = await get<any[]>('/branches/insights/comparison', {
      range: selectedRange.value,
    })
    comparison.value = data || []
  } catch (e) {
    console.error('Failed to fetch branch comparison', e)
  } finally {
    loading.value = false
  }
}

watch(selectedRange, fetchComparison)

onMounted(fetchComparison)
</script>

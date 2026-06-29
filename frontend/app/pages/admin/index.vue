<template>
  <NuxtLayout name="admin">
    <div class="space-y-8 animate-in fade-in slide-in-from-bottom-6 duration-1000">
      <!-- Welcome Header -->
      <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <h2 class="text-[28px] font-black text-neutral-900 dark:text-white tracking-tight leading-none mb-2">
            {{ greeting }}, {{ authUser?.employeeName?.split(' ')[0] || 'Admin' }}
          </h2>
          <p class="text-neutral-500 dark:text-neutral-400 font-medium flex items-center gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            {{ currentDate }}
          </p>
        </div>
        <div class="hidden md:block">
          <Breadcrumb>
            <BreadcrumbList>
              <BreadcrumbItem>
                <BreadcrumbPage>Dashboard</BreadcrumbPage>
              </BreadcrumbItem>
            </BreadcrumbList>
          </Breadcrumb>
        </div>
      </div>

      <!-- Stats Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card
          v-for="(card, index) in stats"
          :key="card.label"
          :class="[
            'group transition-all duration-500 hover:scale-[1.02] hover:-translate-y-0.5',
            `stagger-${index + 1}`
          ]"
        >
          <CardContent class="p-6">
            <div class="flex items-start justify-between mb-4">
              <div :class="['w-12 h-12 rounded-2xl flex items-center justify-center shadow-lg transition-all duration-500 group-hover:scale-110 group-hover:rotate-3', card.iconBg, card.iconColor]">
                <component :is="card.icon" class="w-6 h-6" />
              </div>
              <div
                v-if="card.trend !== null"
                :class="['flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-bold tracking-tight', card.trend >= 0 ? 'bg-success-500/10 text-success-600 dark:text-success-400' : 'bg-error-500/10 text-error-600 dark:text-error-400']"
              >
                <svg v-if="card.trend >= 0" xmlns="http://www.w3.org/2000/svg" class="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="M12 19V5"/><path d="m5 12 7-7 7 7"/></svg>
                <svg v-else xmlns="http://www.w3.org/2000/svg" class="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="M12 5v14"/><path d="m19 12-7 7-7-7"/></svg>
                {{ Math.abs(card.trend) }}%
              </div>
              <div v-else class="w-12"></div>
            </div>
            <div class="space-y-1">
              <p class="text-neutral-500 dark:text-neutral-400 text-sm font-bold uppercase tracking-widest">{{ card.label }}</p>
              <div class="flex items-baseline gap-2">
                <h3 class="text-3xl font-black text-neutral-900 dark:text-white tracking-tighter leading-none">{{ card.value }}</h3>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <!-- Quick Actions -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
        <NuxtLink
          v-for="action in quickActions"
          :key="action.label"
          :to="action.to"
          class="flex items-center gap-3 rounded-lg px-3 py-2.5 hover:bg-muted/50 transition-colors"
        >
          <component :is="action.icon" class="w-4 h-4 shrink-0 text-muted-foreground" />
          <div>
            <p class="text-sm font-medium leading-tight">{{ action.label }}</p>
            <p class="text-[11px] text-muted-foreground leading-tight">{{ action.desc }}</p>
          </div>
        </NuxtLink>
      </div>

      <!-- Charts & Content Row -->
      <div class="grid lg:grid-cols-3 gap-6">
        <!-- Sales Overview -->
        <Card class="lg:col-span-2 relative overflow-hidden group">
          <CardContent class="p-6 sm:p-8">
            <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between mb-6 relative z-10 gap-4">
              <div>
                <h3 class="text-[20px] font-black text-neutral-900 dark:text-white tracking-tight">Sales Overview</h3>
                <p class="text-sm text-neutral-500 dark:text-neutral-400 font-medium">Daily revenue track record</p>
              </div>
              <div class="flex items-center gap-1 p-1 bg-black/5 dark:bg-white/5 rounded-xl">
                <button
                  v-for="period in periods"
                  :key="period"
                  @click="activePeriod = period"
                  :class="[
                    'px-3.5 py-1.5 text-xs font-bold rounded-lg transition-all duration-200',
                    activePeriod === period
                      ? 'bg-white dark:bg-neutral-800 shadow-sm text-neutral-900 dark:text-white'
                      : 'text-neutral-500 hover:text-neutral-900 dark:hover:text-white'
                  ]"
                >
                  {{ period }}
                </button>
              </div>
            </div>

            <div class="relative z-10">
              <div v-if="loading" class="h-[260px] skeleton-shimmer rounded-xl"></div>
              <div v-else-if="dailySales.length === 0" class="h-[260px] flex flex-col items-center justify-center text-neutral-400">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-12 h-12 mb-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 3v18h18"/><path d="m19 9-5 5-4-4-3 3"/></svg>
                <p class="text-sm font-medium">No sales data available yet</p>
              </div>
              <div v-else class="h-[260px]">
                <AdminDashboardChart :data="dailySales" />
              </div>
            </div>
          </CardContent>
          <div class="absolute -top-20 -left-20 w-64 h-64 bg-primary-500/5 rounded-full blur-[80px] group-hover:bg-primary-500/10 transition-colors pointer-events-none"></div>
        </Card>

        <!-- Sidebar Widgets -->
        <div class="space-y-6">
          <!-- Top Products Widget -->
          <Card>
            <CardContent class="p-6">
              <div class="flex items-center justify-between mb-5">
                <h3 class="text-[17px] font-bold text-neutral-900 dark:text-white tracking-tight">Hottest Items</h3>
                <div v-if="!loading && topProducts.length > 0" class="flex items-center gap-1 text-success-600 text-[11px] font-bold">
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="M12 19V5"/><path d="m5 12 7-7 7 7"/></svg>
                  Top sellers
                </div>
              </div>

              <div class="space-y-4">
                <template v-if="loading">
                  <div v-for="i in 4" :key="i" class="flex items-center gap-4">
                    <div class="w-12 h-12 rounded-2xl skeleton-shimmer"></div>
                    <div class="flex-1 space-y-2">
                      <div class="h-4 w-3/4 skeleton-shimmer rounded-full"></div>
                      <div class="h-3 w-1/2 skeleton-shimmer rounded-full"></div>
                    </div>
                  </div>
                </template>
                <template v-else-if="topProducts.length === 0">
                  <div class="text-center py-6">
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-10 h-10 mx-auto mb-2 text-neutral-300 dark:text-neutral-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                    <p class="text-sm text-neutral-400 font-medium">No sales yet today</p>
                  </div>
                </template>
                <template v-else>
                  <div
                    v-for="(product, index) in topProducts.slice(0, 4)"
                    :key="product.name"
                    class="flex items-center gap-4 group cursor-default"
                  >
                    <div class="relative">
                      <div class="w-12 h-12 rounded-2xl bg-[#F2F2F7] dark:bg-white/5 flex items-center justify-center font-black text-neutral-900 dark:text-white transition-all group-hover:scale-110 group-hover:rotate-3 shadow-sm border border-black/5 dark:border-white/5">
                        {{ product.initial }}
                      </div>
                      <div :class="[
                        'absolute -top-1.5 -right-1.5 w-5 h-5 rounded-full shadow-sm border border-black/5 dark:border-white/5 flex items-center justify-center text-[10px] font-black',
                        index === 0 ? 'bg-amber-400 text-white' :
                        index === 1 ? 'bg-neutral-300 text-white' :
                        index === 2 ? 'bg-amber-700 text-white' :
                        'bg-white dark:bg-neutral-800 text-neutral-500'
                      ]">
                        {{ index + 1 }}
                      </div>
                    </div>
                    <div class="flex-1 min-w-0">
                      <h5 class="text-sm font-bold text-neutral-900 dark:text-white truncate">{{ product.name }}</h5>
                      <p class="text-[11px] font-bold text-neutral-400 dark:text-neutral-500 uppercase tracking-wider">{{ product.category }} • {{ product.sold }} sold</p>
                    </div>
                    <div class="text-right">
                      <p class="text-sm font-black text-neutral-900 dark:text-white">${{ product.revenue }}</p>
                    </div>
                  </div>
                </template>
              </div>
            </CardContent>
          </Card>

          <!-- Inventory Health -->
          <Card class="border-l-4 border-l-primary-500 overflow-hidden relative">
            <CardContent class="p-6">
              <h3 class="text-[17px] font-bold text-neutral-900 dark:text-white tracking-tight mb-4">Inventory Health</h3>

              <div v-if="loading" class="space-y-3">
                <div class="h-12 w-full skeleton-shimmer rounded-xl"></div>
                <div class="h-4 w-3/4 skeleton-shimmer rounded-full"></div>
              </div>
              <div v-else-if="lowStockIngredients.length > 0" class="space-y-3">
                <div class="flex items-center gap-3 p-3 bg-warning-500/5 rounded-xl border border-warning-500/10">
                  <div class="w-9 h-9 rounded-lg bg-warning-500 text-white flex items-center justify-center flex-shrink-0">
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                  </div>
                  <div class="flex-1">
                    <p class="text-xs font-black text-warning-600 dark:text-warning-400 uppercase tracking-widest leading-none mb-0.5">Low Stock Alert</p>
                    <p class="text-sm font-bold text-neutral-900 dark:text-white leading-none">{{ lowStockIngredients.length }} ingredient{{ lowStockIngredients.length > 1 ? 's' : '' }} need restocking</p>
                  </div>
                </div>
                <div class="space-y-2 max-h-40 overflow-y-auto custom-scrollbar pr-1">
                  <div
                    v-for="item in lowStockIngredients.slice(0, 5)"
                    :key="item.ingredientId || item.name"
                    class="flex items-center justify-between py-2 px-3 rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-800/30 transition-colors"
                  >
                    <div class="flex-1 min-w-0">
                      <span class="text-xs font-bold text-neutral-700 dark:text-neutral-300 truncate block">{{ item.name }}</span>
                      <div class="mt-1.5 w-full h-1.5 bg-neutral-200 dark:bg-neutral-700 rounded-full overflow-hidden">
                        <div
                          class="h-full rounded-full bg-error-500"
                          :style="{ width: `${Math.min((item.currentStock / item.minStock) * 100, 50)}%` }"
                        ></div>
                      </div>
                    </div>
                    <span class="ml-3 text-[10px] font-bold text-error-500 bg-error-50 dark:bg-error-900/20 px-2 py-0.5 rounded-full whitespace-nowrap">{{ item.currentStock?.toFixed(1) || 0 }} / {{ item.minStock || 0 }}{{ item.unit ? ' ' + item.unit : '' }}</span>
                  </div>
                </div>
                <NuxtLink to="/admin/inventory" class="block w-full text-center py-2.5 text-xs font-black text-primary-600 dark:text-primary-400 hover:underline uppercase tracking-widest rounded-xl hover:bg-primary-500/5 transition-colors">Manage Stock →</NuxtLink>
              </div>
              <div v-else class="text-center py-6">
                <div class="w-14 h-14 mx-auto mb-3 rounded-2xl bg-success-500/10 flex items-center justify-center text-success-600">
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-7 h-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20 6 9 17l-5-5"/></svg>
                </div>
                <p class="text-sm font-bold text-neutral-900 dark:text-white">All levels optimal</p>
                <p class="text-xs text-neutral-400 mt-1">No ingredients need restocking</p>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>

      <!-- Recent Orders & Payment Breakdown -->
      <div class="grid lg:grid-cols-3 gap-6">
        <!-- Recent Orders -->
        <Card class="lg:col-span-2 overflow-hidden">
          <div class="p-6 border-b border-neutral-200 dark:border-neutral-800">
            <div class="flex items-center justify-between">
              <div>
                <h3 class="text-[17px] font-bold text-neutral-900 dark:text-white tracking-tight">Recent Orders</h3>
                <p class="text-xs text-neutral-500 font-medium mt-0.5">Latest transactions across all channels</p>
              </div>
              <NuxtLink to="/admin/orders" class="text-sm font-bold text-primary-600 dark:text-primary-400 hover:text-primary-700 flex items-center gap-1">
                View all
                <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="m9 18 6-6-6-6"/></svg>
              </NuxtLink>
            </div>
          </div>
          <CardContent class="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Order</TableHead>
                  <TableHead>Customer</TableHead>
                  <TableHead>Items</TableHead>
                  <TableHead>Total</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead class="text-right">Time</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                <template v-if="loading">
                  <TableRow v-for="i in 5" :key="i">
                    <TableCell v-for="j in 6" :key="j">
                      <div class="h-4 skeleton-shimmer rounded-full w-3/4"></div>
                    </TableCell>
                  </TableRow>
                </template>
                <template v-else-if="recentOrders.length === 0">
                  <TableRow>
                    <TableCell colspan="6" class="text-center py-12">
                      <svg xmlns="http://www.w3.org/2000/svg" class="w-10 h-10 mx-auto mb-2 text-neutral-300 dark:text-neutral-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                      <p class="text-sm text-neutral-400 font-medium">No orders yet today</p>
                    </TableCell>
                  </TableRow>
                </template>
                <template v-else>
                  <TableRow v-for="order in recentOrders" :key="order.id">
                    <TableCell class="font-medium">
                      <span class="font-mono">{{ order.id }}</span>
                    </TableCell>
                    <TableCell>
                      <div class="flex items-center gap-3">
                        <div class="w-8 h-8 rounded-full bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center border border-primary-200 dark:border-primary-800 flex-shrink-0">
                          <span class="text-[10px] font-bold text-primary-600 dark:text-primary-400">{{ (order.customer?.charAt(0) || 'G').toUpperCase() }}</span>
                        </div>
                        <span class="text-sm font-semibold text-neutral-700 dark:text-neutral-300 truncate max-w-[120px]">{{ order.customer }}</span>
                      </div>
                    </TableCell>
                    <TableCell>{{ order.items }}</TableCell>
                    <TableCell class="font-mono font-medium">${{ order.total }}</TableCell>
                    <TableCell>
                      <span :class="[
                        'inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider',
                        order.status === 'Completed' ? 'bg-success-500/10 text-success-600 dark:text-success-400' :
                        order.status === 'Pending' ? 'bg-warning-500/10 text-warning-600 dark:text-warning-400' :
                        order.status === 'Preparing' ? 'bg-primary-500/10 text-primary-600 dark:text-primary-400' :
                        'bg-neutral-100 dark:bg-neutral-800 text-neutral-500 dark:text-neutral-400'
                      ]">
                        <span :class="[
                          'w-1.5 h-1.5 rounded-full',
                          order.status === 'Completed' ? 'bg-success-500' :
                          order.status === 'Pending' ? 'bg-warning-500' :
                          order.status === 'Preparing' ? 'bg-primary-500' :
                          'bg-neutral-400'
                        ]"></span>
                        {{ order.status }}
                      </span>
                    </TableCell>
                    <TableCell class="text-right text-muted-foreground">{{ formatDate(order.time) }}</TableCell>
                  </TableRow>
                </template>
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        <!-- Payment Breakdown -->
        <Card>
          <CardContent class="p-6">
            <h3 class="text-[17px] font-bold text-neutral-900 dark:text-white tracking-tight mb-5">Payment Methods</h3>
            <div v-if="loading" class="space-y-3">
              <div v-for="i in 3" :key="i" class="h-12 skeleton-shimmer rounded-xl"></div>
            </div>
            <div v-else-if="paymentBreakdown.length === 0" class="text-center py-6">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-10 h-10 mx-auto mb-2 text-neutral-300 dark:text-neutral-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
              <p class="text-sm text-neutral-400 font-medium">No payment data</p>
            </div>
            <div v-else class="space-y-4">
              <div class="flex items-center justify-center py-4">
                <div class="relative w-28 h-28">
                  <svg class="w-full h-full -rotate-90" viewBox="0 0 36 36">
                    <circle cx="18" cy="18" r="15.5" fill="none" stroke="currentColor" stroke-width="3" class="text-neutral-100 dark:text-neutral-800"/>
                    <template v-for="(method, index) in paymentBreakdown" :key="method.method">
                      <circle
                        cx="18" cy="18" r="15.5"
                        fill="none"
                        :stroke="paymentColors[index % paymentColors.length]"
                        stroke-width="3"
                        stroke-dasharray="97.4"
                        :stroke-dashoffset="paymentOffset(method.percentage || ((method.amount / paymentTotal) * 100), index)"
                        class="transition-all duration-1000"
                      />
                    </template>
                  </svg>
                  <div class="absolute inset-0 flex items-center justify-center">
                    <span class="text-2xl font-black text-neutral-900 dark:text-white">${{ paymentTotal }}</span>
                  </div>
                </div>
              </div>
              <div class="space-y-2.5">
                <div
                  v-for="(method, index) in paymentBreakdown"
                  :key="method.method"
                  class="flex items-center justify-between py-2 px-3 rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-800/30 transition-colors"
                >
                  <div class="flex items-center gap-2.5">
                    <div class="w-3 h-3 rounded-full" :style="{ backgroundColor: paymentColors[index % paymentColors.length] }"></div>
                    <span class="text-sm font-bold text-neutral-700 dark:text-neutral-300">{{ method.method }}</span>
                  </div>
                  <div class="text-right">
                    <span class="text-sm font-black text-neutral-900 dark:text-white">${{ (method.amount || 0).toFixed(2) }}</span>
                    <span class="text-xs text-neutral-400 ml-2">({{ method.percentage || ((method.amount / (paymentTotal || 1)) * 100).toFixed(0) }}%)</span>
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
import { h, ref, onMounted, computed } from 'vue'
const { get } = useApi()
const { user: authUser } = useAuth()

definePageMeta({
  layout: false
})

const greeting = computed(() => {
  const hour = new Date().getHours()
  if (hour < 12) return 'Good Morning'
  if (hour < 17) return 'Good Afternoon'
  return 'Good Evening'
})

const currentDate = computed(() => {
  return new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
})

const periods = ['Today', 'Weekly', 'Monthly']
const activePeriod = ref('Today')

interface DashboardStats {
    todayRevenue: number
    todayOrderCount: number
    averageOrderValue: number
    todayCustomerCount: number
    paymentBreakdown: { method: string, amount: number, count: number, percentage?: number }[]
    topSellingItems: { menuItemId: number, name: string, quantitySold: number, revenue: number, categoryName?: string }[]
    recentOrders: { orderId: number, orderNo: string, total: number, status: string, customerName: string, createdAt: string, itemCount?: number }[]
    dailySales: { date: string, revenue: number, orderCount: number }[]
}

interface StatCard {
    label: string
    value: string
    trend: number | null
    icon: any
    iconBg: string
    iconColor: string
}

const loading = ref(true)
const recentOrders = ref<any[]>([])
const stats = ref<StatCard[]>([
  { label: "Today's Revenue", value: '$0.00', trend: null, icon: 'DollarIcon', iconBg: 'bg-success-100 dark:bg-success-900/30', iconColor: 'text-success-600 dark:text-success-400' },
  { label: 'Orders Today', value: '0', trend: null, icon: 'OrderIcon', iconBg: 'bg-primary-100 dark:bg-primary-900/30', iconColor: 'text-primary-600 dark:text-primary-400' },
  { label: 'Avg Order', value: '$0.00', trend: null, icon: 'CustomerIcon', iconBg: 'bg-warning-100 dark:bg-warning-900/30', iconColor: 'text-warning-600 dark:text-warning-400' },
  { label: 'Customers', value: '0', trend: null, icon: 'ProductIcon', iconBg: 'bg-accent-100 dark:bg-accent-900/30', iconColor: 'text-accent-600 dark:text-accent-400' }
])

const topProducts = ref<any[]>([])
const paymentBreakdown = ref<any[]>([])
const lowStockIngredients = ref<any[]>([])
const dailySales = ref<any[]>([])

const paymentTotal = computed(() => {
  return paymentBreakdown.value.reduce((sum, m) => sum + (m.amount || 0), 0)
})

const paymentColors = ['#10b981', '#d4805e', '#f59e0b', '#6366f1', '#ec4899']

const paymentOffset = (percentage: number, index: number) => {
  let offset = 0
  for (let i = 0; i < index; i++) {
    offset += (paymentBreakdown.value[i]?.percentage || ((paymentBreakdown.value[i]?.amount || 0) / (paymentTotal.value || 1)) * 100)
  }
  return 97.4 - (offset / 100) * 97.4
}

const fetchLowStock = async () => {
    try {
        const data = await get<any[]>('/ingredients/low-stock')
        lowStockIngredients.value = data || []
    } catch(err) {
        console.error("Low stock fetch error", err)
    }
}

const DollarIcon = () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': '2', 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }, [ h('line', { x1: '12', x2: '12', y1: '2', y2: '22' }), h('path', { d: 'M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6' }) ])
const OrderIcon = () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': '2', 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }, [ h('path', { d: 'M16 3h5v5' }), h('path', { d: 'M8 3H3v5' }), h('path', { d: 'M12 22v-8.3a4 4 0 0 0-1.172-2.872L3 3' }), h('path', { d: 'm15 9 6-6' }) ])
const CustomerIcon = () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': '2', 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }, [ h('path', { d: 'M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2' }), h('circle', { cx: '9', cy: '7', r: '4' }), h('path', { d: 'M22 21v-2a4 4 0 0 0-3-3.87' }), h('path', { d: 'M16 3.13a4 4 0 0 1 0 7.75' }) ])
const ProductIcon = () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': '2', 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }, [ h('path', { d: 'M17 8h1a4 4 0 1 1 0 8h-1' }), h('path', { d: 'M3 8h14v9a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4Z' }) ])

const QrIcon = () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': '2.5', 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }, [
  h('rect', { x: '3', y: '3', width: '5', height: '5', rx: '1.5' }),
  h('rect', { x: '16', y: '3', width: '5', height: '5', rx: '1.5' }),
  h('rect', { x: '3', y: '16', width: '5', height: '5', rx: '1.5' }),
  h('path', { d: 'M21 16h-3a2 2 0 0 0-2 2v3' }),
  h('path', { d: 'M21 21v.01' }),
  h('path', { d: 'M12 7v3a2 2 0 0 1-2 2H7' }),
  h('path', { d: 'M3 12h.01' }),
  h('path', { d: 'M12 3h.01' }),
  h('path', { d: 'M12 12h.01' }),
  h('path', { d: 'M12 21h.01' }),
  h('path', { d: 'M21 12h.01' }),
  h('path', { d: 'M7 21h.01' }),
])

const ChartIcon = () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': '2.5', 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }, [
  h('path', { d: 'M3 3v18h18' }),
  h('path', { d: 'm19 9-5 5-4-4-3 3' }),
])

const quickActions = [
  { label: 'Orders', desc: 'Manage transactions', to: '/admin/orders', icon: OrderIcon },
  { label: 'Menu', desc: 'Update products', to: '/admin/menu', icon: ProductIcon },
  { label: 'QR Codes', desc: 'Table menus', to: '/admin/qr-codes', icon: QrIcon },
  { label: 'Reports', desc: 'Store analytics', to: '/admin/reports', icon: ChartIcon },
]

const fetchDashboardData = async () => {
    loading.value = true
    try {
        const response = await get<{ success: boolean, data: DashboardStats }>('/reports/dashboard')
        const data = response?.data

        if (data) {
            stats.value = [
                { label: "Today's Revenue", value: '$' + (data.todayRevenue || 0).toFixed(2), trend: 12, icon: DollarIcon, iconBg: 'bg-success-100 dark:bg-success-900/30', iconColor: 'text-success-600 dark:text-success-400' },
                { label: 'Orders Today', value: (data.todayOrderCount || 0).toString(), trend: 8, icon: OrderIcon, iconBg: 'bg-primary-100 dark:bg-primary-900/30', iconColor: 'text-primary-600 dark:text-primary-400' },
                { label: 'Avg Order', value: '$' + (data.averageOrderValue || 0).toFixed(2), trend: -3, icon: CustomerIcon, iconBg: 'bg-warning-100 dark:bg-warning-900/30', iconColor: 'text-warning-600 dark:text-warning-400' },
                { label: 'Customers', value: (data.todayCustomerCount || 0).toString(), trend: 5, icon: ProductIcon, iconBg: 'bg-accent-100 dark:bg-accent-900/30', iconColor: 'text-accent-600 dark:text-accent-400' }
            ]

            topProducts.value = (data.topSellingItems || []).map(item => ({
                name: item.name,
                initial: item.name?.charAt(0).toUpperCase() || '?',
                sold: item.quantitySold,
                revenue: item.revenue?.toFixed(2) || '0.00',
                category: item.categoryName || 'General'
            }))

            paymentBreakdown.value = (data.paymentBreakdown || []).map(m => ({
              ...m,
              percentage: m.percentage || 0
            }))

            recentOrders.value = (data.recentOrders || []).map(o => ({
                id: o.orderNo || `#${o.orderId}`,
                customer: o.customerName || 'Guest',
                items: o.itemCount ? `${o.itemCount} items` : '-',
                total: (o.total || 0).toFixed(2),
                status: mapStatus(o.status),
                time: o.createdAt || ''
            }))

            dailySales.value = data.dailySales || []
        }
    } catch(err) {
        console.error("Dashboard fetch error", err)
    } finally {
        loading.value = false
    }
}

const mapStatus = (status: string) => {
  const map: Record<string, string> = {
    'PAID': 'Completed',
    'COMPLETED': 'Completed',
    'PENDING': 'Pending',
    'PREPARING': 'Preparing',
    'DELIVERED': 'Completed',
    'CANCELLED': 'Cancelled'
  }
  return map[status] || status
}

const formatDate = (dateStr: string) => {
    if (!dateStr) return '-'
    try {
        const date = new Date(dateStr)
        const now = new Date()
        const diff = now.getTime() - date.getTime()
        const mins = Math.floor(diff / 60000)
        if (mins < 1) return 'Just now'
        if (mins < 60) return `${mins}m ago`
        const hours = Math.floor(mins / 60)
        if (hours < 24) return `${hours}h ago`
        return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    } catch {
        return dateStr
    }
}

onMounted(() => {
    fetchDashboardData()
    fetchLowStock()
})
</script>

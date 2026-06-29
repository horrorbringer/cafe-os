<template>
  <NuxtLayout name="admin">
    <div class="space-y-6">
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbLink href="/admin/reports">Reports</BreadcrumbLink>
          </BreadcrumbItem>
          <BreadcrumbSeparator />
          <BreadcrumbItem>
            <BreadcrumbPage>Loyalty Program</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>

      <div class="flex items-center justify-between gap-4">
        <div>
          <h1 class="text-3xl font-black text-neutral-900 dark:text-white tracking-tight">
            Loyalty Program
          </h1>
          <p class="text-neutral-500 dark:text-neutral-400 mt-1">
            Points movement, customer tiers, and outstanding discount value.
          </p>
        </div>
        <Button
          @click="fetchReport"
          variant="default"
          class="py-3 px-5 text-xs font-bold uppercase tracking-widest"
          :disabled="loading"
        >
          {{ loading ? 'Refreshing...' : 'Refresh' }}
        </Button>
      </div>

      <div v-if="loading" class="grid md:grid-cols-4 gap-4">
        <div v-for="i in 8" :key="i" class="h-32 rounded-2xl bg-neutral-100 dark:bg-neutral-800 animate-pulse"></div>
      </div>

      <template v-else-if="report">
        <Card>
          <CardContent class="p-5">
          <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
            <div>
              <h2 class="text-sm font-black text-neutral-500 uppercase tracking-widest">
                Historical Ledger Backfill
              </h2>
              <p class="text-xs text-neutral-500 mt-1">
                Create missing ledger rows for older customer orders without changing customer balances.
              </p>
              <p v-if="backfillResult" class="text-xs text-neutral-600 dark:text-neutral-300 mt-3">
                Scanned {{ backfillResult.scannedOrders }} orders.
                Earn rows: {{ backfillResult.earnTransactionsCreated }}.
                Redeem rows: {{ backfillResult.redeemTransactionsCreated }}.
                {{ backfillResult.note }}
              </p>
            </div>
            <div class="flex gap-3">
              <button
                @click="runBackfill(false)"
                :disabled="backfillLoading"
                class="px-4 py-3 rounded-xl bg-neutral-100 dark:bg-neutral-800 text-neutral-700 dark:text-neutral-300 text-xs font-black uppercase tracking-widest hover:bg-neutral-200 dark:hover:bg-neutral-700 transition-colors"
              >
                Preview
              </button>
              <Button
                @click="runBackfill(true)"
                :disabled="backfillLoading || !backfillCanApply"
                variant="default"
                class="py-3 px-5 text-xs font-black uppercase tracking-widest"
              >
                {{ backfillLoading ? 'Working...' : 'Apply' }}
              </Button>
            </div>
          </div>
          </CardContent>
        </Card>

        <div class="grid md:grid-cols-4 gap-4">
          <Card>
            <CardContent class="p-5">
            <p class="text-[10px] font-black text-neutral-400 uppercase tracking-widest">Outstanding Points</p>
            <p class="text-3xl font-black text-neutral-900 dark:text-white mt-2">{{ report.outstandingPoints }}</p>
            <p class="text-xs text-neutral-500 mt-1">${{ money(report.outstandingValue) }} redeem value</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent class="p-5">
            <p class="text-[10px] font-black text-neutral-400 uppercase tracking-widest">Loyalty Customers</p>
            <p class="text-3xl font-black text-neutral-900 dark:text-white mt-2">{{ report.activeLoyaltyCustomers }}</p>
            <p class="text-xs text-neutral-500 mt-1">of {{ report.totalCustomers }} customers</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent class="p-5">
            <p class="text-[10px] font-black text-neutral-400 uppercase tracking-widest">Points Earned</p>
            <p class="text-3xl font-black text-success-600 mt-2">{{ report.pointsEarned }}</p>
            <p class="text-xs text-neutral-500 mt-1">{{ report.pointsReversed }} reversed</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent class="p-5">
            <p class="text-[10px] font-black text-neutral-400 uppercase tracking-widest">Points Redeemed</p>
            <p class="text-3xl font-black text-primary-600 mt-2">{{ report.pointsRedeemed }}</p>
            <p class="text-xs text-neutral-500 mt-1">${{ money(report.redeemedValue) }} discount used</p>
            </CardContent>
          </Card>
        </div>

        <div class="grid lg:grid-cols-2 gap-6">
          <Card>
            <CardContent class="p-6">
            <h2 class="text-sm font-black text-neutral-500 uppercase tracking-widest mb-5">
              Membership Mix
            </h2>
            <div class="space-y-4">
              <div v-for="tier in tierRows" :key="tier.label">
                <div class="flex items-center justify-between text-sm mb-2">
                  <span class="font-bold text-neutral-700 dark:text-neutral-300">{{ tier.label }}</span>
                  <span class="font-black text-neutral-900 dark:text-white">{{ tier.value }}</span>
                </div>
                <div class="h-2 bg-neutral-100 dark:bg-neutral-800 rounded-full overflow-hidden">
                  <div :class="['h-full rounded-full', tier.color]" :style="{ width: tier.percent + '%' }"></div>
                </div>
              </div>
            </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent class="p-6">
            <h2 class="text-sm font-black text-neutral-500 uppercase tracking-widest mb-5">
              Point Movement
            </h2>
            <div class="grid grid-cols-2 gap-4">
              <div
                v-for="movement in movementRows"
                :key="movement.label"
                class="rounded-2xl bg-neutral-50 dark:bg-neutral-800/50 p-4"
              >
                <p class="text-[10px] font-black text-neutral-400 uppercase tracking-widest">{{ movement.label }}</p>
                <p :class="['text-2xl font-black mt-2', movement.color]">{{ movement.value }}</p>
              </div>
            </div>
            </CardContent>
          </Card>
        </div>
      </template>

      <Card v-else>
        <CardContent class="p-10 text-center text-neutral-500">
          Loyalty report is not available.
        </CardContent>
      </Card>
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false,
})

interface LoyaltyReport {
  totalCustomers: number
  activeLoyaltyCustomers: number
  bronzeCustomers: number
  silverCustomers: number
  goldCustomers: number
  outstandingPoints: number
  outstandingValue: number
  pointsEarned: number
  pointsRedeemed: number
  pointsRefunded: number
  pointsReversed: number
  pointsAdjustedUp: number
  pointsAdjustedDown: number
  redeemedValue: number
}

interface LoyaltyBackfillResult {
  applied: boolean
  scannedOrders: number
  earnTransactionsCreated: number
  redeemTransactionsCreated: number
  skippedOrders: number
  note: string
}

const { get, post } = useApi()
const toast = useToast()
const loading = ref(true)
const backfillLoading = ref(false)
const report = ref<LoyaltyReport | null>(null)
const backfillResult = ref<LoyaltyBackfillResult | null>(null)
const backfillCanApply = computed(() => {
  if (!backfillResult.value || backfillResult.value.applied) return false
  return (backfillResult.value.earnTransactionsCreated + backfillResult.value.redeemTransactionsCreated) > 0
})

const fetchReport = async () => {
  loading.value = true
  try {
    const response = await get<{ data: LoyaltyReport }>('/reports/loyalty')
    report.value = response?.data || null
  } catch (err) {
    console.error('Failed to fetch loyalty report', err)
    toast.error('Failed to load loyalty report')
  } finally {
    loading.value = false
  }
}

const runBackfill = async (apply: boolean) => {
  if (apply && !backfillCanApply.value) return
  if (apply && !window.confirm('Apply historical loyalty ledger backfill now? Customer balances will not be changed.')) {
    return
  }

  backfillLoading.value = true
  try {
    const response = await post<{ data: LoyaltyBackfillResult }>('/reports/loyalty/backfill', { apply })
    backfillResult.value = response?.data || null
    toast.success(apply ? 'Loyalty backfill applied' : 'Loyalty backfill preview ready')
    if (apply) await fetchReport()
  } catch (err) {
    console.error('Failed to run loyalty backfill', err)
    toast.error('Failed to run loyalty backfill')
  } finally {
    backfillLoading.value = false
  }
}

const money = (value: number) => Number(value || 0).toFixed(2)
const tierRows = computed(() => {
  const total = report.value?.totalCustomers || 0
  const percent = (value: number) => total > 0 ? Math.round((value / total) * 100) : 0
  return [
    { label: 'Bronze', value: report.value?.bronzeCustomers || 0, percent: percent(report.value?.bronzeCustomers || 0), color: 'bg-orange-500' },
    { label: 'Silver', value: report.value?.silverCustomers || 0, percent: percent(report.value?.silverCustomers || 0), color: 'bg-neutral-500' },
    { label: 'Gold', value: report.value?.goldCustomers || 0, percent: percent(report.value?.goldCustomers || 0), color: 'bg-amber-500' },
  ]
})
const movementRows = computed(() => [
  { label: 'Refunded Redemptions', value: report.value?.pointsRefunded || 0, color: 'text-success-600' },
  { label: 'Reversed Earnings', value: report.value?.pointsReversed || 0, color: 'text-warning-600' },
  { label: 'Manual Additions', value: report.value?.pointsAdjustedUp || 0, color: 'text-success-600' },
  { label: 'Manual Removals', value: report.value?.pointsAdjustedDown || 0, color: 'text-error-600' },
])

onMounted(fetchReport)
</script>

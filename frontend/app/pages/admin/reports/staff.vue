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
            <BreadcrumbPage>Staff Productivity</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>

      <!-- Header -->
      <div
        class="flex flex-col md:flex-row md:items-center justify-between gap-4"
      >
        <div>
          <h1 class="text-2xl font-bold text-neutral-900 dark:text-white">
            Staff Productivity
          </h1>
          <p class="text-neutral-500 dark:text-neutral-400">
            Monitor employee performance
          </p>
        </div>

        <div class="flex items-center gap-2">
          <input
            type="date"
            v-model="startDate"
            class="bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-xl px-4 py-2 text-sm"
          />
          <span class="text-neutral-400">to</span>
          <input
            type="date"
            v-model="endDate"
            class="bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-xl px-4 py-2 text-sm"
          />
          <Button @click="fetchReport" variant="default" :disabled="loading">
            Update
          </Button>
          <button
            @click="downloadProductivity"
            class="flex items-center gap-2 px-4 py-2 bg-neutral-100 dark:bg-neutral-800 hover:bg-neutral-200 dark:hover:bg-neutral-700 text-neutral-700 dark:text-neutral-300 rounded-xl text-sm font-bold transition-colors"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="w-4 h-4"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            >
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
              <polyline points="7 10 12 15 17 10" />
              <line x1="12" y1="15" x2="12" y2="3" />
            </svg>
            Export
          </button>
        </div>
      </div>

      <div v-if="loading" class="space-y-6">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div
            v-for="i in 4"
            :key="i"
            class="h-64 animate-pulse bg-neutral-100 dark:bg-neutral-800 rounded-3xl"
          ></div>
        </div>
        <div
          class="h-80 animate-pulse bg-neutral-100 dark:bg-neutral-800 rounded-3xl"
        ></div>
      </div>

      <template v-else-if="report && report.employeeStats">
        <!-- Stats Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <Card
            v-for="stat in report.employeeStats"
            :key="stat.employeeId"
          >
            <CardContent class="p-6 flex flex-col items-center text-center">
            <div
              class="w-16 h-16 rounded-2xl bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center text-2xl font-bold text-neutral-400 mb-4"
            >
              {{ stat.fullName.charAt(0) }}
            </div>
            <h3 class="font-bold text-neutral-900 dark:text-white">
              {{ stat.fullName }}
            </h3>
            <p class="text-xs text-neutral-500 uppercase tracking-widest mt-1">
              {{ stat.position }}
            </p>

            <div
              class="mt-6 w-full space-y-3 pt-6 border-t border-neutral-100 dark:border-neutral-800"
            >
              <div class="flex justify-between text-sm">
                <span class="text-neutral-500">Sales</span>
                <span class="font-bold text-success-600"
                  >${{ stat.totalSalesGenerated?.toFixed(2) }}</span
                >
              </div>
              <div class="flex justify-between text-sm">
                <span class="text-neutral-500">Orders</span>
                <span class="font-bold text-neutral-900 dark:text-white">{{
                  stat.totalOrdersHandled
                }}</span>
              </div>
              <div class="flex justify-between text-sm">
                <span class="text-neutral-500">Punctuality</span>
                <span
                  :class="
                    stat.punctualityRate >= 90
                      ? 'text-success-600'
                      : 'text-warning-600'
                  "
                  class="font-bold"
                >
                  {{ stat.punctualityRate?.toFixed(1) }}%
                </span>
              </div>
            </div>
          </CardContent>
          </Card>
        </div>

        <!-- Detail Table -->
        <Card class="overflow-hidden">
          <CardContent class="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>
                  Employee
                </TableHead>
                <TableHead>
                  Total Hours
                </TableHead>
                <TableHead class="text-center">
                  Late Clock-ins
                </TableHead>
                <TableHead class="text-right">
                  Avg Order Value
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow
                v-for="stat in report.employeeStats"
                :key="stat.employeeId"
              >
                <TableCell>
                  <span class="font-medium text-neutral-900 dark:text-white">{{
                    stat.fullName
                  }}</span>
                </TableCell>
                <TableCell class="text-neutral-600 dark:text-neutral-400">
                  {{ (stat.totalMinutesWorked / 60).toFixed(1) }} hrs
                </TableCell>
                <TableCell class="text-center">
                  <span
                    :class="
                      stat.lateOccurrences > 2
                        ? 'text-error-600 font-bold'
                        : 'text-neutral-600'
                    "
                    class="px-2 py-1 rounded-lg"
                  >
                    {{ stat.lateOccurrences }}
                  </span>
                </TableCell>
                <TableCell class="text-right font-bold text-neutral-900 dark:text-white">
                  ${{ stat.averageOrderValue?.toFixed(2) }}
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
          </CardContent>
        </Card>
      </template>

      <!-- Empty State -->
      <Card v-else>
        <CardContent class="p-12 text-center text-neutral-500">
          No report data available. Try selecting a different date range.
        </CardContent>
      </Card>
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";

definePageMeta({
  layout: false,
});

const { get, download } = useApi();
const config = useRuntimeConfig();

const startDate = ref(
  new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split("T")[0],
);
const endDate = ref(new Date().toISOString().split("T")[0]);
const loading = ref(true);
const report = ref<any>(null);

const fetchReport = async () => {
  loading.value = true;
  try {
    const response = await get<any>(
      `/reports/staff?startDate=${startDate.value}&endDate=${endDate.value}`,
    );
    if (response?.data) {
      report.value = response.data;
    }
  } catch (err) {
    console.error("Failed to fetch staff report", err);
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  fetchReport();
});

const downloadProductivity = () => {
  const endpoint = `/api/import-export/export/staff?start=${startDate.value}&end=${endDate.value}`;
  download(
    endpoint,
    `staff_productivity_${startDate.value}_to_${endDate.value}.xlsx`,
  );
};
</script>

<style scoped>
</style>

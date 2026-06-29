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
            <BreadcrumbPage>Stock Transfer History</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>

      <!-- Header -->
      <div
        class="flex flex-col md:flex-row md:items-center justify-between gap-4"
      >
        <div>
          <h1 class="text-2xl font-bold text-neutral-900 dark:text-white">
            Stock Transfer History
          </h1>
          <p class="text-neutral-500 dark:text-neutral-400">
            Audit movements of ingredients between branches.
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
          <Button
            @click="fetchTransfers"
            variant="default"
            :disabled="loading"
          >
            Update
          </Button>
        </div>
      </div>

      <!-- Content -->
      <Card v-if="loading">
        <CardContent class="p-12 flex justify-center">
          <div
            class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-500"
          ></div>
        </CardContent>
      </Card>

      <div v-else-if="transfers.length > 0">
        <Card class="overflow-hidden">
          <CardContent class="p-0">
          <div class="overflow-x-auto">
            <Table class="font-sans">
              <TableHeader
                class="bg-neutral-50 dark:bg-neutral-800/50 text-xs font-bold text-neutral-500 uppercase tracking-widest"
              >
                <TableRow>
                  <TableHead>Date & Time</TableHead>
                  <TableHead>Ingredient</TableHead>
                  <TableHead>From Branch</TableHead>
                  <TableHead>To Branch</TableHead>
                  <TableHead class="text-right">Quantity</TableHead>
                  <TableHead>Transferred By</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                <TableRow
                  v-for="t in transfers"
                  :key="t.transferId"
                >
                  <TableCell class="whitespace-nowrap text-sm">
                    {{ formatDate(t.transferDate) }}
                  </TableCell>
                  <TableCell>
                    <div class="font-bold text-neutral-900 dark:text-white">
                      {{ t.ingredientName }}
                    </div>
                  </TableCell>
                  <TableCell class="whitespace-nowrap">
                    <span
                      class="px-3 py-1 bg-neutral-100 dark:bg-neutral-800 rounded-full text-xs font-medium"
                    >
                      {{ t.fromBranchName }}
                    </span>
                  </TableCell>
                  <TableCell class="whitespace-nowrap text-primary-600 dark:text-primary-400 font-bold">
                    → {{ t.toBranchName }}
                  </TableCell>
                  <TableCell class="text-right font-mono font-bold">
                    {{ t.quantity }}
                    <span
                      class="text-[10px] text-neutral-400 uppercase tracking-tighter"
                      >{{ t.unit }}</span
                    >
                  </TableCell>
                  <TableCell class="text-sm text-neutral-600 dark:text-neutral-400">
                    {{ t.transferredByName }}
                  </TableCell>
                </TableRow>
              </TableBody>
            </Table>
          </div>
          </CardContent>
        </Card>
      </div>

      <!-- Empty State -->
      <Card v-else>
        <CardContent class="p-20 text-center space-y-4">
        <div
          class="w-20 h-20 bg-neutral-100 dark:bg-neutral-800 rounded-full flex items-center justify-center mx-auto text-neutral-400"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="w-10 h-10"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
          >
            <path d="m16 3 4 4-4 4" />
            <path d="M20 7H4" />
            <path d="m8 21-4-4 4-4" />
            <path d="M4 17h16" />
          </svg>
        </div>
        <div>
          <h3 class="text-lg font-bold">No Transfer History</h3>
          <p class="text-neutral-500">
            No stock transfers found for the selected period.
          </p>
        </div>
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

const { get } = useApi();

const startDate = ref(
  new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split("T")[0],
);
const endDate = ref(new Date().toISOString().split("T")[0]);
const loading = ref(true);
const transfers = ref<any[]>([]);

const fetchTransfers = async () => {
  loading.value = true;
  try {
    const res = await get<any>(
      `/reports/transfers?startDate=${startDate.value}&endDate=${endDate.value}`,
    );
    if (res?.data) {
      transfers.value = res.data;
    }
  } catch (err) {
    console.error("Failed to fetch transfers", err);
  } finally {
    loading.value = false;
  }
};

const formatDate = (dateStr: string) => {
  const date = new Date(dateStr);
  return new Intl.DateTimeFormat("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(date);
};

onMounted(() => {
  fetchTransfers();
});
</script>

<style scoped>
</style>

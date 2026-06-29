<template>
  <NuxtLayout name="admin">
    <div class="space-y-6">
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbPage>Orders</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>

      <!-- Header -->
      <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 class="text-2xl font-bold text-neutral-900 dark:text-white">
            Order Management
          </h1>
          <p class="text-neutral-500 dark:text-neutral-400">
            View and manage all POS orders
          </p>
        </div>

        <div class="flex items-center gap-3">
          <div class="relative">
            <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-400" />
            <Input
              v-model="searchQuery"
              type="text"
              placeholder="Search by order #..."
              class="w-64 pl-10"
            />
          </div>
          <Button variant="ghost" size="icon" @click="fetchOrders">
            <RefreshCwIcon class="w-4 h-4" />
          </Button>
        </div>
      </div>

      <!-- Filters -->
      <div class="flex flex-wrap items-center gap-3 pb-2 overflow-x-auto">
        <Button
          v-for="status in ['ALL', 'PAID', 'PENDING', 'VOID', 'REFUND']"
          :key="status"
          :variant="selectedStatus === status ? 'default' : 'outline'"
          @click="selectedStatus = status"
        >
          {{ status }}
        </Button>
      </div>

      <Card class="overflow-hidden">
        <CardContent class="p-0">
        <div class="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead
                  v-for="h in [
                    'Order No',
                    'Date',
                    'Customer',
                    'Type',
                    'Total',
                    'Status',
                    'Actions',
                  ]"
                  :key="h"
                >
                  {{ h === "Actions" ? "" : h }}
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <template v-if="loading">
                <TableRow v-for="i in 5" :key="i" class="animate-pulse">
                  <TableCell v-for="j in 7" :key="j">
                    <div
                      class="h-4 bg-neutral-100 dark:bg-neutral-800 rounded"
                    ></div>
                  </TableCell>
                </TableRow>
              </template>
              <TableRow
                v-for="order in filteredOrders"
                :key="order.orderId"
              >
                <TableCell class="whitespace-nowrap">
                  <span
                    class="text-sm font-mono font-bold text-neutral-900 dark:text-white"
                    >{{ order.orderNo }}</span
                  >
                </TableCell>
                <TableCell class="whitespace-nowrap">
                  <div class="text-sm text-neutral-600 dark:text-neutral-400">
                    {{ new Date(order.createdAt).toLocaleDateString() }}
                  </div>
                  <div class="text-[10px] text-neutral-500">
                    {{ new Date(order.createdAt).toLocaleTimeString() }}
                  </div>
                </TableCell>
                <TableCell class="whitespace-nowrap">
                  <div class="text-sm text-neutral-900 dark:text-white">
                    {{ order.customer?.name || "Walk-in" }}
                  </div>
                  <div class="text-[10px] text-neutral-500">
                    Cashier: {{ order.cashierUser?.userName || "System" }}
                  </div>
                </TableCell>
                <TableCell class="whitespace-nowrap text-sm text-neutral-500"
                >
                  <div class="flex flex-col gap-1">
                    <span
                      class="font-medium text-neutral-900 dark:text-white"
                      >{{ order.orderType }}</span
                    >
                    <span
                      v-if="order.tableNo"
                      class="text-[10px] bg-primary-50 text-primary-700 dark:bg-primary-900/30 dark:text-primary-400 px-1.5 py-0.5 rounded-md w-fit font-bold"
                      >Table {{ order.tableNo }}</span
                    >
                    <span
                      class="text-[10px] text-neutral-400 font-medium uppercase tracking-tighter"
                      >{{ order.orderSource || "POS" }}</span
                    >
                  </div>
                </TableCell>
                <TableCell class="whitespace-nowrap">
                  <span
                    class="text-sm font-bold text-neutral-900 dark:text-white"
                    >${{ order.totalAmount?.toFixed(2) }}</span
                  >
                </TableCell>
                <TableCell class="whitespace-nowrap">
                  <span
                    :class="getStatusClass(order.status)"
                    class="text-[10px] px-2 py-1 rounded-full font-bold uppercase"
                  >
                    {{ order.status }}
                  </span>
                </TableCell>
                <TableCell class="whitespace-nowrap text-right text-sm font-medium">
                  <div class="flex items-center justify-end gap-2">
                    <Button variant="ghost" size="icon" @click="viewOrder(order)" title="View Details">
                      <EyeIcon class="w-4 h-4" />
                    </Button>
                    <Button
                      v-if="order.status === 'PENDING'"
                      variant="ghost"
                      size="icon"
                      @click="initiateAdjustment(order, 'VOID')"
                      title="Void Order"
                    >
                      <BanIcon class="w-4 h-4" />
                    </Button>
                    <Button
                      v-if="order.status === 'PAID'"
                      variant="ghost"
                      size="icon"
                      @click="initiateAdjustment(order, 'REFUND')"
                      title="Refund Order"
                    >
                      <RotateCcwIcon class="w-4 h-4" />
                    </Button>
                  </div>
                </TableCell>
              </TableRow>
              <TableRow v-if="filteredOrders.length === 0">
                <TableCell colspan="7" class="text-center">
                  <div class="flex flex-col items-center justify-center text-neutral-400">
                    <InboxIcon class="w-12 h-12 mb-2 opacity-20" />
                    <p>No orders matching your criteria</p>
                  </div>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>

        <!-- Pagination Controls -->
        <div
          class="px-6 py-4 border-t border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800/50 flex items-center justify-between"
        >
          <span class="text-sm text-neutral-500">
            Showing {{ orders.length }} of {{ totalElements }} orders
          </span>
          <div class="flex items-center gap-2">
            <Button variant="outline" size="icon" :disabled="currentPage === 0" @click="changePage(currentPage - 1)">
              <ChevronLeftIcon class="w-4 h-4" />
            </Button>
            <div class="flex items-center gap-1">
              <span class="text-sm font-medium px-3 py-1 bg-white dark:bg-neutral-700 rounded-md border border-neutral-200 dark:border-neutral-600">
                {{ currentPage + 1 }}
              </span>
              <span class="text-neutral-400 text-sm">/ {{ totalPages }}</span>
            </div>
            <Button variant="outline" size="icon" :disabled="currentPage >= totalPages - 1" @click="changePage(currentPage + 1)">
              <ChevronRightIcon class="w-4 h-4" />
            </Button>
          </div>
        </div>
        </CardContent>
      </Card>

      <Dialog v-model:open="showDetailsModal">
        <DialogContent class="sm:max-w-2xl">
          <DialogHeader>
            <DialogTitle v-if="selectedOrder">Order Details: {{ selectedOrder.orderNo }}</DialogTitle>
          </DialogHeader>
          <div v-if="selectedOrder" class="space-y-6">
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div>
                <p class="text-[10px] text-neutral-500 uppercase tracking-widest font-bold">Date</p>
                <p class="text-sm font-medium dark:text-white">{{ new Date(selectedOrder.createdAt).toLocaleString() }}</p>
              </div>
              <div>
                <p class="text-[10px] text-neutral-500 uppercase tracking-widest font-bold">Customer</p>
                <p class="text-sm font-medium dark:text-white">{{ selectedOrder.customer?.name || "Walk-in" }}</p>
              </div>
              <div>
                <p class="text-[10px] text-neutral-500 uppercase tracking-widest font-bold">Cashier</p>
                <p class="text-sm font-medium dark:text-white">{{ selectedOrder.cashierUser?.userName }}</p>
              </div>
              <div>
                <p class="text-[10px] text-neutral-500 uppercase tracking-widest font-bold">Status</p>
                <span :class="getStatusClass(selectedOrder.status)" class="text-[10px] px-2 py-0.5 rounded-full font-bold uppercase">{{ selectedOrder.status }}</span>
              </div>
              <div>
                <p class="text-[10px] text-neutral-500 uppercase tracking-widest font-bold">Source</p>
                <p class="text-sm font-medium dark:text-white">{{ selectedOrder.orderSource || "POS" }}<span v-if="selectedOrder.tableNo" class="text-primary-600 ml-1">(Table {{ selectedOrder.tableNo }})</span></p>
              </div>
            </div>
            <div class="space-y-3">
              <h4 class="text-xs font-bold text-neutral-900 dark:text-white border-b border-neutral-200 dark:border-neutral-700 pb-2 uppercase tracking-widest">Order Items</h4>
              <div v-for="item in selectedOrder.items" :key="item.orderItemId" class="flex justify-between items-center text-sm py-2 group">
                <div class="flex-1">
                  <div class="flex items-center gap-2">
                    <span class="w-6 h-6 rounded bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center text-[10px] font-bold text-primary-600">{{ item.qty }}x</span>
                    <p class="font-medium dark:text-white">{{ item.menuItemName || item.menuItem?.name }}<span v-if="item.variantName || item.variant?.name" class="text-xs text-neutral-500">({{ item.variantName || item.variant?.name }})</span></p>
                  </div>
                  <div v-if="item.addOnItems?.length" class="pl-8 mt-1 space-x-1">
                    <span v-for="addon in item.addOnItems" :key="addon.id" class="text-[10px] px-1.5 py-0.5 bg-accent-50 text-accent-700 rounded-md">+ {{ addon.name }}</span>
                  </div>
                </div>
                <p class="font-bold dark:text-white">${{ ((item.unitPrice || 0) * item.qty).toFixed(2) }}</p>
              </div>
            </div>
            <div class="space-y-1 pt-4 border-t border-neutral-200 dark:border-neutral-700">
              <div class="flex justify-between text-sm text-neutral-500"><span>Subtotal</span><span>${{ selectedOrder.subTotal?.toFixed(2) }}</span></div>
              <div v-if="selectedOrder.discountAmount > 0" class="flex justify-between text-sm text-error-500 font-medium"><span>Discount</span><span>-${{ selectedOrder.discountAmount?.toFixed(2) }}</span></div>
              <div v-if="selectedOrder.taxAmount > 0" class="flex justify-between text-sm text-neutral-500"><span>Tax</span><span>${{ selectedOrder.taxAmount?.toFixed(2) }}</span></div>
              <div class="flex justify-between text-lg font-bold text-neutral-900 dark:text-white pt-2"><span>Grand Total</span><span class="text-primary-600">${{ selectedOrder.totalAmount?.toFixed(2) }}</span></div>
            </div>
            <div v-if="selectedOrder.note" class="bg-neutral-50 dark:bg-neutral-900/50 p-4 rounded-xl border border-neutral-200 dark:border-neutral-700">
              <p class="text-[10px] text-neutral-500 uppercase font-black mb-1">Audit Log / Note</p>
              <p class="text-sm dark:text-neutral-300 italic leading-relaxed">{{ selectedOrder.note }}</p>
            </div>
          </div>
          <DialogFooter>
            <Button variant="secondary" @click="selectedOrder = null">Close</Button>
            <Button v-if="selectedOrder?.status === 'PAID'" variant="default" class="bg-error-600 border-error-600 hover:bg-error-700" @click="initiateAdjustment(selectedOrder, 'REFUND')">Initiate Refund</Button>
            <Button v-if="selectedOrder?.status === 'PENDING'" variant="default" class="bg-warning-600 border-warning-600 hover:bg-warning-700" @click="initiateAdjustment(selectedOrder, 'VOID')">Void Order</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <!-- New Approval Modal (PIN + Reason) -->
      <ApprovalModal
        v-model="showApprovalModal"
        :action-type="approvalActionType"
        :loading="submittingAdjustment"
        @approve="handleApprovedAdjustment"
      />
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from "vue";
import { SearchIcon, RefreshCwIcon, EyeIcon, BanIcon, RotateCcwIcon, InboxIcon, ChevronLeftIcon, ChevronRightIcon } from "@lucide/vue"
import ApprovalModal from "~/components/pos/ApprovalModal.vue";

definePageMeta({
  layout: false,
});

const { get, post, put } = useApi();
const toast = useToast();

// -- State --
const loading = ref(true);
const orders = ref<any[]>([]);
const searchQuery = ref("");
const selectedStatus = ref("ALL");
const selectedOrder = ref<any | null>(null);

// Pagination State
const currentPage = ref(0);
const totalPages = ref(0);
const totalElements = ref(0);
const pageSize = 20;

// Adjustment State
const adjustmentTarget = ref<any | null>(null);
const submittingAdjustment = ref(false);
const showApprovalModal = ref(false);
const approvalActionType = ref<"VOID" | "REFUND">("VOID");

// -- Fetch Logic --
const fetchOrders = async () => {
  loading.value = true;
  try {
    // Construct query params
    const params: any = {
      page: currentPage.value,
      size: pageSize,
      sort: "createdAt,desc",
    };

    if (selectedStatus.value !== "ALL") {
      params.status = selectedStatus.value;
    }

    if (searchQuery.value) {
      params.search = searchQuery.value;
    }

    const data = await get<any>("/orders", params);

    // Handle Standardized ApiResponse structure
    const pageData = data?.data;

    // Handle Page response structure
    if (pageData && pageData.content) {
      orders.value = pageData.content;
      totalPages.value = pageData.totalPages;
      totalElements.value = pageData.totalElements;
    } else if (Array.isArray(pageData)) {
      orders.value = pageData;
    } else if (Array.isArray(data)) {
      // Direct array fallback
      orders.value = data;
    } else {
      orders.value = [];
    }
  } catch (err) {
    console.error("Failed to fetch orders", err);
    toast.error("Failed to load orders");
  } finally {
    loading.value = false;
  }
};

// Watchers for server-side filtering
watch([selectedStatus], () => {
  currentPage.value = 0; // Reset to first page on filter change
  fetchOrders();
});

// Debounce search
let searchTimeout: any;
watch(searchQuery, () => {
  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => {
    currentPage.value = 0;
    fetchOrders();
  }, 500);
});

const changePage = (newPage: number) => {
  if (newPage >= 0 && newPage < totalPages.value) {
    currentPage.value = newPage;
    fetchOrders();
  }
};

// Helper for "filteredOrders" replacement (now just direct orders)
const filteredOrders = computed(() => orders.value);

const showDetailsModal = computed({
  get: () => selectedOrder.value !== null,
  set: (v) => { if (!v) selectedOrder.value = null }
})

// -- Actions --
const viewOrder = (order: any) => {
  selectedOrder.value = order;
};

const initiateAdjustment = (order: any, type: "VOID" | "REFUND") => {
  adjustmentTarget.value = { order, type };
  approvalActionType.value = type;
  showApprovalModal.value = true;
  selectedOrder.value = null;
};

const handleApprovedAdjustment = async (data: {
  pin: string;
  reason: string;
}) => {
  if (!adjustmentTarget.value) return;

  submittingAdjustment.value = true;
  try {
    const orderId = adjustmentTarget.value.order.orderId;
    const type = adjustmentTarget.value.type; // VOID or REFUND

    const endpoint = `/orders/${orderId}/${type.toLowerCase()}`;
    await put(endpoint, null, {
      params: {
        pinCode: data.pin,
        reason: data.reason,
      },
    });

    await fetchOrders();

    showApprovalModal.value = false;
    adjustmentTarget.value = null;
    toast.success(`Order ${type} successfully processed`);
  } catch (err: any) {
    console.error("Adjustment failed", err);
    toast.error(err.response?.data?.message || "Failed to process adjustment");
  } finally {
    submittingAdjustment.value = false;
  }
};

// -- Helpers --
const getStatusClass = (status: string) => {
  const classes: any = {
    PAID: "bg-success-100 text-success-700 dark:bg-success-900/30 dark:text-success-400",
    PENDING:
      "bg-warning-100 text-warning-700 dark:bg-warning-900/30 dark:text-warning-400",
    VOID: "bg-neutral-100 text-neutral-500 dark:bg-neutral-700 dark:text-neutral-400",
    REFUND:
      "bg-error-100 text-error-700 dark:bg-error-900/30 dark:text-error-400",
  };
  return classes[status] || "bg-neutral-100 text-neutral-700";
};

onMounted(() => {
  fetchOrders();
});
</script>

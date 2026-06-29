<template>
  <NuxtLayout name="admin">
    <div class="space-y-6">
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbPage>QR Table Codes</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>

      <div class="flex items-center justify-between">
        <div>
          <h2 class="text-2xl font-bold text-neutral-900 dark:text-white">QR Table Codes</h2>
          <p class="text-neutral-500 mt-1">Generate QR codes for customer table ordering</p>
        </div>
      </div>

    <Card class="mb-6">
      <CardContent class="p-6">
      <h2 class="text-lg font-semibold text-neutral-900 dark:text-white mb-4">Configuration</h2>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="space-y-2">
          <Label>Branch</Label>
          <Select v-model="selectedBranch">
            <SelectTrigger>
              <SelectValue placeholder="Select a branch" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem v-for="branch in branches" :key="branch.branchId" :value="branch">
                {{ branch.name }} ({{ branch.code }})
              </SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div class="space-y-2">
          <Label>Menu Base URL</Label>
          <Input v-model="baseUrl" type="text" placeholder="https://yourdomain.com" />
          <p class="text-xs text-neutral-400">URL where customers can access the menu</p>
        </div>

        <div class="space-y-2">
          <Label>Number of Tables</Label>
          <Input v-model.number="numberOfTables" type="number" min="1" max="100" @change="generateQRCodes" />
        </div>
      </div>

      <div class="flex gap-3 mt-6">
        <Button @click="saveConfiguration" :disabled="!selectedBranch || isSaving">
          <SaveIcon v-if="!isSaving" class="w-4 h-4" />
          <span v-else class="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin"></span>
          Save Configuration
        </Button>
        <Button v-if="qrCodes.length > 0" @click="printAll" variant="secondary">
          <PrinterIcon class="w-4 h-4" />
          Print All
        </Button>
      </div>
      </CardContent>
    </Card>

    <!-- QR Codes grid -->
    <div
      v-if="qrCodes.length > 0"
      id="qr-print-area"
      class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4"
    >
      <Card
        v-for="qr in qrCodes"
        :key="qr.tableNo"
        class="text-center hover:shadow-lg transition-shadow print:break-inside-avoid print:shadow-none print:border print:border-neutral-300"
      >
        <CardContent class="p-6">
        <div class="mb-3">
          <span
            class="text-xs font-semibold uppercase tracking-wider text-primary-600 dark:text-primary-400"
          >
            {{ selectedBranch?.name }}
          </span>
        </div>

        <!-- QR Code Component -->
        <div class="flex justify-center mb-3">
          <!-- Wrapped in a div to capture the canvas from the component if needed, 
                 but QrcodeVue renders a canvas we can ref directly via :ref but it might be a component ref -->
          <qrcode-vue
            :value="qr.url"
            :size="200"
            level="H"
            class="rounded-lg"
            :id="'qr-canvas-' + qr.tableNo"
          />
        </div>

        <h3 class="text-lg font-bold text-neutral-900 dark:text-white">
          Table {{ qr.tableNo }}
        </h3>
        <p class="text-xs text-neutral-400 mt-1 break-all">{{ qr.url }}</p>

        <div class="flex gap-2 mt-4 print:hidden">
          <Button @click="downloadQR(qr.tableNo)" variant="ghost" size="sm" class="flex-1 text-xs">
            <DownloadIcon class="w-3.5 h-3.5" />
            Download
          </Button>
          <Button @click="printSingle(qr.tableNo)" variant="ghost" size="sm" class="flex-1 text-xs">
            <PrinterIcon class="w-3.5 h-3.5" />
            Print
          </Button>
        </div>
        </CardContent>
      </Card>
    </div>

    <!-- Empty state -->
    <div v-else>
      <Card>
      <CardContent class="p-12 text-center">
      <div class="text-6xl mb-4">📱</div>
      <h3 class="text-lg font-bold text-neutral-900 dark:text-white mb-2">
        No QR codes generated yet
      </h3>
      <p class="text-neutral-500 dark:text-neutral-400">
        Select a branch and click "Generate QR Codes" to create table QR codes.
      </p>
      </CardContent>
      </Card>
    </div>
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
import QrcodeVue from "qrcode.vue";
import { SaveIcon, PrinterIcon, DownloadIcon } from '@lucide/vue'

definePageMeta({ layout: false });

const { get, put } = useApi();
const toast = useToast();

const branches = ref<any[]>([]);
const selectedBranch = ref<any>(null);
const baseUrl = ref("");
const numberOfTables = ref(10);
const qrCodes = ref<{ tableNo: number; url: string }[]>([]);
const isSaving = ref(false);

// Fetch branches
const fetchBranches = async () => {
  try {
    const data = await get<any>("/branches");
    branches.value = Array.isArray(data) ? data : data?.content || [];
  } catch (e) {
    console.error("Failed to fetch branches:", e);
  }
};

onMounted(() => {
  fetchBranches();
  // Default to current origin
  if (typeof window !== "undefined") {
    baseUrl.value = window.location.origin;
  }
});

watch(selectedBranch, (newBranch) => {
  if (newBranch) {
    numberOfTables.value = newBranch.tableCount || 10;
    generateQRCodes();
  } else {
    qrCodes.value = [];
  }
});

const generateQRCodes = () => {
  if (!selectedBranch.value || !baseUrl.value) return;

  // Generate QR code data
  qrCodes.value = Array.from({ length: numberOfTables.value }, (_, i) => ({
    tableNo: i + 1,
    url: `${baseUrl.value}/menu/${selectedBranch.value.code}?table=${i + 1}`,
  }));
};

const saveConfiguration = async () => {
  if (!selectedBranch.value) return;

  isSaving.value = true;
  try {
    await put(`/branches/update/${selectedBranch.value.branchId}`, {
      ...selectedBranch.value,
      tableCount: numberOfTables.value,
    });
    // Update local branch data
    selectedBranch.value.tableCount = numberOfTables.value;
    toast.success("Configuration saved successfully");
  } catch (e) {
    console.error("Failed to save branch configuration:", e);
    toast.error("Failed to save configuration");
  } finally {
    isSaving.value = false;
  }
};

// Helper to get canvas from the rendered component (QrcodeVue renders a canvas)
const getCanvasFromId = (tableNo: number): HTMLCanvasElement | null => {
  // We are using :id on the QrcodeVue component which passes it to the canvas
  const canvas = document.getElementById(
    `qr-canvas-${tableNo}`,
  ) as HTMLCanvasElement;
  return canvas;
};

const downloadQR = (tableNo: number) => {
  const canvas = getCanvasFromId(tableNo);
  if (!canvas) return;

  const link = document.createElement("a");
  link.download = `table-${tableNo}-qr.png`;
  link.href = canvas.toDataURL("image/png");
  link.click();
};

const printSingle = (tableNo: number) => {
  const canvas = getCanvasFromId(tableNo);
  if (!canvas) return;

  const win = window.open("");
  if (!win) return;
  win.document.write(`
    <html><head><title>Table ${tableNo} QR Code</title>
    <style>body { display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 100vh; font-family: system-ui; }
    h2 { margin-bottom: 8px; } p { color: #666; font-size: 12px; }</style></head>
    <body>
      <h2>${selectedBranch.value?.name || "Cafe"}</h2>
      <img src="${canvas.toDataURL()}" width="250" height="250" />
      <h3>Table ${tableNo}</h3>
      <p>Scan to view menu and order</p>
    </body></html>
  `);
  win.document.close();
  win.print();
};

const printAll = () => {
  window.print();
};

useHead({ title: "QR Table Codes" });
</script>

<style scoped>
@media print {
  :deep(.print\\:hidden) {
    display: none !important;
  }
}
</style>

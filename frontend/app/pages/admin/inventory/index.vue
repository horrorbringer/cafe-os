<template>
  <NuxtLayout name="admin">
    <div class="space-y-6 relative">
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbPage>Inventory</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>

      <!-- Header -->
      <div class="flex items-center justify-between">
        <div>
          <h2 class="text-2xl font-bold text-neutral-900 dark:text-white">
            Inventory Management
          </h2>
          <p class="text-xs text-neutral-500 mt-1">
            Monitor stock levels and manage ingredient adjustments.
          </p>
        </div>
        <div class="flex items-center gap-3">
          <Tabs v-model="activeTab">
            <TabList>
              <TabTrigger value="items">Stock Items</TabTrigger>
              <TabTrigger value="adjustments">Audit History</TabTrigger>
            </TabList>
          </Tabs>

          <Button variant="outline" @click="openTransferModal">
            <ArrowLeftRightIcon class="w-4 h-4" />
            Transfer
          </Button>

          <div class="h-8 w-px bg-neutral-200 dark:bg-neutral-800 mx-1"></div>

          <div class="flex items-center gap-2">
            <Button variant="ghost" size="icon" @click="downloadIngredients('excel')" title="Export as Excel">
              <DownloadIcon class="w-5 h-5" />
            </Button>
            <Button variant="ghost" size="icon" @click="triggerFileInput" title="Bulk Import Stock">
              <UploadIcon class="w-5 h-5" />
            </Button>
            <input type="file" ref="fileInput" class="hidden" accept=".xlsx,.csv" @change="onFileChange" />
          </div>

          <Button @click="openCreateModal">
            <PlusIcon class="w-4 h-4" />
            Add Ingredient
          </Button>
        </div>
      </div>

      <TabsContent value="items" class="space-y-6">
        <!-- Filters -->
        <div class="flex items-center gap-4 bg-white dark:bg-neutral-900 p-4 rounded-xl border border-neutral-200 dark:border-neutral-800">
          <div class="relative flex-1 max-w-md">
            <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-400" />
            <Input v-model="searchQuery" placeholder="Search ingredients..." class="pl-10" />
          </div>
          <div class="flex items-center gap-2">
            <Label class="text-[10px] font-black uppercase">View Branch:</Label>
            <Select v-model="selectedBranchId">
              <SelectTrigger class="min-w-[150px]">
                <SelectValue placeholder="Global Overview" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="null">Global Overview</SelectItem>
                <SelectItem v-for="b in branches" :key="b.branchId" :value="String(b.branchId)">
                  {{ b.name }}
                </SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div class="flex items-center gap-2">
            <Select v-model="filterStatus">
              <SelectTrigger>
                <SelectValue placeholder="All Status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Status</SelectItem>
                <SelectItem value="low">Low Stock</SelectItem>
                <SelectItem value="sufficient">Sufficient</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>

        <!-- Stock Table -->
        <div
          class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-800 rounded-xl overflow-hidden"
        >
          <div class="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow
                  class="bg-neutral-50 dark:bg-neutral-800/50 border-b border-neutral-200 dark:border-neutral-800"
                >
                  <TableHead>
                    Name
                  </TableHead>
                  <TableHead>
                    Stock Level
                  </TableHead>
                  <TableHead>
                    Unit Cost
                  </TableHead>
                  <TableHead>
                    Reorder Point
                  </TableHead>
                  <TableHead>
                    Last Stock In
                  </TableHead>
                  <TableHead class="text-right">
                    Actions
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                <template v-if="loading">
                  <TableRow v-for="i in 5" :key="i" class="animate-pulse">
                    <TableCell v-for="j in 6" :key="j">
                      <div
                        class="h-4 bg-neutral-200 dark:bg-neutral-800 rounded"
                      ></div>
                    </TableCell>
                  </TableRow>
                </template>
                <TableRow v-else-if="filteredIngredients.length === 0">
                  <TableCell colspan="6" class="text-center">
                    <div class="flex flex-col items-center text-neutral-500 py-8">
                      <PackageSearchIcon class="w-12 h-12 mb-3 opacity-20" />
                      <p>No ingredients found.</p>
                    </div>
                  </TableCell>
                </TableRow>
                <TableRow
                  v-for="item in filteredIngredients"
                  :key="item.ingredientId"
                >
                  <TableCell>
                    <div class="font-medium text-neutral-900 dark:text-white">
                      {{ item.name }}
                    </div>
                    <div class="text-xs text-neutral-500">
                      {{ item.sku || "No SKU" }}
                    </div>
                  </TableCell>
                  <TableCell>
                    <div class="flex items-center gap-2">
                      <span
                        :class="[
                          'font-mono font-medium',
                          item.currentStock <= item.reorderLevel
                            ? 'text-error-600 dark:text-error-400'
                            : 'text-neutral-900 dark:text-white',
                        ]"
                      >
                        {{ item.currentStock?.toFixed(2) }} {{ item.unit }}
                      </span>
                      <span
                        v-if="item.currentStock <= item.reorderLevel"
                        class="px-1.5 py-0.5 rounded text-[10px] font-bold bg-error-100 text-error-700 dark:bg-error-900/30 dark:text-error-400 uppercase tracking-wide"
                      >
                        Low
                      </span>
                    </div>
                  </TableCell>
                  <TableCell class="text-sm text-neutral-600 dark:text-neutral-400">
                    ${{ item.costPerUnit?.toFixed(2) }}
                  </TableCell>
                  <TableCell class="text-sm text-neutral-600 dark:text-neutral-400">
                    {{ item.reorderLevel?.toFixed(2) }} {{ item.unit }}
                  </TableCell>
                  <TableCell class="text-sm text-neutral-600 dark:text-neutral-400">
                    {{
                      item.updatedAt
                        ? new Date(item.updatedAt).toLocaleDateString()
                        : "-"
                    }}
                  </TableCell>
                  <TableCell class="text-right">
                    <div class="flex items-center justify-end gap-1">
                      <Button variant="ghost" size="icon" @click="openStockIn(item)" title="Stock In">
                        <PackagePlusIcon class="w-4 h-4 text-success-600" />
                      </Button>
                      <Button variant="ghost" size="icon" @click="openAdjustment(item)" title="Adjust Stock">
                        <PencilLineIcon class="w-4 h-4 text-warning-600" />
                      </Button>
                      <Button variant="ghost" size="icon" @click="editIngredient(item)">
                        <PencilIcon class="w-4 h-4" />
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              </TableBody>
            </Table>
          </div>
        </div>
      </TabsContent>

      <TabsContent value="adjustments" class="space-y-6">
        <div
          class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-800 rounded-xl overflow-hidden"
        >
          <div class="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow
                  class="bg-neutral-50 dark:bg-neutral-800/50 border-b border-neutral-200 dark:border-neutral-800"
                >
                  <TableHead>
                    Date
                  </TableHead>
                  <TableHead>
                    Ingredient
                  </TableHead>
                  <TableHead>
                    Type
                  </TableHead>
                  <TableHead>
                    Qty Change
                  </TableHead>
                  <TableHead>
                    Status
                  </TableHead>
                  <TableHead class="text-right">
                    Action
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                <TableRow v-if="adjLoading">
                  <TableCell colspan="6" class="text-center">
                    <div
                      class="animate-spin h-6 w-6 border-2 border-primary-500 border-t-transparent rounded-full mx-auto"
                    ></div>
                  </TableCell>
                </TableRow>
                <TableRow v-else-if="adjustments.length === 0">
                  <TableCell
                    colspan="6"
                    class="text-center text-neutral-500"
                  >
                    No adjustment history found.
                  </TableCell>
                </TableRow>
                <TableRow
                  v-for="adj in adjustments"
                  :key="adj.adjustmentId"
                >
                  <TableCell class="whitespace-nowrap text-neutral-500 font-mono text-[10px]">
                    {{ new Date(adj.date).toLocaleString() }}
                  </TableCell>
                  <TableCell class="font-bold text-neutral-900 dark:text-white">
                    {{ adj.ingredient?.name }}
                  </TableCell>
                  <TableCell>
                    <span
                      class="text-[10px] font-black uppercase tracking-tighter"
                      >{{ adj.reasonType }}</span
                    >
                  </TableCell>
                  <TableCell
                    :class="[
                      'font-mono font-bold',
                      adj.qtyChange < 0 ? 'text-red-500' : 'text-success-500',
                    ]"
                  >
                    {{ adj.qtyChange > 0 ? "+" : "" }}{{ adj.qtyChange }}
                  </TableCell>
                  <TableCell>
                    <span
                      :class="[
                        'px-2 py-0.5 rounded-full text-[10px] font-black uppercase',
                        adj.status === 'APPROVED'
                          ? 'bg-success-100 text-success-700'
                          : adj.status === 'PENDING'
                            ? 'bg-warning-100 text-warning-700'
                            : 'bg-error-100 text-error-700',
                      ]"
                    >
                      {{ adj.status }}
                    </span>
                  </TableCell>
                  <TableCell class="text-right">
                    <Button
                      v-if="adj.status === 'PENDING'"
                      size="sm"
                      @click="initiateApproval(adj)"
                    >
                      Approve
                    </Button>
                    <div v-else class="text-[10px] text-neutral-500 italic">
                      By: {{ adj.approvedByName }}
                    </div>
                  </TableCell>
                </TableRow>
              </TableBody>
            </Table>
          </div>
        </div>
      </TabsContent>

      <Dialog v-model:open="showCreateModal">
        <DialogContent class="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>{{ isEditing ? "Edit Ingredient" : "New Ingredient" }}</DialogTitle>
          </DialogHeader>
          <div class="space-y-4">
            <div class="space-y-2">
              <Label>Name</Label>
              <Input v-model="newIngredient.name" type="text" required placeholder="e.g. Milk" />
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2">
                <Label>Unit</Label>
                <Input v-model="newIngredient.unit" type="text" required placeholder="e.g. Liters" />
              </div>
              <div class="space-y-2">
                <Label>Cost Per Unit</Label>
                <Input v-model="newIngredient.costPerUnit" type="number" step="0.01" />
              </div>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2">
                <Label>Initial Stock</Label>
                <Input v-model="newIngredient.currentStock" type="number" />
              </div>
              <div class="space-y-2">
                <Label>Reorder Level</Label>
                <Input v-model="newIngredient.reorderLevel" type="number" />
              </div>
            </div>
            <div class="space-y-2">
              <Label>SKU</Label>
              <Input v-model="newIngredient.sku" type="text" placeholder="Optional" />
            </div>
            <div><CustomImageUpload v-model="newIngredient.imageUrl" label="Ingredient Image" /></div>
          </div>
          <DialogFooter>
            <Button variant="secondary" @click="showCreateModal = false">Cancel</Button>
            <Button variant="default" @click="saveIngredient">{{ isEditing ? "Update" : "Save" }} Ingredient</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog v-model:open="showStockInModal">
        <DialogContent class="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Stock In: {{ selectedIngredient?.name }}</DialogTitle>
          </DialogHeader>
          <div class="space-y-4">
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2">
                <Label>Branch</Label>
                <Select v-model="newStockIn.branchId">
                  <SelectTrigger>
                    <SelectValue placeholder="Select branch" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem v-for="branch in branches" :key="branch.branchId" :value="String(branch.branchId)">{{ branch.name }}</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div class="space-y-2">
                <Label>Supplier</Label>
                <Select v-model="newStockIn.supplierId">
                  <SelectTrigger>
                    <SelectValue placeholder="Select supplier" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem v-for="sup in suppliers" :key="sup.supplierId" :value="String(sup.supplierId)">{{ sup.name }}</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2">
                <Label>Quantity</Label>
                <Input v-model="newStockIn.qtyIn" type="number" step="1" />
              </div>
              <div class="space-y-2">
                <Label>Unit Cost</Label>
                <Input v-model="newStockIn.unitCost" type="number" step="0.01" />
              </div>
            </div>
            <div class="space-y-2">
              <Label>Invoice No</Label>
              <Input v-model="newStockIn.invoiceNo" type="text" />
            </div>
            <div class="space-y-2">
              <Label>Received By</Label>
              <Select v-model="newStockIn.receivedBy">
                <SelectTrigger>
                  <SelectValue placeholder="Select user" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="user in users" :key="user.userId" :value="String(user.userId)">{{ user.username }}</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <DialogFooter>
            <Button variant="secondary" @click="showStockInModal = false">Cancel</Button>
            <Button variant="default" @click="createStockIn">Confirm Stock In</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog v-model:open="showAdjustmentModal">
        <DialogContent class="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Adjust Stock: {{ selectedIngredient?.name }}</DialogTitle>
          </DialogHeader>
          <div class="space-y-4">
            <div class="space-y-2">
              <Label>Branch</Label>
              <Select v-model="newAdjustment.branchId">
                <SelectTrigger>
                  <SelectValue placeholder="Select branch" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="branch in branches" :key="branch.branchId" :value="String(branch.branchId)">{{ branch.name }}</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="space-y-2">
              <Label>Adjustment Qty (+/-)</Label>
              <Input v-model="newAdjustment.qtyChange" type="number" step="0.1" placeholder="-2 or 5" />
              <p class="text-xs text-neutral-500">Use negative values for wastage/loss, positive for corrections.</p>
            </div>
            <div class="space-y-2">
              <Label>Reason</Label>
              <Select v-model="newAdjustment.reasonType">
                <SelectTrigger>
                  <SelectValue placeholder="Select reason" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="WASTAGE">Wastage / Spoiled</SelectItem>
                  <SelectItem value="CORRECTION">Inventory Correction</SelectItem>
                  <SelectItem value="THEFT">Theft / Loss</SelectItem>
                  <SelectItem value="OTHER">Other</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="space-y-2">
              <Label>Note</Label>
              <Textarea v-model="newAdjustment.note" rows="3" />
            </div>
            <div class="space-y-2">
              <Label>Created By</Label>
              <Select v-model="newAdjustment.createdBy">
                <SelectTrigger>
                  <SelectValue placeholder="Select user" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="user in users" :key="user.userId" :value="String(user.userId)">{{ user.username }}</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <DialogFooter>
            <Button variant="secondary" @click="showAdjustmentModal = false">Cancel</Button>
            <Button variant="default" @click="createAdjustment">Submit Adjustment</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ApprovalModal
        v-model="showApprovalModal"
        action-type="VOID"
        :loading="approving"
        @approve="confirmApproval"
      />

      <Dialog v-model:open="showTransferModal">
        <DialogContent class="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Inter-Branch Transfer</DialogTitle>
          </DialogHeader>
          <div class="space-y-4">
            <div class="space-y-2">
              <Label>Ingredient</Label>
              <Select v-model="transferForm.ingredientId">
                <SelectTrigger>
                  <SelectValue placeholder="Select ingredient" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="item in ingredients" :key="item.ingredientId" :value="String(item.ingredientId)">{{ item.name }}</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2">
                <Label>From Branch</Label>
                <Select v-model="transferForm.fromBranchId">
                  <SelectTrigger>
                    <SelectValue placeholder="Select branch" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem v-for="b in branches" :key="b.branchId" :value="String(b.branchId)">{{ b.name }}</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div class="space-y-2">
                <Label>To Branch</Label>
                <Select v-model="transferForm.toBranchId">
                  <SelectTrigger>
                    <SelectValue placeholder="Select branch" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem v-for="b in branches" :key="b.branchId" :value="String(b.branchId)">{{ b.name }}</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
            <div class="space-y-2">
              <Label>Quantity</Label>
              <Input v-model="transferForm.amount" type="number" />
            </div>
          </div>
          <DialogFooter>
            <Button variant="secondary" @click="showTransferModal = false">Cancel</Button>
            <Button variant="default" :disabled="loading" @click="executeTransfer">Execute Transfer</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, reactive, watch } from "vue";
import ApprovalModal from "~/components/pos/ApprovalModal.vue";
import { PlusIcon, ArrowLeftRightIcon, DownloadIcon, UploadIcon, SearchIcon, PackageSearchIcon, PackagePlusIcon, PencilLineIcon, PencilIcon } from '@lucide/vue'

definePageMeta({
  layout: false,
});
const config = useRuntimeConfig();
const { get, post, put, download } = useApi();
const toast = useToast();

interface Ingredient {
  ingredientId: number;
  name: string;
  sku?: string;
  unit: string;
  currentStock: number;
  costPerUnit: number;
  reorderLevel: number;
  updatedAt: string;
  imageUrl?: string | null;
}

interface Supplier {
  supplierId: number;
  name: string;
}

interface User {
  userId: number;
  username: string;
}

// State
const activeTab = ref("items");
const ingredients = ref<Ingredient[]>([]);
const adjustments = ref<any[]>([]);
const adjLoading = ref(false);
const suppliers = ref<Supplier[]>([]);
const users = ref<User[]>([]);
const loading = ref(true);
const searchQuery = ref("");
const filterStatus = ref("all");
const branches = ref<any[]>([]);

const showCreateModal = ref(false);
const showStockInModal = ref(false);
const showAdjustmentModal = ref(false);
const showApprovalModal = ref(false);
const approving = ref(false);
const isEditing = ref(false);
const editingId = ref<number | null>(null);
const selectedAdjustment = ref<any | null>(null);
const selectedBranchId = ref<string>('');

const selectedIngredient = ref<Ingredient | null>(null);
const showTransferModal = ref(false);
const fileInput = ref<HTMLInputElement | null>(null);

const transferForm = reactive({
  ingredientId: '',
  fromBranchId: '',
  toBranchId: '',
  amount: 0,
});

// Forms
const newIngredient = reactive({
  name: "",
  unit: "G",
  currentStock: 0,
  costPerUnit: 0,
  reorderLevel: 5,
  sku: "",
  imageUrl: "",
});

const newStockIn = reactive({
  supplierId: '',
  ingredientId: null as number | null,
  branchId: '',
  qtyIn: 0,
  unitCost: 0,
  totalCost: 0,
  invoiceNo: '',
  receivedDate: '',
  receivedBy: '',
});

const newAdjustment = reactive({
  ingredientId: null as number | null,
  branchId: '',
  qtyChange: 0,
  reasonType: 'WASTAGE',
  note: '',
  createdBy: '',
  date: '',
});

// Fetching
const fetchIngredients = async () => {
  loading.value = true;
  try {
    if (selectedBranchId.value && selectedBranchId.value !== 'null') {
      const data = await get<any[]>(
        `/inventory/branch/${selectedBranchId.value}`,
      );
      ingredients.value = (data || []).map((d) => ({
        ingredientId: d.ingredientId,
        name: d.ingredientName,
        sku: d.sku,
        unit: d.unit,
        currentStock: d.currentStock,
        reorderLevel: d.reorderLevel,
        costPerUnit: d.costPerUnit || 0,
        updatedAt: "",
      }));
    } else {
      const data = await get<Ingredient[]>("/ingredients");
      ingredients.value = data || [];
    }
  } catch (err) {
    console.error("Failed to fetch ingredients", err);
  } finally {
    loading.value = false;
  }
};

const fetchAdjustments = async () => {
  adjLoading.value = true;
  try {
    const data = await get<any[]>("/stock-adjustments");
    adjustments.value = data || [];
  } catch (e) {
    toast.error("Failed to load adjustment history");
  } finally {
    adjLoading.value = false;
  }
};

watch(activeTab, (val) => {
  if (val === "adjustments") fetchAdjustments();
  else fetchIngredients();
});

watch(selectedBranchId, () => {
  fetchIngredients();
});

const fetchSuppliers = async () => {
  try {
    // Mocking if endpoint not ready, or implement
    const data = await get<Supplier[]>("/suppliers");
    suppliers.value = data || [];
  } catch (err) {
    console.error("Failed fetch suppliers");
    // Mock
    suppliers.value = [
      { supplierId: 1, name: "Local Farm" },
      { supplierId: 2, name: "Wholesale Depot" },
    ];
  }
};

const fetchUsers = async () => {
  try {
    const data = await get<User[]>("/users");
    users.value = data || [];
  } catch (err) {
    console.error("Failed fetch users");
    // Mock
    users.value = [
      { userId: 1, username: "admin" },
      { userId: 2, username: "staff" },
    ];
  }
};

const fetchBranches = async () => {
  try {
    const data = await get<any[]>("/branches");
    branches.value = data || [];
  } catch (err) {
    console.error("Failed to fetch branches", err);
  }
};

const filteredIngredients = computed(() => {
  let result = ingredients.value;

  if (searchQuery.value) {
    const q = searchQuery.value.toLowerCase();
    result = result.filter(
      (i) =>
        i.name.toLowerCase().includes(q) ||
        (i.sku && i.sku.toLowerCase().includes(q)),
    );
  }

  if (filterStatus.value === "low") {
    result = result.filter((i) => i.currentStock <= i.reorderLevel);
  } else if (filterStatus.value === "sufficient") {
    result = result.filter((i) => i.currentStock > i.reorderLevel);
  }

  return result;
});

// Actions
const openCreateModal = () => {
  isEditing.value = false;
  editingId.value = null;
  Object.assign(newIngredient, {
    name: "",
    unit: "pcs",
    currentStock: 0,
    costPerUnit: 0,
    reorderLevel: 5,
    sku: "",
    imageUrl: "",
  });
  showCreateModal.value = true;
};

const saveIngredient = async () => {
  try {
    if (isEditing.value && editingId.value) {
      await put(`/ingredients/${editingId.value}`, newIngredient);
      toast.success("Ingredient updated successfully");
    } else {
      await post("/ingredients", newIngredient);
      toast.success("Ingredient created successfully");
    }
    showCreateModal.value = false;
    fetchIngredients();
  } catch (err) {
    toast.error("Failed to save ingredient");
  }
};

const editIngredient = (item: Ingredient) => {
  isEditing.value = true;
  editingId.value = item.ingredientId;
  Object.assign(newIngredient, {
    name: item.name,
    unit: item.unit,
    currentStock: item.currentStock,
    costPerUnit: item.costPerUnit,
    reorderLevel: item.reorderLevel,
    sku: item.sku || "",
    imageUrl: item.imageUrl || "",
  });
  showCreateModal.value = true;
};

const openStockIn = (item: Ingredient) => {
  selectedIngredient.value = item;
  newStockIn.ingredientId = item.ingredientId;
  newStockIn.branchId =
    selectedBranchId.value && selectedBranchId.value !== 'null'
      ? selectedBranchId.value
      : String(branches.value[0]?.branchId || '');
  newStockIn.unitCost = item.costPerUnit || 0;
  newStockIn.qtyIn = 0;
  newStockIn.receivedDate = new Date().toISOString();
  showStockInModal.value = true;
};

const createStockIn = async () => {
  newStockIn.totalCost = newStockIn.qtyIn * newStockIn.unitCost;

  const payload = {
    ...newStockIn,
    supplierId: newStockIn.supplierId ? Number(newStockIn.supplierId) : null,
    branchId: newStockIn.branchId ? Number(newStockIn.branchId) : null,
    receivedBy: newStockIn.receivedBy ? Number(newStockIn.receivedBy) : null,
  }

  try {
    await post("/stock-in", payload);
    showStockInModal.value = false;
    toast.success("Stock-in recorded successfully");
    fetchIngredients();
  } catch (err) {
    console.error(err);
    toast.error("Failed to record stock in");
  }
};

const openAdjustment = (item: Ingredient) => {
  selectedIngredient.value = item;
  newAdjustment.ingredientId = item.ingredientId;
  newAdjustment.branchId =
    selectedBranchId.value && selectedBranchId.value !== 'null'
      ? selectedBranchId.value
      : String(branches.value[0]?.branchId || '');
  newAdjustment.qtyChange = 0;
  newAdjustment.note = "";
  newAdjustment.date = new Date().toISOString();
  showAdjustmentModal.value = true;
};

const openTransferModal = () => {
  transferForm.fromBranchId =
    selectedBranchId.value && selectedBranchId.value !== 'null'
      ? selectedBranchId.value
      : String(branches.value[0]?.branchId || '');
  transferForm.toBranchId = '';
  transferForm.amount = 0;
  showTransferModal.value = true;
};

const executeTransfer = async () => {
  if (
    !transferForm.ingredientId ||
    !transferForm.fromBranchId ||
    !transferForm.toBranchId ||
    transferForm.amount <= 0
  ) {
    toast.error("Please fill all transfer details correctly");
    return;
  }

  loading.value = true;
  try {
    await post("/inventory/branch/transfer", null, {
      params: {
        fromBranchId: Number(transferForm.fromBranchId),
        toBranchId: Number(transferForm.toBranchId),
        ingredientId: Number(transferForm.ingredientId),
        amount: transferForm.amount,
      },
    });
    toast.success("Stock transfer successful");
    showTransferModal.value = false;
    fetchIngredients();
  } catch (e: any) {
    toast.error(e.response?.data?.message || "Transfer failed");
  } finally {
    loading.value = false;
  }
};

const downloadIngredients = (format: "excel" | "csv") => {
  const endpoint = `/api/import-export/export/ingredients/${format}`;
  download(
    endpoint,
    `inventory_portfolio.${format === "excel" ? "xlsx" : "csv"}`,
  );
};

const triggerFileInput = () => {
  fileInput.value?.click();
};

const onFileChange = async (event: any) => {
  const file = event.target.files[0];
  if (!file) return;

  if (!selectedBranchId.value) {
    toast.error("Please select a branch first to update stock");
    if (fileInput.value) fileInput.value.value = "";
    return;
  }

  loading.value = true;
  const formData = new FormData();
  formData.append("file", file);
  formData.append("branchId", selectedBranchId.value.toString());

  try {
    await $fetch(config.public.apiBase + "/api/import-export/import/stock", {
      method: "POST",
      body: formData,
      headers: {
        Authorization: "Bearer " + useCookie("auth_token").value,
      },
    });

    toast.success("Stock updated successfully!");
    fetchIngredients();
  } catch (err: any) {
    console.error(err);
    toast.error(err.response?._data?.message || "Import failed");
  } finally {
    loading.value = false;
    if (fileInput.value) fileInput.value.value = "";
  }
};

const createAdjustment = async () => {
  try {
    const { user } = useAuth();
    newAdjustment.date = new Date().toISOString();
    const payload = {
      ...newAdjustment,
      branchId: newAdjustment.branchId ? Number(newAdjustment.branchId) : null,
      createdBy: user.value?.userId || 1,
    }
    await post("/stock-adjustments", payload);
    showAdjustmentModal.value = false;
    toast.success("Inventory adjustment submitted for approval");
    fetchIngredients();
  } catch (err) {
    console.error(err);
    toast.error("Failed to submit adjustment");
  }
};

const initiateApproval = (adj: any) => {
  selectedAdjustment.value = adj;
  showApprovalModal.value = true;
};

const confirmApproval = async (data: { pin: string }) => {
  if (!selectedAdjustment.value) return;
  approving.value = true;
  try {
    await put(
      `/stock-adjustments/${selectedAdjustment.value.adjustmentId}/approve`,
      null,
      {
        params: {
          pinCode: data.pin,
        },
      },
    );
    toast.success("Adjustment approved");
    showApprovalModal.value = false;
    fetchAdjustments();
  } catch (e: any) {
    toast.error(e.response?.data?.message || "Approval failed");
  } finally {
    approving.value = false;
  }
};

onMounted(() => {
  fetchIngredients();
  fetchSuppliers();
  fetchUsers();
  fetchBranches();
});
</script>

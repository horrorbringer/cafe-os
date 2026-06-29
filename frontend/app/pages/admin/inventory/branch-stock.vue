<template>
  <NuxtLayout name="admin">
    <div class="space-y-6">
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbLink href="/admin/inventory">Inventory</BreadcrumbLink>
          </BreadcrumbItem>
          <BreadcrumbSeparator />
          <BreadcrumbItem>
            <BreadcrumbPage>Branch Stock</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>

      <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 class="text-2xl font-bold text-neutral-900 dark:text-white tracking-tight">
            Branch Inventory
          </h2>
          <p class="text-neutral-500 text-sm">
            Monitor and manage stock levels by location
          </p>
        </div>

        <div class="flex items-center gap-3">
          <div class="min-w-[200px]">
            <Select v-model="selectedBranchId">
              <SelectTrigger>
                <SelectValue placeholder="Select Branch" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem v-for="b in branches" :key="b.branchId" :value="String(b.branchId)">
                  {{ b.name }}
                </SelectItem>
              </SelectContent>
            </Select>
          </div>

          <Button @click="showTransferModal = true">
            <ArrowLeftRightIcon class="w-4 h-4" />
            Transfer Stock
          </Button>
        </div>
      </div>

      <Card>
        <CardContent>
          <div v-if="loading" class="p-12 flex flex-col items-center justify-center gap-4">
            <div class="w-10 h-10 border-4 border-primary-500/20 border-t-primary-500 rounded-full animate-spin"></div>
            <span class="text-neutral-500 font-bold text-xs uppercase tracking-widest">Loading branch stock...</span>
          </div>

          <div v-else-if="!selectedBranchId" class="p-20 text-center">
            <div class="w-20 h-20 bg-neutral-100 dark:bg-neutral-800 rounded-full flex items-center justify-center mx-auto mb-6">
              <Building2Icon class="w-10 h-10 text-neutral-400" />
            </div>
            <h3 class="text-xl font-bold text-neutral-900 dark:text-white mb-2">No Branch Selected</h3>
            <p class="text-neutral-500 text-sm max-w-xs mx-auto">
              Please select a branch from the dropdown above to view its current inventory levels.
            </p>
          </div>

          <div v-else class="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Ingredient</TableHead>
                  <TableHead class="text-right">Current Stock</TableHead>
                  <TableHead class="text-right">Reorder Level</TableHead>
                  <TableHead class="text-center">Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                <TableRow v-for="item in inventory" :key="item.branchStockId" class="group">
                  <TableCell>
                    <div class="flex items-center gap-3">
                      <div class="w-10 h-10 rounded-xl bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center">
                        <span class="text-lg font-bold text-neutral-500">{{ item.ingredient.name.charAt(0) }}</span>
                      </div>
                      <div>
                        <div class="text-sm font-bold text-neutral-900 dark:text-white">{{ item.ingredient.name }}</div>
                        <div class="text-[10px] text-neutral-500 font-medium uppercase tracking-tighter">{{ item.ingredient.sku || 'No SKU' }}</div>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell class="text-right">
                    <span :class="['text-sm font-black', item.currentStock <= item.reorderLevel ? 'text-red-400' : 'text-success-500']">
                      {{ item.currentStock?.toFixed(2) }} {{ item.ingredient.unit }}
                    </span>
                  </TableCell>
                  <TableCell class="text-right">
                    <span class="text-xs font-bold text-neutral-400">{{ item.reorderLevel?.toFixed(2) }} {{ item.ingredient.unit }}</span>
                  </TableCell>
                  <TableCell class="text-center">
                    <span v-if="item.currentStock <= 0" class="text-[10px] bg-red-500/10 text-red-500 px-2 py-0.5 rounded-full font-black uppercase border border-red-500/20">Out of Stock</span>
                    <span v-else-if="item.currentStock <= item.reorderLevel" class="text-[10px] bg-warning-500/10 text-warning-500 px-2 py-0.5 rounded-full font-black uppercase border border-warning-500/20">Low Stock</span>
                    <span v-else class="text-[10px] bg-success-500/10 text-success-500 px-2 py-0.5 rounded-full font-black uppercase border border-success-500/20">Healthy</span>
                  </TableCell>
                </TableRow>
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>

      <Dialog v-model:open="showTransferModal">
        <DialogContent class="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Inter-Branch Transfer</DialogTitle>
          </DialogHeader>
          <div class="space-y-6">
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
              <Label>Ingredient</Label>
              <Select v-model="transferForm.ingredientId">
                <SelectTrigger>
                  <SelectValue placeholder="Select ingredient" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="item in allIngredients" :key="item.ingredientId" :value="String(item.ingredientId)">
                    {{ item.name }} ({{ item.unit }})
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="space-y-2">
              <Label>Amount to Transfer</Label>
              <Input v-model.number="transferForm.amount" type="number" placeholder="0.00" />
            </div>
            <Button @click="submitTransfer" :disabled="submitting || !transferForm.amount || transferForm.fromBranchId === transferForm.toBranchId" class="w-full">
              <span v-if="submitting" class="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin"></span>
              {{ submitting ? 'Processing...' : 'Execute Transfer' }}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { ArrowLeftRightIcon, Building2Icon } from '@lucide/vue'

definePageMeta({
  layout: false
})

const { get, post } = useApi()
const toast = useToast()

const branches = ref<any[]>([])
const selectedBranchId = ref<string>('')
const inventory = ref<any[]>([])
const loading = ref(false)
const showTransferModal = ref(false)
const submitting = ref(false)
const allIngredients = ref<any[]>([])

const transferForm = ref({
  fromBranchId: '',
  toBranchId: '',
  ingredientId: '',
  amount: 0,
})

const fetchBranches = async () => {
  try {
    const data = await get<any[]>('/branches')
    branches.value = data || []
    if (branches.value.length > 0) {
      selectedBranchId.value = String(branches.value[0].branchId)
    }
  } catch (e) {
    console.error('Failed to fetch branches', e)
  }
}

const fetchAllIngredients = async () => {
  try {
    const data = await get<any[]>('/ingredients')
    allIngredients.value = data || []
  } catch (e) {
    console.error('Failed to fetch ingredients', e)
  }
}

const fetchInventory = async () => {
  if (!selectedBranchId.value) return
  loading.value = true
  try {
    const data = await get<any[]>(`/inventory/branch/${selectedBranchId.value}`)
    inventory.value = data || []
  } catch (e) {
    console.error('Failed to fetch inventory', e)
  } finally {
    loading.value = false
  }
}

const submitTransfer = async () => {
  submitting.value = true
  try {
    await post('/inventory/branch/transfer', null, {
      params: {
        fromBranchId: transferForm.value.fromBranchId,
        toBranchId: transferForm.value.toBranchId,
        ingredientId: transferForm.value.ingredientId,
        amount: transferForm.value.amount,
      },
    })
    toast.success('Stock transfer successful')
    showTransferModal.value = false
    fetchInventory()
  } catch (e: any) {
    toast.error(e.response?.data?.message || 'Transfer failed')
  } finally {
    submitting.value = false
  }
}

watch(selectedBranchId, fetchInventory)

onMounted(() => {
  fetchBranches()
  fetchAllIngredients()
})
</script>

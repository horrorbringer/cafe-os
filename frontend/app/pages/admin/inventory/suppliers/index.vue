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
            <BreadcrumbPage>Suppliers</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>
      
      <!-- Header -->
      <div class="flex items-center justify-between">
        <div>
          <h2 class="text-2xl font-bold text-neutral-900 dark:text-white">Supplier Management</h2>
          <p class="text-sm text-neutral-500 mt-1">Manage ingredient vendors, contacts, and delivery terms.</p>
        </div>
        <Button @click="openModal()">
          <PlusIcon class="w-4 h-4" />
          Add Supplier
        </Button>
      </div>

      <!-- Stats -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
          <Card class="border-l-4 border-l-accent-500">
              <CardContent class="p-6">
                <p class="text-[10px] font-black text-neutral-500 uppercase tracking-widest mb-1">Total Suppliers</p>
                <p class="text-3xl font-black text-neutral-900 dark:text-white">{{ suppliers.length }}</p>
              </CardContent>
          </Card>
          <Card class="border-l-4 border-l-success-500">
              <CardContent class="p-6">
                <p class="text-[10px] font-black text-neutral-500 uppercase tracking-widest mb-1">Active Partners</p>
                <p class="text-3xl font-black text-neutral-900 dark:text-white">{{ suppliers.filter(s => s.status === 'ACTIVE').length }}</p>
              </CardContent>
          </Card>
      </div>

      <!-- Table -->
      <Card class="overflow-hidden">
        <CardContent class="p-0">
        <div class="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow class="bg-neutral-50 dark:bg-neutral-800/50 border-b border-neutral-200 dark:border-neutral-700">
                <TableHead>Supplier</TableHead>
                <TableHead>Contact Details</TableHead>
                <TableHead>Location/Address</TableHead>
                <TableHead>Status</TableHead>
                <TableHead class="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <template v-if="loading">
                <TableRow v-for="i in 5" :key="i" class="animate-pulse">
                   <TableCell v-for="j in 5" :key="j"><div class="h-4 bg-neutral-100 dark:bg-neutral-800 rounded w-full"></div></TableCell>
                </TableRow>
              </template>
              <TableRow v-for="s in suppliers" :key="s.supplierId">
                <TableCell>
                  <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-xl gradient-accent flex items-center justify-center text-white font-black">
                      {{ s.name.charAt(0) }}
                    </div>
                    <div class="text-sm font-bold text-neutral-900 dark:text-white">{{ s.name }}</div>
                  </div>
                </TableCell>
                <TableCell>
                  <div class="text-sm text-neutral-600 dark:text-neutral-400">{{ s.phone }}</div>
                  <div class="text-xs text-neutral-500">{{ s.email }}</div>
                </TableCell>
                <TableCell>
                  <p class="text-sm text-neutral-600 dark:text-neutral-400 truncate max-w-xs">{{ s.address || 'Global' }}</p>
                </TableCell>
                <TableCell>
                  <span :class="s.status === 'ACTIVE' ? 'bg-success-100 text-success-700 dark:bg-success-900/30 dark:text-success-400' : 'bg-neutral-100 text-neutral-500'" class="text-[10px] px-2 py-0.5 rounded-full font-bold uppercase">
                    {{ s.status }}
                  </span>
                </TableCell>
                <TableCell class="text-right">
                  <div class="flex items-center justify-end gap-2">
                    <Button variant="ghost" size="icon" @click="openModal(s)">
                      <PencilIcon class="w-4 h-4" />
                    </Button>
                    <Button variant="ghost" size="icon" @click="confirmDelete(s.supplierId)">
                      <Trash2Icon class="w-4 h-4" />
                    </Button>
                  </div>
                </TableCell>
              </TableRow>
              <TableRow v-if="suppliers.length === 0 && !loading">
                  <TableCell colspan="5" class="text-center text-neutral-400 italic">No suppliers registered yet.</TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>
        </CardContent>
      </Card>

      <Dialog v-model:open="showModal">
        <DialogContent class="sm:max-w-xl">
          <DialogHeader>
            <DialogTitle>{{ editingId ? 'Update Partner' : 'New Supplier' }}</DialogTitle>
          </DialogHeader>
          <form @submit.prevent="saveSupplier" class="space-y-6">
            <div class="grid grid-cols-2 gap-6">
              <div class="col-span-2 space-y-2">
                <Label class="text-xs font-bold uppercase tracking-widest">Company Name</Label>
                <Input v-model="form.name" type="text" required placeholder="e.g. Arabica Roast Co." />
              </div>
              <div class="space-y-2">
                <Label class="text-xs font-bold uppercase tracking-widest">Phone Number</Label>
                <Input v-model="form.phone" type="text" required placeholder="+855 ..." />
              </div>
              <div class="space-y-2">
                <Label class="text-xs font-bold uppercase tracking-widest">Email Address</Label>
                <Input v-model="form.email" type="email" required placeholder="vendor@example.com" />
              </div>
              <div class="space-y-2">
                <Label class="text-xs font-bold uppercase tracking-widest">Status</Label>
                <Select v-model="form.status">
                  <SelectTrigger>
                    <SelectValue placeholder="Select status" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="ACTIVE">Active</SelectItem>
                    <SelectItem value="INACTIVE">Inactive</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div class="space-y-2">
                <Label class="text-xs font-bold uppercase tracking-widest">Contact Person Gender</Label>
                <Select v-model="form.gender">
                  <SelectTrigger>
                    <SelectValue placeholder="Select gender" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Mr">Mr</SelectItem>
                    <SelectItem value="Ms">Ms</SelectItem>
                    <SelectItem value="Other">Other</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div class="col-span-2 space-y-2">
                <Label class="text-xs font-bold uppercase tracking-widest">Base Office / Address</Label>
                <Textarea v-model="form.address" placeholder="Full business address..." />
              </div>
              <div class="col-span-2 space-y-2">
                <Label class="text-xs font-bold uppercase tracking-widest">Terms / Notes</Label>
                <Textarea v-model="form.notes" placeholder="Delivery terms, lead times, etc." />
              </div>
            </div>
          </form>
          <DialogFooter>
            <Button variant="secondary" @click="showModal = false">Cancel</Button>
            <Button type="submit" variant="default" :disabled="saving" @click="saveSupplier">
              {{ saving ? 'Saving...' : (editingId ? 'Update Partner' : 'Register Supplier') }}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <AlertDialog v-model:open="showDeleteAlert">
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Supplier</AlertDialogTitle>
            <AlertDialogDescription>Are you sure you want to delete this supplier? This action cannot be undone.</AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction @click="executeDelete">Delete</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { PlusIcon, PencilIcon, Trash2Icon } from '@lucide/vue'

definePageMeta({
  layout: false
})
const { get, post, put, del } = useApi()
const toast = useToast()

interface Supplier {
  supplierId: number
  name: string
  phone: string
  email: string
  gender: string
  address: string
  notes: string
  status: string
}

const suppliers = ref<Supplier[]>([])
const loading = ref(true)
const saving = ref(false)
const showModal = ref(false)
const editingId = ref<number | null>(null)
const showDeleteAlert = ref(false)
const supplierToDelete = ref<number | null>(null)

const form = reactive({
  name: '',
  phone: '',
  email: '',
  gender: 'Mr',
  address: '',
  notes: '',
  status: 'ACTIVE',
})

const fetchSuppliers = async () => {
  loading.value = true
  try {
    const data = await get<Supplier[]>('/suppliers')
    suppliers.value = data || []
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

const openModal = (supplier: Supplier | null = null) => {
  if (supplier) {
    editingId.value = supplier.supplierId
    form.name = supplier.name
    form.phone = supplier.phone
    form.email = supplier.email
    form.gender = supplier.gender
    form.address = supplier.address
    form.notes = supplier.notes
    form.status = supplier.status
  } else {
    editingId.value = null
    form.name = ''
    form.phone = ''
    form.email = ''
    form.gender = 'Mr'
    form.address = ''
    form.notes = ''
    form.status = 'ACTIVE'
  }
  showModal.value = true
}

const saveSupplier = async () => {
  saving.value = true
  try {
    if (editingId.value) {
      await put(`/suppliers/${editingId.value}`, form)
      toast.success('Supplier partner updated')
    } else {
      await post('/suppliers', form)
      toast.success('New supplier registered')
    }
    showModal.value = false
    fetchSuppliers()
  } catch (err) {
    toast.error('Failed to save supplier details')
  } finally {
    saving.value = false
  }
}

const confirmDelete = (id: number) => {
  supplierToDelete.value = id
  showDeleteAlert.value = true
}

const executeDelete = async () => {
  if (!supplierToDelete.value) return
  try {
    await del(`/suppliers/${supplierToDelete.value}`)
    toast.success('Supplier removed')
    fetchSuppliers()
  } catch (e) {
    toast.error('Failed to delete supplier')
  } finally {
    showDeleteAlert.value = false
    supplierToDelete.value = null
  }
}

onMounted(fetchSuppliers)
</script>

<style scoped>
.gradient-accent {
  @apply bg-gradient-to-br from-accent-500 to-accent-700;
}
</style>

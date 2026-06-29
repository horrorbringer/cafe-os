<template>
  <NuxtLayout name="admin">
    <div class="space-y-6 relative">
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbPage>Add-ons</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>

      <!-- Header -->
      <div class="flex items-center justify-between">
        <h2 class="text-2xl font-bold text-neutral-900 dark:text-white">Add-ons Management</h2>
        <Button @click="openCreateModal">
          <PlusIcon class="w-4 h-4" />
          Add Add-on
        </Button>
      </div>

      <!-- Filters -->
      <div class="flex items-center gap-4 bg-white dark:bg-neutral-900 p-4 rounded-xl border border-neutral-200 dark:border-neutral-800">
        <div class="relative flex-1 max-w-md">
          <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-400" />
          <Input
            v-model="searchQuery"
            type="text"
            placeholder="Search add-ons..."
            class="pl-10"
          />
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-12 text-neutral-500">
        Loading add-ons...
      </div>

      <!-- Empty -->
      <div v-else-if="filteredAddOns.length === 0" class="text-center py-12 text-neutral-500">
        No add-ons found.
      </div>

      <!-- Add-ons Table -->
      <div v-else class="bg-white dark:bg-neutral-900 rounded-xl border border-neutral-200 dark:border-neutral-800 overflow-hidden">
        <Table>
          <TableHeader class="bg-neutral-50 dark:bg-neutral-800/50">
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Price</TableHead>
              <TableHead class="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="addon in filteredAddOns" :key="addon.id">
              <TableCell>
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-lg bg-accent-100 dark:bg-accent-900/30 flex items-center justify-center">
                    <CirclePlusIcon class="w-5 h-5 text-accent-600 dark:text-accent-400" />
                  </div>
                  <span class="font-medium text-neutral-900 dark:text-white">{{ addon.name }}</span>
                </div>
              </TableCell>
              <TableCell>
                <span class="text-sm font-bold text-primary-600 dark:text-primary-400">${{ addon.price.toFixed(2) }}</span>
              </TableCell>
              <TableCell class="text-right">
                <div class="flex items-center justify-end gap-2">
                  <Button variant="ghost" size="icon" @click="openEditModal(addon)">
                    <PencilIcon class="w-4 h-4" />
                  </Button>
                  <Button variant="ghost" size="icon" @click="confirmDelete(addon)">
                    <Trash2Icon class="w-4 h-4" />
                  </Button>
                </div>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </div>

      <Dialog v-model:open="showModal">
        <DialogContent class="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>{{ isEditing ? 'Edit Add-on' : 'New Add-on' }}</DialogTitle>
          </DialogHeader>
          <div class="space-y-4">
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2">
                <Label for="name">🇺🇸 Name</Label>
                <Input id="name" v-model="form.name" placeholder="e.g. Extra Shot" />
              </div>
              <div class="space-y-2">
                <Label for="nameKh">🇰🇭 Khmer Name</Label>
                <Input id="nameKh" v-model="form.nameKh" placeholder="ឧទាហរណ៍៖ បន្ថែមឈុត" class="font-khmer" />
              </div>
            </div>
            <div class="space-y-2">
              <Label for="price">Price ($)</Label>
              <Input id="price" v-model.number="form.price" type="number" step="0.01" min="0" placeholder="0.50" />
            </div>
          </div>
          <DialogFooter>
            <Button variant="secondary" @click="closeModal">Cancel</Button>
            <Button variant="default" @click="saveAddOn">{{ isEditing ? 'Save Changes' : 'Create Add-on' }}</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <!-- Delete Confirmation -->
      <AlertDialog v-model:open="showDeleteAlert">
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Add-on</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to delete <strong>{{ addonToDelete?.name }}</strong>? This action cannot be undone.
            </AlertDialogDescription>
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
import { ref, computed, onMounted, reactive } from 'vue'
import { PlusIcon, SearchIcon, CirclePlusIcon, PencilIcon, Trash2Icon } from '@lucide/vue'

definePageMeta({
  layout: false
})

const { get, post, put, del } = useApi()
const toast = useToast()

interface AddOn {
  id: number
  name: string
  nameKh?: string
  price: number
}

const addOns = ref<AddOn[]>([])
const loading = ref(true)
const searchQuery = ref('')
const showModal = ref(false)
const isEditing = ref(false)
const currentAddOnId = ref<number | null>(null)
const showDeleteAlert = ref(false)
const addonToDelete = ref<AddOn | null>(null)

const form = reactive({
  name: '',
  nameKh: '',
  price: 0
})

const filteredAddOns = computed(() => {
  if (!searchQuery.value) return addOns.value
  const q = searchQuery.value.toLowerCase()
  return addOns.value.filter(addon => addon.name.toLowerCase().includes(q))
})

const fetchAddOns = async () => {
  loading.value = true
  try {
    const data = await get<AddOn[]>('/addons')
    addOns.value = data || []
  } catch (err) {
    console.error(err)
    toast.error('Failed to load add-ons')
  } finally {
    loading.value = false
  }
}

const openCreateModal = () => {
  isEditing.value = false
  currentAddOnId.value = null
  form.name = ''
  form.nameKh = ''
  form.price = 0
  showModal.value = true
}

const openEditModal = (addon: AddOn) => {
  isEditing.value = true
  currentAddOnId.value = addon.id
  form.name = addon.name
  form.nameKh = addon.nameKh || ''
  form.price = addon.price
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
}

const saveAddOn = async () => {
  if (!form.name.trim()) {
    toast.error('Please enter a name')
    return
  }

  try {
    const payload = { name: form.name, nameKh: form.nameKh, price: form.price }

    if (isEditing.value && currentAddOnId.value) {
      await put(`/addons/${currentAddOnId.value}`, payload)
      toast.success('Add-on updated')
    } else {
      await post('/addons', payload)
      toast.success('Add-on created')
    }

    await fetchAddOns()
    closeModal()
  } catch (err) {
    console.error(err)
    toast.error('Failed to save add-on')
  }
}

const confirmDelete = (addon: AddOn) => {
  addonToDelete.value = addon
  showDeleteAlert.value = true
}

const executeDelete = async () => {
  if (!addonToDelete.value) return

  try {
    await del(`/addons/${addonToDelete.value.id}`)
    toast.success('Add-on deleted')
    await fetchAddOns()
  } catch (err) {
    console.error(err)
    toast.error('Failed to delete add-on')
  } finally {
    showDeleteAlert.value = false
    addonToDelete.value = null
  }
}

onMounted(() => {
  fetchAddOns()
})
</script>

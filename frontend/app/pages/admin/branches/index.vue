<template>
  <NuxtLayout name="admin">
    <div class="space-y-6">
      <!-- Header -->
      <Breadcrumb class="mb-2">
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbPage>Branches</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>
      <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 class="text-2xl font-bold text-neutral-900 dark:text-white">Branch Management</h2>
          <p class="text-neutral-500 dark:text-neutral-400">Manage your cafe branches and locations</p>
        </div>
        <Button @click="openAddModal">
          <PlusIcon class="w-5 h-5" />
          Add Branch
        </Button>
      </div>

      <!-- Branch Cards Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- Loading Skeletons -->
        <template v-if="loading">
          <Card v-for="i in 3" :key="i">
            <CardContent class="p-6 space-y-4">
              <div class="flex items-start justify-between">
                <div class="space-y-2 flex-1">
                  <div class="h-5 w-24 skeleton-shimmer rounded-lg"></div>
                  <div class="h-4 w-32 skeleton-shimmer rounded-lg"></div>
                </div>
                <div class="h-10 w-10 skeleton-shimmer rounded-xl"></div>
              </div>
              <div class="space-y-2">
                <div class="h-3 w-full skeleton-shimmer rounded-lg"></div>
                <div class="h-3 w-2/3 skeleton-shimmer rounded-lg"></div>
              </div>
            </CardContent>
          </Card>
        </template>

        <!-- Empty State -->
        <div v-else-if="branches.length === 0" class="col-span-full">
          <Card>
            <CardContent class="p-12 text-center">
              <div class="w-16 h-16 mx-auto bg-neutral-100 dark:bg-neutral-800 rounded-2xl flex items-center justify-center mb-4">
                <StoreIcon class="w-8 h-8 text-neutral-400" />
              </div>
              <h3 class="text-lg font-semibold text-neutral-900 dark:text-white mb-2">No branches yet</h3>
              <p class="text-neutral-500 mb-4">Add your first branch to get started</p>
              <Button @click="openAddModal" variant="default">
                Add Branch
              </Button>
            </CardContent>
          </Card>
        </div>

        <!-- Branch Cards -->
        <Card
          v-for="(branch, index) in branches"
          :key="branch.branchId"
          :class="[
            'animate-hidden animate-slide-up',
            `stagger-${Math.min(index + 1, 5)}`
          ]"
        >
          <CardContent class="p-6">
          <div class="flex items-start justify-between mb-4">
            <div>
              <span class="inline-block px-2.5 py-1 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 text-xs font-bold rounded-lg mb-2">
                {{ branch.code }}
              </span>
              <h3 class="text-lg font-semibold text-neutral-900 dark:text-white">{{ branch.name }}</h3>
            </div>
            <div class="flex gap-1">
              <Button variant="ghost" size="icon" @click="openEditModal(branch)" title="Edit">
                <PencilIcon class="w-4 h-4" />
              </Button>
              <Button variant="ghost" size="icon" @click="confirmDelete(branch)" title="Delete">
                <Trash2Icon class="w-4 h-4" />
              </Button>
            </div>
          </div>

          <div class="space-y-2 text-sm text-neutral-600 dark:text-neutral-400">
            <div v-if="branch.location" class="flex items-start gap-2">
              <MapPinIcon class="w-4 h-4 mt-0.5 flex-shrink-0" />
              <span>{{ branch.location }}</span>
            </div>
            <div v-if="branch.phone" class="flex items-center gap-2">
              <PhoneIcon class="w-4 h-4 flex-shrink-0" />
              <span>{{ branch.phone }}</span>
            </div>
          </div>

          <div class="mt-4 pt-4 border-t border-neutral-200 dark:border-neutral-700">
            <div v-if="branch.latitude && branch.longitude" class="flex items-center gap-2 text-xs text-success-600 dark:text-success-400">
              <GlobeIcon class="w-4 h-4" />
              <span>GPS: {{ branch.latitude.toFixed(4) }}, {{ branch.longitude.toFixed(4) }}</span>
              <span class="text-neutral-400">• {{ branch.radiusMeters || 100 }}m</span>
            </div>
            <div v-else class="flex items-center gap-2 text-xs text-neutral-400">
              <MapPinOffIcon class="w-4 h-4" />
              <span>No GPS coordinates set</span>
            </div>
          </div>
          </CardContent>
        </Card>
      </div>

      <Dialog v-model:open="showModal">
        <DialogContent class="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>{{ isEditing ? 'Edit Branch' : 'Add Branch' }}</DialogTitle>
          </DialogHeader>
          <form @submit.prevent="saveBranch" class="space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label>Branch Code</Label>
              <Input v-model="form.code" type="text" required placeholder="e.g. BR001" />
            </div>
            <div class="space-y-2">
              <Label>Name</Label>
              <Input v-model="form.name" type="text" required placeholder="e.g. Main Street Cafe" />
            </div>
          </div>

          <div class="space-y-2">
            <Label>Location / Address</Label>
            <Input v-model="form.location" type="text" placeholder="e.g. 123 Main St, City" />
          </div>

          <div class="space-y-2">
            <Label>Phone</Label>
            <Input v-model="form.phone" type="tel" placeholder="e.g. 012-345-6789" />
          </div>

          <!-- Geolocation Section -->
          <div class="pt-4 border-t border-neutral-200 dark:border-neutral-700">
            <div class="flex items-center justify-between mb-3">
              <h4 class="text-sm font-semibold text-neutral-900 dark:text-white">GPS Location</h4>
              <Button
                type="button"
                variant="link"
                size="sm"
                @click="getCurrentLocation"
                :disabled="gettingLocation"
              >
                <LoaderCircleIcon v-if="gettingLocation" class="w-3 h-3 animate-spin" />
                <CrosshairIcon v-else class="w-3 h-3" />
                {{ gettingLocation ? 'Getting...' : 'Use Current Location' }}
              </Button>
            </div>
            <p class="text-xs text-neutral-500 mb-3">Click on map or drag marker to set location</p>
            
            <!-- Interactive Map Picker -->
            <ClientOnly>
              <CustomMapPicker 
                v-model="mapLocation"
                :radius="form.radiusMeters"
                class="mb-4"
              />
            </ClientOnly>
            
            <div class="grid grid-cols-3 gap-3">
              <div>
                <label class="text-xs text-neutral-500 mb-1 block">Latitude</label>
                <Input
                  :modelValue="form.latitude === null ? '' : form.latitude"
                  @update:modelValue="(v: any) => form.latitude = v === '' || v === null ? null : Number(v)"
                  type="number"
                  step="0.000001"
                  class="text-sm py-2"
                  placeholder="11.5564"
                />
              </div>
              <div>
                <label class="text-xs text-neutral-500 mb-1 block">Longitude</label>
                <Input
                  :modelValue="form.longitude === null ? '' : form.longitude"
                  @update:modelValue="(v: any) => form.longitude = v === '' || v === null ? null : Number(v)"
                  type="number"
                  step="0.000001"
                  class="text-sm py-2"
                  placeholder="104.9282"
                />
              </div>
              <div>
                <label class="text-xs text-neutral-500 mb-1 block">Radius (m)</label>
                <Input
                  v-model.number="form.radiusMeters"
                  type="number"
                  min="10"
                  max="1000"
                  class="text-sm py-2"
                  placeholder="100"
                />
              </div>
            </div>
          </div>

          <DialogFooter>
            <Button variant="secondary" @click="showModal = false">Cancel</Button>
            <Button type="submit" :disabled="saving" variant="default">
              <span v-if="saving" class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
              {{ isEditing ? 'Save Changes' : 'Create Branch' }}
            </Button>
          </DialogFooter>
        </form>
        </DialogContent>
      </Dialog>

      <AlertDialog v-model:open="showDeleteModal">
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Branch</AlertDialogTitle>
            <AlertDialogDescription>Are you sure you want to delete <span class="font-bold text-neutral-900 dark:text-white">{{ branchToDelete?.name }}</span>? This action cannot be undone.</AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction :disabled="deleting" @click="deleteBranch">
              <span v-if="deleting" class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { PlusIcon, StoreIcon, PencilIcon, Trash2Icon, MapPinIcon, PhoneIcon, GlobeIcon, MapPinOffIcon, LoaderCircleIcon, CrosshairIcon } from '@lucide/vue'

definePageMeta({
  layout: false
})

interface Branch {
  branchId: number
  code: string
  name: string
  location: string
  phone: string
  latitude?: number
  longitude?: number
  radiusMeters?: number
}

const { get, post, put, del } = useApi()
const toast = useToast()

const branches = ref<Branch[]>([])
const loading = ref(true)
const saving = ref(false)
const deleting = ref(false)
const gettingLocation = ref(false)
const showModal = ref(false)
const showDeleteModal = ref(false)
const editId = ref<number | null>(null)
const branchToDelete = ref<Branch | null>(null)

const form = ref({
  code: '',
  name: '',
  location: '',
  phone: '',
  latitude: null as number | null,
  longitude: null as number | null,
  radiusMeters: 100
})

const isEditing = computed(() => !!editId.value)

// Two-way binding for map picker
const mapLocation = computed({
  get: () => ({
    lat: form.value.latitude,
    lng: form.value.longitude
  }),
  set: (val: { lat: number | null; lng: number | null }) => {
    form.value.latitude = val.lat
    form.value.longitude = val.lng
  }
})

const fetchBranches = async () => {
  loading.value = true
  try {
    const data = await get<Branch[]>('/branches')
    branches.value = data || []
  } catch (error) {
    console.error('Failed to fetch branches', error)
  } finally {
    loading.value = false
  }
}

const openAddModal = () => {
  editId.value = null
  form.value = { code: '', name: '', location: '', phone: '', latitude: null, longitude: null, radiusMeters: 100 }
  showModal.value = true
}

const openEditModal = (branch: Branch) => {
  editId.value = branch.branchId
  form.value = { 
    code: branch.code,
    name: branch.name,
    location: branch.location || '',
    phone: branch.phone || '',
    latitude: branch.latitude || null,
    longitude: branch.longitude || null,
    radiusMeters: branch.radiusMeters || 100
  }
  showModal.value = true
}

const confirmDelete = (branch: Branch) => {
  branchToDelete.value = branch
  showDeleteModal.value = true
}

const getCurrentLocation = () => {
  if (!navigator.geolocation) {
    toast.error('Geolocation is not supported by your browser')
    return
  }
  
  gettingLocation.value = true
  navigator.geolocation.getCurrentPosition(
    (position) => {
      form.value.latitude = position.coords.latitude
      form.value.longitude = position.coords.longitude
      gettingLocation.value = false
    },
    (error) => {
      console.error('Geolocation error:', error)
      toast.error('Unable to get your location. Please enter coordinates manually.')
      gettingLocation.value = false
    },
    { enableHighAccuracy: true, timeout: 10000 }
  )
}

const saveBranch = async () => {
  saving.value = true
  try {
    const payload = {
      ...form.value,
      latitude: form.value.latitude || undefined,
      longitude: form.value.longitude || undefined
    }
    
    if (isEditing.value) {
      await put(`/branches/update/${editId.value}`, payload)
    } else {
      await post('/branches/add', payload)
    }
    await fetchBranches()
    showModal.value = false
  } catch (error) {
    console.error('Failed to save branch', error)
  } finally {
    saving.value = false
  }
}

const deleteBranch = async () => {
  if (!branchToDelete.value) return
  deleting.value = true
  try {
    await put(`/branches/delete/${branchToDelete.value.branchId}`, {})
    await fetchBranches()
    showDeleteModal.value = false
  } catch (error) {
    console.error('Failed to delete branch', error)
  } finally {
    deleting.value = false
    branchToDelete.value = null
  }
}

onMounted(() => {
  fetchBranches()
})
</script>

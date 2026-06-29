<template>
  <NuxtLayout name="admin">
    <div class="space-y-6">
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbPage>Categories</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>

      <!-- Header -->
      <div class="flex items-center justify-between">
        <div>
          <h2 class="text-2xl font-bold text-neutral-900 dark:text-white">
            Category Management
          </h2>
          <p class="text-sm text-neutral-500 mt-1">
            Manage your product categories and hierarchy
          </p>
        </div>
        <Button @click="openCreateModal">
          <PlusIcon class="w-4 h-4" />
          Add Category
        </Button>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="space-y-4">
        <div v-for="i in 3" :key="i" class="h-16 bg-neutral-100 dark:bg-neutral-800 rounded-lg animate-pulse" />
      </div>

      <!-- Empty -->
      <div v-else-if="categories.length === 0" class="text-center py-12 bg-white dark:bg-neutral-900 rounded-xl border border-neutral-200 dark:border-neutral-800">
        <div class="w-16 h-16 bg-neutral-100 dark:bg-neutral-800 rounded-full flex items-center justify-center mx-auto mb-4">
          <BookOpenIcon class="w-8 h-8 text-neutral-400" />
        </div>
        <h3 class="text-lg font-medium text-neutral-900 dark:text-white">
          No categories found
        </h3>
        <p class="text-neutral-500 mt-1">
          Get started by creating your first category.
        </p>
        <Button variant="link" class="mt-4" @click="openCreateModal">
          Create Category
        </Button>
      </div>

      <!-- Category Tree -->
      <div v-else class="bg-white dark:bg-neutral-900 rounded-xl border border-neutral-200 dark:border-neutral-800 p-6">
        <div class="space-y-2">
          <CategoryTreeItem
            v-for="category in categories"
            :key="category.categoryId"
            :category="category"
            @edit="openEditModal"
            @delete="confirmDelete"
          />
        </div>
      </div>

      <!-- Create/Edit Dialog -->
      <Dialog v-model:open="showModal">
        <DialogContent class="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>{{ isEditing ? "Edit Category" : "New Category" }}</DialogTitle>
          </DialogHeader>
          <form @submit.prevent="saveCategory" class="space-y-4">
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2">
                <Label for="name">🇺🇸 Name <span class="text-error-500">*</span></Label>
                <Input id="name" v-model="form.name" required placeholder="e.g. Beverages" />
              </div>
              <div class="space-y-2">
                <Label for="nameKh">🇰🇭 Khmer Name</Label>
                <Input id="nameKh" v-model="form.nameKh" placeholder="ឧទាហរណ៍៖ ភេសជ្ជៈ" class="font-khmer" />
              </div>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2">
                <Label for="desc">🇺🇸 Description</Label>
                <Textarea id="desc" v-model="form.description" placeholder="Optional description..." />
              </div>
              <div class="space-y-2">
                <Label for="descKh">🇰🇭 Khmer Description</Label>
                <Textarea id="descKh" v-model="form.descriptionKh" placeholder="ព័ត៌មានលម្អិត..." class="font-khmer" />
              </div>
            </div>
            <div class="space-y-2">
              <Label>Parent Category</Label>
              <Select v-model="selectedParentId">
                <SelectTrigger>
                  <SelectValue placeholder="None (Root Category)" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="root">None (Root Category)</SelectItem>
                  <SelectItem
                    v-for="cat in flattenedCategories"
                    :key="cat.id"
                    :value="String(cat.id)"
                    :disabled="isEditing && (cat.id === currentId || isDescendant(cat.id, currentId))"
                  >
                    {{ cat.name }}
                  </SelectItem>
                </SelectContent>
              </Select>
              <p v-if="isEditing" class="text-xs text-neutral-500 mt-1">Cannot select itself or its descendants as parent.</p>
            </div>
          </form>
          <DialogFooter>
            <Button variant="secondary" @click="closeModal">Cancel</Button>
            <Button type="submit" :disabled="saving" variant="default" @click="saveCategory">{{ saving ? "Saving..." : isEditing ? "Update" : "Create" }}</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <!-- Delete Confirmation -->
      <AlertDialog v-model:open="showDeleteAlert">
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Category</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to delete <strong>{{ categoryToDelete?.name }}</strong> and all its sub-categories? This action cannot be undone.
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
import { ref, reactive, computed, onMounted } from "vue"
import { PlusIcon, BookOpenIcon } from "@lucide/vue"
import CategoryTreeItem from "~/components/admin/CategoryTreeItem.vue"

definePageMeta({
  layout: false,
})

const { get, post, put, del } = useApi()
const toast = useToast()

interface Category {
  categoryId: number
  name: string
  nameKh?: string
  description?: string
  descriptionKh?: string
  parentId?: number
  children?: Category[]
}

const categories = ref<Category[]>([])
const loading = ref(true)
const showModal = ref(false)
const isEditing = ref(false)
const saving = ref(false)
const currentId = ref<number | null>(null)
const showDeleteAlert = ref(false)
const categoryToDelete = ref<Category | null>(null)
const selectedParentId = ref("root")

const form = reactive({
  name: "",
  nameKh: "",
  description: "",
  descriptionKh: "",
})

const fetchCategories = async () => {
  loading.value = true
  try {
    const data = await get<Category[]>("/categories")
    categories.value = data || []
  } catch (err) {
    console.error(err)
    toast.error("Failed to load categories")
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchCategories()
})

const flattenedCategories = computed(() => {
  const result: { id: number; name: string; parentId?: number }[] = []

  const traverse = (cats: Category[], prefix = "") => {
    for (const cat of cats) {
      result.push({
        id: cat.categoryId,
        name: prefix + cat.name,
        parentId: cat.parentId,
      })
      if (cat.children && cat.children.length > 0) {
        traverse(cat.children, prefix + "— ")
      }
    }
  }

  traverse(categories.value)
  return result
})

const isDescendant = (childId: number, potentialAncestorId: number | null): boolean => {
  if (!potentialAncestorId) return false
  if (childId === potentialAncestorId) return true

  const findChildrenIds = (cats: Category[], targetId: number): number[] => {
    let ids: number[] = []
    for (const cat of cats) {
      if (cat.categoryId === targetId) {
        const collectIds = (c: Category[]) => {
          for (const child of c) {
            ids.push(child.categoryId)
            if (child.children) collectIds(child.children)
          }
        }
        if (cat.children) collectIds(cat.children)
        return ids
      }
      if (cat.children) {
        const found = findChildrenIds(cat.children, targetId)
        if (found.length > 0) return found
      }
    }
    return ids
  }

  const descendants = findChildrenIds(categories.value, potentialAncestorId)
  return descendants.includes(childId)
}

const openCreateModal = () => {
  isEditing.value = false
  currentId.value = null
  form.name = ""
  form.nameKh = ""
  form.description = ""
  form.descriptionKh = ""
  selectedParentId.value = "root"
  showModal.value = true
}

const openEditModal = (category: Category) => {
  isEditing.value = true
  currentId.value = category.categoryId
  form.name = category.name
  form.nameKh = category.nameKh || ""
  form.description = category.description || ""
  form.descriptionKh = category.descriptionKh || ""
  selectedParentId.value = category.parentId ? String(category.parentId) : "root"
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
}

const confirmDelete = (id: number) => {
  categoryToDelete.value = categories.value.find(c => findInTree(c, id)) || null
  showDeleteAlert.value = true
}

const findInTree = (cat: Category, id: number): boolean => {
  if (cat.categoryId === id) return true
  if (cat.children) return cat.children.some(c => findInTree(c, id))
  return false
}

const executeDelete = async () => {
  if (!categoryToDelete.value) return
  try {
    await del(`/categories/${categoryToDelete.value.categoryId}`)
    toast.success("Category deleted")
    await fetchCategories()
  } catch (err) {
    console.error(err)
    toast.error("Failed to delete category")
  } finally {
    showDeleteAlert.value = false
    categoryToDelete.value = null
  }
}

const saveCategory = async () => {
  if (!form.name) return

  saving.value = true
  try {
    const payload = {
      ...form,
      parentId: selectedParentId.value === "root" ? null : Number(selectedParentId.value),
    }

    if (isEditing.value && currentId.value) {
      await put(`/categories/${currentId.value}`, payload)
      toast.success("Category updated")
    } else {
      await post("/categories/add", payload)
      toast.success("Category created")
    }

    await fetchCategories()
    closeModal()
  } catch (err) {
    console.error(err)
    toast.error("Failed to save category")
  } finally {
    saving.value = false
  }
}
</script>

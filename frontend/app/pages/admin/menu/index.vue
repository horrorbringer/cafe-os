<template>
  <NuxtLayout name="admin">
    <div class="space-y-6 relative">
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbPage>Menu</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>

      <!-- Header with Stats -->
      <div class="flex items-center justify-between">
        <div>
          <h2 class="text-2xl font-bold text-neutral-900 dark:text-white">
            Menu Management
          </h2>
          <p class="text-sm text-neutral-500 mt-1" v-if="!loading">
            {{ filteredItems.length }} of {{ menuItems.length }} items
            <span v-if="filterCategory" class="text-primary-600"
              >• Filtered by category</span
            >
          </p>
        </div>
        <div class="flex items-center gap-3">
          <!-- Export/Import Actions -->
          <div class="flex items-center gap-2">
            <Button variant="ghost" size="icon" @click="downloadMenu('excel')" title="Export Menu as Excel">
              <DownloadIcon class="w-5 h-5" />
            </Button>
            <Button variant="ghost" size="icon" @click="triggerFileInput" title="Bulk Import Menu Items">
              <UploadIcon class="w-5 h-5" />
            </Button>
            <input type="file" ref="fileInput" class="hidden" accept=".xlsx,.csv" @change="onFileChange" />
          </div>

          <Button @click="openCreateModal">
            <PlusIcon class="w-4 h-4" />
            Add Item
          </Button>
        </div>
      </div>

      <!-- Filters with Quick Stats -->
      <div
        class="bg-white dark:bg-neutral-900 p-4 rounded-xl border border-neutral-200 dark:border-neutral-800 shadow-sm"
      >
        <div
          class="flex flex-col lg:flex-row items-start lg:items-center gap-4"
        >
          <!-- Search -->
          <div class="relative flex-1 w-full lg:max-w-md">
            <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-400" />
            <Input v-model="searchQuery" placeholder="Search menu items..." class="pl-10 pr-10" />
            <button
              v-if="searchQuery"
              @click="searchQuery = ''"
              class="absolute right-3 top-1/2 -translate-y-1/2 text-neutral-400 hover:text-neutral-600"
            >
              <XIcon class="w-4 h-4" />
            </button>
          </div>

          <!-- Category Filter -->
          <div class="flex items-center gap-3 w-full lg:w-auto">
            <Select v-model="filterCategory">
              <SelectTrigger class="min-w-[200px]">
                <SelectValue placeholder="All Categories" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="">All Categories</SelectItem>
                <SelectItem v-for="cat in flattenedCategories" :key="cat.id" :value="String(cat.id)">
                  {{ cat.name }}
                </SelectItem>
              </SelectContent>
            </Select>

            <!-- View Toggle -->
            <Tabs v-model="viewMode">
              <TabList class="bg-neutral-100 dark:bg-neutral-800">
                <TabTrigger value="grid" title="Grid View">
                  <LayoutGridIcon class="w-4 h-4" />
                </TabTrigger>
                <TabTrigger value="list" title="List View">
                  <ListIcon class="w-4 h-4" />
                </TabTrigger>
              </TabList>
            </Tabs>
          </div>
        </div>

        <!-- Quick Stats Bar -->
        <div
          v-if="!loading"
          class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mt-4 pt-4 border-t border-neutral-200 dark:border-neutral-800"
        >
          <div class="flex items-center gap-4">
            <div class="flex items-center gap-2 text-xs">
              <div class="w-2 h-2 rounded-full bg-success-500"></div>
              <span class="text-neutral-600 dark:text-neutral-400"
                >{{ activeItemsCount }} Active</span
              >
            </div>
            <div class="flex items-center gap-2 text-xs">
              <div class="w-2 h-2 rounded-full bg-error-500"></div>
              <span class="text-neutral-600 dark:text-neutral-400"
                >{{ inactiveItemsCount }} Inactive</span
              >
            </div>
            <div class="flex items-center gap-2 text-xs">
              <div class="w-2 h-2 rounded-full bg-blue-500"></div>
              <span class="text-neutral-600 dark:text-neutral-400"
                >{{ categoriesCount }} Categories</span
              >
            </div>
          </div>

          <!-- Items Per Page Selector -->
          <div class="flex items-center gap-2">
            <Label class="text-xs">Show:</Label>
            <Select v-model="itemsPerPage">
              <SelectTrigger class="w-16 text-xs h-7">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="12">12</SelectItem>
                <SelectItem value="24">24</SelectItem>
                <SelectItem value="48">48</SelectItem>
                <SelectItem value="96">96</SelectItem>
              </SelectContent>
            </Select>
            <span class="text-xs text-neutral-600 dark:text-neutral-400">per page</span>
          </div>
        </div>
      </div>

      <!-- Loading State with Skeletons -->
      <div
        v-if="loading"
        :class="
          viewMode === 'grid'
            ? 'grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6'
            : 'space-y-3'
        "
      >
        <div
          v-for="i in 8"
          :key="i"
          class="bg-white dark:bg-neutral-900 rounded-xl border border-neutral-200 dark:border-neutral-800 overflow-hidden"
        >
          <div
            v-if="viewMode === 'grid'"
            class="h-48 bg-neutral-200 dark:bg-neutral-800 animate-pulse"
          ></div>
          <div class="p-4">
            <div
              class="h-4 bg-neutral-200 dark:bg-neutral-800 rounded animate-pulse mb-2"
            ></div>
            <div
              class="h-3 bg-neutral-200 dark:bg-neutral-800 rounded animate-pulse w-2/3"
            ></div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div
        v-else-if="filteredItems.length === 0"
        class="bg-white dark:bg-neutral-900 rounded-xl border border-neutral-200 dark:border-neutral-800 p-12 text-center"
      >
        <div
          class="w-20 h-20 mx-auto mb-4 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center"
        >
          <SearchXIcon class="w-10 h-10 text-neutral-400" />
        </div>
        <h3 class="text-lg font-semibold text-neutral-900 dark:text-white mb-2">
          No menu items found
        </h3>
        <p class="text-sm text-neutral-500 mb-4">
          {{
            searchQuery || filterCategory
              ? "Try adjusting your filters"
              : "Get started by adding your first menu item"
          }}
        </p>
        <Button
          v-if="!searchQuery && !filterCategory"
          @click="openCreateModal"
        >
          <PlusIcon class="w-4 h-4" />
          Add First Item
        </Button>
        <Button
          v-else
          variant="secondary"
          @click="clearFilters"
        >
          Clear Filters
        </Button>
      </div>

      <!-- Grid View -->
      <div
        v-else-if="viewMode === 'grid'"
        class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6"
      >
        <div
          v-for="item in paginatedItems"
          :key="item.menuItemId"
          class="bg-white dark:bg-neutral-900 rounded-xl border border-neutral-200 dark:border-neutral-800 overflow-hidden hover:shadow-xl hover:border-primary-500/50 transition-all duration-300 group cursor-pointer"
          @click="openEditModal(item)"
        >
          <div
            class="h-48 bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center relative overflow-hidden"
          >
            <img
              v-if="item.imageUrl"
              :src="item.imageUrl"
              :alt="item.name"
              loading="lazy"
              class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
            />
          <ImageIcon
            v-else
            class="w-12 h-12 text-neutral-300 transition-transform group-hover:scale-110"
          />

            <!-- Status Badge -->
            <div class="absolute top-2 right-2">
              <span
                :class="[
                  'px-2 py-1 rounded-lg text-xs font-bold uppercase tracking-wide backdrop-blur-md shadow-lg',
                  item.isAvailable
                    ? 'bg-success-500/90 text-white'
                    : 'bg-error-500/90 text-white',
                ]"
              >
                {{ item.isAvailable ? "Active" : "Inactive" }}
              </span>
            </div>
          </div>
          <div class="p-4">
            <div class="flex justify-between items-start mb-2">
              <h3
                class="font-semibold text-neutral-900 dark:text-white truncate pr-2 group-hover:text-primary-600 transition-colors"
                :title="item.name"
              >
                {{ item.name }}
              </h3>
              <span
                class="text-sm font-bold text-primary-600 dark:text-primary-400 whitespace-nowrap"
                >${{ item.basePrice.toFixed(2) }}</span
              >
            </div>
            <div
              class="flex items-center gap-2 text-xs text-neutral-500 dark:text-neutral-400 mb-4"
            >
              <FolderIcon class="w-3 h-3" />
              {{ item.category?.name || "Uncategorized" }}
            </div>

            <div class="flex items-center justify-between pt-3 border-t border-neutral-100 dark:border-neutral-800">
              <Button variant="ghost" size="sm" @click.stop="confirmDelete(item.menuItemId)" class="text-error-600 hover:text-error-700">
                <Trash2Icon class="w-3.5 h-3.5" />
                Delete
              </Button>
              <Button variant="ghost" size="sm" @click.stop="openEditModal(item)">
                Edit Details →
              </Button>
            </div>
          </div>
        </div>
      </div>

      <!-- List View -->
      <div
        v-else
        class="bg-white dark:bg-neutral-900 rounded-xl border border-neutral-200 dark:border-neutral-800 overflow-hidden"
      >
        <Table>
          <TableHeader
            class="bg-neutral-50 dark:bg-neutral-800/50 border-b border-neutral-200 dark:border-neutral-800"
          >
            <TableRow>
              <TableHead>
                Item
              </TableHead>
              <TableHead>
                Category
              </TableHead>
              <TableHead>
                Price
              </TableHead>
              <TableHead>
                Status
              </TableHead>
              <TableHead class="text-right">
                Actions
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow
              v-for="item in paginatedItems"
              :key="item.menuItemId"
              class="cursor-pointer"
              @click="openEditModal(item)"
            >
              <TableCell>
                <div class="flex items-center gap-3">
                  <div
                    class="w-12 h-12 rounded-lg bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center overflow-hidden flex-shrink-0"
                  >
                    <img
                      v-if="item.imageUrl"
                      :src="item.imageUrl"
                      :alt="item.name"
                      class="w-full h-full object-cover"
                      loading="lazy"
                    />
                    <ImageIcon
                      v-else
                      class="w-6 h-6 text-neutral-400"
                    />
                  </div>
                  <div class="min-w-0">
                    <div
                      class="font-semibold text-neutral-900 dark:text-white truncate"
                    >
                      {{ item.name }}
                    </div>
                  </div>
                </div>
              </TableCell>
              <TableCell>
                <span class="text-sm text-neutral-600 dark:text-neutral-400">{{
                  item.category?.name || "Uncategorized"
                }}</span>
              </TableCell>
              <TableCell>
                <span
                  class="text-sm font-bold text-neutral-900 dark:text-white font-mono"
                  >${{ item.basePrice.toFixed(2) }}</span
                >
              </TableCell>
              <TableCell>
                <span
                  :class="[
                    'px-2 py-1 rounded-lg text-xs font-bold uppercase tracking-wide',
                    item.isAvailable
                      ? 'bg-success-100 dark:bg-success-900/30 text-success-700 dark:text-success-400'
                      : 'bg-error-100 dark:bg-error-900/30 text-error-700 dark:text-error-400',
                  ]"
                >
                  {{ item.isAvailable ? "Active" : "Inactive" }}
                </span>
              </TableCell>
              <TableCell class="text-right">
                <div class="flex items-center justify-end gap-2">
                  <Button variant="ghost" size="sm" @click.stop="confirmDelete(item.menuItemId)" class="text-error-600">
                    <Trash2Icon class="w-3.5 h-3.5" />
                    Delete
                  </Button>
                  <Button variant="ghost" size="sm" @click.stop="openEditModal(item)">
                    Edit
                  </Button>
                </div>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </div>

      <!-- Pagination Controls -->
      <div
        v-if="!loading && filteredItems.length > 0 && totalPages > 1"
        class="flex flex-col sm:flex-row items-center justify-between gap-4 bg-white dark:bg-neutral-900 rounded-xl border border-neutral-200 dark:border-neutral-800 p-4"
      >
        <!-- Pagination Info -->
        <div class="text-sm text-neutral-600 dark:text-neutral-400">
          Showing
          <span class="font-bold text-neutral-900 dark:text-white">{{
            (currentPage - 1) * Number(itemsPerPage) + 1
          }}</span>
          to
          <span class="font-bold text-neutral-900 dark:text-white">{{
            Math.min(currentPage * Number(itemsPerPage), filteredItems.length)
          }}</span>
          of
          <span class="font-bold text-neutral-900 dark:text-white">{{
            filteredItems.length
          }}</span>
          items
        </div>

        <!-- Pagination Buttons -->
        <div class="flex items-center gap-2">
          <Button variant="outline" size="sm" @click="prevPage" :disabled="currentPage === 1" title="Previous Page">
            <ChevronLeftIcon class="w-4 h-4" />
          </Button>

          <div class="flex items-center gap-1">
            <Button
              v-if="pageNumbers[0]! > 1"
              variant="outline"
              size="sm"
              @click="goToPage(1)"
            >1</Button>
            <span v-if="pageNumbers[0]! > 2" class="text-neutral-400 px-1">...</span>

            <Button
              v-for="page in pageNumbers"
              :key="page"
              :variant="page === currentPage ? 'default' : 'outline'"
              size="sm"
              @click="goToPage(page)"
            >{{ page }}</Button>

            <span v-if="pageNumbers[pageNumbers.length - 1]! < totalPages - 1" class="text-neutral-400 px-1">...</span>
            <Button
              v-if="pageNumbers[pageNumbers.length - 1]! < totalPages"
              variant="outline"
              size="sm"
              @click="goToPage(totalPages)"
            >{{ totalPages }}</Button>
          </div>

          <Button variant="outline" size="sm" @click="nextPage" :disabled="currentPage === totalPages" title="Next Page">
            <ChevronRightIcon class="w-4 h-4" />
          </Button>
        </div>
      </div>

      <Dialog v-model:open="showModal">
        <DialogContent class="sm:max-w-2xl">
          <DialogHeader>
            <DialogTitle>{{ isEditing ? "Edit Menu Item" : "New Menu Item" }}</DialogTitle>
            <DialogDescription>{{ isEditing ? "Update item details and manage recipe" : "Add a new item to your menu" }}</DialogDescription>
          </DialogHeader>
          <div v-if="isEditing" class="flex gap-1 mb-6 p-1 bg-neutral-100 dark:bg-neutral-800 rounded-lg">
            <Button @click="activeModalTab = 'details'" :variant="activeModalTab === 'details' ? 'default' : 'ghost'" size="sm" class="flex-1">Details</Button>
            <Button @click="activeModalTab = 'recipe'" :variant="activeModalTab === 'recipe' ? 'default' : 'ghost'" size="sm" class="flex-1">Recipe ({{ recipes.length }})</Button>
            <Button @click="activeModalTab = 'variants'" :variant="activeModalTab === 'variants' ? 'default' : 'ghost'" size="sm" class="flex-1">Variants ({{ variants.length }})</Button>
          </div>
          <div v-if="activeModalTab === 'details'" class="space-y-4">
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2">
                <Label>Item Name <span class="text-error-500">*</span></Label>
                <Input v-model="form.name" type="text" required placeholder="e.g. Latte" />
              </div>
              <div class="space-y-2">
                <Label>Khmer Name</Label>
                <Input v-model="form.nameKh" type="text" placeholder="ឧទាហរណ៍៖ ឡាតេ" class="font-khmer" />
              </div>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2">
                <Label>Description</Label>
                <Textarea v-model="form.description" placeholder="Optional details..." />
              </div>
              <div class="space-y-2">
                <Label>Khmer Description</Label>
                <Textarea v-model="form.descriptionKh" placeholder="ព័ត៌មានលម្អិត..." class="font-khmer" />
              </div>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2">
                <Label>Category <span class="text-error-500">*</span></Label>
                <Select v-model="form.categoryId">
                  <SelectTrigger>
                    <SelectValue placeholder="Select category" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem v-for="cat in flattenedCategories" :key="cat.id" :value="String(cat.id)">{{ cat.name }}</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div class="space-y-2">
                <Label>Base Price ($) <span class="text-error-500">*</span></Label>
                <Input v-model="form.basePrice" type="number" step="0.01" min="0" required />
              </div>
            </div>
            <div><CustomImageUpload v-model="form.imageUrl" label="Item Image" /></div>
            <div class="flex items-center gap-3 p-4 bg-neutral-50 dark:bg-neutral-800 rounded-lg">
              <div class="flex items-center gap-3">
                <Switch v-model:checked="form.isAvailable" />
                <Label>Available for Sale</Label>
              </div>
              <div class="ml-auto">
                <span v-if="form.isAvailable" class="text-xs px-2 py-1 bg-success-100 dark:bg-success-900/30 text-success-700 dark:text-success-400 rounded-lg font-bold">ACTIVE</span>
                <span v-else class="text-xs px-2 py-1 bg-error-100 dark:bg-error-900/30 text-error-700 dark:text-error-400 rounded-lg font-bold">INACTIVE</span>
              </div>
            </div>
          </div>
          <div v-if="activeModalTab === 'recipe'">
            <AdminRecipeLinker :product-name="form.name || 'New Item'" :product-price="form.basePrice" :product-emoji="productEmoji" :linked="recipes" :available="ingredients" @add="handleAddRecipe" @remove="handleRemoveRecipe" @update-quantity="handleUpdateRecipeQty" />
          </div>
          <div v-if="activeModalTab === 'variants'" class="space-y-6">
            <div class="bg-neutral-50 dark:bg-neutral-800/50 p-4 rounded-xl border border-neutral-200 dark:border-neutral-800 space-y-3">
              <h4 class="text-sm font-semibold text-neutral-900 dark:text-white flex items-center gap-2">
                <PlusIcon class="w-4 h-4 text-primary-600" />
                Add Variant
              </h4>
              <div class="flex gap-3">
                <div class="flex-1">
                  <Select v-model="newVariant.name">
                    <SelectTrigger>
                      <SelectValue placeholder="Select Size" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="S">Small (S)</SelectItem>
                      <SelectItem value="M">Medium (M)</SelectItem>
                      <SelectItem value="L">Large (L)</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div class="w-32">
                  <Input v-model.number="newVariant.priceAdjustment" type="number" placeholder="Price (+/-)" step="0.5" />
                </div>
                <Button @click="addVariant" :disabled="!newVariant.name">Add</Button>
              </div>
              <div class="flex items-center justify-between text-xs text-neutral-600 dark:text-neutral-400 pt-2 border-t border-neutral-200 dark:border-neutral-700">
                <span>Base Price: <span class="font-bold font-mono">${{ form.basePrice.toFixed(2) }}</span></span>
                <span v-if="newVariant.priceAdjustment !== 0" class="font-bold text-primary-600">Final: <span class="font-mono">${{ (Number(form.basePrice) + Number(newVariant.priceAdjustment)).toFixed(2) }}</span></span>
              </div>
            </div>
            <div>
              <h4 class="text-sm font-semibold text-neutral-900 dark:text-white mb-3">Current Variants ({{ variants.length }})</h4>
              <div v-if="variants.length === 0" class="text-sm text-neutral-500 italic text-center py-8 bg-neutral-50 dark:bg-neutral-800/30 rounded-lg">
                <BoxIcon class="w-12 h-12 mx-auto mb-3 text-neutral-400" />
                <p>No variants added yet.</p>
                <p class="text-xs mt-1">Add size variants with price adjustments</p>
              </div>
              <div v-else class="space-y-2">
                <div v-for="variant in variants" :key="variant.variantId" class="flex items-center justify-between p-3 bg-white dark:bg-neutral-800/50 border border-neutral-100 dark:border-neutral-800 rounded-lg hover:border-primary-500/50 transition-colors">
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center text-blue-600 dark:text-blue-400">
                      <BoxIcon class="w-4 h-4" />
                    </div>
                    <div class="text-sm">
                      <div class="font-medium text-neutral-900 dark:text-white">{{ variant.name }}</div>
                      <div :class="variant.priceAdjustment >= 0 ? 'text-success-600' : 'text-error-600'" class="text-xs font-bold font-mono">{{ variant.priceAdjustment >= 0 ? "+" : "" }}${{ variant.priceAdjustment.toFixed(2) }} = ${{ (form.basePrice + variant.priceAdjustment).toFixed(2) }}</div>
                    </div>
                  </div>
                  <Button variant="ghost" size="icon" @click="removeVariant(variant.variantId)" title="Remove variant">
                    <XIcon class="w-4 h-4" />
                  </Button>
                </div>
              </div>
            </div>
          </div>
          <DialogFooter>
            <Button variant="secondary" @click="closeModal">Cancel</Button>
            <Button v-if="activeModalTab === 'details'" variant="default" :disabled="!form.name || !form.categoryId || form.basePrice <= 0" @click="saveItem">{{ isEditing ? "Save Changes" : "Create Item" }}</Button>
            <Button v-else variant="default" @click="closeModal">Done</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <AlertDialog v-model:open="showDeleteAlert">
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Menu Item</AlertDialogTitle>
            <AlertDialogDescription>Are you sure? This will delete the item and all its recipes and variants. This action cannot be undone.</AlertDialogDescription>
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
import { ref, computed, onMounted, reactive, watch } from "vue";
import {
  PlusIcon, DownloadIcon, UploadIcon, SearchIcon, XIcon,
  LayoutGridIcon, ListIcon, ChevronLeftIcon, ChevronRightIcon,
  Trash2Icon, ImageIcon, SearchXIcon, FolderIcon, BoxIcon
} from '@lucide/vue'

definePageMeta({
  layout: false,
});

const config = useRuntimeConfig();
const { get, post, put, del, download } = useApi();
const toast = useToast();

interface Category {
  categoryId: number;
  name: string;
  children?: Category[];
}

interface MenuItem {
  menuItemId: number;
  name: string;
  nameKh?: string;
  description: string;
  descriptionKh?: string;
  basePrice: number;
  imageUrl: string;
  isAvailable: boolean;
  categoryId: number;
  category?: Category;
}

interface Ingredient {
  ingredientId: number;
  name: string;
  unit: string;
  currentStock?: number | null;
  reorderLevel?: number | null;
  imageUrl?: string | null;
}

interface Recipe {
  recipeId: number;
  menuItemId: number;
  ingredientId: number;
  ingredientName: string;
  ingredientUnit: string;
  quantityNeeded: number;
}

interface Variant {
  variantId: number;
  menuItemId: number;
  name: string;
  priceAdjustment: number;
}

// State
const menuItems = ref<MenuItem[]>([]);
const categories = ref<Category[]>([]);
const ingredients = ref<Ingredient[]>([]);
const recipes = ref<Recipe[]>([]);
const variants = ref<Variant[]>([]);

const loading = ref(true);
const searchQuery = ref("");
const filterCategory = ref("");
const viewMode = ref<"grid" | "list">("grid");
const fileInput = ref<HTMLInputElement | null>(null);

// Pagination
const currentPage = ref(1);
const itemsPerPage = ref('12');

const showModal = ref(false);
const isEditing = ref(false);
const activeModalTab = ref("details");
const currentItemId = ref<number | null>(null);
const imageLoadError = ref(false);

// Form Data
const form = reactive({
  menuItemId: null as number | null,
  name: "",
  nameKh: "",
  description: "",
  descriptionKh: "",
  categoryId: null as string | null,
  basePrice: 0,
  imageUrl: "",
  isAvailable: true,
});

const newRecipe = reactive({
  ingredientId: null as number | null,
  quantityNeeded: 0,
});

const newVariant = reactive({
  name: "",
  priceAdjustment: 0,
});

// Watch for image URL changes to reset error state
watch(
  () => form.imageUrl,
  () => {
    imageLoadError.value = false;
  },
);

// Computed
const flattenedCategories = computed(() => {
  const result: { id: number; name: string }[] = [];

  const traverse = (cats: Category[], prefix = "") => {
    for (const cat of cats) {
      result.push({ id: cat.categoryId, name: prefix + cat.name });
      if (cat.children && cat.children.length > 0) {
        traverse(cat.children, prefix + "— ");
      }
    }
  };

  traverse(categories.value);
  return result;
});

const filteredItems = computed(() => {
  let result = menuItems.value;

  if (searchQuery.value) {
    const q = searchQuery.value.toLowerCase();
    result = result.filter(
      (item) =>
        item.name.toLowerCase().includes(q) ||
        item.category?.name.toLowerCase().includes(q),
    );
  }

  if (filterCategory.value) {
    // When filtering by a category, we might want to include sub-categories too.
    // But for now, let's stick to exact match or check if the implementation needs recursive matching.
    // If the backend filters by exact ID, we do exact ID.
    // If we want "Select Beverages -> Show all Coffees", we need recursive check.

    // Recursive check logic:
    const targetCatId = Number(filterCategory.value);

    // Helper to find all descendant IDs of a category
    const getDescendants = (cats: Category[], id: number): number[] => {
      let ids: number[] = [];
      for (const cat of cats) {
        if (cat.categoryId === id) {
          // Found it, collect all children
          const collect = (c: Category[]) => {
            for (const child of c) {
              ids.push(child.categoryId);
              if (child.children) collect(child.children);
            }
          };
          if (cat.children) collect(cat.children);
          return ids;
        }
        if (cat.children) {
          const found = getDescendants(cat.children, id);
          if (found.length > 0) return found;
        }
      }
      return ids;
    };

    const childIds = getDescendants(categories.value, targetCatId);
    const validIds = [targetCatId, ...childIds];

    result = result.filter(
      (item) =>
        item.category?.categoryId &&
        validIds.includes(item.category.categoryId),
    );
  }

  return result;
});

// Pagination computed properties
const totalPages = computed(() =>
  Math.ceil(filteredItems.value.length / Number(itemsPerPage.value)),
);
const paginatedItems = computed(() => {
  const perPage = Number(itemsPerPage.value)
  const start = (currentPage.value - 1) * perPage;
  const end = start + perPage;
  return filteredItems.value.slice(start, end);
});

const pageNumbers = computed<number[]>(() => {
  const pages = [];
  const maxVisiblePages = 5;
  let startPage = Math.max(
    1,
    currentPage.value - Math.floor(maxVisiblePages / 2),
  );
  let endPage = Math.min(totalPages.value, startPage + maxVisiblePages - 1);

  if (endPage - startPage < maxVisiblePages - 1) {
    startPage = Math.max(1, endPage - maxVisiblePages + 1);
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i);
  }

  return pages;
});

const activeItemsCount = computed(
  () => menuItems.value.filter((item) => item.isAvailable).length,
);
const inactiveItemsCount = computed(
  () => menuItems.value.filter((item) => !item.isAvailable).length,
);
const categoriesCount = computed(() => categories.value.length);

// Pagination methods
const goToPage = (page: number) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
    window.scrollTo({ top: 0, behavior: "smooth" });
  }
};

const nextPage = () => goToPage(currentPage.value + 1);
const prevPage = () => goToPage(currentPage.value - 1);

// Reset to page 1 when filters change
watch([searchQuery, filterCategory], () => {
  currentPage.value = 1;
});

// Clear filters
const clearFilters = () => {
  searchQuery.value = "";
  filterCategory.value = "";
  currentPage.value = 1;
};

// Fetch Data
const fetchMenu = async () => {
  loading.value = true;
  try {
    const data = await get<MenuItem[]>("/menu-items");
    menuItems.value = data || [];
  } catch (err) {
    console.error(err);
    toast.error("Failed to load menu items");
  } finally {
    loading.value = false;
  }
};

const fetchCategories = async () => {
  try {
    const data = await get<Category[]>("/categories");
    categories.value = data || [];
  } catch (err) {
    console.error(err);
  }
};

const fetchIngredients = async () => {
  try {
    const data = await get<Ingredient[]>("/ingredients");
    ingredients.value = data || [];
  } catch (err) {
    console.error(err);
  }
};

const fetchRecipes = async (menuItemId: number) => {
  try {
    const data = await get<Recipe[]>("/recipes/menu-item/" + menuItemId);
    recipes.value = data || [];
  } catch (err) {
    console.error(err);
  }
};

const fetchVariants = async (menuItemId: number) => {
  try {
    const data = await get<Variant[]>("/variants/menu-item/" + menuItemId);
    variants.value = data || [];
  } catch (err) {
    console.error(err);
  }
};

// Actions
const openCreateModal = () => {
  isEditing.value = false;
  activeModalTab.value = "details";
  currentItemId.value = null;
  imageLoadError.value = false;
  // Reset form
  form.name = "";
  form.nameKh = "";
  form.description = "";
  form.descriptionKh = "";

  form.categoryId =
    flattenedCategories.value[0]
      ? String(flattenedCategories.value[0].id)
      : null;

  form.basePrice = 0;
  form.imageUrl = "";
  form.isAvailable = true;

  showModal.value = true;
};

const openEditModal = async (item: MenuItem) => {
  isEditing.value = true;
  activeModalTab.value = "details";
  currentItemId.value = item.menuItemId;
  imageLoadError.value = false;

  // Fill form
  form.name = item.name;
  form.nameKh = item.nameKh || "";
  form.description = item.description || "";
  form.descriptionKh = item.descriptionKh || "";
  form.categoryId = item.category?.categoryId ? String(item.category.categoryId) : null;
  form.basePrice = item.basePrice;
  form.imageUrl = item.imageUrl;
  form.isAvailable = item.isAvailable;

  // Fetch recipes and variants for this item
  await Promise.all([
    fetchRecipes(item.menuItemId),
    fetchVariants(item.menuItemId),
    fetchIngredients(), // Ensure we have list
  ]);

  showModal.value = true;
};

const closeModal = () => {
  showModal.value = false;
};

const saveItem = async () => {
  if (!form.name || !form.categoryId || Number(form.basePrice) <= 0) {
    toast.error("Please fill in all required fields");
    return;
  }

  try {
    const payload = { ...form, categoryId: form.categoryId ? Number(form.categoryId) : null };

    if (isEditing.value && currentItemId.value) {
      await put(`/menu-items/${currentItemId.value}`, payload);
    } else {
      await post("/menu-items/add", payload);
    }

    await fetchMenu();

    // Invalidate POS cache so it re-fetches with the new image
    const posCache = useState<any[]>("pos-menu-items");
    const posCatCache = useState<any[]>("pos-categories");
    if (posCache.value) posCache.value = [];
    if (posCatCache.value) posCatCache.value = [];

    toast.success(isEditing.value ? "Menu item updated" : "Menu item created");
    closeModal(); // Always close on success (create or edit)
  } catch (err) {
    console.error(err);
    toast.error("Failed to save menu item");
  }
};

const itemToDelete = ref<number | null>(null)
const showDeleteAlert = ref(false)

const confirmDelete = (id: number) => {
  itemToDelete.value = id
  showDeleteAlert.value = true
}

const executeDelete = async () => {
  if (itemToDelete.value === null) return
  try {
    await del(`/menu-items/${itemToDelete.value}`)
    toast.success('Menu item deleted')
    fetchMenu()
  } catch (err) {
    toast.error('Failed to delete menu item')
  } finally {
    showDeleteAlert.value = false
    itemToDelete.value = null
  }
}

const productEmoji = computed(() => {
  const name = form.name?.toLowerCase() || '';
  if (name.includes('coffee') || name.includes('latte') || name.includes('cappuccino') || name.includes('espresso') || name.includes('mocha') || name.includes('americano')) return '☕';
  if (name.includes('tea') || name.includes('chai') || name.includes('matcha')) return '🍵';
  if (name.includes('smoothie') || name.includes('shake') || name.includes('frappe')) return '🥤';
  if (name.includes('juice') || name.includes('lemonade')) return '🧃';
  if (name.includes('water') || name.includes('sparkling')) return '💧';
  if (name.includes('pastry') || name.includes('croissant') || name.includes('muffin') || name.includes('cake')) return '🥐';
  if (name.includes('sandwich') || name.includes('toast') || name.includes('bagel')) return '🥪';
  if (name.includes('cookie') || name.includes('biscuit')) return '🍪';
  if (name.includes('ice cream') || name.includes('gelato')) return '🍦';
  if (name.includes('salad') || name.includes('bowl')) return '🥗';
  return '☕';
});

const handleAddRecipe = async (ingredientId: number, quantityNeeded: number) => {
  if (!currentItemId.value) {
    toast.error("Save the item first before adding ingredients");
    return;
  }
  try {
    await post("/recipes", {
      menuItemId: currentItemId.value,
      ingredientId,
      quantityNeeded,
    });
    await fetchRecipes(currentItemId.value);
    toast.success("Ingredient linked");
  } catch (err) {
    console.error(err);
    toast.error("Failed to link ingredient");
  }
};

const handleRemoveRecipe = async (recipeId: number) => {
  if (!currentItemId.value) return;
  try {
    await del(`/recipes/${recipeId}`);
    toast.success("Ingredient unlinked");
    await fetchRecipes(currentItemId.value);
  } catch (err) {
    console.error(err);
    toast.error("Failed to unlink ingredient");
  }
};

const handleUpdateRecipeQty = async (recipeId: number, quantity: number) => {
  if (!currentItemId.value) return
  try {
    await put(`/recipes/${recipeId}`, { quantityNeeded: quantity });
    await fetchRecipes(currentItemId.value);
  } catch (err) {
    console.error(err);
    toast.error("Failed to update quantity");
  }
};

const removeRecipe = async (recipeId: number) => {
  if (!currentItemId.value) return;
  try {
    await del(`/recipes/${recipeId}`);
    toast.success("Ingredient removed from recipe");
    await fetchRecipes(currentItemId.value);
  } catch (err) {
    toast.error("Failed to remove ingredient");
  }
};

const addVariant = async () => {
  if (!newVariant.name || !currentItemId.value) {
    toast.error("Please select a variant size");
    return;
  }

  try {
    await post("/variants", {
      menuItemId: currentItemId.value,
      name: newVariant.name,
      priceAdjustment: newVariant.priceAdjustment,
    });

    // Refresh variants
    await fetchVariants(currentItemId.value);

    // Reset sub-form
    newVariant.name = "";
    newVariant.priceAdjustment = 0;
    toast.success("Variant added");
  } catch (err) {
    console.error(err);
    toast.error("Failed to add variant");
  }
};

const removeVariant = async (variantId: number) => {
  if (!currentItemId.value) return;
  try {
    await del(`/variants/${variantId}`);
    toast.success("Variant removed");
    await fetchVariants(currentItemId.value);
  } catch (err) {
    toast.error("Failed to remove variant");
  }
};

// Load view mode from localStorage
onMounted(() => {
  const savedViewMode = localStorage.getItem("menuViewMode");
  if (savedViewMode === "list" || savedViewMode === "grid") {
    viewMode.value = savedViewMode;
  }

  const savedItemsPerPage = localStorage.getItem("menuItemsPerPage");
  if (savedItemsPerPage) {
    const parsed = parseInt(savedItemsPerPage);
    if ([12, 24, 48, 96].includes(parsed)) {
      itemsPerPage.value = String(parsed);
    }
  }

  fetchMenu();
  fetchCategories();
  fetchIngredients();
});

// Save view mode to localStorage
watch(viewMode, (newMode) => {
  localStorage.setItem("menuViewMode", newMode);
});

// Save items per page to localStorage
watch(itemsPerPage, (newValue: string) => {
  localStorage.setItem("menuItemsPerPage", newValue.toString());
  currentPage.value = 1; // Reset to first page when changing items per page
});

const downloadMenu = (format: "excel" | "csv") => {
  const endpoint = `/api/import-export/export/menu-items/${format}`;
  download(endpoint, `menu_items.${format === "excel" ? "xlsx" : "csv"}`);
};

const triggerFileInput = () => {
  fileInput.value?.click();
};

const onFileChange = async (event: any) => {
  const file = event.target.files[0];
  if (!file) return;

  loading.value = true;
  const formData = new FormData();
  formData.append("file", file);

  try {
    await $fetch(
      config.public.apiBase + "/api/import-export/import/menu-items",
      {
        method: "POST",
        body: formData,
        headers: {
          Authorization: "Bearer " + useCookie("auth_token").value,
        },
      },
    );

    toast.success("Menu items imported successfully!");
    fetchMenu();
  } catch (err: any) {
    console.error(err);
    toast.error(err.response?._data?.message || "Import failed");
  } finally {
    loading.value = false;
    if (fileInput.value) fileInput.value.value = "";
  }
};
</script>

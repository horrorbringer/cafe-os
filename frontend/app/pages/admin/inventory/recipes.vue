<template>
  <NuxtLayout name="admin">
    <Breadcrumb>
      <BreadcrumbList>
        <BreadcrumbItem>
          <BreadcrumbLink href="/admin/inventory">Inventory</BreadcrumbLink>
        </BreadcrumbItem>
        <BreadcrumbSeparator />
        <BreadcrumbItem>
          <BreadcrumbPage>Recipes</BreadcrumbPage>
        </BreadcrumbItem>
      </BreadcrumbList>
    </Breadcrumb>

    <div class="h-[calc(100vh-180px)] flex gap-6 overflow-hidden mt-4">
      <!-- Left: Menu Item List -->
      <div class="w-[340px] flex-shrink-0 bg-white dark:bg-neutral-900 rounded-3xl border border-neutral-200 dark:border-neutral-800 shadow-sm flex flex-col overflow-hidden">
        <!-- Search Header -->
        <div class="p-4 border-b border-neutral-100 dark:border-neutral-800 space-y-2">
          <div class="relative">
            <SearchIcon class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-neutral-400" />
            <Input v-model="search" placeholder="Search menu items..." class="pl-10" />
          </div>
          <p class="text-[10px] font-bold text-neutral-400 uppercase tracking-widest">{{ filteredItems.length }} items</p>
        </div>

        <!-- Category Filter Pills -->
        <div class="px-3 pb-2 flex flex-wrap gap-1.5">
          <Button
            v-for="cat in ['', ...categories]"
            :key="cat"
            @click="selectedCategory = cat"
            :variant="selectedCategory === cat ? 'default' : 'ghost'"
            size="sm"
            class="text-[10px] font-bold uppercase tracking-wider"
          >{{ cat || 'All' }}</Button>
        </div>

        <!-- Items List -->
        <div class="flex-1 overflow-y-auto p-3 space-y-1">
          <button
            v-for="item in filteredItems"
            :key="item.menuItemId"
            @click="selectItem(item)"
            class="w-full text-left p-3 rounded-2xl transition-all duration-200 group"
            :class="selectedItem?.menuItemId === item.menuItemId
              ? 'bg-primary-50 dark:bg-primary-900/20 border border-primary-200 dark:border-primary-800 shadow-sm'
              : 'hover:bg-neutral-50 dark:hover:bg-neutral-800/50 border border-transparent'"
          >
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-xl flex items-center justify-center text-sm font-black shadow-sm"
                :class="selectedItem?.menuItemId === item.menuItemId
                  ? 'bg-primary-500 text-white'
                  : 'bg-neutral-100 dark:bg-neutral-800 text-neutral-500 group-hover:bg-primary-100 group-hover:text-primary-600 dark:group-hover:bg-primary-900/30'"
              >
                {{ item.name?.charAt(0)?.toUpperCase() }}
              </div>
              <div class="flex-1 min-w-0">
                <div class="font-bold text-sm text-neutral-900 dark:text-white truncate">{{ item.name }}</div>
                <div class="text-[10px] text-neutral-500 font-bold uppercase tracking-wider">{{ item.categoryName || 'Uncategorized' }}</div>
              </div>
              <div class="text-xs font-mono font-bold text-neutral-500 bg-neutral-100 dark:bg-neutral-800 px-2 py-1 rounded-lg">
                ${{ item.basePrice?.toFixed(2) }}
              </div>
            </div>
          </button>

          <!-- Empty -->
          <div v-if="filteredItems.length === 0" class="flex flex-col items-center justify-center py-12 text-center">
            <div class="w-12 h-12 rounded-2xl bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center mb-3">
              <SearchXIcon class="w-6 h-6 text-neutral-300" />
            </div>
            <p class="text-sm font-bold text-neutral-400">No items found</p>
          </div>
        </div>
      </div>

      <!-- Right: Recipe Detail -->
      <div class="flex-1 bg-white dark:bg-neutral-900 rounded-3xl border border-neutral-200 dark:border-neutral-800 shadow-sm flex flex-col overflow-hidden">
        <!-- Selected Item View -->
        <div v-if="selectedItem" class="flex-1 flex flex-col h-full overflow-y-auto custom-scrollbar">
          <div class="p-5">
            <AdminRecipeLinker
              :product-name="selectedItem.name"
              :product-price="selectedItem.basePrice || 0"
              :product-emoji="productEmoji"
              :linked="recipes"
              :available="ingredients"
              @add="handleAddRecipe"
              @remove="handleRemoveRecipe"
              @update-quantity="handleUpdateRecipeQty"
            />
          </div>
        </div>

        <!-- Placeholder: No Item Selected -->
        <div v-else class="flex-1 flex flex-col items-center justify-center text-center p-12">
          <div class="w-24 h-24 rounded-3xl bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center mb-6">
            <ChefHatIcon class="w-12 h-12 text-neutral-300 dark:text-neutral-600" />
          </div>
          <h3 class="text-xl font-black text-neutral-900 dark:text-white mb-2">Select a Menu Item</h3>
          <p class="text-sm text-neutral-400 max-w-sm">Choose an item from the list to manage its recipe — the ingredients that get deducted when it's sold.</p>
        </div>
      </div>
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
import { SearchIcon, SearchXIcon, ChefHatIcon } from '@lucide/vue'

definePageMeta({
  layout: false
})

const { get, post, put, del } = useApi();
const toast = useToast();

const menuItems = ref<any[]>([]);
const search = ref('');
const selectedCategory = ref('');
const selectedItem = ref<any>(null);
const recipes = ref<any[]>([]);
const ingredients = ref<any[]>([]);

onMounted(async () => {
    try {
        const [itemsData, ingData] = await Promise.all([
            get<any[]>('/menu-items'),
            get<any[]>('/ingredients')
        ]);
        menuItems.value = itemsData || [];
        ingredients.value = ingData || [];
    } catch (e) {
        console.error(e);
        toast.error("Failed to load data");
    }
});

const categories = computed(() => {
    const cats = new Set<string>();
    menuItems.value.forEach(item => {
        if (item.categoryName) cats.add(item.categoryName);
    });
    return Array.from(cats).sort();
});

const filteredItems = computed(() => {
    let items = menuItems.value;
    if (selectedCategory.value) {
        items = items.filter(item => item.categoryName === selectedCategory.value);
    }
    if (search.value) {
        const q = search.value.toLowerCase();
        items = items.filter(item =>
            item.name.toLowerCase().includes(q) ||
            item.categoryName?.toLowerCase().includes(q)
        );
    }
    return items;
});

const productEmoji = computed(() => {
  const name = selectedItem.value?.name?.toLowerCase() || '';
  if (name.includes('coffee') || name.includes('latte') || name.includes('cappuccino') || name.includes('espresso') || name.includes('mocha') || name.includes('americano')) return '☕';
  if (name.includes('tea') || name.includes('chai') || name.includes('matcha')) return '🍵';
  if (name.includes('smoothie') || name.includes('shake') || name.includes('frappe')) return '🥤';
  if (name.includes('juice') || name.includes('lemonade')) return '🧃';
  if (name.includes('pastry') || name.includes('croissant') || name.includes('muffin') || name.includes('cake')) return '🥐';
  if (name.includes('sandwich') || name.includes('toast') || name.includes('bagel')) return '🥪';
  if (name.includes('cookie') || name.includes('biscuit')) return '🍪';
  if (name.includes('ice cream') || name.includes('gelato')) return '🍦';
  return '☕';
});

const selectItem = async (item: any) => {
    selectedItem.value = item;
    await fetchRecipes(item.menuItemId);
};

const fetchRecipes = async (menuItemId: number) => {
    try {
        const data = await get<any[]>(`/recipes/menu-item/${menuItemId}`);
        recipes.value = data || [];
    } catch (e) {
        console.error(e);
        toast.error("Failed to fetch recipes");
    }
};

const handleAddRecipe = async (ingredientId: number, quantityNeeded: number) => {
  if (!selectedItem.value) return;
  try {
    await post('/recipes', {
      menuItemId: selectedItem.value.menuItemId,
      ingredientId,
      quantityNeeded,
    });
    toast.success("Ingredient linked");
    fetchRecipes(selectedItem.value.menuItemId);
  } catch (e) {
    console.error(e);
    toast.error("Failed to link ingredient");
  }
};

const handleRemoveRecipe = async (recipeId: number) => {
  if (!selectedItem.value) return;
  try {
    await del(`/recipes/${recipeId}`);
    toast.success("Ingredient unlinked");
    fetchRecipes(selectedItem.value.menuItemId);
  } catch (e) {
    console.error(e);
    toast.error("Failed to unlink ingredient");
  }
};

const handleUpdateRecipeQty = async (recipeId: number, quantity: number) => {
  try {
    await put(`/recipes/${recipeId}`, { quantityNeeded: quantity });
    fetchRecipes(selectedItem.value.menuItemId);
  } catch (e) {
    console.error(e);
    toast.error("Failed to update quantity");
  }
};
</script>

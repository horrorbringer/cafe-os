<template>
  <div class="min-h-screen bg-neutral-50 dark:bg-neutral-950">
    <!-- Header -->
    <header class="sticky top-0 z-40 bg-white/80 dark:bg-neutral-900/80 backdrop-blur-xl border-b border-neutral-200/50 dark:border-neutral-800/50">
      <div class="max-w-lg mx-auto px-4 pt-3 pb-0">
        <div class="flex items-center justify-between gap-3">
          <div class="min-w-0">
            <h1 class="text-lg font-bold text-neutral-900 dark:text-white truncate">{{ branchInfo?.name || 'Menu' }}</h1>
            <p v-if="tableNo" class="text-[11px] text-primary-600 dark:text-primary-400 font-medium flex items-center gap-1 mt-0.5">
              <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
              Table {{ tableNo }}
            </p>
          </div>
          <div class="flex items-center gap-1 flex-shrink-0">
            <button
              @click="showSearch = !showSearch; if (!showSearch) searchQuery = ''"
              class="p-2.5 rounded-xl hover:bg-neutral-100 dark:hover:bg-neutral-800 transition-all"
              :class="showSearch ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-600' : 'text-neutral-500 dark:text-neutral-400'"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
            </button>
          </div>
        </div>

        <!-- Search bar -->
        <div v-if="showSearch" class="mt-3 mb-3 animate-slide-down">
          <div class="relative">
            <svg class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Search menu..."
              class="w-full pl-10 pr-4 py-2.5 rounded-xl bg-neutral-100 dark:bg-neutral-800 border-0 text-sm text-neutral-900 dark:text-white placeholder-neutral-400 focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
              autofocus
            />
            <button
              v-if="searchQuery"
              @click="searchQuery = ''"
              class="absolute right-3 top-1/2 -translate-y-1/2 p-0.5 text-neutral-400 hover:text-neutral-600 dark:hover:text-neutral-300 transition-colors"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
          </div>
        </div>
      </div>

      <!-- Category tabs -->
      <div v-if="categories.length > 0" class="max-w-lg mx-auto">
        <div class="flex overflow-x-auto scrollbar-hide px-4 gap-1.5 pb-3">
          <button
            v-for="cat in categories"
            :key="cat.categoryId"
            @click="activeCategory = cat.categoryId; scrollToCategory(cat.categoryId)"
            class="flex-shrink-0 px-3.5 py-1.5 rounded-full text-sm font-medium transition-all whitespace-nowrap"
            :class="activeCategory === cat.categoryId
              ? 'bg-primary-600 text-white shadow-md shadow-primary-500/25'
              : 'bg-neutral-100 dark:bg-neutral-800/70 text-neutral-500 dark:text-neutral-400 hover:bg-neutral-200 dark:hover:bg-neutral-700'"
          >
            {{ cat.name }}
          </button>
        </div>
      </div>
    </header>

    <!-- Loading state -->
    <div v-if="loading" class="max-w-lg mx-auto px-4 py-6">
      <div class="space-y-4">
        <div v-for="i in 6" :key="i" class="flex gap-3" :style="{ animationDelay: `${i * 100}ms` }">
          <div class="w-24 h-24 rounded-2xl skeleton-shimmer flex-shrink-0" />
          <div class="flex-1 space-y-2 py-2">
            <div class="h-4 skeleton-shimmer rounded w-3/4" />
            <div class="h-3 skeleton-shimmer rounded w-1/2" />
            <div class="h-4 skeleton-shimmer rounded w-1/4 mt-2" />
          </div>
        </div>
      </div>
    </div>

    <!-- Error state -->
    <div v-else-if="error" class="max-w-lg mx-auto px-4 py-20 text-center animate-fade-in">
      <div class="w-20 h-20 mx-auto mb-5 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center">
        <svg class="w-10 h-10 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
      </div>
      <h2 class="text-xl font-bold text-neutral-900 dark:text-white mb-2">Menu not found</h2>
      <p class="text-neutral-500 dark:text-neutral-400 max-w-xs mx-auto text-sm">This menu link may be invalid or the branch is currently unavailable.</p>
    </div>

    <!-- Menu content -->
    <main v-else class="max-w-lg mx-auto px-4 pt-4 pb-28">
      <!-- Active Order Badge -->
      <div v-if="activeOrderNo" class="mb-6 animate-slide-down">
        <NuxtLink
          :to="`/menu/${branchCode}/order/${activeOrderNo}`"
          class="flex items-center justify-between p-4 bg-gradient-to-r from-primary-50 to-primary-50/50 dark:from-primary-900/20 dark:to-primary-900/10 border border-primary-200 dark:border-primary-800 rounded-2xl group transition-all hover:from-primary-100 hover:to-primary-50 dark:hover:from-primary-900/30 dark:hover:to-primary-900/20"
        >
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-primary-600 flex items-center justify-center text-white shadow-lg shadow-primary-500/30">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
            </div>
            <div>
              <p class="text-[10px] font-bold text-primary-600 dark:text-primary-400 uppercase tracking-widest">Active Order</p>
              <p class="text-sm font-bold text-neutral-900 dark:text-white">#{{ activeOrderNo }}</p>
            </div>
          </div>
          <div class="flex items-center gap-2 text-primary-600 font-bold text-xs">
            View Status
            <svg class="w-4 h-4 transition-transform group-hover:translate-x-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
          </div>
        </NuxtLink>
      </div>

      <!-- Search results count -->
      <div v-if="showSearch && searchQuery" class="mb-4 animate-fade-in">
        <p class="text-sm text-neutral-500 dark:text-neutral-400">
          {{ filteredItems.length }} result{{ filteredItems.length !== 1 ? 's' : '' }}
        </p>
      </div>

      <!-- Category sections -->
      <div>
        <div
          v-for="(cat, catIdx) in categories"
          :key="cat.categoryId"
          :id="`cat-${cat.categoryId}`"
          class="mb-6"
          :class="{ 'animate-fade-in': !loading }"
        >
          <!-- Only show category header if has visible items or no search -->
          <div v-if="!showSearch || !searchQuery || getFilteredItems(cat.items).length > 0">
            <h2
              class="text-base font-bold text-neutral-900 dark:text-white mb-3 sticky bg-neutral-50/95 dark:bg-neutral-950/95 backdrop-blur-sm py-2 z-10"
              :style="{ top: headerOffset + 'px' }"
            >
              {{ cat.name }}
            </h2>
            <div class="space-y-3">
              <div
                v-for="(item, itemIdx) in (showSearch && searchQuery ? getFilteredItems(cat.items) : cat.items)"
                :key="item.menuItemId"
              >
                <MenuItemCard
                  :item="item"
                  :cartQty="cartQtyMap.get(item.menuItemId) || 0"
                  @add="openItemDetail(item)"
                />
              </div>
            </div>
            <!-- No results in this category -->
            <p
              v-if="showSearch && searchQuery && getFilteredItems(cat.items).length === 0"
              class="text-xs text-neutral-400 dark:text-neutral-500 text-center py-4"
            >
              No items found in this category
            </p>
          </div>
        </div>
      </div>

      <!-- Empty search -->
      <div v-if="showSearch && searchQuery && filteredItems.length === 0" class="py-16 text-center animate-fade-in">
        <div class="w-16 h-16 mx-auto mb-4 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center">
          <svg class="w-8 h-8 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
        </div>
        <p class="text-sm text-neutral-500 dark:text-neutral-400">No items match your search</p>
      </div>
    </main>

    <!-- Floating cart button -->
    <div v-if="itemCount > 0" class="fixed bottom-0 left-0 right-0 z-50">
      <div class="max-w-lg mx-auto px-4 pb-4">
        <NuxtLink
          :to="`/menu/${branchCode}/cart`"
          class="flex items-center justify-between w-full bg-primary-600 hover:bg-primary-700 text-white rounded-2xl px-5 py-3.5 shadow-2xl shadow-primary-500/30 transition-all hover:shadow-primary-500/50 hover:-translate-y-0.5 active:scale-[0.98] animate-slide-up"
        >
          <div class="flex items-center gap-3">
            <div class="bg-primary-500 rounded-xl px-2.5 py-1 text-sm font-bold min-w-[28px] text-center">{{ itemCount }}</div>
            <span class="font-semibold text-sm">View Cart</span>
          </div>
          <div class="flex items-center gap-2">
            <span class="font-bold text-base">${{ total.toFixed(2) }}</span>
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
          </div>
        </NuxtLink>
      </div>
    </div>

    <!-- Item detail modal -->
    <Teleport to="body">
      <Transition name="modal-overlay">
        <div
          v-if="selectedItem"
          class="fixed inset-0 bg-black/60 z-[60] flex items-end sm:items-center justify-center backdrop-blur-sm"
          @click.self="selectedItem = null"
        >
          <Transition name="modal">
            <div
              v-if="selectedItem"
              class="bg-white dark:bg-neutral-900 rounded-t-3xl sm:rounded-3xl w-full max-w-lg max-h-[90vh] overflow-y-auto shadow-2xl"
            >
              <!-- Drag handle (mobile) -->
              <div class="sticky top-0 z-10 flex justify-center pt-2 pb-1 bg-white dark:bg-neutral-900 sm:hidden">
                <div class="w-10 h-1 rounded-full bg-neutral-300 dark:bg-neutral-600" />
              </div>

              <!-- Item image -->
              <div v-if="selectedItem.imageUrl" class="relative h-56 -mt-3 sm:rounded-t-3xl overflow-hidden">
                <img :src="selectedItem.imageUrl" :alt="selectedItem.name" class="w-full h-full object-cover" />
                <div class="absolute inset-0 bg-gradient-to-t from-white/60 dark:from-neutral-900/60 to-transparent" />
                <button
                  @click="selectedItem = null"
                  class="absolute top-4 right-4 bg-black/30 backdrop-blur-md text-white p-2 rounded-full hover:bg-black/50 transition-all"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                </button>
              </div>
              <div v-else class="flex justify-end px-4 pt-2 pb-0">
                <button
                  @click="selectedItem = null"
                  class="p-2 rounded-full hover:bg-neutral-100 dark:hover:bg-neutral-800 transition-colors"
                >
                  <svg class="w-5 h-5 text-neutral-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                </button>
              </div>

              <div class="p-5 pt-4">
                <h3 class="text-xl font-bold text-neutral-900 dark:text-white">{{ selectedItem.name }}</h3>
                <p v-if="selectedItem.description" class="text-sm text-neutral-500 dark:text-neutral-400 mt-1.5 leading-relaxed">
                  {{ selectedItem.description }}
                </p>

                <!-- Price -->
                <div class="flex items-baseline gap-2 mt-3">
                  <span class="text-2xl font-bold text-primary-600 dark:text-primary-400">${{ selectedVariantPrice.toFixed(2) }}</span>
                  <span v-if="selectedItem.variants && selectedItem.variants.length > 0" class="text-xs text-neutral-400 dark:text-neutral-500">per item</span>
                </div>

                <hr class="my-5 border-neutral-100 dark:border-neutral-800" />

                <!-- Variant selection -->
                <div v-if="selectedItem.variants && selectedItem.variants.length > 0" class="mb-5">
                  <p class="text-sm font-semibold text-neutral-700 dark:text-neutral-300 mb-3">Choose Size</p>
                  <div class="grid grid-cols-2 gap-2.5">
                    <button
                      v-for="variant in selectedItem.variants"
                      :key="variant.variantId"
                      @click="selectedVariant = variant"
                      class="py-3 px-3 rounded-xl text-sm font-medium border-2 transition-all text-left"
                      :class="selectedVariant?.variantId === variant.variantId
                        ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300 ring-1 ring-primary-500/20'
                        : 'border-neutral-200 dark:border-neutral-700 text-neutral-600 dark:text-neutral-400 hover:border-neutral-300 dark:hover:border-neutral-600'"
                    >
                      <span class="font-bold block">{{ variant.size }}</span>
                      <span class="text-xs mt-0.5 opacity-70">${{ variant.price.toFixed(2) }}</span>
                    </button>
                  </div>
                </div>

                <!-- Add-ons -->
                <div v-if="availableAddOns.length > 0" class="mb-5">
                  <p class="text-sm font-semibold text-neutral-700 dark:text-neutral-300 mb-3">Add-ons</p>
                  <div class="space-y-2">
                    <label
                      v-for="addon in availableAddOns"
                      :key="addon.addOnId"
                      class="flex items-center justify-between p-3.5 rounded-xl border-2 transition-all cursor-pointer"
                      :class="selectedAddOns.includes(addon.addOnId)
                        ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20'
                        : 'border-neutral-200 dark:border-neutral-700 hover:border-neutral-300 dark:hover:border-neutral-600'"
                    >
                      <div class="flex items-center gap-3">
                        <div
                          class="w-5 h-5 rounded border-2 flex items-center justify-center transition-all"
                          :class="selectedAddOns.includes(addon.addOnId)
                            ? 'bg-primary-600 border-primary-600 text-white'
                            : 'border-neutral-300 dark:border-neutral-600'"
                        >
                          <svg v-if="selectedAddOns.includes(addon.addOnId)" class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"/></svg>
                        </div>
                        <span class="text-sm font-medium text-neutral-700 dark:text-neutral-300">{{ addon.name }}</span>
                      </div>
                      <span class="text-sm font-semibold text-neutral-500 dark:text-neutral-400">+${{ addon.price.toFixed(2) }}</span>
                    </label>
                  </div>
                </div>

                <!-- Note -->
                <div class="mb-5">
                  <p class="text-sm font-semibold text-neutral-700 dark:text-neutral-300 mb-3">Special Instructions</p>
                  <textarea
                    v-model="itemNote"
                    placeholder="e.g. Less sugar, no ice..."
                    rows="2"
                    class="w-full px-4 py-3 rounded-xl bg-neutral-100 dark:bg-neutral-800 border-0 text-sm text-neutral-900 dark:text-white placeholder-neutral-400 focus:outline-none focus:ring-2 focus:ring-primary-500 resize-none transition-all"
                  />
                </div>

                <!-- Quantity & Add button -->
                <div class="flex items-center gap-3 pt-2">
                  <div class="flex items-center bg-neutral-100 dark:bg-neutral-800 rounded-xl">
                    <button @click="modalQty = Math.max(1, modalQty - 1)" class="p-3 text-neutral-500 hover:text-neutral-900 dark:hover:text-white transition-colors">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4"/></svg>
                    </button>
                    <span class="w-10 text-center font-bold text-neutral-900 dark:text-white select-none">{{ modalQty }}</span>
                    <button @click="modalQty++" class="p-3 text-neutral-500 hover:text-neutral-900 dark:hover:text-white transition-colors">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
                    </button>
                  </div>
                  <button
                    @click="addToCart"
                    class="flex-1 bg-primary-600 hover:bg-primary-700 text-white py-3.5 rounded-xl font-semibold transition-all hover:shadow-lg hover:shadow-primary-500/25 active:scale-[0.98]"
                  >
                    Add to Cart — ${{ (selectedVariantPrice * modalQty + selectedAddOnsTotal * modalQty).toFixed(2) }}
                  </button>
                </div>
              </div>
            </div>
          </Transition>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'menu' })

const route = useRoute()
const branchCode = route.params.branchCode as string
const tableNo = (route.query.table as string) || ''

const { get } = usePublicApi()
const cart = useMenuCart()

// Set branch and table in cart
cart.branchCode.value = branchCode
if (tableNo) cart.tableNo.value = tableNo

// State
const loading = ref(true)
const error = ref(false)
const branchInfo = ref<any>(null)
const categories = ref<any[]>([])
const allItems = ref<any[]>([])
const availableAddOns = ref<any[]>([])
const activeCategory = ref<number | null>(null)
const showSearch = ref(false)
const searchQuery = ref('')
const selectedItem = ref<any>(null)
const selectedVariant = ref<any>(null)
const selectedAddOns = ref<number[]>([])
const itemNote = ref('')
const modalQty = ref(1)
const activeOrderNo = ref<string | null>(null)

// Derived
const { itemCount, total } = cart

const cartQtyMap = computed(() => {
  const map = new Map<number, number>()
  for (const item of cart.items.value) {
    map.set(item.menuItemId, (map.get(item.menuItemId) || 0) + item.qty)
  }
  return map
})

const filteredItems = computed(() => {
  if (!searchQuery.value) return allItems.value
  const q = searchQuery.value.toLowerCase()
  return allItems.value.filter(item =>
    item.name.toLowerCase().includes(q)
  )
})

const selectedVariantPrice = computed(() => {
  if (selectedVariant.value) return selectedVariant.value.price
  return selectedItem.value?.basePrice || 0
})

const selectedAddOnsTotal = computed(() => {
  return availableAddOns.value
    .filter(a => selectedAddOns.value.includes(a.addOnId))
    .reduce((sum, a) => sum + a.price, 0)
})

const headerOffset = ref(0)

onMounted(() => {
  fetchMenu()
  if (process.client) {
    updateHeaderOffset()
    window.addEventListener('resize', updateHeaderOffset)
  }
})

onUnmounted(() => {
  if (process.client) {
    window.removeEventListener('resize', updateHeaderOffset)
  }
})

function updateHeaderOffset() {
  const header = document.querySelector('header')
  if (header) {
    headerOffset.value = header.offsetHeight
  }
}

// Methods
const getFilteredItems = (items: any[]) => {
  if (!searchQuery.value) return items
  const q = searchQuery.value.toLowerCase()
  return items.filter((item: any) => item.name.toLowerCase().includes(q))
}

const scrollToCategory = (catId: number) => {
  const el = document.getElementById(`cat-${catId}`)
  if (el) {
    const header = document.querySelector('header')
    const offset = header ? header.offsetHeight : 0
    const top = el.getBoundingClientRect().top + window.scrollY - offset
    window.scrollTo({ top, behavior: 'smooth' })
  }
}

const openItemDetail = (item: any) => {
  selectedItem.value = { ...item }
  selectedVariant.value = item.variants?.[0] || null
  selectedAddOns.value = []
  itemNote.value = ''
  modalQty.value = 1
}

const toggleAddOn = (addonId: number) => {
  if (selectedAddOns.value.includes(addonId)) {
    selectedAddOns.value = selectedAddOns.value.filter(id => id !== addonId)
  } else {
    selectedAddOns.value.push(addonId)
  }
}

const addToCart = () => {
  if (!selectedItem.value) return

  const addOns = availableAddOns.value
    .filter(a => selectedAddOns.value.includes(a.addOnId))
    .map(a => ({ addOnId: a.addOnId, name: a.name, price: a.price }))

  cart.addItem({
    menuItemId: selectedItem.value.menuItemId,
    name: selectedItem.value.name,
    price: selectedItem.value.basePrice,
    imageUrl: selectedItem.value.imageUrl,
    qty: modalQty.value,
    note: itemNote.value || undefined,
    variantId: selectedVariant.value?.variantId,
    variantSize: selectedVariant.value?.size,
    variantPrice: selectedVariant.value?.price,
    addOns: addOns.length > 0 ? addOns : undefined,
    addOnTotal: addOns.reduce((sum, a) => sum + a.price, 0)
  })

  selectedItem.value = null
}

// Fetch menu data
const fetchMenu = async () => {
  try {
    loading.value = true
    error.value = false

    const [menuData, addOnsData] = await Promise.all([
      get<any>(`/public/branches/${branchCode}/menu`),
      get<any[]>('/public/addons')
    ])

    branchInfo.value = menuData.branch
    categories.value = menuData.categories || []

    // Collect all items for search
    allItems.value = categories.value.flatMap(c => c.items || [])
    availableAddOns.value = addOnsData || []

    if (categories.value.length > 0) {
      activeCategory.value = categories.value[0].categoryId
    }

    nextTick(() => updateHeaderOffset())
  } catch (e) {
    console.error('Failed to load menu:', e)
    error.value = true
  } finally {
    loading.value = false
  }

  // Check for active order
  if (process.client) {
    const savedOrder = localStorage.getItem('menu_active_order')
    const savedBranch = localStorage.getItem('menu_active_order_branch')
    if (savedOrder && savedBranch === branchCode) {
      activeOrderNo.value = savedOrder
    }
  }
}

// SEO
useHead({
  title: branchInfo.value?.name ? `${branchInfo.value.name} - Menu` : 'Menu'
})
</script>

<template>
  <div class="min-h-screen bg-neutral-50 dark:bg-neutral-950">
    <!-- Header -->
    <header class="sticky top-0 z-40 bg-white/80 dark:bg-neutral-900/80 backdrop-blur-xl border-b border-neutral-200/50 dark:border-neutral-800/50">
      <div class="max-w-lg mx-auto px-4 py-3">
        <div class="flex items-center gap-3">
          <NuxtLink
            :to="`/menu/${branchCode}${tableNo ? '?table=' + tableNo : ''}`"
            class="p-2 -ml-2 rounded-xl hover:bg-neutral-100 dark:hover:bg-neutral-800 transition-colors"
          >
            <svg class="w-5 h-5 text-neutral-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
          </NuxtLink>
          <div>
            <h1 class="text-lg font-bold text-neutral-900 dark:text-white">Your Order</h1>
            <p v-if="tableNo" class="text-[11px] text-primary-600 dark:text-primary-400 font-medium flex items-center gap-1 mt-0.5">
              <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
              Table {{ tableNo }}
            </p>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-lg mx-auto px-4 pt-4 pb-36">
      <!-- Empty cart -->
      <div v-if="items.length === 0" class="py-20 text-center animate-fade-in">
        <div class="w-20 h-20 mx-auto mb-5 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center">
          <svg class="w-10 h-10 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 100 4 2 2 0 000-4z"/></svg>
        </div>
        <h2 class="text-xl font-bold text-neutral-900 dark:text-white mb-2">Your cart is empty</h2>
        <p class="text-neutral-500 dark:text-neutral-400 mb-6 text-sm">Browse the menu to add items to your order</p>
        <NuxtLink
          :to="`/menu/${branchCode}${tableNo ? '?table=' + tableNo : ''}`"
          class="inline-flex items-center gap-2 bg-primary-600 hover:bg-primary-700 text-white px-5 py-3 rounded-xl font-semibold transition-all hover:shadow-lg hover:shadow-primary-500/25 active:scale-[0.98]"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
          Back to Menu
        </NuxtLink>
      </div>

      <!-- Cart items -->
      <div v-else class="space-y-3">
        <div
          v-for="(item, index) in items"
          :key="index"
          class="bg-white dark:bg-neutral-900 rounded-2xl p-4 border border-neutral-200/50 dark:border-neutral-800/50 animate-slide-up"
          :style="{ animationDelay: `${index * 80}ms` }"
        >
          <div class="flex gap-3">
            <!-- Image -->
            <div class="w-16 h-16 rounded-xl overflow-hidden bg-neutral-100 dark:bg-neutral-800 flex-shrink-0">
              <img v-if="item.imageUrl" :src="item.imageUrl" :alt="item.name" class="w-full h-full object-cover" loading="lazy" />
              <div v-else class="w-full h-full flex items-center justify-center text-neutral-300 dark:text-neutral-600">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
              </div>
            </div>

            <!-- Info -->
            <div class="flex-1 min-w-0">
              <div class="flex items-start justify-between">
                <div class="min-w-0">
                  <h3 class="font-semibold text-neutral-900 dark:text-white text-sm truncate">{{ item.name }}</h3>
                  <p v-if="item.variantSize" class="text-xs text-neutral-500 dark:text-neutral-400 mt-0.5">Size: {{ item.variantSize }}</p>
                  <p v-if="item.addOns && item.addOns.length" class="text-xs text-primary-500 dark:text-primary-400 mt-0.5 truncate">
                    + {{ item.addOns.map(a => a.name).join(', ') }}
                  </p>
                  <p v-if="item.note" class="text-xs text-neutral-400 italic mt-0.5 truncate">{{ item.note }}</p>
                </div>
                <button @click="removeItem(index)" class="p-1.5 text-neutral-400 hover:text-error-500 hover:bg-error-50 dark:hover:bg-error-900/20 rounded-lg transition-all flex-shrink-0 -mr-1">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                </button>
              </div>

              <div class="flex items-center justify-between mt-3">
                <div class="flex items-center bg-neutral-100 dark:bg-neutral-800 rounded-lg">
                  <button @click="updateQty(index, -1)" class="p-1.5 text-neutral-500 hover:text-neutral-900 dark:hover:text-white transition-colors">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4"/></svg>
                  </button>
                  <span class="w-7 text-center text-sm font-bold text-neutral-900 dark:text-white select-none">{{ item.qty }}</span>
                  <button @click="updateQty(index, 1)" class="p-1.5 text-neutral-500 hover:text-neutral-900 dark:hover:text-white transition-colors">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
                  </button>
                </div>
                <span class="font-bold text-sm text-neutral-900 dark:text-white">
                  ${{ ((item.variantPrice || item.price + item.addOnTotal) * item.qty).toFixed(2) }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Order note -->
        <div class="bg-white dark:bg-neutral-900 rounded-2xl p-4 border border-neutral-200/50 dark:border-neutral-800/50">
          <label class="text-sm font-semibold text-neutral-700 dark:text-neutral-300 mb-2 flex items-center gap-2">
            <svg class="w-4 h-4 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
            Order Notes
          </label>
          <textarea
            v-model="orderNote"
            placeholder="Any special requests for the whole order..."
            rows="2"
            class="w-full px-3 py-2.5 rounded-xl bg-neutral-100 dark:bg-neutral-800 border-0 text-sm text-neutral-900 dark:text-white placeholder-neutral-400 focus:outline-none focus:ring-2 focus:ring-primary-500 resize-none transition-all"
          />
        </div>

        <!-- Customer info (optional) -->
        <div class="bg-white dark:bg-neutral-900 rounded-2xl p-4 border border-neutral-200/50 dark:border-neutral-800/50">
          <label class="text-sm font-semibold text-neutral-700 dark:text-neutral-300 mb-2 flex items-center gap-2">
            <svg class="w-4 h-4 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
            Your Info <span class="text-neutral-400 font-normal">(Optional)</span>
          </label>
          <div class="flex gap-2">
            <input
              v-model="customerName"
              type="text"
              placeholder="Your name"
              class="w-full px-3.5 py-2.5 rounded-xl bg-neutral-100 dark:bg-neutral-800 border-0 text-sm text-neutral-900 dark:text-white placeholder-neutral-400 focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
            />
            <input
              v-model="customerPhone"
              type="tel"
              placeholder="Phone"
              class="w-full px-3.5 py-2.5 rounded-xl bg-neutral-100 dark:bg-neutral-800 border-0 text-sm text-neutral-900 dark:text-white placeholder-neutral-400 focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
            />
          </div>
        </div>

        <!-- Order summary -->
        <div class="bg-white dark:bg-neutral-900 rounded-2xl p-4 border border-neutral-200/50 dark:border-neutral-800/50">
          <div class="flex justify-between text-sm text-neutral-600 dark:text-neutral-400 mb-2">
            <span>Subtotal</span>
            <span>${{ subtotal.toFixed(2) }}</span>
          </div>
          <div class="flex justify-between text-base font-bold text-neutral-900 dark:text-white pt-3 border-t border-neutral-200/50 dark:border-neutral-800/50">
            <span>Total</span>
            <span class="text-primary-600 dark:text-primary-400">${{ total.toFixed(2) }}</span>
          </div>
          <p class="text-[11px] text-neutral-400 mt-2 text-center">Taxes calculated at checkout</p>
        </div>
      </div>
    </main>

    <!-- Place order button -->
    <div v-if="items.length > 0" class="fixed bottom-0 left-0 right-0 z-50">
      <div class="max-w-lg mx-auto px-4 pb-4">
        <div class="bg-gradient-to-t from-neutral-50 dark:from-neutral-950 via-neutral-50/90 dark:via-neutral-950/90 to-transparent pt-6 -mx-4 px-4">
          <button
            @click="placeOrder"
            :disabled="submitting"
            class="flex items-center justify-center w-full bg-primary-600 hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed text-white rounded-2xl px-6 py-4 shadow-2xl shadow-primary-500/30 transition-all hover:shadow-primary-500/50 active:scale-[0.98] font-semibold text-base"
          >
            <svg v-if="submitting" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
            </svg>
            {{ submitting ? 'Placing Order...' : `Place Order — $${total.toFixed(2)}` }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'menu' })

const route = useRoute()
const router = useRouter()
const branchCode = route.params.branchCode as string
const { items, tableNo, subtotal, total, removeItem, updateQty, clearCart } = useMenuCart()
const { post } = usePublicApi()
const toast = useToast()

const orderNote = ref('')
const customerName = ref('')
const customerPhone = ref('')
const submitting = ref(false)

const placeOrder = async () => {
  if (items.value.length === 0 || submitting.value) return

  try {
    submitting.value = true

    const orderItems = items.value.map(item => ({
      menuItemId: item.menuItemId,
      variantId: item.variantId || null,
      qty: item.qty,
      addonIds: item.addOns?.map(a => a.addOnId) || [],
      note: item.note || null
    }))

    const request = {
      branchCode,
      tableNo: tableNo.value || null,
      orderSource: 'QR_WEB',
      orderType: tableNo.value ? 'DINE_IN' : 'TAKEAWAY',
      note: orderNote.value || null,
      customerName: customerName.value || null,
      customerPhone: customerPhone.value || null,
      items: orderItems
    }

    const response = await post<any>('/public/orders', request)

    if (response?.orderNo) {
      if (process.client) {
        localStorage.setItem('menu_active_order', response.orderNo)
        localStorage.setItem('menu_active_order_branch', branchCode)
      }
      clearCart()
      toast.success('Check out success!', 2000)
      router.push(`/menu/${branchCode}/order/${response.orderNo}`)
    }
  } catch (e: any) {
    console.error('Order placement error:', e)
    
    // Handle validation errors (400 Bad Request)
    if (e.data && e.data.details) {
      // If we have a map of field errors, show them
      const errorMap = e.data.details
      const firstError = Object.values(errorMap)[0] as string
      toast.error(firstError || 'Validation failed. Please check your order.')
    } else if (e.data && e.data.message) {
      // General error message from backend
      toast.error(e.data.message)
    } else {
      // Network or unknown error
      toast.error('Failed to place order. Please try again.')
    }
  } finally {
    submitting.value = false
  }
}

useHead({ title: 'Your Order' })
</script>

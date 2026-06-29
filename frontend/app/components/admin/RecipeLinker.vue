<template>
  <div class="space-y-5">
    <!-- Product Hero -->
    <div
      ref="productRef"
      class="relative bg-gradient-to-br from-primary-50 to-primary-100/50 dark:from-primary-950/40 dark:to-primary-900/20 rounded-2xl border border-primary-200/50 dark:border-primary-800/30 p-4 overflow-hidden"
    >
      <div class="absolute -top-10 -right-10 w-32 h-32 bg-primary-500/5 rounded-full blur-[60px]"></div>
      <div class="flex items-center gap-4 relative z-10">
        <div class="w-14 h-14 rounded-2xl bg-gradient-to-br from-primary-600 to-primary-800 shadow-lg shadow-primary-500/20 flex items-center justify-center text-3xl flex-shrink-0 border-2 border-white/20">
          {{ productEmoji }}
        </div>
        <div class="flex-1 min-w-0">
          <h3 class="text-[17px] font-black text-neutral-900 dark:text-white tracking-tight truncate">{{ productName }}</h3>
          <p class="text-sm font-bold text-primary-600 dark:text-primary-400">${{ productPrice.toFixed(2) }}</p>
        </div>
        <div class="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-white/60 dark:bg-white/5 border border-primary-200/50 dark:border-primary-800/30">
          <span class="text-sm">⚡</span>
          <span class="text-xs font-bold text-neutral-600 dark:text-neutral-400">{{ linked.length }} linked</span>
        </div>
      </div>
    </div>

    <!-- Linking Canvas -->
    <div
      ref="canvasRef"
      class="relative rounded-2xl border-2 border-dashed min-h-[220px] transition-all duration-300 overflow-hidden"
      :class="dragOver
        ? 'border-sky-400 bg-sky-500/5 shadow-[0_0_30px_rgba(56,189,248,0.15)]'
        : linked.length > 0
          ? 'border-primary-300/50 dark:border-primary-700/50 bg-white dark:bg-neutral-900/60'
          : 'border-neutral-300 dark:border-neutral-700 bg-neutral-50/50 dark:bg-neutral-900/30'"
      @dragover.prevent="dragOver = true"
      @dragleave="dragOver = false"
      @drop="onDrop"
    >
      <!-- Grid dots bg -->
      <svg class="absolute inset-0 w-full h-full opacity-[0.025] pointer-events-none">
        <pattern id="rl-grid-dots" x="0" y="0" width="20" height="20" patternUnits="userSpaceOnUse">
          <circle cx="2" cy="2" r="1" fill="currentColor" class="text-neutral-900"/>
        </pattern>
        <rect width="100%" height="100%" fill="url(#rl-grid-dots)"/>
      </svg>

      <!-- SVG energy lines -->
      <svg
        class="absolute inset-0 w-full h-full pointer-events-none z-10"
        :viewBox="`0 0 ${svgW} ${svgH}`"
        v-if="svgW > 0 && linked.length > 0"
      >
        <defs>
          <filter id="rl-glow">
            <feGaussianBlur stdDeviation="1.5" result="b"/>
            <feMerge><feMergeNode in="b"/><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
          </filter>
          <linearGradient :id="'rl-energy-'+uid" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stop-color="#38bdf8" stop-opacity="0.1"/>
            <stop offset="50%" stop-color="#38bdf8" stop-opacity="0.9"/>
            <stop offset="100%" stop-color="#7dd3fc" stop-opacity="0.1"/>
          </linearGradient>
        </defs>
        <g v-for="(line, i) in lineData" :key="i">
          <path :d="line.path" fill="none" stroke="#38bdf8" stroke-width="1" opacity="0.12"/>
          <path :d="line.path" fill="none" :stroke="'url(#rl-energy-'+uid+')'" stroke-width="1.5" stroke-dasharray="5 4" class="rl-energy-flow" filter="url(#rl-glow)"/>
          <circle r="2" fill="#bae6fd" filter="url(#rl-glow)">
            <animateMotion :dur="`${1.2 + i * 0.15}s`" repeatCount="indefinite" :path="line.path"/>
          </circle>
        </g>
      </svg>

      <!-- Empty state -->
      <div v-if="linked.length === 0 && !dragOver" class="relative z-20 flex flex-col items-center justify-center py-10 text-center select-none">
        <div class="w-14 h-14 rounded-2xl bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center text-2xl mb-3 border border-dashed border-neutral-300 dark:border-neutral-600">
          <span class="opacity-40">📦</span>
        </div>
        <p class="text-sm font-bold text-neutral-500 dark:text-neutral-400 mb-1">No ingredients linked</p>
        <p class="text-xs text-neutral-400 dark:text-neutral-500 max-w-[240px] leading-relaxed">
          <span class="hidden sm:inline">Drag ingredients from below onto this area, or </span>
          <span class="sm:hidden">Tap</span>
          <span class="hidden sm:inline">click</span> an ingredient to link it
        </p>
      </div>

      <!-- Drop zone hint -->
      <div v-if="dragOver" class="relative z-20 flex items-center justify-center py-10 pointer-events-none">
        <div class="flex flex-col items-center gap-2 text-sky-400">
          <span class="text-3xl">⚡</span>
          <span class="text-sm font-black uppercase tracking-widest">Release to Link</span>
        </div>
      </div>

      <!-- Linked ingredient cards -->
      <TransitionGroup
        v-if="linked.length > 0 && !dragOver"
        name="rl-card"
        tag="div"
        class="relative z-20 grid grid-cols-2 gap-2.5 p-3"
        :class="linked.length <= 2 ? 'sm:grid-cols-2 md:grid-cols-2' : 'sm:grid-cols-3'"
      >
        <div
          v-for="(item, i) in linked"
          :key="item.recipeId || item.ingredientId"
          :ref="el => setCardRef(i, el)"
          class="group relative rounded-xl transition-all duration-300"
          :class="item.ingredientId === editingIngredient
            ? 'ring-2 ring-sky-400 shadow-lg shadow-sky-500/20 scale-[1.02]'
            : 'bg-white dark:bg-neutral-800/80 border border-neutral-200 dark:border-neutral-700 shadow-sm hover:shadow-md hover:border-sky-300/50 dark:hover:border-sky-700/50'"
        >
          <div class="p-2.5">
            <div class="flex items-center gap-2 mb-2">
              <div class="w-7 h-7 rounded-lg bg-gradient-to-br from-primary-500/20 to-primary-600/10 flex items-center justify-center text-sm flex-shrink-0 border border-primary-200/50 dark:border-primary-700/30 overflow-hidden">
                <img v-if="itemImage(item.ingredientId)" :src="itemImage(item.ingredientId)" class="w-full h-full object-cover" />
                <span v-else>{{ ingredientEmoji(item.ingredientName) }}</span>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-xs font-bold text-neutral-900 dark:text-white truncate leading-tight">{{ item.ingredientName }}</p>
                <p class="text-[9px] text-neutral-400 font-mono leading-tight">{{ item.ingredientUnit }}</p>
              </div>
              <button
                @click="removeItem(item)"
                class="opacity-0 group-hover:opacity-100 w-6 h-6 rounded-full bg-error-500/10 text-error-500 hover:bg-error-500 hover:text-white flex items-center justify-center transition-all text-xs font-bold flex-shrink-0"
                title="Remove ingredient"
              >✕</button>
            </div>
            <div class="flex items-center gap-1.5">
              <button
                @mousedown.prevent="startAdjust(item, -1)"
                @mouseup="stopAdjust"
                @mouseleave="stopAdjust"
                @touchstart.prevent="startAdjust(item, -1)"
                @touchend="stopAdjust"
                class="w-7 h-7 rounded-lg bg-neutral-100 dark:bg-neutral-700 text-neutral-500 hover:bg-neutral-200 dark:hover:bg-neutral-600 active:bg-neutral-300 dark:active:bg-neutral-500 transition-all text-sm font-bold flex items-center justify-center flex-shrink-0 select-none"
              >−</button>
              <input
                :value="item.quantityNeeded"
                @change="updateQty(item, ($event.target as HTMLInputElement).value)"
                type="number"
                step="0.5"
                min="0.1"
                class="w-full bg-transparent text-center text-xs font-bold font-mono text-neutral-900 dark:text-white border-b border-transparent focus:border-sky-400 outline-none transition-colors [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none select-none"
              />
              <button
                @mousedown.prevent="startAdjust(item, 1)"
                @mouseup="stopAdjust"
                @mouseleave="stopAdjust"
                @touchstart.prevent="startAdjust(item, 1)"
                @touchend="stopAdjust"
                class="w-7 h-7 rounded-lg bg-neutral-100 dark:bg-neutral-700 text-neutral-500 hover:bg-neutral-200 dark:hover:bg-neutral-600 active:bg-neutral-300 dark:active:bg-neutral-500 transition-all text-sm font-bold flex items-center justify-center flex-shrink-0 select-none"
              >+</button>
            </div>
          </div>
          <div class="absolute -top-1 -right-1 w-3 h-3 rounded-full bg-sky-400 border-2 border-white dark:border-neutral-900 shadow-sm"></div>
        </div>
      </TransitionGroup>
    </div>

    <!-- Available Ingredients Pool -->
    <div>
      <div class="flex items-center justify-between mb-3">
        <h4 class="text-sm font-bold text-neutral-700 dark:text-neutral-300 flex items-center gap-2">
          <span class="text-base">📦</span> Ingredients
          <span class="text-[10px] font-normal text-neutral-400">({{ available.length }})</span>
        </h4>
        <div class="relative">
          <svg class="absolute left-2.5 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-neutral-400 pointer-events-none" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Filter..."
            class="w-32 pl-7 pr-2 py-1.5 text-[11px] bg-neutral-100 dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg outline-none focus:ring-2 focus:ring-primary-500/30 transition-all"
          />
        </div>
      </div>

      <div class="space-y-3" @dragover.prevent>
        <div v-for="(group, groupUnit) in groupedIngredients" :key="groupUnit">
          <div class="flex items-center gap-2 mb-1.5 px-1">
            <span class="text-[10px] font-bold text-neutral-400 dark:text-neutral-500 uppercase tracking-wider">{{ groupUnit }}</span>
            <div class="flex-1 h-px bg-neutral-200 dark:bg-neutral-800"></div>
            <span class="text-[9px] text-neutral-400 dark:text-neutral-500">{{ group.length }}</span>
          </div>
          <div class="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 gap-1.5">
            <div
              v-for="ing in group"
              :key="ing.ingredientId"
              draggable="true"
              @dragstart="onDragStart(ing, $event)"
              @click="quickLink(ing)"
              class="relative aspect-square rounded-xl transition-all duration-200 cursor-pointer group/ing border"
              :class="isLinked(ing.ingredientId)
                ? 'border-sky-300/40 bg-sky-500/10 opacity-40 cursor-default'
                : ing.currentStock != null && ing.currentStock <= ing.reorderLevel
                  ? 'border-amber-300/50 bg-amber-50 dark:bg-amber-900/10 hover:border-amber-400 hover:shadow-md hover:shadow-amber-500/10 hover:-translate-y-0.5 active:scale-95'
                  : 'border-neutral-200 dark:border-neutral-700 bg-white dark:bg-neutral-800/60 hover:border-sky-400/50 hover:shadow-md hover:shadow-sky-500/10 hover:-translate-y-0.5 active:scale-95'"
              :title="isLinked(ing.ingredientId) ? `Already linked` : `${ing.name} (${ing.currentStock ?? '?'} ${ing.unit})`"
            >
              <div class="absolute inset-0 flex flex-col items-center justify-center p-1">
                <div v-if="ing.imageUrl" class="w-6 h-6 rounded-lg overflow-hidden mb-0.5 shadow-sm border border-black/5">
                  <img :src="ing.imageUrl" class="w-full h-full object-cover" />
                </div>
                <span v-else class="text-base mb-0.5 drop-shadow-sm">{{ ingredientEmoji(ing.name) }}</span>
                <span class="text-[7px] font-bold text-neutral-500 dark:text-neutral-400 uppercase tracking-wider truncate max-w-full leading-tight">{{ ing.name }}</span>
                <!-- Stock dot indicator -->
                <div v-if="ing.currentStock != null" class="flex items-center gap-1 mt-0.5">
                  <div
                    class="w-1.5 h-1.5 rounded-full"
                    :class="ing.currentStock <= ing.reorderLevel ? 'bg-amber-400' : 'bg-green-400'"
                  ></div>
                  <span class="text-[6px] font-mono text-neutral-400 dark:text-neutral-500">{{ Math.round(ing.currentStock) }}{{ ing.unit }}</span>
                </div>
              </div>
              <!-- Hover link badge -->
              <div v-if="!isLinked(ing.ingredientId)" class="absolute inset-0 rounded-xl bg-sky-500/5 opacity-0 group-hover/ing:opacity-100 transition-opacity flex items-center justify-center pointer-events-none">
                <span class="text-[8px] font-bold text-sky-400 bg-white/80 dark:bg-neutral-900/80 px-1.5 py-0.5 rounded-full shadow-sm backdrop-blur-sm">+ Link</span>
              </div>
              <!-- Low stock badge -->
              <div
                v-if="!isLinked(ing.ingredientId) && ing.currentStock != null && ing.currentStock <= ing.reorderLevel"
                class="absolute top-0.5 right-0.5 w-2.5 h-2.5 rounded-full bg-amber-400 border border-white dark:border-neutral-900"
              ></div>
            </div>
          </div>
        </div>
      </div>

      <p v-if="Object.keys(groupedIngredients).length === 0" class="text-center py-4 text-xs text-neutral-400">
        {{ searchQuery ? 'No ingredients match your filter' : 'All ingredients are linked' }}
      </p>
    </div>

    <!-- Undo Snackbar -->
    <Teleport to="body">
      <Transition name="rl-toast">
        <div
          v-if="undoState"
          class="fixed bottom-6 left-1/2 -translate-x-1/2 z-[9999] flex items-center gap-3 px-4 py-3 bg-neutral-900 dark:bg-neutral-800 text-white rounded-2xl shadow-2xl border border-white/10 backdrop-blur-xl"
        >
          <span class="text-sm">Unlinked <strong>{{ undoState.name }}</strong></span>
          <button
            @click="undoRemove"
            class="px-3 py-1 rounded-lg bg-sky-500 hover:bg-sky-400 text-white text-xs font-bold transition-all active:scale-95"
          >Undo</button>
          <button @click="undoState = null" class="text-neutral-500 hover:text-white transition-colors text-sm">✕</button>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  productName: string
  productPrice: number
  productEmoji?: string
  linked: RecipeItem[]
  available: AvailableIngredient[]
}>()

const emit = defineEmits<{
  add: [ingredientId: number, quantityNeeded: number]
  remove: [recipeId: number]
  updateQuantity: [recipeId: number, quantity: number]
}>()

interface RecipeItem {
  recipeId: number
  ingredientId: number
  ingredientName: string
  ingredientUnit: string
  quantityNeeded: number
}

interface AvailableIngredient {
  ingredientId: number
  name: string
  unit: string
  currentStock?: number | null
  reorderLevel?: number | null
  imageUrl?: string | null
}

const uid = 'rl-' + Math.random().toString(36).slice(2, 7)
const dragOver = ref(false)
const searchQuery = ref('')
const editingIngredient = ref<number | null>(null)
const adjustTimer = ref<ReturnType<typeof setInterval> | null>(null)
const svgW = ref(100)
const svgH = ref(100)
const lineData = ref<{ path: string }[]>([])
const canvasRef = ref<HTMLElement | null>(null)
const cardElements = ref<(HTMLElement | null)[]>([])

interface UndoState {
  recipeId: number
  ingredientId: number
  name: string
}
const undoState = ref<UndoState | null>(null)
let undoTimeout: ReturnType<typeof setTimeout> | null = null

function setCardRef(i: number, el: unknown) {
  cardElements.value[i] = el as HTMLElement | null
}

function recalcLines() {
  nextTick(() => {
    const canvas = canvasRef.value
    if (!canvas || props.linked.length === 0) {
      lineData.value = []
      return
    }
    const cr = canvas.getBoundingClientRect()
    svgW.value = cr.width
    svgH.value = cr.height
    if (cr.width === 0 || cr.height === 0) return

    // Origin: top-center of canvas (below product area)
    const ox = cr.width / 2
    const oy = 12

    const lines: { path: string }[] = []
    const seen = new Set<number>()

    for (let i = 0; i < props.linked.length && i < cardElements.value.length; i++) {
      const card = cardElements.value[i]
      if (!card || seen.has(props.linked[i].ingredientId)) continue
      seen.add(props.linked[i].ingredientId)
      const cardRect = card.getBoundingClientRect()
      const ex = cardRect.left - cr.left + cardRect.width / 2
      const ey = cardRect.top - cr.top + cardRect.height / 2
      const cpx = (ox + ex) / 2
      const cpy = (oy + ey) / 2 - 10
      lines.push({ path: `M ${ox} ${oy} Q ${cpx} ${cpy}, ${ex} ${ey}` })
    }
    lineData.value = lines
  })
}

watch(() => props.linked.length, recalcLines)
watch(canvasRef, recalcLines)

onMounted(() => {
  if (typeof ResizeObserver !== 'undefined' && canvasRef.value) {
    const ro = new ResizeObserver(recalcLines)
    ro.observe(canvasRef.value)
    onUnmounted(() => ro.disconnect())
  }
  recalcLines()
})

const filteredAvailable = computed(() => {
  if (!searchQuery.value) return props.available
  const q = searchQuery.value.toLowerCase()
  return props.available.filter(ing =>
    ing.name.toLowerCase().includes(q) || ing.unit.toLowerCase().includes(q)
  )
})

const groupedIngredients = computed(() => {
  const groups: Record<string, AvailableIngredient[]> = {}
  for (const ing of filteredAvailable.value) {
    const unit = ing.unit || 'other'
    if (!groups[unit]) groups[unit] = []
    groups[unit].push(ing)
  }
  const order = ['G', 'ML', 'PCS']
  return Object.keys(groups)
    .sort((a, b) => {
      const ai = order.indexOf(a)
      const bi = order.indexOf(b)
      return (ai === -1 ? 99 : ai) - (bi === -1 ? 99 : bi)
    })
    .reduce((acc, key) => { acc[key] = groups[key]; return acc }, {} as Record<string, AvailableIngredient[]>)
})

function isLinked(ingredientId: number): boolean {
  return props.linked.some(r => r.ingredientId === ingredientId)
}

function onDragStart(ing: AvailableIngredient, event: DragEvent) {
  if (isLinked(ing.ingredientId)) {
    event.preventDefault()
    return
  }
  event.dataTransfer?.setData('text/plain', String(ing.ingredientId))
  if (event.dataTransfer) event.dataTransfer.effectAllowed = 'copy'
  // custom drag ghost
  const ghost = document.createElement('div')
  ghost.textContent = `+ ${ing.name}`
  ghost.style.cssText = 'padding:6px 12px;background:#38bdf8;color:#fff;border-radius:8px;font:bold 13px sans-serif;position:absolute;top:-999px;left:-999px;white-space:nowrap;box-shadow:0 4px 20px rgba(56,189,248,0.4)'
  document.body.appendChild(ghost)
  event.dataTransfer?.setDragImage(ghost, 0, 0)
  setTimeout(() => document.body.removeChild(ghost), 0)
}

function onDrop(event: DragEvent) {
  dragOver.value = false
  const id = event.dataTransfer?.getData('text/plain')
  if (id) {
    const ing = props.available.find(i => i.ingredientId === Number(id))
    if (ing && !isLinked(ing.ingredientId)) {
      emit('add', ing.ingredientId, 1)
    }
  }
}

function quickLink(ing: AvailableIngredient) {
  if (isLinked(ing.ingredientId)) return
  editingIngredient.value = ing.ingredientId
  emit('add', ing.ingredientId, 1)
  setTimeout(() => { editingIngredient.value = null }, 600)
}

function removeItem(item: RecipeItem) {
  if (undoTimeout) clearTimeout(undoTimeout)
  undoState.value = { recipeId: item.recipeId, ingredientId: item.ingredientId, name: item.ingredientName }
  emit('remove', item.recipeId)
  undoTimeout = setTimeout(() => { undoState.value = null }, 4000)
}

function undoRemove() {
  if (!undoState.value) return
  emit('add', undoState.value.ingredientId, 1)
  undoState.value = null
  if (undoTimeout) clearTimeout(undoTimeout)
}

function startAdjust(item: RecipeItem, delta: number) {
  adjustQty(item, delta)
  adjustTimer.value = setInterval(() => adjustQty(item, delta), 150)
}

function stopAdjust() {
  if (adjustTimer.value) {
    clearInterval(adjustTimer.value)
    adjustTimer.value = null
  }
}

function adjustQty(item: RecipeItem, delta: number) {
  const newQty = Math.max(0.1, (item.quantityNeeded || 0) + delta)
  emit('updateQuantity', item.recipeId, Math.round(newQty * 10) / 10)
}

function updateQty(item: RecipeItem, val: string) {
  const num = parseFloat(val)
  if (!isNaN(num) && num > 0) {
    emit('updateQuantity', item.recipeId, Math.round(num * 10) / 10)
  }
}

function itemImage(ingredientId: number): string | null {
  const ing = props.available.find(i => i.ingredientId === ingredientId)
  return ing?.imageUrl || null
}

function ingredientEmoji(name: string): string {
  const map: Record<string, string> = {
    'coffee': '🫘', 'bean': '🫘', 'espresso': '☕',
    'milk': '🥛', 'cream': '🍦', 'whipped': '🍦',
    'ice': '🧊', 'sugar': '🧂', 'syrup': '🧴',
    'vanilla': '🌿', 'chocolate': '🍫', 'cocoa': '🍫',
    'matcha': '🍵', 'water': '💧', 'caramel': '🍯',
    'honey': '🍯', 'cinnamon': '🌿', 'mint': '🌱',
    'coconut': '🥥', 'almond': '🥜', 'oat': '🌾',
    'cherry': '🍒', 'berry': '🫐', 'banana': '🍌',
    'strawberry': '🍓', 'lemon': '🍋', 'lime': '🍈',
    'ginger': '🧄', 'nutmeg': '🌰', 'cheese': '🧀',
    'egg': '🥚', 'butter': '🧈', 'flour': '🌾',
    'salt': '🧂', 'pepper': '🌶️',
  }
  const lower = name.toLowerCase()
  for (const [key, emoji] of Object.entries(map)) {
    if (lower.includes(key)) return emoji
  }
  return '🧪'
}

onUnmounted(() => {
  if (undoTimeout) clearTimeout(undoTimeout)
  if (adjustTimer.value) clearInterval(adjustTimer.value)
})
</script>

<style scoped>
.rl-energy-flow {
  animation: rlFlow 0.9s linear infinite;
}
@keyframes rlFlow {
  0% { stroke-dashoffset: 0; }
  100% { stroke-dashoffset: -18; }
}

/* card enter/leave transition */
.rl-card-enter-active {
  transition: all 0.35s cubic-bezier(0.23, 1, 0.32, 1);
}
.rl-card-leave-active {
  transition: all 0.2s ease-in;
}
.rl-card-enter-from {
  opacity: 0;
  transform: scale(0.85) translateY(8px);
}
.rl-card-leave-to {
  opacity: 0;
  transform: scale(0.9) translateY(-4px);
}
.rl-card-move {
  transition: transform 0.35s cubic-bezier(0.23, 1, 0.32, 1);
}

/* undo toast */
.rl-toast-enter-active { transition: all 0.3s cubic-bezier(0.23, 1, 0.32, 1); }
.rl-toast-leave-active { transition: all 0.2s ease-in; }
.rl-toast-enter-from { opacity: 0; transform: translate(-50%, 20px) scale(0.95); }
.rl-toast-leave-to { opacity: 0; transform: translate(-50%, 20px) scale(0.95); }
</style>

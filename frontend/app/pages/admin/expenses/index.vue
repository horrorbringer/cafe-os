<template>
  <NuxtLayout name="admin">
    <div class="space-y-6">
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbPage>Expenses</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>
      
      <!-- Header -->
      <div class="flex items-center justify-between">
        <div>
          <h2 class="text-2xl font-bold text-neutral-900 dark:text-white">Expense Tracking</h2>
          <p class="text-sm text-neutral-500 mt-1">Monitor daily operations costs and utility bills.</p>
        </div>
        <Button variant="destructive" @click="showModal = true">
          <PlusIcon class="w-4 h-4" />
          New Expense
        </Button>
      </div>

      <!-- Stats -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div class="bg-white dark:bg-neutral-900 p-6 rounded-2xl border border-neutral-200 dark:border-neutral-800 shadow-sm transition-transform hover:-translate-y-1">
              <p class="text-[10px] font-black text-neutral-500 uppercase tracking-widest mb-1">Total Expenses (MTD)</p>
              <p class="text-3xl font-black text-error-600">${{ totalExpenses.toFixed(2) }}</p>
          </div>
          <div class="bg-white dark:bg-neutral-900 p-6 rounded-2xl border border-neutral-200 dark:border-neutral-800 shadow-sm transition-transform hover:-translate-y-1">
              <p class="text-[10px] font-black text-neutral-500 uppercase tracking-widest mb-1">Largest Category</p>
              <p class="text-3xl font-black text-neutral-900 dark:text-white">{{ topCategory || '---' }}</p>
          </div>
          <div class="bg-white dark:bg-neutral-900 p-6 rounded-2xl border border-neutral-200 dark:border-neutral-800 shadow-sm transition-transform hover:-translate-y-1">
              <p class="text-[10px] font-black text-neutral-500 uppercase tracking-widest mb-1">Bills Pending</p>
              <p class="text-3xl font-black text-warning-500">0</p>
          </div>
      </div>

      <!-- Table -->
      <div class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-800 rounded-3xl overflow-hidden shadow-sm">
        <div class="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow class="bg-neutral-50 dark:bg-neutral-800/50 border-b border-neutral-200 dark:border-neutral-800">
                <TableHead>Date</TableHead>
                <TableHead>Expense / Title</TableHead>
                <TableHead>Category</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead class="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <template v-if="loading">
                <TableRow v-for="i in 5" :key="i" class="animate-pulse">
                   <TableCell v-for="j in 5" :key="j"><div class="h-4 bg-neutral-100 dark:bg-neutral-800 rounded"></div></TableCell>
                </TableRow>
              </template>
              <TableRow v-for="item in expenses" :key="item.expenseId" class="group">
                <TableCell>
                  <div class="text-sm font-bold text-neutral-900 dark:text-white">{{ formatDate(item.date) }}</div>
                </TableCell>
                <TableCell>
                  <div class="text-sm font-bold text-neutral-900 dark:text-white">{{ item.title }}</div>
                  <div class="text-[10px] text-neutral-500">{{ item.description || 'No description' }}</div>
                </TableCell>
                <TableCell>
                  <span class="px-2 py-1 rounded-md bg-neutral-100 dark:bg-neutral-800 text-[10px] font-bold text-neutral-600 dark:text-neutral-400 uppercase tracking-wider">
                    {{ item.category }}
                  </span>
                </TableCell>
                <TableCell class="font-black text-error-600">
                  ${{ item.amount.toFixed(2) }}
                </TableCell>
                <TableCell class="text-right">
                  <Button variant="ghost" size="icon" @click="confirmDeleteExpense(item.expenseId)">
                    <Trash2Icon class="w-4 h-4" />
                  </Button>
                </TableCell>
              </TableRow>
              <TableRow v-if="expenses.length === 0 && !loading">
                  <TableCell colspan="5" class="text-center text-neutral-400 italic">No expenses recorded yet.</TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>
      </div>

      <Dialog v-model:open="showModal">
        <DialogContent class="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>Record Expense</DialogTitle>
          </DialogHeader>
          <form @submit.prevent="saveExpense" class="space-y-6">
            <div class="grid grid-cols-2 gap-4">
              <div class="col-span-2 space-y-2">
                <Label class="text-xs font-bold uppercase tracking-widest">Title / Payee</Label>
                <Input v-model="form.title" type="text" required placeholder="e.g. Electric Bill Jan 2024" />
              </div>
              <div class="space-y-2">
                <Label class="text-xs font-bold uppercase tracking-widest">Amount ($)</Label>
                <Input v-model.number="form.amount" type="number" step="0.01" required placeholder="0.00" />
              </div>
              <div class="space-y-2">
                <Label class="text-xs font-bold uppercase tracking-widest">Category</Label>
                <Select v-model="form.category">
                  <SelectTrigger>
                    <SelectValue placeholder="Select category" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="UTILITIES">Utilities</SelectItem>
                    <SelectItem value="MARKETING">Marketing</SelectItem>
                    <SelectItem value="RENT">Rent</SelectItem>
                    <SelectItem value="SALARY">Salary</SelectItem>
                    <SelectItem value="SUPPLIES">Supplies</SelectItem>
                    <SelectItem value="OTHER">Other</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div class="col-span-2 space-y-2">
                <Label class="text-xs font-bold uppercase tracking-widest">Notes</Label>
                <Textarea v-model="form.description" placeholder="Additional details..." />
              </div>
            </div>
          </form>
          <DialogFooter>
            <Button variant="secondary" @click="showModal = false">Cancel</Button>
            <Button type="submit" variant="destructive" :disabled="saving" @click="saveExpense">
              {{ saving ? 'Saving...' : 'Log Expense' }}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <AlertDialog v-model:open="showDeleteAlert">
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Expense</AlertDialogTitle>
            <AlertDialogDescription>Are you sure you want to delete this expense? This action cannot be undone.</AlertDialogDescription>
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
import { ref, reactive, computed, onMounted } from 'vue'
import { PlusIcon, Trash2Icon } from '@lucide/vue'

definePageMeta({
  layout: false
})
const { get, post, del } = useApi()
const toast = useToast()

interface Expense {
  expenseId: number
  title: string
  description: string
  amount: number
  date: string
  category: string
}

const expenses = ref<Expense[]>([])
const loading = ref(true)
const saving = ref(false)
const showModal = ref(false)
const showDeleteAlert = ref(false)
const expenseToDelete = ref<number | null>(null)

const form = reactive({
  title: '',
  description: '',
  amount: undefined as number | undefined,
  category: 'UTILITIES',
  branchId: 1,
  recordedById: 1,
})

const totalExpenses = computed(() => expenses.value.reduce((s, e) => s + e.amount, 0))
const topCategory = computed(() => {
  if (expenses.value.length === 0) return ''
  const cats: any = {}
  expenses.value.forEach(e => cats[e.category] = (cats[e.category] || 0) + e.amount)
  return Object.keys(cats).reduce((a, b) => cats[a] > cats[b] ? a : b)
})

const fetchExpenses = async () => {
  loading.value = true
  try {
    const data = await get<Expense[]>('/expenses')
    expenses.value = data || []
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

const saveExpense = async () => {
  saving.value = true
  try {
    await post('/expenses', form)
    showModal.value = false
    toast.success('Expense recorded successfully')
    fetchExpenses()
    form.title = ''
    form.description = ''
    form.amount = undefined
  } catch (err) {
    toast.error('Failed to save expense')
  } finally {
    saving.value = false
  }
}

const confirmDeleteExpense = (id: number) => {
  expenseToDelete.value = id
  showDeleteAlert.value = true
}

const executeDelete = async () => {
  if (!expenseToDelete.value) return
  try {
    await del(`/expenses/${expenseToDelete.value}`)
    toast.success('Expense deleted')
    fetchExpenses()
  } catch (e) {
    toast.error('Delete failed')
  } finally {
    showDeleteAlert.value = false
    expenseToDelete.value = null
  }
}

const formatDate = (d: string) => new Date(d).toLocaleDateString()

onMounted(fetchExpenses)
</script>

<style scoped>
</style>

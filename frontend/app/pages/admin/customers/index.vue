<template>
  <NuxtLayout name="admin">
    <div class="space-y-6">
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbPage>Customers</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>
      
      <!-- Header -->
      <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 class="text-2xl font-bold text-neutral-900 dark:text-white">Customer Relationship Management</h1>
          <p class="text-neutral-500 dark:text-neutral-400">Manage customer profiles, loyalty, and purchase history</p>
        </div>
        
        <div class="flex items-center gap-3">
          <div class="relative">
            <SearchIcon class="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-neutral-400" />
            <Input v-model="searchQuery" placeholder="Search by phone or name..." class="w-64 md:w-80 pl-10" @keyup.enter="searchCustomer" />
          </div>
          <Button @click="openCreateModal">
            <UserPlusIcon class="w-4 h-4" />
            Add Customer
          </Button>
        </div>
      </div>

      <!-- CRM Summary Stats -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card class="group hover:scale-[1.02] transition-all">
          <CardContent class="p-5">
            <p class="text-[10px] font-black text-neutral-400 uppercase tracking-widest mb-1">Total Customers</p>
            <p class="text-2xl font-black text-neutral-900 dark:text-white">{{ customers.length }}</p>
          </CardContent>
        </Card>
        <Card class="group hover:scale-[1.02] transition-all">
          <CardContent class="p-5">
            <p class="text-[10px] font-black text-neutral-400 uppercase tracking-widest mb-1">Total Revenue</p>
            <p class="text-2xl font-black text-success-600">${{ totalCustomerRevenue.toFixed(2) }}</p>
          </CardContent>
        </Card>
        <Card class="group hover:scale-[1.02] transition-all">
          <CardContent class="p-5">
            <p class="text-[10px] font-black text-neutral-400 uppercase tracking-widest mb-1">Avg Spend</p>
            <p class="text-2xl font-black text-accent-600">${{ avgCustomerSpend.toFixed(2) }}</p>
          </CardContent>
        </Card>
        <Card class="group hover:scale-[1.02] transition-all">
          <CardContent class="p-5">
            <p class="text-[10px] font-black text-neutral-400 uppercase tracking-widest mb-1">Gold Members</p>
            <p class="text-2xl font-black text-warning-600">{{ goldMemberCount }}</p>
          </CardContent>
        </Card>
      </div>

      <!-- Main Content Area -->
      <div class="grid lg:grid-cols-12 gap-6">
        
        <!-- Left Sidebar -->
         <div class="lg:col-span-4 space-y-4">
           <div class="bg-white dark:bg-neutral-900 rounded-3xl border border-neutral-200 dark:border-neutral-800 overflow-hidden shadow-sm">
              <div class="p-4 bg-neutral-50/50 dark:bg-neutral-800/50 border-b border-neutral-200 dark:border-neutral-800 flex justify-between items-center">
                 <h3 class="text-xs font-black text-neutral-500 uppercase tracking-widest">{{ searchActive ? 'Search Results' : 'All Customers' }}</h3>
                 <span class="text-[10px] font-bold text-neutral-400 bg-neutral-100 dark:bg-neutral-800 px-2 py-0.5 rounded-full">{{ displayCustomers.length }}</span>
              </div>
              <div class="divide-y divide-neutral-100 dark:divide-neutral-800 max-h-[600px] overflow-y-auto custom-scrollbar">
                 <template v-if="loading && customers.length === 0">
                    <div v-for="i in 5" :key="i" class="p-4 flex items-center gap-3 animate-pulse">
                        <div class="w-10 h-10 rounded-xl bg-neutral-100 dark:bg-neutral-800"></div>
                        <div class="flex-1 space-y-2">
                           <div class="h-3 bg-neutral-100 dark:bg-neutral-800 rounded w-24"></div>
                           <div class="h-2 bg-neutral-100 dark:bg-neutral-800 rounded w-32"></div>
                        </div>
                    </div>
                 </template>
                 <template v-else>
                    <div 
                      v-for="cust in displayCustomers" 
                      :key="cust.customerId"
                      @click="selectCustomer(cust)"
                      :class="[
                        'p-4 cursor-pointer transition-all hover:bg-neutral-50 dark:hover:bg-neutral-800/50',
                        selectedCustomerId === cust.customerId ? 'bg-primary-50 dark:bg-primary-900/10 border-l-4 border-l-primary-500' : ''
                      ]"
                    >
                       <div class="flex items-center gap-3">
                          <div :class="[
                            'w-10 h-10 rounded-xl flex items-center justify-center text-sm font-black text-white shadow-md',
                            cust.membershipLevel === 'GOLD' ? 'bg-gradient-to-br from-warning-400 to-warning-600 shadow-warning-500/20' :
                            cust.membershipLevel === 'SILVER' ? 'bg-gradient-to-br from-neutral-400 to-neutral-600 shadow-neutral-500/20' :
                            'bg-gradient-to-br from-primary-500 to-accent-500 shadow-primary-500/20'
                          ]">
                             {{ cust.name?.charAt(0)?.toUpperCase() }}
                          </div>
                          <div class="flex-1 overflow-hidden">
                             <p class="font-bold text-neutral-900 dark:text-white truncate text-sm">{{ cust.name }}</p>
                             <p class="text-[11px] text-neutral-500">{{ cust.phone }}</p>
                          </div>
                          <div class="text-right flex flex-col items-end gap-1">
                             <span :class="getMemberBadgeClass(cust.membershipLevel)" class="text-[9px] font-black px-1.5 py-0.5 rounded uppercase tracking-wider">{{ cust.membershipLevel || 'BRONZE' }}</span>
                             <p class="text-[10px] font-bold text-primary-600">{{ cust.loyaltyPoints || 0 }} pt</p>
                          </div>
                       </div>
                    </div>
                    <div v-if="displayCustomers.length === 0" class="p-8 text-center text-neutral-400 italic text-sm">
                       No customers found.
                    </div>
                 </template>
              </div>
           </div>
        </div>

        <!-- Right Content -->
        <div class="lg:col-span-8">
           <div v-if="loading && selectedCustomerId" class="space-y-6">
               <div class="h-32 animate-pulse bg-neutral-100 dark:bg-neutral-800 rounded-3xl"></div>
               <div class="grid grid-cols-3 gap-6">
                  <div v-for="i in 3" :key="i" class="h-24 animate-pulse bg-neutral-100 dark:bg-neutral-800 rounded-3xl"></div>
              </div>
           </div>
           <template v-else-if="history">
              <!-- Profile Card -->
              <div class="relative overflow-hidden rounded-3xl animate-in fade-in slide-in-from-right duration-300 mb-6">
                <div class="absolute inset-0 bg-gradient-to-br from-primary-600 via-primary-700 to-accent-700"></div>
                <div class="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHZpZXdCb3g9IjAgMCA2MCA2MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZyBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPjxnIGZpbGw9IiNmZmYiIGZpbGwtb3BhY2l0eT0iMC4wMyI+PHBhdGggZD0iTTM2IDM0di00aC0ydjRoLTRWMzBoNHYtNGgydjRoNHY0aC00ek0wIDBoNHY0SDB6bTAgMTZoNHY0SDB6bTE2IDBoNHY0aC00em0wLTE2aDR2NGgtNHoiLz48L2c+PC9nPjwvc3ZnPg==')] opacity-50"></div>
                <div class="relative p-6 md:p-8">
                  <div class="flex flex-col md:flex-row md:items-center gap-6">
                    <div class="w-20 h-20 rounded-3xl bg-white/20 backdrop-blur-xl flex items-center justify-center text-white text-3xl font-black shadow-2xl shadow-black/20 border border-white/20">
                      {{ history.customerName?.charAt(0)?.toUpperCase() }}
                    </div>
                    <div class="flex-1">
                      <div class="flex items-center gap-3 flex-wrap">
                         <h2 class="text-2xl font-black text-white">{{ history.customerName }}</h2>
                         <span :class="[
                           'px-2.5 py-1 rounded-lg text-[10px] font-black uppercase tracking-widest backdrop-blur-sm',
                           history.membershipLevel === 'GOLD' ? 'bg-warning-400/30 text-warning-200 border border-warning-400/30' :
                           history.membershipLevel === 'SILVER' ? 'bg-white/20 text-white/90 border border-white/20' :
                           'bg-orange-400/30 text-orange-200 border border-orange-400/30'
                         ]">
                           {{ history.membershipLevel || 'BRONZE' }} MEMBER
                         </span>
                          <Button variant="ghost" size="sm" @click="openEditModal(history)" class="text-white/70 hover:text-white">Edit</Button>
                      </div>
                      <div class="flex flex-wrap items-center gap-4 mt-2.5 text-sm text-white/70">
                        <span class="flex items-center gap-1.5">
                          <PhoneIcon class="w-4 h-4" />
                          {{ history.phone }}
                        </span>
                        <span class="flex items-center gap-1.5">
                          <CalendarDaysIcon class="w-4 h-4" />
                          Since {{ formatDate(history.memberSince) }}
                        </span>
                      </div>
                    </div>
                    <div class="flex flex-wrap items-center gap-2">
                      <div class="flex items-center gap-2 px-5 py-3 bg-white/15 backdrop-blur-xl rounded-2xl border border-white/20">
                        <StarIcon class="w-5 h-5 text-warning-300" />
                        <span class="text-white font-black text-xl">{{ history.loyaltyPoints }} <span class="text-xs text-white/60 uppercase ml-0.5">pts</span></span>
                      </div>
                      <Button
                        type="button"
                        variant="secondary"
                        size="sm"
                        @click="openAdjustmentModal"
                      >
                        Adjust
                      </Button>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Stats Cards -->
              <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                <Card class="group hover:-translate-y-1 transition-all">
                  <CardContent class="p-5">
                    <div class="w-9 h-9 rounded-xl bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center text-primary-600 mb-3">
                      <ShoppingBagIcon class="w-5 h-5" />
                    </div>
                    <p class="text-[10px] font-black text-neutral-400 uppercase tracking-widest mb-0.5">Orders</p>
                    <p class="text-2xl font-black text-neutral-900 dark:text-white">{{ history.totalOrders }}</p>
                  </CardContent>
                </Card>
                <Card class="group hover:-translate-y-1 transition-all">
                  <CardContent class="p-5">
                    <div class="w-9 h-9 rounded-xl bg-success-100 dark:bg-success-900/30 flex items-center justify-center text-success-600 mb-3">
                      <DollarSignIcon class="w-5 h-5" />
                    </div>
                    <p class="text-[10px] font-black text-neutral-400 uppercase tracking-widest mb-0.5">Total Spend</p>
                    <p class="text-2xl font-black text-success-600">${{ history.totalSpent?.toFixed(2) }}</p>
                  </CardContent>
                </Card>
                <Card class="group hover:-translate-y-1 transition-all">
                  <CardContent class="p-5">
                    <div class="w-9 h-9 rounded-xl bg-accent-100 dark:bg-accent-900/30 flex items-center justify-center text-accent-600 mb-3">
                      <TrendingUpIcon class="w-5 h-5" />
                    </div>
                    <p class="text-[10px] font-black text-neutral-400 uppercase tracking-widest mb-0.5">Avg Ticket</p>
                    <p class="text-2xl font-black text-accent-600">${{ (history.totalSpent / (history.totalOrders || 1)).toFixed(2) }}</p>
                  </CardContent>
                </Card>
                <Card class="group hover:-translate-y-1 transition-all">
                  <CardContent class="p-5">
                    <div class="w-9 h-9 rounded-xl bg-warning-100 dark:bg-warning-900/30 flex items-center justify-center text-warning-600 mb-3">
                      <CalendarIcon class="w-5 h-5" />
                    </div>
                    <p class="text-[10px] font-black text-neutral-400 uppercase tracking-widest mb-0.5">Last Visit</p>
                    <p class="text-lg font-black text-neutral-700 dark:text-neutral-300">{{ history.lastVisit ? formatDate(history.lastVisit) : 'N/A' }}</p>
                  </CardContent>
                </Card>
              </div>

              <!-- Membership Progress -->
              <Card class="relative overflow-hidden mb-6">
                <CardContent class="p-5">
                  <div class="flex items-center justify-between mb-3">
                    <span class="text-xs font-black text-neutral-500 uppercase tracking-widest">Loyalty Progress</span>
                    <span class="text-xs font-bold text-neutral-400">{{ history.loyaltyPoints }} / {{ nextTierThreshold }} pts → {{ nextTierName }}</span>
                  </div>
                  <div class="w-full h-3 bg-neutral-200 dark:bg-neutral-700 rounded-full overflow-hidden">
                    <div class="h-full rounded-full transition-all duration-1000 relative" :class="tierProgressColor" :style="{ width: tierProgressPercent + '%' }">
                      <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/30 to-transparent animate-shimmer"></div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <!-- Content Grid -->
              <div class="grid lg:grid-cols-3 gap-6 mb-6">
                <!-- Favorite Items -->
                <Card class="relative overflow-hidden">
                  <CardContent class="p-6">
                    <h3 class="text-sm font-black text-neutral-500 uppercase tracking-widest mb-6 flex items-center gap-2">
                      <HeartIcon class="w-4 h-4 text-red-500" />
                      Top Favorites
                    </h3>
                    <div class="space-y-3">
                      <div 
                        v-for="(item, idx) in history.favoriteItems" 
                        :key="item.menuItemId" 
                        class="flex items-center gap-3 p-3 bg-neutral-50 dark:bg-neutral-800/50 rounded-2xl hover:bg-neutral-100 dark:hover:bg-neutral-800 transition-colors group"
                      >
                        <div :class="[
                          'w-8 h-8 rounded-lg flex items-center justify-center text-xs font-black text-white flex-shrink-0',
                          idx === 0 ? 'bg-gradient-to-br from-warning-400 to-warning-600' :
                          idx === 1 ? 'bg-gradient-to-br from-neutral-400 to-neutral-500' :
                          'bg-gradient-to-br from-orange-400 to-orange-500'
                        ]">#{{ idx + 1 }}</div>
                        <div class="flex-1 overflow-hidden">
                          <p class="font-bold text-neutral-900 dark:text-white truncate text-sm">{{ item.name }}</p>
                          <p class="text-[10px] font-bold text-neutral-400 uppercase tracking-widest">{{ item.orderCount }}x ordered</p>
                        </div>
                        <span class="text-sm font-black text-primary-600 group-hover:scale-110 transition-transform">${{ item.totalSpent?.toFixed(2) }}</span>
                      </div>
                      <div v-if="!history.favoriteItems?.length" class="text-center py-12 text-neutral-400 italic text-xs">
                        No purchase history available.
                      </div>
                    </div>
                  </CardContent>
                </Card>

                <!-- Recent Orders -->
                <Card class="lg:col-span-2 overflow-hidden">
                   <div class="p-6 border-b border-neutral-100 dark:border-neutral-800 flex items-center justify-between">
                      <h3 class="text-sm font-black text-neutral-500 uppercase tracking-widest">Order History</h3>
                      <span class="text-[10px] font-bold text-neutral-400 uppercase tracking-widest">{{ history.recentOrders?.length || 0 }} items</span>
                   </div>
                   <CardContent class="p-0">
                     <div class="divide-y divide-neutral-100 dark:divide-neutral-800 max-h-[400px] overflow-y-auto custom-scrollbar">
                        <div 
                          v-for="order in history.recentOrders" 
                          :key="order.orderId" 
                          class="p-4 hover:bg-neutral-50 dark:hover:bg-neutral-800/50 transition-colors cursor-pointer"
                          @click="toggleOrderDetails(order.orderId)"
                        >
                          <div class="flex items-center justify-between">
                            <div class="flex items-center gap-4">
                              <div class="w-12 h-12 rounded-2xl bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center text-primary-600">
                                 <ShoppingBagIcon class="w-5 h-5" />
                              </div>
                              <div>
                                <p class="font-black text-neutral-900 dark:text-white">{{ order.orderNo }}</p>
                                <p class="text-[10px] text-neutral-500 font-bold uppercase tracking-wider">{{ order.date }} at {{ order.time }}</p>
                              </div>
                            </div>
                            <div class="text-right">
                              <p class="text-lg font-black text-neutral-900 dark:text-white">${{ order.total?.toFixed(2) }}</p>
                              <span :class="getStatusClass(order.status)" class="text-[10px] font-black px-2 py-0.5 rounded-full uppercase tracking-widest">{{ order.status }}</span>
                            </div>
                          </div>
                          
                          <!-- Expanded Details -->
                          <div v-if="expandedOrderId === order.orderId" class="mt-6 pt-6 border-t border-neutral-200 dark:border-neutral-700 animate-in fade-in slide-in-from-top-2 duration-300">
                            <div class="flex items-center gap-4 text-[10px] font-black text-neutral-400 uppercase tracking-widest mb-4">
                              <span>{{ order.orderType }}</span>
                              <span v-if="order.paymentMethod" class="flex items-center gap-1"><div class="w-1 h-1 rounded-full bg-neutral-300"></div> {{ order.paymentMethod }}</span>
                            </div>
                            <div class="space-y-3 bg-neutral-50 dark:bg-neutral-800/50 p-4 rounded-2xl">
                              <div v-for="(item, idx) in order.items" :key="idx" class="flex justify-between items-center text-sm">
                                <span class="text-neutral-700 dark:text-neutral-300 font-medium">
                                  <span class="w-6 h-6 inline-flex items-center justify-center bg-white dark:bg-neutral-800 rounded mr-2 text-[10px] font-black border border-neutral-200 dark:border-neutral-700">{{ item.qty }}</span>
                                  {{ item.name }}
                                </span>
                                <span class="font-bold text-neutral-500">${{ (item.price * item.qty).toFixed(2) }}</span>
                              </div>
                            </div>
                          </div>
                        </div>
                        
                        <div v-if="!history.recentOrders?.length" class="text-center py-20 bg-neutral-50/20">
                          <ClockIcon class="w-12 h-12 mx-auto mb-4 text-neutral-200" />
                          <p class="text-sm text-neutral-400 font-medium">No order data available.</p>
                        </div>
                     </div>
                   </CardContent>
                </Card>
              </div>

              <!-- Loyalty Ledger -->
              <Card class="overflow-hidden mb-6">
                <div class="p-6 border-b border-neutral-100 dark:border-neutral-800 flex items-center justify-between">
                  <div>
                    <h3 class="text-sm font-black text-neutral-500 uppercase tracking-widest">Loyalty Ledger</h3>
                    <p class="text-xs text-neutral-400 mt-1">Every earn, redeem, refund, and reversal for this customer</p>
                  </div>
                  <span class="text-[10px] font-bold text-neutral-400 uppercase tracking-widest">{{ history.loyaltyTransactions?.length || 0 }} entries</span>
                </div>
                <CardContent class="p-0">
                  <div class="divide-y divide-neutral-100 dark:divide-neutral-800 max-h-[360px] overflow-y-auto custom-scrollbar">
                    <div
                      v-for="tx in history.loyaltyTransactions"
                      :key="tx.transactionId"
                      class="p-4 flex items-center justify-between gap-4 hover:bg-neutral-50 dark:hover:bg-neutral-800/50 transition-colors"
                    >
                      <div class="flex items-center gap-4 min-w-0">
                        <div
                          :class="[
                            'w-11 h-11 rounded-2xl flex items-center justify-center font-black text-sm',
                            tx.points >= 0
                              ? 'bg-success-100 text-success-700 dark:bg-success-900/30 dark:text-success-400'
                              : 'bg-error-100 text-error-700 dark:bg-error-900/30 dark:text-error-400'
                          ]"
                        >
                          {{ tx.points >= 0 ? '+' : '' }}{{ tx.points }}
                        </div>
                        <div class="min-w-0">
                          <div class="flex items-center gap-2 flex-wrap">
                            <span class="text-sm font-black text-neutral-900 dark:text-white">{{ loyaltyTypeLabel(tx.type) }}</span>
                            <span v-if="tx.orderNo" class="text-[10px] font-bold text-primary-600 bg-primary-50 dark:bg-primary-900/20 px-2 py-0.5 rounded-full">{{ tx.orderNo }}</span>
                          </div>
                          <p class="text-xs text-neutral-500 truncate max-w-md">{{ tx.note || 'No note' }}</p>
                          <p class="text-[10px] text-neutral-400 font-bold uppercase tracking-wider mt-1">{{ tx.date }} at {{ tx.time }}</p>
                        </div>
                      </div>
                      <div class="text-right shrink-0">
                        <p class="text-[10px] font-black text-neutral-400 uppercase tracking-widest">Balance</p>
                        <p class="text-lg font-black text-neutral-900 dark:text-white">{{ tx.balanceAfter }} pts</p>
                      </div>
                    </div>

                    <div v-if="!history.loyaltyTransactions?.length" class="text-center py-16 bg-neutral-50/20">
                      <AwardIcon class="w-12 h-12 mx-auto mb-4 text-neutral-200" />
                      <p class="text-sm text-neutral-400 font-medium">No loyalty transactions yet.</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
           </template>

           <!-- Empty State: Choose a Customer -->
           <div v-else class="h-full flex flex-col items-center justify-center p-12 bg-neutral-50 dark:bg-neutral-800/30 rounded-[40px] text-center border-2 border-dashed border-neutral-200 dark:border-neutral-800">
               <div class="w-24 h-24 rounded-full bg-white dark:bg-neutral-800 flex items-center justify-center shadow-2xl shadow-primary-500/10 mb-8">
                  <UsersIcon class="w-12 h-12 text-neutral-300 dark:text-neutral-600" />
               </div>
              <h3 class="text-2xl font-black text-neutral-900 dark:text-white mb-3">Select a Customer</h3>
              <p class="text-neutral-500 max-w-sm">Browse the list on the left or search to view detailed profiles, purchase habits, and loyalty history.</p>
           </div>
        </div>
      </div>

      <Dialog v-model:open="showModal">
        <DialogContent class="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>{{ editingCustomer ? 'Update CRM Profile' : 'New Customer' }}</DialogTitle>
          </DialogHeader>
          <form @submit.prevent="saveCustomer" class="space-y-5">
            <div class="grid grid-cols-2 gap-4">
              <div class="col-span-2 space-y-2">
                <Label>Full Name</Label>
                <Input v-model="form.name" type="text" required placeholder="Customer Name" />
              </div>
              <div class="space-y-2">
                <Label>Phone Number</Label>
                <Input v-model="form.phone" type="text" required placeholder="+855 ..." />
              </div>
              <div class="space-y-2">
                <Label>Email</Label>
                <Input v-model="form.email" type="email" placeholder="email@example.com" />
              </div>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2">
                <Label>Gender</Label>
                <Select v-model="form.gender">
                  <SelectTrigger>
                    <SelectValue placeholder="Not Set" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="">Not Set</SelectItem>
                    <SelectItem value="MALE">Male</SelectItem>
                    <SelectItem value="FEMALE">Female</SelectItem>
                    <SelectItem value="OTHER">Other</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div class="space-y-2">
                <Label>Date of Birth</Label>
                <Input v-model="form.dob" type="date" />
              </div>
            </div>
            <div class="space-y-2">
              <Label>Address</Label>
              <Input v-model="form.address" type="text" placeholder="Street, City" />
            </div>
            <div class="space-y-2">
              <Label>Notes</Label>
              <Textarea v-model="form.notes" placeholder="Allergies, preferences, etc." />
            </div>
          </form>
          <DialogFooter>
            <Button variant="secondary" @click="closeModal">Cancel</Button>
            <Button type="submit" variant="default" :disabled="saving" @click="saveCustomer">{{ editingCustomer ? 'Save Profile' : 'Register Member' }}</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog v-model:open="showAdjustmentModal">
        <DialogContent class="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Adjust Loyalty Points</DialogTitle>
            <DialogDescription v-if="history">{{ history.customerName }} currently has {{ history.loyaltyPoints }} pts</DialogDescription>
          </DialogHeader>
          <form @submit.prevent="saveLoyaltyAdjustment" class="space-y-5">
            <div class="space-y-2">
              <Label>Point Change</Label>
              <Input v-model.number="adjustmentForm.points" type="number" required step="1" placeholder="Example: 10 or -5" />
              <p class="text-[11px] text-neutral-500">Use positive points to add. Use negative points to remove.</p>
            </div>
            <div class="space-y-2">
              <Label>Reason</Label>
              <Textarea v-model="adjustmentForm.reason" required placeholder="Example: Corrected missing points from receipt #123" />
            </div>
            <div class="rounded-2xl bg-neutral-50 dark:bg-neutral-800/60 p-4 flex items-center justify-between">
              <span class="text-xs font-bold text-neutral-500">Balance after save</span>
              <span class="text-lg font-black text-neutral-900 dark:text-white">{{ adjustmentPreviewBalance }} pts</span>
            </div>
          </form>
          <DialogFooter>
            <Button variant="secondary" @click="closeAdjustmentModal">Cancel</Button>
            <Button type="submit" variant="default" :disabled="savingAdjustment || !adjustmentForm.points || !adjustmentForm.reason.trim()" @click="saveLoyaltyAdjustment">{{ savingAdjustment ? 'Saving...' : 'Save Adjustment' }}</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { SearchIcon, UserPlusIcon, ShoppingBagIcon, DollarSignIcon, TrendingUpIcon, CalendarIcon, PhoneIcon, CalendarDaysIcon, StarIcon, HeartIcon, ClockIcon, AwardIcon, UsersIcon } from '@lucide/vue'

definePageMeta({
  layout: false
})

const { get, post, put } = useApi()
const toast = useToast()

// Interfaces
interface Customer {
  customerId: number
  name: string
  phone: string
  email?: string
  loyaltyPoints: number
  createdAt: string
}

interface CustomerHistory {
  customerId: number
  customerName: string
  phone: string
  totalOrders: number
  totalSpent: number
  loyaltyPoints: number
  memberSince: string
  membershipLevel: string
  recentOrders: any[]
  favoriteItems: any[]
  loyaltyTransactions: LoyaltyTransaction[]
}

interface LoyaltyTransaction {
  transactionId: number
  orderId?: number
  orderNo?: string
  type: string
  points: number
  balanceAfter: number
  note?: string
  date?: string
  time?: string
}

// State
const loading = ref(true)
const saving = ref(false)
const searchQuery = ref('')
const searchActive = ref(false)
const customers = ref<Customer[]>([])
const searchResults = ref<Customer[]>([])
const history = ref<CustomerHistory | null>(null)
const selectedCustomerId = ref<number | null>(null)
const expandedOrderId = ref<number | null>(null)
const silverThreshold = ref(300)
const goldThreshold = ref(1000)

// Modal State
const showModal = ref(false)
const editingCustomer = ref<any>(null)
const showAdjustmentModal = ref(false)
const savingAdjustment = ref(false)
const form = reactive({
  name: '',
  phone: '',
  email: '',
  gender: '',
  dob: '',
  address: '',
  notes: ''
})
const adjustmentForm = reactive({
  points: 0,
  reason: ''
})

// Computed
const displayCustomers = computed(() => searchActive.value ? searchResults.value : customers.value)

// CRM Summary Stats
const totalCustomerRevenue = computed(() => {
  if (history.value) return history.value.totalSpent || 0
  return 0
})
const avgCustomerSpend = computed(() => {
  if (history.value && history.value.totalOrders > 0) return history.value.totalSpent / history.value.totalOrders
  return 0
})
const goldMemberCount = computed(() => customers.value.filter((c: any) => c.membershipLevel === 'GOLD').length)

// Membership Tier Progress
const nextTierName = computed(() => {
  const tier = history.value?.membershipLevel || 'BRONZE'
  if (tier === 'BRONZE') return 'SILVER'
  if (tier === 'SILVER') return 'GOLD'
  return 'MAX'
})
const nextTierThreshold = computed(() => {
  const tier = history.value?.membershipLevel || 'BRONZE'
  if (tier === 'BRONZE') return silverThreshold.value
  return goldThreshold.value
})
const tierProgressPercent = computed(() => {
  const pts = history.value?.loyaltyPoints || 0
  const threshold = nextTierThreshold.value
  return Math.min(100, (pts / threshold) * 100)
})
const tierProgressColor = computed(() => {
  const tier = history.value?.membershipLevel || 'BRONZE'
  if (tier === 'GOLD') return 'bg-gradient-to-r from-warning-400 to-warning-600'
  if (tier === 'SILVER') return 'bg-gradient-to-r from-neutral-400 to-neutral-600'
  return 'bg-gradient-to-r from-orange-400 to-orange-600'
})
const adjustmentPreviewBalance = computed(() => {
  const currentPoints = history.value?.loyaltyPoints || 0
  const change = Number.isFinite(Number(adjustmentForm.points)) ? Number(adjustmentForm.points) : 0
  return Math.max(0, currentPoints + change)
})

// Actions
const fetchAllCustomers = async () => {
  loading.value = true
  try {
    const data = await get<Customer[]>('/customers')
    customers.value = data || []
  } catch (err) {
    console.error('Failed to fetch customers', err)
  } finally {
    loading.value = false
  }
}

const fetchLoyaltySettings = async () => {
  try {
    const data = await get<any[]>('/settings')
    const settingValue = (key: string, fallback: number) => {
      const raw = data?.find((s: any) => s.key === key)?.value
      const parsed = Number.parseInt(raw, 10)
      return Number.isFinite(parsed) ? parsed : fallback
    }
    silverThreshold.value = settingValue('LOYALTY_SILVER_THRESHOLD', 300)
    goldThreshold.value = settingValue('LOYALTY_GOLD_THRESHOLD', 1000)
  } catch (err) {
    console.error('Failed to fetch loyalty settings', err)
  }
}

const selectCustomer = async (cust: Customer) => {
  selectedCustomerId.value = cust.customerId
  loading.value = true
  try {
    const response = await get<{ data: CustomerHistory }>(`/customers/${cust.customerId}/history`)
    if (response?.data) {
      history.value = response.data
    }
  } catch (err) {
    console.error('Failed to fetch history', err)
    history.value = null
  } finally {
    loading.value = false
  }
}

const searchCustomer = async () => {
  if (!searchQuery.value.trim()) {
    clearSearch()
    return
  }
  
  loading.value = true
  searchActive.value = true
  try {
    const data = await get<Customer[]>(`/customers/search?query=${encodeURIComponent(searchQuery.value)}`)
    searchResults.value = data || []
    if (searchResults.value.length > 0) {
       selectCustomer(searchResults.value[0])
    } else {
       history.value = null
       selectedCustomerId.value = null
    }
  } catch (error) {
    console.error('Search failed:', error)
  } finally {
    loading.value = false
  }
}

const clearSearch = () => {
  searchQuery.value = ''
  searchActive.value = false
  searchResults.value = []
}

const openCreateModal = () => {
  editingCustomer.value = null
  form.name = ''
  form.phone = ''
  form.email = ''
  form.gender = ''
  form.dob = ''
  form.address = ''
  form.notes = ''
  showModal.value = true
}

const openEditModal = (cust: any) => {
  editingCustomer.value = cust
  form.name = cust.customerName || cust.name
  form.phone = cust.phone
  form.email = cust.email || ''
  form.gender = cust.gender || ''
  form.dob = cust.dob || ''
  form.address = cust.address || ''
  form.notes = cust.notes || ''
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
}

const openAdjustmentModal = () => {
  adjustmentForm.points = 0
  adjustmentForm.reason = ''
  showAdjustmentModal.value = true
}

const closeAdjustmentModal = () => {
  showAdjustmentModal.value = false
}

const saveCustomer = async () => {
  saving.value = true
  try {
    if (editingCustomer.value) {
      await put(`/customers/${editingCustomer.value.customerId}`, form)
    } else {
      await post('/customers/add', form)
    }
    await fetchAllCustomers()
    if (editingCustomer.value) toast.success('Customer profile updated')
    else toast.success('New customer registered')
  } catch (err: any) {
    toast.error(err.data?.message || 'Failed to save customer')
  } finally {
    saving.value = false
  }
}

const saveLoyaltyAdjustment = async () => {
  if (!history.value || !adjustmentForm.points || !adjustmentForm.reason.trim()) return

  savingAdjustment.value = true
  try {
    await post(`/customers/${history.value.customerId}/loyalty-adjustments`, {
      points: Number(adjustmentForm.points),
      reason: adjustmentForm.reason.trim()
    })
    toast.success('Loyalty points adjusted')
    closeAdjustmentModal()
    const customerId = history.value.customerId
    await fetchAllCustomers()
    const refreshed = customers.value.find((customer) => customer.customerId === customerId)
    if (refreshed) {
      await selectCustomer(refreshed)
    }
  } catch (err: any) {
    toast.error(err.data?.message || 'Failed to adjust loyalty points')
  } finally {
    savingAdjustment.value = false
  }
}

const toggleOrderDetails = (orderId: number) => {
  expandedOrderId.value = expandedOrderId.value === orderId ? null : orderId
}

// Helpers
const formatDate = (dateStr: string) => {
  if (!dateStr) return 'N/A'
  return new Date(dateStr).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })
}

const getStatusClass = (status: string) => {
  const classes: Record<string, string> = {
    PAID: 'bg-success-100 text-success-700 dark:bg-success-900/30 dark:text-success-400',
    PENDING: 'bg-warning-100 text-warning-700 dark:bg-warning-900/30 dark:text-warning-400',
    CANCELLED: 'bg-error-100 text-error-700 dark:bg-error-900/30 dark:text-error-400'
  }
  return classes[status] || 'bg-neutral-100 text-neutral-700'
}

const getMemberBadgeClass = (level: string) => {
  if (level === 'GOLD') return 'bg-warning-100 text-warning-700 dark:bg-warning-900/30 dark:text-warning-400'
  if (level === 'SILVER') return 'bg-neutral-200 text-neutral-700 dark:bg-neutral-700 dark:text-neutral-300'
  return 'bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400'
}

const loyaltyTypeLabel = (type: string) => {
  const labels: Record<string, string> = {
    EARN: 'Earned Points',
    REDEEM: 'Redeemed Points',
    REFUND_REDEEM: 'Refunded Redemption',
    REVERT_EARN: 'Reversed Earned Points',
    ADJUSTMENT: 'Manual Adjustment',
  }
  return labels[type] || type
}

onMounted(() => {
  fetchLoyaltySettings()
  fetchAllCustomers()
})
</script>

<style scoped>
@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}
.animate-shimmer {
  animation: shimmer 2s ease-in-out infinite;
}
</style>

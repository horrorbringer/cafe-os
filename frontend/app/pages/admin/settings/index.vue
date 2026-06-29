<template>
  <NuxtLayout name="admin">
    <div class="space-y-6">
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbPage>Settings</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>

      <!-- Header -->
      <div class="flex items-center justify-between">
        <div>
          <h2 class="text-2xl font-bold text-neutral-900 dark:text-white">
            Settings & Access Control
          </h2>
          <p class="text-neutral-500 text-sm">
            Manage user accounts, system roles, and permissions.
          </p>
        </div>
      </div>

      <!-- Tabs -->
      <Tabs v-model="activeTab">
        <TabsList variant="line">
          <TabsTrigger v-for="tab in tabs" :key="tab.id" :value="tab.id">{{ tab.name }}</TabsTrigger>
        </TabsList>

      <!-- Tab Content: Users -->
      <TabsContent value="users" class="space-y-4">
        <div class="flex justify-between items-center">
          <div class="text-sm text-neutral-500">
            Total Users: {{ users.length }}
          </div>
          <Button @click="openUserModal()">
            <PlusIcon class="w-4 h-4" />
            Add User
          </Button>
        </div>

        <div
          class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-800 rounded-2xl overflow-hidden shadow-sm"
        >
          <Table>
            <TableHeader>
              <TableRow
                class="bg-neutral-50 dark:bg-neutral-800/50 border-b border-neutral-200 dark:border-neutral-800"
              >
                <TableHead>
                  Username
                </TableHead>
                <TableHead>
                  Linked Employee
                </TableHead>
                <TableHead>
                  Role
                </TableHead>
                <TableHead class="text-right">
                  Actions
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <template v-if="loading">
                <TableRow v-for="i in 5" :key="i" class="animate-pulse">
                  <TableCell v-for="j in 4" :key="j">
                    <div
                      class="h-4 bg-neutral-100 dark:bg-neutral-800 rounded"
                    ></div>
                  </TableCell>
                </TableRow>
              </template>
              <template v-else>
                <TableRow
                  v-for="user in users"
                  :key="user.userId"
                >
                  <TableCell>
                    <div class="flex items-center gap-3">
                      <div
                        class="w-8 h-8 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center text-sm font-bold text-neutral-600 dark:text-neutral-400"
                      >
                        {{ user.userName.charAt(0).toUpperCase() }}
                      </div>
                      <span
                        class="font-medium text-neutral-900 dark:text-white"
                        >{{ user.userName }}</span
                      >
                    </div>
                  </TableCell>
                  <TableCell>
                    <span
                      v-if="user.employee"
                      class="text-neutral-600 dark:text-neutral-400"
                      >{{ user.employee.fullName }}</span
                    >
                    <span v-else class="text-neutral-400 italic"
                      >No Employee linked</span
                    >
                  </TableCell>
                  <TableCell>
                    <span
                      class="px-2 py-1 rounded-lg text-[10px] font-bold uppercase bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-400"
                    >
                      {{ user.role?.roleName || "No Role" }}
                    </span>
                  </TableCell>
                  <TableCell class="text-right">
                    <div class="flex items-center justify-end gap-2">
                      <Button variant="ghost" size="icon" @click="openUserModal(user)">
                        <PencilIcon class="w-4 h-4" />
                      </Button>
                      <Button variant="ghost" size="icon" @click="confirmDeleteUser(user.userId)">
                        <Trash2Icon class="w-4 h-4" />
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              </template>
            </TableBody>
          </Table>
        </div>

      </TabsContent>
      <!-- Tab Content: Roles -->
      <TabsContent value="roles" class="space-y-6">
        <div class="flex justify-between items-center">
          <div>
            <h3
              class="text-lg font-bold text-neutral-900 dark:text-white leading-tight"
            >
              System Roles
            </h3>
            <p class="text-xs text-neutral-500 font-medium mt-1">
              Define and configure access levels for your team
            </p>
          </div>
          <Button @click="openRoleModal()">
            <PlusIcon class="w-4 h-4" />
            Create Role
          </Button>
        </div>

        <!-- Role Cards Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div
            v-for="role in roles"
            :key="role.roleId"
            class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-800 rounded-3xl p-6 hover:border-primary-500/50 transition-all group relative overflow-hidden shadow-sm hover:shadow-xl dark:shadow-none"
          >
            <div class="flex justify-between items-start mb-6">
              <div
                class="w-12 h-12 rounded-2xl bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center text-primary-600 dark:text-primary-400"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="w-6 h-6"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                >
                  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                </svg>
              </div>
              <div class="flex gap-1 opacity-0 group-hover:opacity-100 transition-all translate-y-2 group-hover:translate-y-0">
                <Button variant="ghost" size="icon" @click="openRoleModal(role)">
                  <PencilIcon class="w-4 h-4" />
                </Button>
                <Button
                  v-if="role.roleName !== 'SUPER_ADMIN'"
                  variant="ghost"
                  size="icon"
                  @click="confirmDeleteRole(role.roleId)"
                >
                  <Trash2Icon class="w-4 h-4" />
                </Button>
              </div>
            </div>

            <h3 class="text-xl font-bold text-neutral-900 dark:text-white mb-2">
              {{ role.roleName }}
            </h3>
            <p
              class="text-neutral-500 dark:text-neutral-400 text-sm mb-6 line-clamp-2 min-h-[40px]"
            >
              {{
                role.description ||
                "Access and management permissions for system functions."
              }}
            </p>

            <div class="flex flex-wrap gap-2 mt-auto">
              <span
                v-for="perm in role.permissions?.slice(0, 3)"
                :key="perm.code"
                class="px-2.5 py-1 rounded-lg bg-neutral-100 dark:bg-neutral-800 text-[10px] font-bold text-neutral-600 dark:text-neutral-400 uppercase tracking-wider"
              >
                {{ perm.code.split("_").pop() }}
              </span>
              <span
                v-if="role.permissions?.length > 3"
                class="px-2.5 py-1 rounded-lg bg-primary-100 dark:bg-primary-900/20 text-[10px] font-bold text-primary-600 dark:text-primary-400"
              >
                +{{ role.permissions.length - 3 }} more
              </span>
            </div>
          </div>
        </div>

      </TabsContent>
      <!-- Tab Content: System Config -->
      <TabsContent value="config" class="space-y-6">
        <div
          class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-800 rounded-2xl p-6 shadow-sm"
        >
          <div class="flex justify-between items-center mb-6">
            <h3 class="text-lg font-bold text-neutral-900 dark:text-white">
              General Configuration
            </h3>
            <Button
              @click="saveSettings"
              variant="default"
              class="py-2 px-4 text-xs font-bold uppercase tracking-wider flex items-center gap-2"
              :disabled="saving"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="w-4 h-4"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
              >
                <path
                  d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"
                ></path>
                <polyline points="17 21 17 13 7 13 7 21"></polyline>
                <polyline points="7 3 7 8 15 8"></polyline>
              </svg>
              Save Changes
            </Button>
          </div>

          <div
            v-if="settings.length === 0"
            class="text-center py-8 text-neutral-500"
          >
            No settings found.
          </div>

          <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div v-for="setting in settings" :key="setting.id" class="relative group">
              <label
                class="block text-xs font-bold text-neutral-500 uppercase tracking-widest mb-2"
                :title="setting.key"
                >{{ setting.description || setting.key }}</label
              >
              <div class="relative">
                <input
                  v-if="setting.key !== 'THEME'"
                  :type="isSensitive(setting.key) && !showSettings[setting.key] ? 'password' : 'text'"
                  v-model="setting.value"
                  class="w-full bg-neutral-50 dark:bg-neutral-800 border-none rounded-xl px-4 py-3 text-sm ring-1 ring-neutral-200 dark:ring-neutral-700 focus:ring-2 focus:ring-primary-500 pr-10"
                />
                <button
                  v-if="isSensitive(setting.key)"
                  type="button"
                  @click="showSettings[setting.key] = !showSettings[setting.key]"
                  class="absolute right-3 top-1/2 -translate-y-1/2 text-neutral-400 hover:text-neutral-600 dark:hover:text-neutral-300"
                >
                  <svg v-if="showSettings[setting.key]" xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
                  <svg v-else xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                </button>
              </div>
              <select
                v-if="setting.key === 'THEME'"
                v-model="setting.value"
                class="w-full bg-neutral-50 dark:bg-neutral-800 border-none rounded-xl px-4 py-3 text-sm ring-1 ring-neutral-200 dark:ring-neutral-700 focus:ring-2 focus:ring-primary-500"
              >
                <option value="LIGHT">Light</option>
                <option value="DARK">Dark</option>
              </select>
            </div>
          </div>
        </div>

      </TabsContent>
      <!-- Tab Content: Loyalty Program -->
      <TabsContent value="loyalty" class="space-y-6">
        <div
          class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-800 rounded-2xl p-6 shadow-sm"
        >
          <div
            class="flex items-center gap-4 mb-6 pb-6 border-b border-neutral-200 dark:border-neutral-800"
          >
            <div
              class="w-12 h-12 rounded-xl bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="w-6 h-6 text-amber-600"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
              >
                <path
                  d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"
                />
              </svg>
            </div>
            <div>
              <h3 class="text-lg font-bold text-neutral-900 dark:text-white">
                Loyalty Rewards Program
              </h3>
              <p class="text-sm text-neutral-500">
                Configure how points are earned and redeemed
              </p>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
            <!-- Point Calculation -->
            <div class="space-y-4">
              <h4
                class="text-sm font-bold text-neutral-900 dark:text-white flex items-center gap-2"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="w-4 h-4 text-primary-500"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                >
                  <path
                    d="M12 1v22M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"
                  />
                </svg>
                Earning & Redemption
              </h4>

              <div
                class="space-y-4 p-4 bg-neutral-50 dark:bg-neutral-800/50 rounded-xl"
              >
                <div>
                  <label
                    class="block text-xs font-bold text-neutral-500 uppercase tracking-widest mb-2"
                    >Point Earn Rate</label
                  >
                  <div class="flex items-center gap-3">
                    <input
                      v-model="loyaltyConfig.earnRate"
                      type="number"
                      step="0.1"
                      class="w-full bg-white dark:bg-neutral-800 border-none rounded-xl px-4 py-3 text-sm ring-1 ring-neutral-200 dark:ring-neutral-700 focus:ring-2 focus:ring-primary-500"
                    />
                    <span class="text-sm text-neutral-500 whitespace-nowrap"
                      >Points per $1</span
                    >
                  </div>
                  <div
                    class="mt-3 rounded-lg border border-primary-200 bg-primary-50 p-3 text-xs text-primary-900 dark:border-primary-900/40 dark:bg-primary-950/30 dark:text-primary-200"
                  >
                    <p class="font-bold">
                      Formula: order total x earn rate, rounded down.
                    </p>
                    <p class="mt-1">
                      With current rate, $1.00 earns
                      <strong>{{ earnPreviewOneDollar }}</strong> point(s), and
                      $0.10 earns
                      <strong>{{ earnPreviewTenCents }}</strong> point(s).
                    </p>
                    <p class="mt-1 text-primary-700 dark:text-primary-300">
                      Use 1 for 1 point per $1. Use 10 for 1 point per $0.10.
                      Use 0.1 for 1 point per $10.
                    </p>
                  </div>
                  <div
                    class="mt-3 rounded-lg border border-neutral-200 bg-white p-3 dark:border-neutral-700 dark:bg-neutral-900"
                  >
                    <label
                      class="block text-[10px] font-bold text-neutral-500 uppercase tracking-widest mb-2"
                      >Test order total</label
                    >
                    <div class="flex items-center gap-3">
                      <input
                        v-model="loyaltyConfig.sampleOrderTotal"
                        type="number"
                        min="0"
                        step="0.01"
                        class="w-full bg-neutral-50 dark:bg-neutral-800 border-none rounded-lg px-3 py-2 text-sm ring-1 ring-neutral-200 dark:ring-neutral-700 focus:ring-2 focus:ring-primary-500"
                      />
                      <span class="text-sm font-black text-neutral-900 dark:text-white whitespace-nowrap">
                        = {{ sampleEarnedPoints }} pts
                      </span>
                    </div>
                    <p class="mt-2 text-[11px] text-neutral-500">
                      Points are whole numbers, so decimal results are rounded down.
                    </p>
                  </div>
                </div>

                <div>
                  <label
                    class="block text-xs font-bold text-neutral-500 uppercase tracking-widest mb-2"
                    >Point Value ($)</label
                  >
                  <div class="flex items-center gap-3">
                    <input
                      v-model="loyaltyConfig.redeemRate"
                      type="number"
                      step="0.01"
                      class="w-full bg-white dark:bg-neutral-800 border-none rounded-xl px-4 py-3 text-sm ring-1 ring-neutral-200 dark:ring-neutral-700 focus:ring-2 focus:ring-primary-500"
                    />
                    <span class="text-sm text-neutral-500 whitespace-nowrap"
                      >Discount per point</span
                    >
                  </div>
                  <div
                    class="mt-3 rounded-lg border border-amber-200 bg-amber-50 p-3 text-xs text-amber-900 dark:border-amber-900/40 dark:bg-amber-950/30 dark:text-amber-200"
                  >
                    <p class="font-bold">
                      Formula: points used x point value = discount.
                    </p>
                    <p class="mt-1">
                      With current value, 1 point saves
                      <strong>${{ redeemPreviewOnePoint }}</strong>, and 10
                      points save <strong>${{ redeemPreviewTenPoints }}</strong>.
                    </p>
                    <p class="mt-1 text-amber-700 dark:text-amber-300">
                      Use 0.1 if 10 points should equal $1.00 discount.
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Membership Tiers -->
            <div class="space-y-4">
              <h4
                class="text-sm font-bold text-neutral-900 dark:text-white flex items-center gap-2"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="w-4 h-4 text-amber-500"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                >
                  <path
                    d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6M18 9h1.5a2.5 2.5 0 0 0 0-5H18M4 22h16M10 14.66V17c0 .55.45 1 1 1h2c.55 0 1-.45 1-1v-2.34M12 11c1.33 0 2.3-1.63 1.4-2.8a1.3 1.3 0 0 0-1.4-.2 1.3 1.3 0 0 0-1.4.2c-.9 1.17.07 2.8 1.4 2.8z"
                  />
                  <path
                    d="M10 2c0 .55.45 1 1 1h2c.55 0 1-.45 1-1V1c0-.55-.45-1-1-1h-2c-.55 0-1 .45-1 1v1z"
                  />
                  <path
                    d="M5.5 10c.28 0 .5.22.5.5V14c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2v-3.5c0-.28.22-.5.5-.5h.5c.55 0 1-.45 1-1V5c0-.55-.45-1-1-1h-15c-.55 0-1 .45-1 1v4c0 .55.45 1 1 1h.5z"
                  />
                </svg>
                Membership Tiers
              </h4>

              <div
                class="space-y-4 p-4 bg-neutral-50 dark:bg-neutral-800/50 rounded-xl"
              >
                <div>
                  <label
                    class="block text-xs font-bold text-neutral-500 uppercase tracking-widest mb-2"
                    >Silver Tier Threshold</label
                  >
                  <div class="flex items-center gap-3">
                    <input
                      v-model="loyaltyConfig.silverThreshold"
                      type="number"
                      class="w-full bg-white dark:bg-neutral-800 border-none rounded-xl px-4 py-3 text-sm ring-1 ring-neutral-200 dark:ring-neutral-700 focus:ring-2 focus:ring-primary-500"
                    />
                    <span class="text-sm text-neutral-500 whitespace-nowrap"
                      >Points</span
                    >
                  </div>
                </div>

                <div>
                  <label
                    class="block text-xs font-bold text-neutral-500 uppercase tracking-widest mb-2"
                    >Gold Tier Threshold</label
                  >
                  <div class="flex items-center gap-3">
                    <input
                      v-model="loyaltyConfig.goldThreshold"
                      type="number"
                      class="w-full bg-white dark:bg-neutral-800 border-none rounded-xl px-4 py-3 text-sm ring-1 ring-neutral-200 dark:ring-neutral-700 focus:ring-2 focus:ring-primary-500"
                    />
                    <span class="text-sm text-neutral-500 whitespace-nowrap"
                      >Points</span
                    >
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div
            class="flex justify-end p-6 border-t border-neutral-100 dark:border-neutral-800 -mx-6 -mb-6"
          >
            <Button
              @click="saveLoyaltyConfig"
              :disabled="savingLoyalty"
              variant="default"
              class="py-3 px-8 text-xs font-bold uppercase tracking-widest flex items-center gap-2 shadow-xl shadow-primary-500/20"
            >
              <div
                v-if="savingLoyalty"
                class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"
              ></div>
              <svg
                v-else
                xmlns="http://www.w3.org/2000/svg"
                class="w-4 h-4"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
              >
                <path
                  d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"
                ></path>
                <polyline points="17 21 17 13 7 13 7 21"></polyline>
                <polyline points="7 3 7 8 15 8"></polyline>
              </svg>
              Apply Settings
            </Button>
          </div>
        </div>

      </TabsContent>
      <!-- Tab Content: Notifications -->
      <TabsContent value="notifications" class="space-y-6">
        <div
          class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-800 rounded-2xl p-6 shadow-sm"
        >
          <div
            class="flex items-center gap-4 mb-6 pb-6 border-b border-neutral-200 dark:border-neutral-800"
          >
            <div
              class="w-12 h-12 rounded-xl bg-[#0088cc]/10 flex items-center justify-center"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="w-6 h-6 text-[#0088cc]"
                viewBox="0 0 24 24"
                fill="currentColor"
              >
                <path
                  d="m20.665 3.717-17.73 6.837c-1.21.486-1.203 1.161-.222 1.462l4.552 1.42 10.532-6.645c.498-.303.953-.14.579.192l-8.533 7.701h-.002l.002.001-.314 4.692c.46 0 .663-.211.921-.46l2.211-2.15 4.599 3.397c.848.467 1.457.227 1.668-.787l3.019-14.228c.309-1.239-.473-1.8-1.282-1.432z"
                />
              </svg>
            </div>
            <div>
              <h3 class="text-lg font-bold text-neutral-900 dark:text-white">
                Telegram Notifications
              </h3>
              <p class="text-sm text-neutral-500">
                Receive alerts via Telegram Bot
              </p>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <div>
              <label
                class="block text-xs font-bold text-neutral-500 uppercase tracking-widest mb-2"
                >Bot Token</label
              >
              <div class="relative">
                <input
                  v-model="telegramConfig.botToken"
                  :type="showBotToken ? 'text' : 'password'"
                  placeholder="123456789:ABCdefGHIjklMNOpqrsTUVwxyz"
                  class="w-full bg-neutral-50 dark:bg-neutral-800 border-none rounded-xl px-4 py-3 text-sm ring-1 ring-neutral-200 dark:ring-neutral-700 focus:ring-2 focus:ring-primary-500 font-mono pr-10"
                />
                <button
                  type="button"
                  @click="showBotToken = !showBotToken"
                  class="absolute right-3 top-1/2 -translate-y-1/2 text-neutral-400 hover:text-neutral-600 dark:hover:text-neutral-300"
                >
                  <svg v-if="showBotToken" xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
                  <svg v-else xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                </button>
              </div>
              <p class="text-[10px] text-neutral-400 mt-1">
                Get from @BotFather on Telegram
              </p>
            </div>
            <div>
              <label
                class="block text-xs font-bold text-neutral-500 uppercase tracking-widest mb-2"
                >Chat ID</label
              >
              <div class="relative">
                <input
                  v-model="telegramConfig.chatId"
                  :type="showChatId ? 'text' : 'password'"
                  placeholder="-1001234567890"
                  class="w-full bg-neutral-50 dark:bg-neutral-800 border-none rounded-xl px-4 py-3 text-sm ring-1 ring-neutral-200 dark:ring-neutral-700 focus:ring-2 focus:ring-primary-500 font-mono pr-10"
                />
                <button
                  type="button"
                  @click="showChatId = !showChatId"
                  class="absolute right-3 top-1/2 -translate-y-1/2 text-neutral-400 hover:text-neutral-600 dark:hover:text-neutral-300"
                >
                  <svg v-if="showChatId" xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
                  <svg v-else xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                </button>
              </div>
              <p class="text-[10px] text-neutral-400 mt-1">
                Your user or group chat ID
              </p>
            </div>
          </div>

          <div class="flex gap-3 mb-8">
            <Button
              @click="saveTelegramConfig"
              :disabled="savingTelegram"
              variant="default"
              class="py-2 px-4 text-xs font-bold uppercase tracking-wider"
            >
              Save Configuration
            </Button>
            <button
              @click="testTelegram"
              :disabled="testingTelegram"
              class="py-2 px-4 text-xs font-bold uppercase tracking-wider bg-[#0088cc] hover:bg-[#0077b5] text-white rounded-2xl transition-colors flex items-center gap-2"
            >
              <div
                v-if="testingTelegram"
                class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"
              ></div>
              <svg
                v-else
                xmlns="http://www.w3.org/2000/svg"
                class="w-4 h-4"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
              >
                <path d="M22 2 11 13" />
                <path d="m22 2-7 20-4-9-9-4 20-7z" />
              </svg>
              Test Connection
            </button>
          </div>

          <h4
            class="text-sm font-bold text-neutral-700 dark:text-neutral-300 mb-4"
          >
            Alert Types
          </h4>
          <div class="space-y-4">
            <div
              class="flex items-center justify-between p-4 bg-neutral-50 dark:bg-neutral-800 rounded-xl"
            >
              <div>
                <p class="font-medium text-neutral-900 dark:text-white">
                  Low Stock Alerts
                </p>
                <p class="text-xs text-neutral-500">
                  Notify when ingredients are below reorder level
                </p>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="telegramConfig.lowStock"
                  class="sr-only peer"
                />
                <div
                  class="w-11 h-6 bg-neutral-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 dark:peer-focus:ring-primary-800 rounded-full peer dark:bg-neutral-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-primary-600"
                ></div>
              </label>
            </div>

            <div
              class="flex items-center justify-between p-4 bg-neutral-50 dark:bg-neutral-800 rounded-xl"
            >
              <div class="flex-1">
                <p class="font-medium text-neutral-900 dark:text-white">
                  Large Order Alerts
                </p>
                <p class="text-xs text-neutral-500">
                  Notify for orders above threshold
                </p>
              </div>
              <div class="flex items-center gap-3">
                <div class="flex items-center gap-1">
                  <span class="text-sm text-neutral-500">$</span>
                  <input
                    v-model="telegramConfig.largeOrderThreshold"
                    type="number"
                    class="w-20 bg-white dark:bg-neutral-700 border-none rounded-lg px-2 py-1 text-sm text-center ring-1 ring-neutral-200 dark:ring-neutral-600"
                  />
                </div>
                <label class="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    v-model="telegramConfig.largeOrder"
                    class="sr-only peer"
                  />
                  <div
                    class="w-11 h-6 bg-neutral-200 peer-focus:outline-none rounded-full peer dark:bg-neutral-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"
                  ></div>
                </label>
              </div>
            </div>

            <div
              class="flex items-center justify-between p-4 bg-neutral-50 dark:bg-neutral-800 rounded-xl"
            >
              <div>
                <p class="font-medium text-neutral-900 dark:text-white">
                  Shift Discrepancy Alerts
                </p>
                <p class="text-xs text-neutral-500">
                  Notify when cash doesn't match expected amount
                </p>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="telegramConfig.shiftDiscrepancy"
                  class="sr-only peer"
                />
                <div
                  class="w-11 h-6 bg-neutral-200 peer-focus:outline-none rounded-full peer dark:bg-neutral-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"
                ></div>
              </label>
            </div>
          </div>
        </div>
      </TabsContent>
    </Tabs>

      <!-- User Modal -->
      <Dialog v-model:open="showUserModal">
        <DialogContent class="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>{{ editingUser ? "Edit User Account" : "New User Account" }}</DialogTitle>
          </DialogHeader>
          <form @submit.prevent="saveUser" class="space-y-4">
            <div class="space-y-2">
              <Label>Username</Label>
              <Input v-model="userForm.userName" type="text" required placeholder="Enter username" />
            </div>
            <div class="space-y-2">
              <Label>Password</Label>
              <Input v-model="userForm.password" type="password" :required="!editingUser" :placeholder="editingUser ? 'Leave blank to keep current' : 'Enter password'" />
            </div>
            <div class="space-y-2">
              <Label>Link Employee</Label>
              <Select v-model="selectedUserEmployeeId">
                <SelectTrigger>
                  <SelectValue placeholder="Select an employee" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="emp in employees" :key="emp.employeeId" :value="String(emp.employeeId)">
                    {{ emp.fullName }} ({{ emp.position }})
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="space-y-2">
              <Label>Assign Role</Label>
              <Select v-model="selectedUserRoleId">
                <SelectTrigger>
                  <SelectValue placeholder="Select a role" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="role in roles" :key="role.roleId" :value="String(role.roleId)">
                    {{ role.roleName }}
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
          </form>
          <DialogFooter>
            <Button variant="secondary" @click="showUserModal = false">Cancel</Button>
            <Button type="submit" variant="default" :disabled="saving" @click="saveUser">
              {{ editingUser ? "Update User" : "Create User" }}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog v-model:open="showRoleModal">
        <DialogContent class="sm:max-w-5xl bg-white dark:bg-neutral-900 border-neutral-200 dark:border-neutral-800 !p-0 flex flex-col max-h-[90vh]" :show-close-button="false">
          <div class="p-8 border-b border-neutral-100 dark:border-neutral-800 flex justify-between items-center shrink-0 bg-neutral-50/30 dark:bg-neutral-800/20">
            <h2 class="text-2xl font-black text-neutral-900 dark:text-white tracking-tight">{{ editingRole ? "Edit Role Profile" : "Create New System Role" }}</h2>
          </div>
          <div class="p-8 overflow-y-auto flex-1 custom-scrollbar">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
              <div class="space-y-6">
                <div>
                  <label class="block text-sm font-medium text-neutral-400 mb-2">Role Name</label>
                  <input v-model="roleForm.roleName" type="text" placeholder="e.g. Store Manager" class="w-full bg-neutral-50 dark:bg-neutral-800 border-none rounded-2xl px-5 py-4 text-neutral-900 dark:text-white ring-1 ring-neutral-200 dark:ring-neutral-700 focus:ring-2 focus:ring-primary-500 font-bold tracking-wide transition-all uppercase placeholder:font-normal placeholder:lowercase" />
                </div>
                <div>
                  <label class="block text-sm font-medium text-neutral-400 mb-2">Description</label>
                  <textarea v-model="roleForm.description" rows="4" placeholder="Provide a brief summary of this role's purpose..." class="w-full bg-neutral-50 dark:bg-neutral-800 border-none rounded-2xl px-5 py-4 text-neutral-900 dark:text-white ring-1 ring-neutral-200 dark:ring-neutral-700 focus:ring-2 focus:ring-primary-500 transition-all resize-none placeholder:font-normal text-sm"></textarea>
                </div>
                <div class="p-6 rounded-2xl bg-primary-500/5 border border-primary-500/10">
                  <h4 class="text-xs font-bold text-primary-400 uppercase tracking-widest mb-2">Security Impact</h4>
                  <p class="text-xs text-neutral-400 leading-relaxed">This role will grant access to <strong>{{ roleForm.permissionIds.length }}</strong> specific system capabilities. Changes will take effect for all assigned users upon their next session.</p>
                </div>
              </div>
              <div class="space-y-4">
                <label class="block text-sm font-medium text-neutral-400 mb-0">Permissions Portfolio</label>
                <div class="space-y-6 max-h-[600px] overflow-y-auto pr-4 custom-scrollbar">
                  <div v-for="(perms, group) in groupedPermissions" :key="group" class="space-y-3">
                    <div class="flex items-center gap-2">
                      <span class="text-[10px] font-bold text-neutral-500 uppercase tracking-widest">{{ group }}</span>
                      <div class="flex-1 h-px bg-neutral-700/50"></div>
                    </div>
                    <div class="grid grid-cols-1 gap-2">
                      <label v-for="perm in perms" :key="perm.permissionId" class="flex items-center gap-3 p-4 rounded-2xl bg-white dark:bg-neutral-800/50 hover:bg-white dark:hover:bg-neutral-800 border border-neutral-100 dark:border-neutral-800 hover:border-primary-200 dark:hover:border-primary-900 transition-all cursor-pointer group hover:shadow-lg hover:shadow-primary-500/5 active:scale-[0.98]">
                        <input type="checkbox" :value="perm.permissionId" v-model="roleForm.permissionIds" class="w-4 h-4 rounded border-neutral-700 bg-neutral-800 text-primary-500 focus:ring-primary-500 transition-all cursor-pointer" />
                        <div class="flex-1 min-w-0">
                          <div class="text-xs font-bold text-neutral-200 group-hover:text-white transition-colors uppercase whitespace-nowrap overflow-hidden text-ellipsis">{{ perm.code.replace(/_/g, " ") }}</div>
                          <div class="text-[9px] text-neutral-500 truncate mt-0.5">{{ perm.description || "Access to " + group.toLowerCase() + " features" }}</div>
                        </div>
                      </label>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="p-8 border-t border-neutral-100 dark:border-neutral-800 flex justify-end gap-4 shrink-0 bg-neutral-50/50 dark:bg-neutral-800/20">
            <Button variant="outline" @click="showRoleModal = false">Cancel</Button>
            <Button @click="saveRole" :disabled="saving || !roleForm.roleName" variant="default" class="px-10 py-3.5 rounded-2xl flex items-center gap-3 disabled:opacity-50 text-sm uppercase tracking-widest font-black shadow-2xl shadow-primary-500/30">
              <span v-if="saving" class="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin"></span>
              {{ editingRole ? "Update Profile" : "Activate Role" }}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      <!-- Delete User Confirmation -->
      <AlertDialog v-model:open="showDeleteUserAlert">
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete User</AlertDialogTitle>
            <AlertDialogDescription>Are you sure you want to delete this user? This action cannot be undone.</AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction @click="executeDeleteUser">Delete</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      <!-- Delete Role Confirmation -->
      <AlertDialog v-model:open="showDeleteRoleAlert">
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Role</AlertDialogTitle>
            <AlertDialogDescription>Are you sure you want to delete this role? This action cannot be undone.</AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction @click="executeDeleteRole">Delete</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch, computed } from "vue"
import { useRoute } from "vue-router"
import { PlusIcon, PencilIcon, Trash2Icon, EyeIcon, EyeOffIcon, SendIcon, SettingsIcon, GiftIcon, BellIcon } from "@lucide/vue"

definePageMeta({
  layout: false,
})

const route = useRoute()
const { get, post, put, del } = useApi()
const toast = useToast()
const { hasPermission } = usePermissions()

const tabs = [
  { id: "users", name: "User Accounts" },
  { id: "roles", name: "Roles & Access" },
  { id: "loyalty", name: "Loyalty Program" },
  { id: "notifications", name: "Notifications" },
  { id: "config", name: "System Config" },
]

const activeTab = ref("users")

onMounted(() => {
  if (route.query.tab && tabs.some((t) => t.id === route.query.tab)) {
    activeTab.value = route.query.tab as string
  }
  fetchData()
})

watch(
  () => route.query.tab,
  (newTab) => {
    if (newTab && tabs.some((t) => t.id === newTab)) {
      activeTab.value = newTab as string
    }
  },
)

const users = ref<any[]>([])
const roles = ref<any[]>([])
const employees = ref<any[]>([])
const permissions = ref<any[]>([])
const settings = ref<any[]>([])
const loading = ref(true)
const saving = ref(false)

const showUserModal = ref(false)
const showRoleModal = ref(false)
const editingUser = ref<any>(null)
const editingRole = ref<any>(null)
const showDeleteUserAlert = ref(false)
const showDeleteRoleAlert = ref(false)
const userToDelete = ref<number | null>(null)
const roleToDelete = ref<number | null>(null)

const selectedUserEmployeeId = ref("")
const selectedUserRoleId = ref("")

const userForm = reactive({
  userName: "",
  password: "",
  employeeId: null as number | null,
  roleId: null as number | null,
  isActive: true,
})

const roleForm = reactive({
  roleName: "",
  description: "",
  permissionIds: [] as number[],
});

const groupedPermissions = computed(() => {
  const groups: Record<string, any[]> = {};
  permissions.value.forEach((p) => {
    let group = "System";
    if (p.code.startsWith("POS_")) group = "POS";
    else if (p.code.startsWith("INV_") || p.code.startsWith("RECIPE_"))
      group = "Inventory";
    else if (p.code.startsWith("EMP_")) group = "Employees";
    else if (
      p.code.startsWith("MENU_") ||
      p.code.startsWith("CAT_") ||
      p.code.startsWith("ADDON_")
    )
      group = "Menu";
    else if (p.code.startsWith("RPT_")) group = "Reports";

    if (!groups[group]) groups[group] = [];
    groups[group].push(p);
  });
  return groups;
});

// Telegram Configuration
const telegramConfig = reactive({
  botToken: "",
  chatId: "",
  lowStock: false,
  largeOrder: false,
  largeOrderThreshold: 100,
  shiftDiscrepancy: false,
});

// Loyalty Configuration
const loyaltyConfig = reactive({
  earnRate: 1.0,
  redeemRate: 0.1,
  silverThreshold: 300,
  goldThreshold: 1000,
  sampleOrderTotal: 10,
});
const earnPreviewOneDollar = computed(() =>
  Math.floor(1 * Number(loyaltyConfig.earnRate || 0)),
);
const earnPreviewTenCents = computed(() =>
  Math.floor(0.1 * Number(loyaltyConfig.earnRate || 0)),
);
const redeemPreviewOnePoint = computed(() =>
  Number(loyaltyConfig.redeemRate || 0).toFixed(2),
);
const redeemPreviewTenPoints = computed(() =>
  (10 * Number(loyaltyConfig.redeemRate || 0)).toFixed(2),
);
const sampleEarnedPoints = computed(() =>
  Math.floor(Number(loyaltyConfig.sampleOrderTotal || 0) * Number(loyaltyConfig.earnRate || 0)),
);
const savingLoyalty = ref(false);
const savingTelegram = ref(false);
const testingTelegram = ref(false);

// Visibility States for sensitive data
const showBotToken = ref(false);
const showChatId = ref(false);
const showSettings = reactive<Record<string, boolean>>({});

const sensitiveKeys = ['TELEGRAM_BOT_TOKEN', 'TELEGRAM_CHAT_ID', 'BAKONG_ACCOUNT_ID'];
const isSensitive = (key: string) => sensitiveKeys.includes(key);

const loadTelegramConfig = () => {
  // Load from settings array
  const findSetting = (key: string) =>
    settings.value.find((s: any) => s.key === key)?.value || "";
  telegramConfig.botToken = findSetting("TELEGRAM_BOT_TOKEN");
  telegramConfig.chatId = findSetting("TELEGRAM_CHAT_ID");
  telegramConfig.lowStock = findSetting("NOTIFY_LOW_STOCK") === "true";
  telegramConfig.largeOrder = findSetting("NOTIFY_LARGE_ORDER") === "true";
  telegramConfig.largeOrderThreshold =
    parseInt(findSetting("LARGE_ORDER_THRESHOLD")) || 100;
  telegramConfig.shiftDiscrepancy =
    findSetting("NOTIFY_SHIFT_DISCREPANCY") === "true";

  // Loyalty
  loyaltyConfig.earnRate = parseFloat(findSetting("LOYALTY_EARN_RATE")) || 1.0;
  loyaltyConfig.redeemRate =
    parseFloat(findSetting("LOYALTY_REDEEM_RATE")) || 0.1;
  loyaltyConfig.silverThreshold =
    parseInt(findSetting("LOYALTY_SILVER_THRESHOLD")) || 300;
  loyaltyConfig.goldThreshold =
    parseInt(findSetting("LOYALTY_GOLD_THRESHOLD")) || 1000;
};

const saveTelegramConfig = async () => {
  savingTelegram.value = true;
  try {
    const payload: Record<string, string> = {
      TELEGRAM_BOT_TOKEN: telegramConfig.botToken,
      TELEGRAM_CHAT_ID: telegramConfig.chatId,
      NOTIFY_LOW_STOCK: telegramConfig.lowStock ? "true" : "false",
      NOTIFY_LARGE_ORDER: telegramConfig.largeOrder ? "true" : "false",
      LARGE_ORDER_THRESHOLD: telegramConfig.largeOrderThreshold.toString(),
      NOTIFY_SHIFT_DISCREPANCY: telegramConfig.shiftDiscrepancy
        ? "true"
        : "false",
    };
    await post("/settings/batch", payload);
    toast.success("Telegram configuration saved!");
  } catch (err) {
    toast.error("Failed to save Telegram config");
  } finally {
    savingTelegram.value = false;
  }
};

const testTelegram = async () => {
  testingTelegram.value = true;
  try {
    await post("/notifications/test", {});
    toast.success("Test notification sent! Check your Telegram.");
  } catch (err) {
    toast.error("Failed to send test notification. Check your configuration.");
  } finally {
    testingTelegram.value = false;
  }
};

const saveLoyaltyConfig = async () => {
  savingLoyalty.value = true;
  try {
    const payload: Record<string, string> = {
      LOYALTY_EARN_RATE: loyaltyConfig.earnRate.toString(),
      LOYALTY_REDEEM_RATE: loyaltyConfig.redeemRate.toString(),
      LOYALTY_SILVER_THRESHOLD: loyaltyConfig.silverThreshold.toString(),
      LOYALTY_GOLD_THRESHOLD: loyaltyConfig.goldThreshold.toString(),
    };
    await post("/settings/batch", payload);
    toast.success("Loyalty program settings updated!");
    fetchData(); // Refresh settings from server
  } catch (err) {
    toast.error("Failed to update loyalty settings");
  } finally {
    savingLoyalty.value = false;
  }
};

const fetchData = async () => {
  loading.value = true;
  try {
    const [userData, roleData, empData, permData, settingsData] =
      await Promise.all([
        get<any[]>("/users"),
        get<any[]>("/roles"),
        get<any[]>("/employees"),
        get<any[]>("/permissions"),
        get<any[]>("/settings"),
      ]);
    users.value = userData || [];
    roles.value = roleData || [];
    employees.value = empData || [];
    permissions.value = permData || [];
    settings.value = settingsData || [];
    loadTelegramConfig();
  } catch (err) {
    console.error("Failed to fetch access control data", err);
  } finally {
    loading.value = false;
  }
};

// User Actions
const openUserModal = (user: any = null) => {
  editingUser.value = user
  if (user) {
    userForm.userName = user.userName
    userForm.password = ""
    userForm.employeeId = user.employee?.employeeId || null
    userForm.roleId = user.role?.roleId || null
    userForm.isActive = user.isActive ?? true
    selectedUserEmployeeId.value = user.employee?.employeeId ? String(user.employee.employeeId) : ""
    selectedUserRoleId.value = user.role?.roleId ? String(user.role.roleId) : ""
  } else {
    userForm.userName = ""
    userForm.password = ""
    userForm.employeeId = null
    userForm.roleId = null
    userForm.isActive = true
    selectedUserEmployeeId.value = ""
    selectedUserRoleId.value = ""
  }
  showUserModal.value = true
}

const saveUser = async () => {
  saving.value = true
  try {
    const payload = {
      ...userForm,
      employeeId: selectedUserEmployeeId.value ? Number(selectedUserEmployeeId.value) : null,
      roleId: selectedUserRoleId.value ? Number(selectedUserRoleId.value) : null,
    }
    if (editingUser.value) {
      await put(`/users/${editingUser.value.userId}`, payload)
      toast.success("User updated successfully")
    } else {
      await post("/users/add", payload)
      toast.success("User created successfully")
    }
    showUserModal.value = false
    fetchData()
  } catch (err: any) {
    toast.error(err.data?.message || "Failed to save user")
  } finally {
    saving.value = false
  }
}

const confirmDeleteUser = (id: number) => {
  userToDelete.value = id
  showDeleteUserAlert.value = true
}

const executeDeleteUser = async () => {
  if (!userToDelete.value) return
  try {
    await del(`/users/${userToDelete.value}`)
    toast.success("User deleted")
    fetchData()
  } catch (err) {
    toast.error("Failed to delete user")
  } finally {
    showDeleteUserAlert.value = false
    userToDelete.value = null
  }
}

// Role Actions
const openRoleModal = (role: any = null) => {
  editingRole.value = role;
  if (role) {
    roleForm.roleName = role.roleName;
    roleForm.description = role.description;
    roleForm.permissionIds = role.permissions
      ? role.permissions.map((p: any) => p.permissionId)
      : [];
  } else {
    roleForm.roleName = "";
    roleForm.description = "";
    roleForm.permissionIds = [];
  }
  showRoleModal.value = true;
};

const saveRole = async () => {
  saving.value = true;
  try {
    const payload = { ...roleForm };
    if (editingRole.value) {
      await put(`/roles/${editingRole.value.roleId}`, payload);
      toast.success("Role updated");
    } else {
      await post("/roles", payload);
      toast.success("Role created");
    }
    showRoleModal.value = false;
    fetchData();
  } catch (err: any) {
    toast.error(err.data?.message || "Failed to save role");
  } finally {
    saving.value = false;
  }
};

const confirmDeleteRole = (id: number) => {
  roleToDelete.value = id
  showDeleteRoleAlert.value = true
}

const executeDeleteRole = async () => {
  if (!roleToDelete.value) return
  try {
    await del(`/roles/${roleToDelete.value}`)
    toast.success("Role removed")
    fetchData()
  } catch (err) {
    toast.error("Failed to delete role")
  } finally {
    showDeleteRoleAlert.value = false
    roleToDelete.value = null
  }
}

const saveSettings = async () => {
  saving.value = true;
  try {
    // Convert array to map
    const payload = settings.value.reduce(
      (acc, curr) => {
        acc[curr.key] = curr.value;
        return acc;
      },
      {} as Record<string, string>,
    );

    await post("/settings/batch", payload);
    toast.success("Settings saved successfully");
  } catch (err) {
    toast.error("Failed to save settings");
  } finally {
    saving.value = false;
  }
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
</style>

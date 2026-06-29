<template>
  <NuxtLayout name="admin">
    <div class="space-y-8">
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbPage>Reports</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>

      <!-- Header -->
      <div>
        <h1
          class="text-3xl font-black text-neutral-900 dark:text-white tracking-tight"
        >
          Analytics & Reports
        </h1>
        <p class="text-neutral-500 dark:text-neutral-400 mt-1">
          Select a report to view detailed business performance insights.
        </p>
      </div>

      <!-- Report Grid -->
      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        <NuxtLink
          v-for="report in reports"
          :key="report.title"
          :to="report.href"
          class="group bg-white dark:bg-neutral-900 rounded-3xl p-8 border border-neutral-200 dark:border-neutral-800 hover:border-primary-500 dark:hover:border-primary-500 transition-all duration-300 shadow-sm hover:shadow-2xl hover:shadow-primary-500/10"
        >
          <div
            :class="[
              'w-14 h-14 rounded-2xl flex items-center justify-center mb-6 transition-transform group-hover:scale-110 duration-300',
              report.bg,
            ]"
          >
            <component :is="report.icon" :class="['w-7 h-7', report.color]" />
          </div>

          <h3 class="text-xl font-bold text-neutral-900 dark:text-white mb-2">
            {{ report.title }}
          </h3>
          <p
            class="text-sm text-neutral-500 dark:text-neutral-400 leading-relaxed mb-6"
          >
            {{ report.description }}
          </p>

          <div
            class="flex items-center text-sm font-bold text-primary-600 group-hover:translate-x-1 transition-transform"
          >
            View Report
            <ArrowRightIcon class="w-4 h-4 ml-2" />
          </div>
        </NuxtLink>
      </div>

      <!-- Quick Metrics Background -->
      <Card
        class="bg-gradient-to-br from-primary-600 to-accent-600 text-white overflow-hidden relative"
      >
        <CardContent class="p-8">
        <div class="relative z-10">
          <h2 class="text-2xl font-black mb-2">Need a Custom Report?</h2>
          <p class="text-white/80 max-w-sm mb-6 leading-relaxed">
            Our advanced analytics engine can generate specialized reports for
            inventory auditing, employee performance, and more.
          </p>
          <Button variant="secondary">
            Request Extension
          </Button>
        </div>
        <!-- Decorative SVG -->
        <HexagonIcon class="absolute right-0 bottom-0 w-64 h-64 text-white/10 -mr-16 -mb-16" />
        </CardContent>
      </Card>
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
import { ChartPieIcon, PackageSearchIcon, UsersIcon, ArrowLeftRightIcon, StarIcon, ArrowRightIcon, HexagonIcon } from '@lucide/vue'

definePageMeta({
  layout: false,
});

const reports = [
  {
    title: "Sales Performance",
    description: "Track revenue, order volume, and top-selling items over any date range.",
    href: "/admin/reports/sales",
    icon: ChartPieIcon,
    bg: "bg-primary-100 dark:bg-primary-900/30",
    color: "text-primary-600 dark:text-primary-400",
  },
  {
    title: "Inventory Audit",
    description: "Analyze stock movements, wastage, and identify high-cost ingredients.",
    href: "/admin/reports/inventory",
    icon: PackageSearchIcon,
    bg: "bg-accent-100 dark:bg-accent-900/30",
    color: "text-accent-600 dark:text-accent-400",
  },
  {
    title: "Staff Productivity",
    description: "Compare sales by cashier and monitor attendance patterns.",
    href: "/admin/reports/staff",
    icon: UsersIcon,
    bg: "bg-success-100 dark:bg-success-900/30",
    color: "text-success-600 dark:text-success-400",
  },
  {
    title: "Stock Transfer History",
    description: "Monitor stock movements between branches to ensure accountability.",
    href: "/admin/reports/transfers",
    icon: ArrowLeftRightIcon,
    bg: "bg-warning-100 dark:bg-warning-900/30",
    color: "text-warning-600 dark:text-warning-400",
  },
  {
    title: "Loyalty Program",
    description: "Review points earned, redeemed, adjusted, and outstanding customer liability.",
    href: "/admin/reports/loyalty",
    icon: StarIcon,
    bg: "bg-amber-100 dark:bg-amber-900/30",
    color: "text-amber-600 dark:text-amber-400",
  },
];
</script>

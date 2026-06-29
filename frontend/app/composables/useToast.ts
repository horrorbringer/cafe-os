import { toast as sonnerToast } from 'vue-sonner'

export const useToast = () => {
  return {
    success: sonnerToast.success,
    error: sonnerToast.error,
    warn: sonnerToast.warning,
    info: sonnerToast.info,
  }
}

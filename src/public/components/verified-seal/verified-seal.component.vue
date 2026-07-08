<script setup>
defineProps({
  label: {
    type: String,
    default: 'Certificado verificado'
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg'].includes(value)
  }
});
</script>

<template>
  <span class="verified-seal" :class="`verified-seal--${size}`" role="img" :aria-label="label" :title="label">
    <i class="pi pi-check verified-seal__icon" aria-hidden="true"></i>
  </span>
</template>

<style scoped>
.verified-seal {
  --seal-size: 1.75rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: var(--seal-size);
  height: var(--seal-size);
  flex-shrink: 0;
  border-radius: 50%;
  background-color: var(--color-verified, #B08D3E);
  box-shadow: 0 0 0 2px var(--color-paper, #FCFCFA), 0 1px 3px rgba(18, 33, 28, 0.25);
  animation: verified-seal-appear 200ms ease-out;
}

.verified-seal--sm {
  --seal-size: 1.25rem;
}

.verified-seal--lg {
  --seal-size: 2.25rem;
}

.verified-seal__icon {
  color: var(--color-paper, #FCFCFA);
  font-size: calc(var(--seal-size) * 0.55);
}

@keyframes verified-seal-appear {
  from {
    opacity: 0;
    transform: scale(0.6);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

@media (prefers-reduced-motion: reduce) {
  .verified-seal {
    animation: none;
  }
}
</style>

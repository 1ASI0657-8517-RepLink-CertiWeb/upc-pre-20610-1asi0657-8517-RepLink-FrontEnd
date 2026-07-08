<script setup>
import { defineProps } from 'vue';
import { Reservation } from '@/certifications/model/reservation.entity.js';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
const props = defineProps({
  reservation: {
    type: Object,
    required: true,
    default: () => new Reservation()
  }
});

const formatDateTime = (dateTimeString) => {
  if (!dateTimeString) return 'Fecha no especificada';
  try {
    const date = new Date(dateTimeString);
    if (isNaN(date.getTime())) return 'Fecha inválida';
    return date.toLocaleString('es-ES', {
      year: 'numeric', month: 'long', day: 'numeric',
      hour: '2-digit', minute: '2-digit'
    });
  } catch (e) {
    return 'Fecha inválida';
  }
};

const placeholderImage = 'https://static.vecteezy.com/system/resources/previews/005/720/408/non_2x/crossed-image-icon-picture-not-available-delete-picture-symbol-free-vector.jpg';
const handleImageError = (event) => {
  event.target.src = placeholderImage;
};
</script>

<template>
  <pv-card class="history-item-card">
    <template #header>
      <img
        :src="reservation.imageUrl || placeholderImage"
        :alt="t('historyItem.imageAlt')"
        class="vehicle-image"
        @error="handleImageError"
      />
    </template>
    <template #title>
      <div class="card-title">{{ reservation.reservationName || t('historyItem.noName') }}</div>
    </template>
    <template #subtitle>
      <div class="card-subtitle">{{ reservation.brand }} - {{ reservation.model }}</div>
    </template>
    <template #content>
      <div class="reservation-details">
        <p><strong>{{ t('historyItem.dateTime') }}</strong> {{ formatDateTime(reservation.inspectionDateTime) }}</p>
        <p><strong>{{ t('historyItem.price') }}</strong> <span class="price-value">S/ {{ reservation.price || t('historyItem.priceNotSpecified') }}</span></p>
        <p><strong>{{ t('historyItem.status') }}</strong> <span :class="`status-${reservation.status?.toLowerCase()}`">{{ reservation.status || t('historyItem.statusNotSpecified') }}</span></p>
      </div>
    </template>
  </pv-card>
</template>

<style scoped>
.history-item-card,
.history-item-card * {
  box-sizing: border-box;
}

.history-item-card {
  width: 100%;
  max-width: 400px;
  margin: 0 auto 1.5rem;
  background: var(--color-paper, #FCFCFA);
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid var(--color-border, #D8DFDA);
  transition: box-shadow 0.2s ease;
}

.history-item-card:hover {
  box-shadow: 0 8px 24px rgba(18, 33, 28, 0.1);
}

.vehicle-image {
  width: 100%;
  height: 220px;
  object-fit: cover;
  background: var(--color-brand-soft, #E8F0EC);
}

:deep(.p-card-body) {
  padding: 1.5rem;
}

:deep(.p-card-title) {
  margin-bottom: 0.75rem;
}

:deep(.p-card-subtitle) {
  margin-bottom: 1.25rem;
}

:deep(.p-card-content) {
  padding-top: 0;
}

.card-title {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin-bottom: 0.5rem;
  line-height: 1.3;
}

.card-subtitle {
  font-size: 1rem;
  color: var(--color-brand, #1B4B3A);
  font-weight: 600;
  margin-bottom: 1rem;
  padding: 0.4rem 0.9rem;
  background: var(--color-brand-soft, #E8F0EC);
  border-radius: 20px;
  display: inline-block;
}

.reservation-details {
  background: var(--color-brand-soft, #E8F0EC);
  padding: 1.25rem;
  border-radius: 8px;
  border: 1px solid var(--color-border, #D8DFDA);
}

.reservation-details p {
  font-size: 0.95rem;
  margin-bottom: 0.875rem;
  color: var(--color-graphite, #5C645F);
  line-height: 1.5;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0;
  border-bottom: 1px solid var(--color-border, #D8DFDA);
}

.reservation-details p:last-child {
  border-bottom: none;
  margin-bottom: 0;
}

.reservation-details strong {
  color: var(--color-ink, #12211C);
  font-weight: 600;
  min-width: 100px;
}

.price-value {
  font-family: var(--font-mono, 'IBM Plex Mono', monospace);
}

/* Status Styles */
.status-confirmada,
.status-completada {
  color: var(--color-brand, #1B4B3A);
  font-weight: 700;
  background: var(--color-brand-soft, #E8F0EC);
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.status-pendiente {
  color: var(--color-verified, #B08D3E);
  font-weight: 700;
  background: var(--color-verified-soft, #F5EDDC);
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.status-cancelada {
  color: #a02525;
  font-weight: 700;
  background: #fdf2f2;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

/* Responsive Design */
@media (max-width: 768px) {
  .history-item-card {
    max-width: 100%;
    margin: 0 0 1.25rem;
  }
  
  .vehicle-image {
    height: 200px;
  }
  
  :deep(.p-card-body) {
    padding: 1.25rem;
  }
  
  .card-title {
    font-size: 1.25rem;
  }
  
  .card-subtitle {
    font-size: 1rem;
    padding: 0.4rem 0.8rem;
  }
  
  .reservation-details {
    padding: 1rem;
  }
  
  .reservation-details p {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.25rem;
    font-size: 0.9rem;
  }
  
  .reservation-details strong {
    min-width: auto;
    font-size: 0.85rem;
  }
}

@media (max-width: 480px) {
  .vehicle-image {
    height: 180px;
  }
  
  :deep(.p-card-body) {
    padding: 1rem;
  }
  
  .card-title {
    font-size: 1.125rem;
  }
  
  .card-subtitle {
    font-size: 0.95rem;
    padding: 0.35rem 0.7rem;
  }
  
  .reservation-details {
    padding: 0.875rem;
  }
  
  .reservation-details p {
    font-size: 0.85rem;
  }
  
  .reservation-details strong {
    font-size: 0.8rem;
  }
}

@media (max-width: 360px) {
  .vehicle-image {
    height: 160px;
  }
  
  :deep(.p-card-body) {
    padding: 0.875rem;
  }
  
  .card-title {
    font-size: 1rem;
  }
  
  .reservation-details {
    padding: 0.75rem;
  }
}
</style>
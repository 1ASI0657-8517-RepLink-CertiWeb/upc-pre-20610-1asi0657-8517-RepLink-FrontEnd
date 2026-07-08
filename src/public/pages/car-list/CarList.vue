<script setup>
import { ref, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { carService } from '../../../certifications/services/car.service';
import toolbarComponent from '../../../certifications/components/dashboard/toolbar/toolbar.component.vue';
import { useI18n } from 'vue-i18n';

const router = useRouter();
const route = useRoute();
const { t } = useI18n();
const cars = ref([]);
const loading = ref(true);
const error = ref(null);
  
const fetchCars = async () => {
  try {
    loading.value = true;
    error.value = null;
    
    const carsData = await carService.getAllCars();
    
    if (Array.isArray(carsData)) {
      const brandQuery = route.query.brand ? route.query.brand.toLowerCase() : null;
      const modelQuery = route.query.model ? route.query.model.toLowerCase() : null;
      if (brandQuery || modelQuery) {
        cars.value = carsData.filter(car => {
          const carBrand = car.brand ? car.brand.toLowerCase() : '';
          const carModel = car.model ? car.model.toLowerCase() : '';
          let matchesBrand = true;
          if (brandQuery) {
            matchesBrand = carBrand === brandQuery;
          }
          let matchesModel = true;
          if (modelQuery) {
            matchesModel = carModel === modelQuery;
          }
          return matchesBrand && matchesModel;
        });
        console.log('Cars filtered by query:', cars.value);
      } else {
        cars.value = carsData;
        console.log('All cars loaded:', carsData);
      }
    } else {
      console.warn('Fetched data is not an array:', carsData);
      cars.value = [];
    }
  } catch (err) {
    console.error('Error fetching cars:', err);
    error.value = err;
    cars.value = [];
  } finally {
    loading.value = false;
  }
};

const navigateToCarDetail = (carId) => {
  console.log('Navigating to car detail with ID:', carId, typeof carId);
  
  const id = String(carId);
  
  if (!id || id === 'undefined' || id === 'null') {
    console.error('Invalid car ID for navigation:', carId);
    return;
  }
  
  router.push(`/car-detail/${id}`);
};

const getPhotoUrl = (car) => {
  return car.imageUrl || 'https://via.placeholder.com/300x200?text=No+Image';
};

const formatCurrency = (value) => {
  const numValue = typeof value === 'string' ? parseFloat(value) : value;
  if (typeof numValue !== 'number' || isNaN(numValue)) {
    return value;
  }
  return new Intl.NumberFormat('es-PE', { style: 'currency', currency: 'PEN' }).format(numValue);
};

onMounted(() => {
  fetchCars();
});
</script>

<template>
  <toolbarComponent/>
  <div class="car-list-container p-d-flex p-flex-column p-ai-center">
    <h2 class="p-mb-4">{{ t('carList.title') }}</h2>
    <div v-if="loading" class="p-d-flex p-jc-center p-ai-center" style="height: 200px;">
      <pv-progress-spinner />
      <span class="p-ml-2">{{ t('carList.loading') }}</span>
    </div>
    <div v-else-if="error" class="p-error p-text-center">
      <p>{{ t('carList.error') }} {{ error.message }}</p>
    </div>
    <div v-else-if="cars.length === 0" class="p-text-center">
      <p>{{ t('carList.empty') }}</p>
    </div>
    <div v-else class="car-grid">
      <pv-card
        v-for="car in cars"
        :key="car.id"
        class="car-card"
        tabindex="0"
        role="link"
        :aria-label="car.title"
        @click="navigateToCarDetail(car.id)"
        @keydown.enter="navigateToCarDetail(car.id)"
      >
        <template #header>
          <div class="car-image-wrap">
            <img :src="getPhotoUrl(car)" :alt="car.model" class="car-image" />
            <verified-seal v-if="car.hasPdfCertification" class="car-seal" size="sm" />
          </div>
        </template>
        <template #title>
          <div class="car-title">{{ car.title }}</div>
        </template>
        <template #subtitle>
          <div class="car-brand-model">{{ car.brand }} - {{ car.model }}</div>
          <div class="car-meta-row">
            <span class="car-year">{{ t('carList.year') }} {{ car.year }}</span>
            <span v-if="car.licensePlate" class="car-plate">{{ car.licensePlate }}</span>
          </div>
        </template>
        <template #content>
          <p class="car-description">{{ car.description ? car.description.substring(0, 100) + '...' : t('carList.noDescription') }}</p>
          <div class="car-owner">{{ t('carList.owner') }} {{ car.owner }}</div>
        </template>
        <template #footer>
          <div class="car-price">{{ formatCurrency(car.price) }}</div>
          <pv-button :label="t('carList.viewDetails')" icon="pi pi-search" class="p-button-sm" />
        </template>
      </pv-card>
    </div>
  </div>
</template>

<style scoped>
.car-list-container {
  padding: 2rem;
  max-width: 1400px;
  margin: 0 auto;
  background: var(--color-paper, #FCFCFA);
  font-family: var(--font-body, 'Inter', sans-serif);
  min-height: calc(100vh - 70px);
}

.car-list-container h2 {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 2.25rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  text-align: center;
  margin-bottom: 3rem;
}

.car-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 2rem;
  width: 100%;
  padding: 1rem 0;
}

.car-card {
  cursor: pointer;
  transition: border-color 0.2s ease;
  border-radius: 12px;
  overflow: hidden;
  background: var(--color-paper, #FCFCFA);
  border: 1px solid var(--color-border, #D8DFDA);
  position: relative;
}

.car-card:hover {
  border-color: var(--color-brand, #1B4B3A);
}

.car-image-wrap {
  position: relative;
}

.car-seal {
  position: absolute;
  top: 0.75rem;
  right: 0.75rem;
  z-index: 2;
}

.car-image {
  width: 100%;
  height: 240px;
  object-fit: cover;
  display: block;
}

.car-title {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 0.75rem;
  color: var(--color-ink, #12211C);
  line-height: 1.3;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.car-brand-model {
  font-size: 1rem;
  color: var(--color-brand, #1B4B3A);
  margin-bottom: 0.5rem;
  font-weight: 600;
}

.car-meta-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.car-year {
  font-size: 0.85rem;
  color: var(--color-graphite, #5C645F);
  font-weight: 500;
  background: var(--color-brand-soft, #E8F0EC);
  padding: 0.2rem 0.65rem;
  border-radius: 12px;
  display: inline-block;
}

.car-plate {
  font-family: var(--font-mono, 'IBM Plex Mono', monospace);
  font-size: 0.8rem;
  color: var(--color-graphite, #5C645F);
  background: var(--color-paper, #FCFCFA);
  border: 1px solid var(--color-border, #D8DFDA);
  border-radius: 4px;
  padding: 0.2rem 0.5rem;
  letter-spacing: 0.03em;
}

.car-description {
  font-size: 0.95rem;
  color: var(--color-graphite, #5C645F);
  margin-bottom: 1rem;
  min-height: 60px;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.car-owner {
  font-size: 0.875rem;
  color: var(--color-graphite, #5C645F);
  margin-bottom: 1.25rem;
  padding: 0.5rem 0.75rem;
  background: var(--color-brand-soft, #E8F0EC);
  border-radius: 8px;
}

.car-price {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--color-ink, #12211C);
  margin-bottom: 0.75rem;
  display: inline-block;
}

/* Loading and Error States */
.car-list-container .p-d-flex {
  background: var(--color-paper, #FCFCFA);
  padding: 3rem;
  border-radius: 12px;
  border: 1px solid var(--color-border, #D8DFDA);
  margin: 2rem 0;
}

.car-list-container .p-error {
  background: #fdf2f2;
  color: #7a1f1f;
  padding: 2rem;
  border-radius: 12px;
  border: 1px solid #f0caca;
  margin: 2rem 0;
}

.car-list-container .p-text-center {
  background: var(--color-paper, #FCFCFA);
  padding: 3rem;
  border-radius: 12px;
  border: 1px solid var(--color-border, #D8DFDA);
  margin: 2rem 0;
  font-size: 1.2rem;
  color: var(--color-graphite, #5C645F);
}

/* PrimeVue Card Customization */
:deep(.p-card-body) {
  padding: 1.5rem;
}

:deep(.p-card-title) {
  font-size: 1.2rem;
  margin-bottom: 1rem;
}

:deep(.p-card-subtitle) {
  margin-bottom: 1rem;
}

:deep(.p-card-content) {
  padding-top: 0;
  padding-bottom: 1rem;
}

:deep(.p-card-footer) {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  padding-top: 0;
  gap: 1rem;
}

:deep(.p-button-sm) {
  padding: 0.625rem 1.25rem !important;
  font-size: 0.875rem !important;
  font-weight: 600 !important;
  border-radius: 8px !important;
  background: var(--color-brand, #1B4B3A) !important;
  border: none !important;
  transition: background-color 0.2s ease !important;
}

:deep(.p-button-sm:hover) {
  background: var(--color-brand-strong, #123329) !important;
}

:deep(.p-button-sm:focus-visible) {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}

.car-card:focus-visible {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .car-grid {
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 1.5rem;
  }
  
  .car-list-container {
    padding: 1.5rem;
  }
  
  .car-list-container h2 {
    font-size: 2.25rem;
    margin-bottom: 2.5rem;
  }
}

@media (max-width: 992px) {
  .car-grid {
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 1.5rem;
  }
  
  .car-list-container h2 {
    font-size: 2rem;
    margin-bottom: 2rem;
  }
  
  .car-image {
    height: 220px;
  }
  
  .car-title {
    font-size: 1.25rem;
  }
  
  .car-price {
    font-size: 1.25rem;
  }
}

@media (max-width: 768px) {
  .car-list-container {
    padding: 1rem;
  }
  
  .car-grid {
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 1.25rem;
  }
  
  .car-list-container h2 {
    font-size: 1.75rem;
    margin-bottom: 1.5rem;
  }
  
  .car-list-container h2::after {
    width: 80px;
    height: 3px;
  }
  
  .car-image {
    height: 200px;
  }
  
  .car-title {
    font-size: 1.125rem;
  }
  
  .car-brand-model {
    font-size: 1rem;
  }
  
  .car-description {
    font-size: 0.9rem;
    min-height: 50px;
  }
  
  .car-price {
    font-size: 1.125rem;
    padding: 0.4rem 0.8rem;
  }
  
  :deep(.p-card-body) {
    padding: 1.25rem;
  }
  
  :deep(.p-card-footer) {
    flex-direction: column;
    align-items: stretch;
    gap: 0.75rem;
  }
  
  :deep(.p-button-sm) {
    width: 100% !important;
    justify-content: center !important;
  }
}

@media (max-width: 480px) {
  .car-list-container {
    padding: 0.75rem;
  }
  
  .car-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .car-list-container h2 {
    font-size: 1.5rem;
    margin-bottom: 1.25rem;
  }
  
  .car-list-container h2::after {
    width: 60px;
    height: 2px;
  }
  
  .car-image {
    height: 180px;
  }
  
  .car-title {
    font-size: 1rem;
    margin-bottom: 0.5rem;
  }
  
  .car-brand-model {
    font-size: 0.95rem;
    margin-bottom: 0.4rem;
  }
  
  .car-year {
    font-size: 0.875rem;
    margin-bottom: 0.5rem;
  }
  
  .car-description {
    font-size: 0.875rem;
    min-height: 45px;
    margin-bottom: 0.75rem;
  }
  
  .car-owner {
    font-size: 0.8rem;
    margin-bottom: 1rem;
    padding: 0.4rem 0.6rem;
  }
  
  .car-price {
    font-size: 1rem;
    padding: 0.375rem 0.75rem;
  }
  
  :deep(.p-card-body) {
    padding: 1rem;
  }
  
  :deep(.p-card-footer) {
    padding: 1rem;
    padding-top: 0;
  }
  
  :deep(.p-button-sm) {
    padding: 0.5rem 1rem !important;
    font-size: 0.8rem !important;
  }
}

@media (max-width: 360px) {
  .car-list-container {
    padding: 0.5rem;
  }
  
  .car-list-container h2 {
    font-size: 1.375rem;
  }
  
  .car-image {
    height: 160px;
  }
  
  .car-title {
    font-size: 0.95rem;
  }
  
  .car-brand-model {
    font-size: 0.9rem;
  }
  
  .car-description {
    font-size: 0.8rem;
  }
  
  .car-price {
    font-size: 0.95rem;
  }
  
  :deep(.p-card-body) {
    padding: 0.875rem;
  }
}
</style>
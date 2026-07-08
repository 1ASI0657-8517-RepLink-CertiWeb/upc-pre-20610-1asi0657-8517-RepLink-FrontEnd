<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { carService } from '../../../services/car.service';

const { t } = useI18n();
const router = useRouter();

const certifiedCars = ref([]);
const loading = ref(true);

const fetchCertifiedCars = async () => {
  try {
    loading.value = true;
    const cars = await carService.getAllCars();
    certifiedCars.value = (Array.isArray(cars) ? cars : []).slice(0, 6).map((car) => ({
      id: car.id,
      name: `${car.brand} ${car.model}`,
      image: car.imageUrl,
      price: car.price,
      licensePlate: car.licensePlate,
      hasPdfCertification: car.hasPdfCertification,
      route: `/car-detail/${car.id}`
    }));
  } catch (err) {
    console.error('Error fetching certified cars:', err);
    certifiedCars.value = [];
  } finally {
    loading.value = false;
  }
};

const currentIndex = ref(0);
const visibleItems = ref(4);
const autoplayInterval = ref(null);
const isHovering = ref(false);

const navigateToCar = (route) => {
  router.push(route);
};

const nextSlide = () => {
  if (currentIndex.value < certifiedCars.value.length - visibleItems.value) {
    currentIndex.value++;
  } else {
    currentIndex.value = 0;
  }
};

const prevSlide = () => {
  if (currentIndex.value > 0) {
    currentIndex.value--;
  } else {
    currentIndex.value = certifiedCars.value.length - visibleItems.value;
  }
};

const adjustVisibleItems = () => {
  if (window.innerWidth < 640) {
    visibleItems.value = 1;
  } else if (window.innerWidth < 1024) {
    visibleItems.value = 2;
  } else if (window.innerWidth < 1280) {
    visibleItems.value = 3;
  } else {
    visibleItems.value = 4;
  }
};

const startAutoplay = () => {
  if (!autoplayInterval.value && !isHovering.value) {
    autoplayInterval.value = setInterval(() => {
      nextSlide();
    }, 5000);
  }
};

const stopAutoplay = () => {
  if (autoplayInterval.value) {
    clearInterval(autoplayInterval.value);
    autoplayInterval.value = null;
  }
};

const handleMouseEnter = () => {
  isHovering.value = true;
  stopAutoplay();
};

const handleMouseLeave = () => {
  isHovering.value = false;
  startAutoplay();
};

const formatCurrency = (value) => {
  const numValue = typeof value === 'string' ? parseFloat(value) : value;
  if (typeof numValue !== 'number' || isNaN(numValue)) {
    return value;
  }
  return new Intl.NumberFormat('es-PE', { style: 'currency', currency: 'PEN' }).format(numValue);
};

onMounted(async () => {
  adjustVisibleItems();
  window.addEventListener('resize', adjustVisibleItems);
  await fetchCertifiedCars();
  if (certifiedCars.value.length > 0) {
    startAutoplay();
  }

  return () => {
    window.removeEventListener('resize', adjustVisibleItems);
    stopAutoplay();
  };
});
</script>

<template>
  <section class="certified-cars-section">
    <div class="certified-cars-container">
      <div class="certified-cars-header">
        <h2 class="welcome-title">{{ t('welcome.title') }}</h2>
        <p class="welcome-subtitle">{{ t('welcome.subtitle') }}</p>
      </div>
      
      <div v-if="loading" class="certified-cars-loading">
        <pv-progress-spinner />
      </div>

      <div v-else-if="certifiedCars.length === 0" class="certified-cars-empty">
        <p>{{ t('welcome.noCars') }}</p>
      </div>

      <div
        v-else
        class="carousel-container"
        @mouseenter="handleMouseEnter"
        @mouseleave="handleMouseLeave"
      >
        <pv-button
          class="carousel-arrow carousel-arrow-prev"
          @click="prevSlide"
          :class="{ 'disabled': currentIndex === 0 }"
        >
          <i class="pi pi-chevron-left"></i>
        </pv-button>

        <div class="carousel-wrapper">
          <div
            class="carousel-track"
            :style="{ transform: `translateX(-${currentIndex * (100 / visibleItems)}%)` }"
          >
            <div
              v-for="car in certifiedCars"
              :key="car.id"
              class="carousel-item"
              :style="{ width: `calc(${100 / visibleItems}% - 1rem)` }"
              tabindex="0"
              role="link"
              :aria-label="car.name"
              @click="navigateToCar(car.route)"
              @keydown.enter="navigateToCar(car.route)"
            >
              <div class="car-card">
                <div class="car-image-container">
                  <img :src="car.image" :alt="car.name" class="car-image" />
                  <verified-seal v-if="car.hasPdfCertification" class="car-seal" size="sm" />
                  <div class="car-overlay">
                    <span class="car-price">{{ formatCurrency(car.price) }}</span>
                    <span class="car-view-details">
                      <i class="pi pi-search"></i> {{ t('car.viewDetails') }}
                    </span>
                  </div>
                </div>
                <div class="car-info">
                  <h3 class="car-name">{{ car.name }}</h3>
                  <span v-if="car.licensePlate" class="car-plate">{{ car.licensePlate }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <pv-button
          class="carousel-arrow carousel-arrow-next"
          @click="nextSlide"
          :class="{ 'disabled': currentIndex >= certifiedCars.length - visibleItems }"
        >
          <i class="pi pi-chevron-right"></i>
        </pv-button>
      </div>

      <div class="see-more-container">
        <router-link to="/cars" class="see-more-link">
          {{ t('navigation2.seeMoreModels') }}
          <i class="pi pi-arrow-right"></i>
        </router-link>
      </div>
    </div>
  </section>
</template>

<style scoped>
.certified-cars-section {
  padding: 2.5rem 0.75rem;
  background-color: var(--color-paper, #FCFCFA);
}

.certified-cars-container {
  max-width: 1280px;
  margin: 0 auto;
  position: relative;
}

.certified-cars-header {
  text-align: center;
  margin-bottom: 1.5rem;
  padding: 0 0.5rem;
}

.welcome-title {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin-bottom: 0.5rem;
  line-height: 1.2;
}

.welcome-subtitle {
  font-size: 0.95rem;
  color: var(--color-graphite, #5C645F);
  line-height: 1.5;
}

.carousel-container {
  position: relative;
  display: flex;
  align-items: center;
  margin: 0 -0.5rem;
  padding: 1rem 0;
}

.certified-cars-loading,
.certified-cars-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 3rem 1rem;
  color: var(--color-graphite, #5C645F);
  font-size: 1rem;
}

.carousel-wrapper {
  width: 100%;
  overflow: hidden;
  padding: 0 0.5rem;
}

.carousel-track {
  display: flex;
  transition: transform 0.5s ease;
}

.carousel-item {
  flex-shrink: 0;
  padding: 0 0.5rem;
  cursor: pointer;
}

.car-card {
  background-color: var(--color-paper, #FCFCFA);
  border: 1px solid var(--color-border, #D8DFDA);
  border-radius: 12px;
  overflow: hidden;
  transition: border-color 0.2s ease;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.car-card:hover {
  border-color: var(--color-brand, #1B4B3A);
}

.car-image-container {
  position: relative;
  overflow: hidden;
  height: 0;
  padding-bottom: 66.67%;
  flex-shrink: 0;
}

.car-seal {
  position: absolute;
  top: 0.75rem;
  right: 0.75rem;
  z-index: 2;
}

.car-image {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.car-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(to top, rgba(0, 0, 0, 0.7), transparent);
  padding: 1.5rem 1rem 0.75rem;
  color: white;
  opacity: 0;
  transform: translateY(20px);
  transition: all 0.3s ease;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
}

.car-card:hover .car-overlay {
  opacity: 1;
  transform: translateY(0);
}

.car-price {
  font-weight: 700;
  font-size: 1.1rem;
}

.car-view-details {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
}

.car-info {
  padding: 1rem;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.car-name {
  font-size: 1rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin: 0 0 0.35rem;
  line-height: 1.3;
}

.car-plate {
  display: inline-block;
  font-family: var(--font-mono, 'IBM Plex Mono', monospace);
  font-size: 0.8rem;
  color: var(--color-graphite, #5C645F);
  background: var(--color-brand-soft, #E8F0EC);
  border: 1px solid var(--color-border, #D8DFDA);
  border-radius: 4px;
  padding: 0.15rem 0.45rem;
  letter-spacing: 0.03em;
  width: fit-content;
}

.carousel-arrow {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 50%;
  background-color: var(--color-paper, #FCFCFA);
  border: 1px solid var(--color-border, #D8DFDA);
  cursor: pointer;
  z-index: 10;
  transition: background-color 0.2s ease;
  color: var(--color-ink, #12211C);
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
}

.carousel-arrow:hover {
  background-color: var(--color-brand-soft, #E8F0EC);
}

.carousel-arrow:active {
  transform: translateY(-50%) scale(0.95);
}

.carousel-arrow.disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.carousel-arrow-prev {
  left: 0.25rem;
}

.carousel-arrow-next {
  right: 0.25rem;
}

.carousel-arrow i {
  font-size: 1rem;
}

.see-more-container {
  display: flex;
  justify-content: center;
  margin-top: 1.5rem;
}

.see-more-link {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--color-brand, #1B4B3A);
  font-weight: 600;
  text-decoration: none;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  transition: background-color 0.2s ease;
  font-size: 0.95rem;
}

.see-more-link:hover {
  background-color: var(--color-brand-soft, #E8F0EC);
}

/* Responsive adjustments */
@media (min-width: 480px) {
  .certified-cars-section {
    padding: 2.5rem 1rem;
  }
  
  .welcome-title {
    font-size: 1.6rem;
  }
  
  .welcome-subtitle {
    font-size: 1rem;
  }
  
  .carousel-arrow {
    width: 2.75rem;
    height: 2.75rem;
  }
  
  .carousel-arrow i {
    font-size: 1.1rem;
  }
  
  .carousel-arrow-prev {
    left: 0.5rem;
  }
  
  .carousel-arrow-next {
    right: 0.5rem;
  }
}

@media (min-width: 640px) {
  .certified-cars-header {
    text-align: left;
    padding-left: 1rem;
  }
  
  .welcome-title {
    font-size: 1.75rem;
  }
  
  .car-name {
    font-size: 1.05rem;
  }
  
  .car-color {
    font-size: 0.9rem;
  }
  
  .car-price {
    font-size: 1.15rem;
  }
  
  .see-more-link {
    font-size: 1rem;
  }
}

@media (min-width: 768px) {
  .certified-cars-section {
    padding: 3rem 1.5rem;
  }
  
  .welcome-title {
    font-size: 1.9rem;
  }
  
  .welcome-subtitle {
    font-size: 1.05rem;
  }
  
  .carousel-arrow {
    width: 3rem;
    height: 3rem;
  }
  
  .carousel-arrow i {
    font-size: 1.2rem;
  }
  
  .carousel-arrow-prev {
    left: 0.75rem;
  }
  
  .carousel-arrow-next {
    right: 0.75rem;
  }
  
  .car-name {
    font-size: 1.1rem;
  }
}

@media (min-width: 1024px) {
  .certified-cars-section {
    padding: 3.5rem 2rem;
  }
  
  .welcome-title {
    font-size: 2rem;
  }
  
  .welcome-subtitle {
    font-size: 1.1rem;
  }
  
  .carousel-arrow-prev {
    left: -1rem;
  }
  
  .carousel-arrow-next {
    right: -1rem;
  }
}

/* Touch device optimizations */
@media (hover: none) {
  .car-overlay {
    opacity: 1;
    transform: translateY(0);
    background: linear-gradient(to top, rgba(0, 0, 0, 0.7), rgba(0, 0, 0, 0.1), transparent);
  }
  
  .carousel-item:hover {
    transform: none;
  }
  
  .car-card:hover .car-image {
    transform: none;
  }
  
  .see-more-link:hover {
    transform: none;
  }
  
  .see-more-link:hover i {
    transform: none;
  }
}

/* Accessibility improvements */
@media (prefers-reduced-motion: reduce) {
  .carousel-track,
  .carousel-item,
  .car-card,
  .car-image,
  .car-overlay,
  .carousel-arrow,
  .see-more-link,
  .see-more-link i {
    transition: none !important;
    transform: none !important;
  }
}

/* Focus styles for keyboard navigation */
.carousel-item:focus-visible,
.carousel-arrow:focus-visible,
.see-more-link:focus-visible {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}
</style>
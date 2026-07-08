<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
const router = useRouter();

const certificationRoute = '/reservation';

const bannerData = ref({
  carImage: 'https://img.freepik.com/foto-gratis/coche-lujoso-estacionado-carretera-faro-iluminado-al-atardecer_181624-60607.jpg?semt=ais_hybrid&w=740'
});

const navigateToCertification = () => {
  router.push(certificationRoute);
};
</script>

<template>
  <section class="certification-banner">
    <div class="certification-container">
      <div class="car-image-container">
        <img 
          :src="bannerData.carImage" 
          :alt="t('banner.carAltText')" 
          class="car-image"
        />
      </div>
      
      <div class="certification-content">
        <h2 class="certification-title">{{ t('banner.title') }}</h2>
        
        <p class="certification-description">
          {{ t('banner.description') }}
        </p>
        
        <div class="certification-action">
          <pv-button 
            class="certification-button" 
            @click="navigateToCertification"
          >
            <span>{{ t('banner.buttonText') }}</span>
            <i class="pi pi-arrow-right button-icon"></i>
          </pv-button>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.certification-banner {
  width: 100%;
  background-color: var(--color-brand-soft, #E8F0EC);
  padding: 1.5rem 1rem;
  overflow: hidden;
}

.certification-container {
  max-width: 1280px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
}

.car-image-container {
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  order: 1;
}

.car-image {
  width: 100%;
  max-width: 500px;
  height: auto;
  object-fit: contain;
  border-radius: 8px;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
}

.certification-content {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 1rem;
  order: 2;
  text-align: center;
}

.certification-title {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.75rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin: 0;
  line-height: 1.2;
}

.certification-description {
  font-size: 1rem;
  color: var(--color-graphite, #5C645F);
  margin: 0;
  line-height: 1.5;
}

.certification-action {
  margin-top: 0.5rem;
  display: flex;
  justify-content: center;
}

:deep(.certification-button) {
  background-color: var(--color-brand, #1B4B3A);
  border: none;
  color: white;
  font-weight: 600;
  font-size: 1rem;
  padding: 0.75rem 1.25rem;
  border-radius: 8px;
  transition: background-color 0.2s ease;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  width: 100%;
  max-width: 300px;
  justify-content: center;
}

:deep(.certification-button:hover) {
  background-color: var(--color-brand-strong, #123329);
}

/* Responsive adjustments */
@media (min-width: 640px) {
  .certification-banner {
    padding: 2rem 1.5rem;
  }
  
  .certification-title {
    font-size: 2rem;
  }
  
  .certification-description {
    font-size: 1.05rem;
    max-width: 500px;
    margin: 0 auto;
  }
  
  :deep(.certification-button) {
    font-size: 1.05rem;
    padding: 0.75rem 1.5rem;
  }
}

@media (min-width: 768px) {
  .certification-container {
    flex-direction: row;
    text-align: left;
    gap: 2rem;
  }
  
  .car-image-container {
    flex: 1;
    order: 2;
  }
  
  .certification-content {
    flex: 1;
    order: 1;
    text-align: left;
    justify-content: center;
  }
  
  .certification-action {
    justify-content: flex-start;
  }
  
  :deep(.certification-button) {
    width: auto;
  }
}

@media (min-width: 1024px) {
  .certification-banner {
    padding: 3rem 2rem;
  }
  
  .certification-container {
    gap: 3rem;
  }
  
  .certification-title {
    font-size: 2.25rem;
  }
  
  .certification-description {
    font-size: 1.1rem;
  }
  
  :deep(.certification-button) {
    font-size: 1.1rem;
    padding: 0.875rem 1.75rem;
  }
  
  .car-image {
    max-width: 600px;
  }
}

/* Focus styles for keyboard navigation */
:deep(.certification-button:focus-visible) {
  outline: 2px solid var(--color-brand-strong, #123329);
  outline-offset: 2px;
}

/* Accessibility improvements */
@media (prefers-reduced-motion: reduce) {
  .car-image,
  .button-icon,
  :deep(.certification-button) {
    transition: none !important;
    transform: none !important;
  }
}

/* High contrast mode */
@media (prefers-contrast: high) {
  .certification-title {
    color: #000;
  }
  
  .certification-description {
    color: #000;
  }
  
  :deep(.certification-button) {
    background-color: #fff;
    color: #000;
    border: 2px solid #000;
  }
}

/* Touch device optimizations */
@media (hover: none) {
  .car-image:hover {
    transform: none;
  }
  
  :deep(.certification-button:hover) {
    transform: none;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }
  
  :deep(.certification-button:hover) .button-icon {
    transform: none;
  }
}
</style>
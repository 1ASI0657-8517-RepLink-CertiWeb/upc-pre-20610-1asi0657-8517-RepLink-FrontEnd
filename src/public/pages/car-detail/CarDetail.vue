<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { carService } from '../../../certifications/services/car.service';
import { useI18n } from 'vue-i18n';

const route = useRoute();
const router = useRouter();
const car = ref(null);
const carPdf = ref(null);
const loading = ref(true);
const loadingPdf = ref(false);
const error = ref(null);
const { t } = useI18n();

const carId = computed(() => {
  const params = route.params;
  console.log('Full route params:', params);
  console.log('Raw ID:', params.id, typeof params.id);
  
  if (params.id && typeof params.id === 'string') {
    return params.id;
  } else if (params.id && typeof params.id === 'object') {
    return String(params.id.id || params.id.value || params.id);
  } else {
    console.error('No valid ID found in route params:', params);
    return null;
  }
});

const fetchCarDetails = async () => {
  try {
    loading.value = true;
    error.value = null;
    
    if (!carId.value || carId.value === 'null' || carId.value === 'undefined') {
      throw new Error('ID de auto no válido');
    }
    
    console.log('Fetching car with ID:', carId.value);
    
    const response = await carService.getCarById(carId.value);
    car.value = response.data || response; 
    console.log('Car details loaded:', car.value);

  } catch (err) {
    console.error('Error fetching car details:', err);
    error.value = err;
  } finally {
    loading.value = false;
  }
};

const fetchCarPdf = async () => {
  if (!car.value?.hasPdfCertification) {
    console.log('Car does not have PDF certification');
    return;
  }
  
  try {
    loadingPdf.value = true;
    const pdfResponse = await carService.getCarPdf(carId.value);
    
    let base64Data = pdfResponse.pdfCertification?.base64Data || pdfResponse.pdfCertification;
    
    if (base64Data && !base64Data.startsWith('data:')) {
      carPdf.value = `data:application/pdf;base64,${base64Data}`;
    } else {
      carPdf.value = base64Data;
    }
    
    console.log('PDF loaded successfully');
  } catch (err) {
    console.error('Error fetching car PDF:', err);
  } finally {
    loadingPdf.value = false;
  }
};

const downloadReport = (base64Data) => {
  if (!base64Data) {
    console.warn('No technical report data provided.');
    return;
  }

  try {
    const link = document.createElement('a');
    link.href = base64Data;
    link.download = `technical_report_${car.value.brand}_${car.value.model}_${car.value.licensePlate}.pdf`; 
    
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  } catch (error) {
    console.error('Error downloading PDF:', error);
    window.open(base64Data, '_blank');
  }
};

const openReportInNewTab = (base64Data) => {
  if (!base64Data) {
    console.warn('No technical report data provided.');
    return;
  }
  
  window.open(base64Data, '_blank');
};

const formatCurrency = (value) => {
  const numValue = typeof value === 'string' ? parseFloat(value) : value;
  if (typeof numValue !== 'number' || isNaN(numValue)) {
    return value;
  }
  return new Intl.NumberFormat('es-PE', { style: 'currency', currency: 'PEN' }).format(numValue);
};

const goBack = () => {
  router.back();
};

const contactSeller = () => {
  if (car.value && car.value.ownerEmail) {
    const subject = encodeURIComponent(t('carDetail.emailSubject', { model: car.value.model, brand: car.value.brand }));
    const body = encodeURIComponent(t('carDetail.emailBody', { 
        model: car.value.model, 
        brand: car.value.brand, 
        licensePlate: car.value.licensePlate 
    }));
    window.location.href = `mailto:${car.value.ownerEmail}?subject=${subject}&body=${body}`;
  } else {
    console.warn('No owner email available to contact.');
    alert(t('carDetail.noEmailWarning'));
  }
};

  const shareUrl = computed(() => {
    const base = import.meta.env.VITE_APP_BASE_URL || window.location.origin;
    return `${base}/certiweb-frontend/car-detail/${carId.value}`;
  });

  const copyLinkFeedback = ref('');
  const showCopyFeedback = ref(false);

  const copyShareLink = async () => {
    try {
      await navigator.clipboard.writeText(shareUrl.value);
      copyLinkFeedback.value = t('carDetail.linkCopied');
    } catch {
      copyLinkFeedback.value = `${t('carDetail.copyFailed')} ${shareUrl.value}`;
    }
    showCopyFeedback.value = true;
    setTimeout(() => { showCopyFeedback.value = false; }, 3000);
  };

onMounted(async () => {
  console.log('=== DEBUGGING ROUTE ===');
  console.log('Current route:', route);
  console.log('Route params:', route.params);
  console.log('Route path:', route.path);
  console.log('Computed carId:', carId.value);
  console.log('======================');
  
  await fetchCarDetails();
  if (car.value?.hasPdfCertification) {
    await fetchCarPdf();
  }
});
</script>

<template>
  <div class="car-detail-container">
    <pv-button 
      icon="pi pi-arrow-left" 
      :label="t('carDetail.backButton')" 
      @click="goBack" 
      class="p-button-text back-button" 
    />

    <div v-if="loading" class="loading-spinner">
      <pv-progress-spinner />
      <p>{{ t('carDetail.loading') }}</p>
    </div>

    <div v-else-if="error" class="error-message">
      <i class="pi pi-exclamation-triangle"></i>
      <p>{{ t('carDetail.error') }} {{ error.message }}</p>
      <pv-button 
        :label="t('carDetail.tryAgain')" 
        @click="fetchCarDetails" 
        icon="pi pi-refresh" 
        class="p-button-outlined" 
      />
    </div>

    <div v-else-if="car" class="car-content-grid">
      <!-- Image Gallery Section -->
      <div class="image-gallery">
        <img 
          :src="car.imageUrl || 'https://via.placeholder.com/600x400?text=No+Image'" 
          :alt="car.model" 
          class="main-car-image" 
        />
      </div>

      <!-- Details Section -->
      <div class="details-section">
        <div class="car-title-row">
          <h1 class="car-main-title">{{ car.title }}</h1>
          <verified-seal v-if="car.hasPdfCertification" size="lg" />
        </div>
        <div class="car-meta">
          <span><i class="pi pi-tag"></i> {{ t('carDetail.brand') }} {{ car.brand }}</span>
          <span><i class="pi pi-car"></i> {{ t('carDetail.model') }} {{ car.model }}</span>
          <span><i class="pi pi-calendar"></i> {{ t('carDetail.year') }} {{ car.year }}</span>
        </div>

        <div class="price-tag">{{ formatCurrency(car.price) }}</div>

        <div class="section-block">
          <h3 class="section-title"><i class="pi pi-user"></i> {{ t('carDetail.ownerInfo') }}</h3>
          <p><strong>{{ t('carDetail.owner') }}</strong> {{ car.owner }}</p>
          <p class="plate-row">
            <strong>{{ t('carDetail.licensePlate') }}</strong>
            <span class="plate-document">{{ car.licensePlate }}</span>
          </p>
        </div>

        <div class="section-block">
          <h3 class="section-title"><i class="pi pi-align-left"></i> {{ t('carDetail.description') }}</h3>
          <p class="car-full-description">{{ car.description || t('carDetail.noDescription') }}</p>
        </div>

        <!-- PDF -->
        <div class="section-block technical-report-section" v-if="car.hasPdfCertification">
          <h3 class="section-title"><i class="pi pi-file-pdf"></i> {{ t('carDetail.techCert') }}</h3>
          
          <!-- Loading PDF -->
          <div v-if="loadingPdf" class="pdf-loading">
            <pv-progress-spinner size="small" />
            <span>Cargando certificación PDF...</span>
          </div>
          
          <!-- PDF Loaded -->
          <div v-else-if="carPdf" class="pdf-content">
            <div class="pdf-actions">
              <pv-button
                :label="t('carDetail.viewCert')"
                icon="pi pi-eye"
                @click="openReportInNewTab(carPdf)"
                class="p-mr-2"
              />
              <pv-button 
                :label="t('carDetail.downloadCert')"
                icon="pi pi-download"
                @click="downloadReport(carPdf)"
                class="p-button-success" 
              />
            </div>
            <div class="pdf-preview-container">
              <iframe :src="carPdf" class="pdf-iframe" :title="t('carDetail.techCert')"></iframe>
            </div>
          </div>
          
          <!-- PDF Error -->
          <div v-else class="pdf-error">
            <i class="pi pi-exclamation-triangle"></i>
            <span>Error al cargar la certificación PDF</span>
            <pv-button 
              label="Reintentar" 
              icon="pi pi-refresh" 
              @click="fetchCarPdf" 
              class="p-button-outlined p-button-sm" 
            />
          </div>
        </div>
        
        <!-- No PDF -->
        <div v-else class="section-block">
            <h3 class="section-title"><i class="pi pi-file-excel"></i> {{ t('carDetail.techCert') }}</h3>
            <p>{{ t('carDetail.noCert') }}</p>
        </div>

        <div class="actions-footer">
          <div class="share-section">
            <h3 class="section-title">
              <i class="pi pi-share-alt"></i> {{ t('carDetail.shareTitle') }}
            </h3>
            <div class="share-actions">
              <pv-input-text
                :value="shareUrl"
                readonly
                class="share-url-input"
              />
              <pv-button
                :label="t('carDetail.shareLink')"
                icon="pi pi-copy"
                class="p-button-outlined"
                @click="copyShareLink"
              />
            </div>
            <pv-message
              v-if="showCopyFeedback"
              severity="success"
              :closable="false"
              class="copy-feedback"
            >
              {{ copyLinkFeedback }}
            </pv-message>
          </div>
          <pv-button
            :label="t('carDetail.contactSeller')" 
            icon="pi pi-envelope" 
            class="p-button-raised p-button-primary" 
            @click="contactSeller" 
          />
        </div>
      </div>
    </div>
    
    <div v-else class="no-car-found">
      <i class="pi pi-car"></i>
      <p>{{ t('carDetail.notFound') }}</p>
    </div>
  </div>
</template>

<style scoped>
.pdf-loading {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 2rem;
  background: var(--color-brand-soft, #E8F0EC);
  border-radius: 8px;
  border: 1px dashed var(--color-border, #D8DFDA);
  justify-content: center;
}

.pdf-error {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  padding: 2rem;
  background: #fdf2f2;
  border-radius: 8px;
  border: 1px dashed #f0caca;
  color: #a02525;
}

.car-detail-container {
  max-width: 1400px;
  margin: 2rem auto;
  padding: 2rem;
  background: var(--color-paper, #FCFCFA);
  border: 1px solid var(--color-border, #D8DFDA);
  border-radius: 12px;
  font-family: var(--font-body, 'Inter', sans-serif);
}

.back-button {
  margin-bottom: 2rem;
  color: var(--color-brand, #1B4B3A) !important;
  font-weight: 600 !important;
  padding: 0.75rem 1.5rem !important;
  border-radius: 8px !important;
  transition: background-color 0.2s ease !important;
}

.back-button:hover {
  background: var(--color-brand-soft, #E8F0EC) !important;
}

.loading-spinner,
.error-message,
.no-car-found {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
  text-align: center;
  color: var(--color-graphite, #5C645F);
  padding: 2rem;
}

.loading-spinner p {
  margin-top: 1.5rem;
  font-size: 1.2rem;
  font-weight: 500;
}

.error-message i {
  font-size: 4rem;
  margin-bottom: 1.5rem;
  color: #b83232;
}

.no-car-found i {
  font-size: 4rem;
  margin-bottom: 1.5rem;
  color: var(--color-graphite, #5C645F);
}

.error-message p,
.no-car-found p {
  font-size: 1.3rem;
  margin-bottom: 1.5rem;
  font-weight: 500;
}

.car-content-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 3rem;
  align-items: start;
}

.image-gallery {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.main-car-image {
  width: 100%;
  max-width: 600px;
  height: auto;
  min-height: 300px;
  max-height: 500px;
  object-fit: cover;
  border-radius: 12px;
  border: 1px solid var(--color-border, #D8DFDA);
  margin-bottom: 1.5rem;
}

.details-section {
  padding: 0;
}

.car-title-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.car-main-title {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 2.25rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  line-height: 1.2;
}

.car-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 1.5rem;
  font-size: 1rem;
  color: var(--color-graphite, #5C645F);
  margin-bottom: 2rem;
  padding: 1.5rem;
  background: var(--color-brand-soft, #E8F0EC);
  border-radius: 12px;
}

.car-meta span {
  display: flex;
  align-items: center;
  font-weight: 500;
  padding: 0.5rem 1rem;
  background: var(--color-paper, #FCFCFA);
  border: 1px solid var(--color-border, #D8DFDA);
  border-radius: 20px;
}

.car-meta i {
  margin-right: 0.75rem;
  color: var(--color-brand, #1B4B3A);
  font-size: 1.1rem;
}

.price-tag {
  font-size: 2rem;
  font-weight: 700;
  color: var(--color-ink, #12211C);
  margin-bottom: 2rem;
  padding: 1.25rem 2rem;
  background: var(--color-brand-soft, #E8F0EC);
  border-radius: 12px;
  display: inline-block;
  border: 1px solid var(--color-border, #D8DFDA);
}

.plate-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.plate-document {
  font-family: var(--font-mono, 'IBM Plex Mono', monospace);
  font-size: 0.95rem;
  letter-spacing: 0.04em;
  color: var(--color-ink, #12211C);
  background: var(--color-paper, #FCFCFA);
  border: 1px solid var(--color-border, #D8DFDA);
  border-radius: 6px;
  padding: 0.35rem 0.75rem;
}

.section-block {
  margin-bottom: 2.5rem;
  padding: 2rem;
  background: var(--color-paper, #FCFCFA);
  border-radius: 12px;
  border: 1px solid var(--color-border, #D8DFDA);
}

.section-title {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.35rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin-bottom: 1.25rem;
  padding-bottom: 0.75rem;
  border-bottom: 2px solid var(--color-brand, #1B4B3A);
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.section-title i {
  color: var(--color-brand, #1B4B3A);
  font-size: 1.2rem;
}

.car-full-description {
  font-size: 1.05rem;
  line-height: 1.8;
  color: var(--color-graphite, #5C645F);
  white-space: pre-wrap;
  background: var(--color-brand-soft, #E8F0EC);
  padding: 1.5rem;
  border-radius: 8px;
}

.technical-report-section .pdf-actions {
  margin-bottom: 1.5rem;
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

.pdf-actions :deep(.p-button) {
  padding: 0.875rem 1.5rem !important;
  font-weight: 600 !important;
  border-radius: 8px !important;
}

.pdf-preview-container {
  border: 1px solid var(--color-border, #D8DFDA);
  border-radius: 12px;
  overflow: hidden;
  height: 600px;
  margin-top: 1.5rem;
  background: var(--color-brand-soft, #E8F0EC);
  position: relative;
}

.pdf-iframe {
  width: 100%;
  height: 100%;
  border: none;
  background: white;
}

.actions-footer {
  margin-top: 3rem;
  padding: 2rem;
  background: var(--color-brand-soft, #E8F0EC);
  border-radius: 12px;
  display: flex;
  justify-content: center;
  gap: 1rem;
}

.actions-footer :deep(.p-button) {
  padding: 1rem 2.5rem !important;
  font-size: 1.1rem !important;
  font-weight: 600 !important;
  border-radius: 8px !important;
}

/* Responsive Design */
@media (min-width: 1200px) {
  .car-content-grid {
    grid-template-columns: 1fr 1.5fr;
    gap: 4rem;
  }
  
  .details-section {
    padding-left: 2rem;
  }
}

@media (max-width: 1024px) {
  .car-detail-container {
    padding: 1.5rem;
    margin: 1rem;
  }
  
  .car-main-title {
    font-size: 2.2rem;
  }
  
  .price-tag {
    font-size: 2rem;
    padding: 1rem 1.5rem;
  }
  
  .section-title {
    font-size: 1.3rem;
  }
  
  .pdf-preview-container {
    height: 500px;
  }
}

@media (max-width: 768px) {
  .car-detail-container {
    padding: 1rem;
    margin: 0.5rem;
  }
  
  .back-button {
    margin-bottom: 1.5rem;
    padding: 0.625rem 1.25rem !important;
    font-size: 0.95rem !important;
  }
  
  .car-content-grid {
    gap: 2rem;
  }
  
  .car-main-title {
    font-size: 1.875rem;
    margin-bottom: 1rem;
  }
  
  .car-meta {
    flex-direction: column;
    gap: 0.75rem;
    padding: 1.25rem;
  }
  
  .car-meta span {
    justify-content: center;
    padding: 0.75rem 1rem;
  }
  
  .price-tag {
    font-size: 1.75rem;
    padding: 1rem 1.25rem;
    text-align: center;
    width: 100%;
    box-sizing: border-box;
  }
  
  .section-block {
    padding: 1.5rem;
    margin-bottom: 2rem;
  }
  
  .section-title {
    font-size: 1.2rem;
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .car-full-description {
    font-size: 1rem;
    padding: 1.25rem;
  }
  
  .pdf-actions {
    flex-direction: column;
  }
  
  .pdf-actions :deep(.p-button) {
    width: 100% !important;
    justify-content: center !important;
  }
  
  .pdf-preview-container {
    height: 400px;
    background: var(--color-brand-soft, #E8F0EC);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    padding: 1rem;
  }

  .pdf-iframe {
    display: none;
  }

  .pdf-preview-container::after {
    content: "Para una mejor experiencia, utiliza los botones de arriba para ver o descargar el certificado PDF";
    color: var(--color-graphite, #5C645F);
    font-size: 0.9rem;
    line-height: 1.5;
    background: var(--color-paper, #FCFCFA);
    padding: 1.5rem;
    border-radius: 8px;
    border: 1px dashed var(--color-border, #D8DFDA);
    max-width: 100%;
  }
  
  .actions-footer {
    padding: 1.5rem;
  }
  
  .actions-footer :deep(.p-button) {
    width: 100% !important;
    padding: 0.875rem 2rem !important;
    font-size: 1rem !important;
  }
}

@media (max-width: 480px) {
  .car-detail-container {
    padding: 0.75rem;
    margin: 0.25rem;
    border-radius: 12px;
  }
  
  .car-main-title {
    font-size: 1.625rem;
    text-align: center;
  }
  
  .car-meta {
    padding: 1rem;
  }
  
  .car-meta span {
    font-size: 0.9rem;
    padding: 0.625rem 0.875rem;
  }
  
  .price-tag {
    font-size: 1.5rem;
    padding: 0.75rem 1rem;
  }
  
  .section-block {
    padding: 1.25rem;
  }
  
  .section-title {
    font-size: 1.1rem;
  }
  
  .car-full-description {
    font-size: 0.95rem;
    padding: 1rem;
  }
  
  .pdf-preview-container {
    height: 300px;
    padding: 0.75rem;
  }
  
  .pdf-preview-container::after {
    font-size: 0.85rem;
    padding: 1.25rem;
  }
  
  .actions-footer {
    padding: 1.25rem;
  }
  
  .actions-footer :deep(.p-button) {
    padding: 0.75rem 1.5rem !important;
    font-size: 0.95rem !important;
  }
}

@media (max-width: 360px) {
  .car-detail-container {
    padding: 0.5rem;
  }
  
  .car-main-title {
    font-size: 1.5rem;
  }
  
  .price-tag {
    font-size: 1.375rem;
    padding: 0.75rem 0.875rem;
  }
  
  .section-block {
    padding: 1rem;
  }
  
  .section-title {
    font-size: 1rem;
  }
  
  .pdf-preview-container {
    height: 250px;
    padding: 0.5rem;
  }
  
  .pdf-preview-container::after {
    font-size: 0.8rem;
    padding: 1rem;
  }
}

@media (min-width: 769px) {
  .pdf-preview-container::after {
    display: none;
  }

  .pdf-iframe {
    display: block !important;
  }
}

.share-section {
  margin-bottom: 1.5rem;
}

.share-actions {
  display: flex;
  gap: 0.75rem;
  align-items: center;
  flex-wrap: wrap;
  margin-top: 0.5rem;
}

.share-url-input {
  flex: 1;
  min-width: 200px;
  font-family: var(--font-mono, 'IBM Plex Mono', monospace);
  font-size: 0.8rem;
  color: var(--color-graphite, #5C645F);
  background: var(--color-brand-soft, #E8F0EC);
}

/* Focus styles for keyboard navigation */
:deep(.back-button:focus-visible),
:deep(.pdf-actions .p-button:focus-visible),
:deep(.actions-footer .p-button:focus-visible),
:deep(.share-actions .p-button:focus-visible) {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}

.copy-feedback {
  margin-top: 0.5rem;
}
</style>
<script setup>
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import AcceptReservationComponent from './accept-reservation/accept-reservation.component.vue';
import AdFormComponent from './ad-form/ad-form.component.vue';
import UploadCertificationComponent from './upload-certification/upload-certification.component.vue';
import { carService } from '@/certifications/services/car.service.js';
import { useI18n } from 'vue-i18n';
const { t } = useI18n();

const acceptedReservationData = ref(null);
const adFormState = ref({ data: {}, isValid: false });
const pdfState = ref(null);
const createdCarId = ref(null);
const isSavingCar = ref(false);

const router = useRouter();

const isStep2Complete = computed(() => adFormState.value.isValid);
const isStep3Complete = computed(() => !!pdfState.value?.pdfCertification);
const isReadyToFinalize = computed(() =>
  !!acceptedReservationData.value && isStep2Complete.value && isStep3Complete.value && !createdCarId.value
);

const handleReservationAccepted = (reservationData) => {
  acceptedReservationData.value = reservationData;
  createdCarId.value = null;
};

const handleAdFormUpdate = (payload) => {
  adFormState.value = payload;
};

const handlePdfDataUpdate = (payload) => {
  pdfState.value = payload;
};

const handleFinalizeCar = async () => {
  if (!acceptedReservationData.value || !isStep2Complete.value || !isStep3Complete.value) {
    alert(t('adminCertification.alertFinalizeIncomplete'));
    return;
  }

  isSavingCar.value = true;

  try {
    const formData = adFormState.value.data;

    if (!acceptedReservationData.value.brand || !acceptedReservationData.value.model) {
      throw new Error('Marca y modelo son requeridos');
    }

    const brandMapping = {
      'toyota': 1,
      'nissan': 2,
      'hyundai': 3,
      'kia': 4,
      'chevrolet': 5,
      'suzuki': 6,
      'mitsubishi': 7,
      'honda': 8,
      'volkswagen': 9,
      'ford': 10,
      'mercedes': 11,
      'mercedes-benz': 11,
      'audi': 12,
      'bmw': 13
    };

    const brandName = acceptedReservationData.value.brand.toLowerCase().trim();
    const correctBrandId = brandMapping[brandName];

    if (!correctBrandId) {
      throw new Error(`Marca no reconocida: ${acceptedReservationData.value.brand}`);
    }

    const currentYear = new Date().getFullYear();
    const year = parseInt(formData.year) || currentYear;
    if (year < 1900 || year > currentYear + 1) {
      throw new Error(`El año debe estar entre 1900 y ${currentYear + 1}`);
    }

    const licensePlate = acceptedReservationData.value.licensePlate;
    if (!licensePlate || licensePlate.length < 6 || licensePlate.length > 10) {
      throw new Error('La placa debe tener entre 6 y 10 caracteres');
    }

    const price = parseFloat(acceptedReservationData.value.price) || 0;
    if (price < 0) {
      throw new Error('El precio no puede ser negativo');
    }

    const carDataPayload = {
      title: formData.title || `${acceptedReservationData.value.brand} ${acceptedReservationData.value.model}`,
      owner: acceptedReservationData.value.reservationName,
      ownerEmail: acceptedReservationData.value.reservationEmail,
      year: year,
      brandId: correctBrandId,
      model: acceptedReservationData.value.model,
      description: formData.description || '',
      pdfCertification: pdfState.value.pdfCertification,
      imageUrl: acceptedReservationData.value.imageUrl || 'https://via.placeholder.com/300x200.png?text=Car+Image',
      price: price,
      licensePlate: licensePlate,
      originalReservationId: parseInt(acceptedReservationData.value.id)
    };

    const requiredFields = ['title', 'owner', 'ownerEmail', 'year', 'brandId', 'model', 'licensePlate', 'originalReservationId', 'pdfCertification'];
    for (const field of requiredFields) {
      if (!carDataPayload[field] && carDataPayload[field] !== 0) {
        throw new Error(`Campo requerido faltante: ${field}`);
      }
    }

    const response = await carService.createCar(carDataPayload);

    if (response && (response.id || response.data?.id)) {
      createdCarId.value = response.id || response.data.id;
      alert(t('adminCertification.alertCarSaved'));
    } else {
      throw new Error('Respuesta inválida del servidor');
    }

  } catch (error) {
    console.error('Error al guardar el auto:', error);
    const errorMessage = error.response?.data?.message || error.message || 'Error desconocido';
    alert(t('adminCertification.alertSaveCarError') + ': ' + errorMessage);
  } finally {
    isSavingCar.value = false;
  }
};

const completedSteps = computed(() => {
  let steps = 0;
  if (acceptedReservationData.value) steps++;
  if (isStep2Complete.value) steps++;
  if (isStep3Complete.value) steps++;
  return steps;
});

const resetProcess = () => {
  acceptedReservationData.value = null;
  adFormState.value = { data: {}, isValid: false };
  pdfState.value = null;
  createdCarId.value = null;
  isSavingCar.value = false;
};

const handleLogout = () => {
  localStorage.removeItem('currentSession');
  router.push('/login');
};
</script>

<template>
  <div class="admin-certification-container">
    <!-- Progress Indicator -->
    <div class="progress-indicator">
      <div class="progress-header">
        <h2 class="progress-title">
          <i class="pi pi-cog"></i>
          {{ t('adminCertification.processTitle') }}
        </h2>
        <div class="progress-stats">
          <span class="steps-completed">{{ t('adminCertification.stepsCompleted', { completedSteps }) }}</span>
          <pv-button
            v-if="completedSteps > 0"
            :label="t('adminCertification.resetProcess')"
            icon="pi pi-refresh"
            class="p-button-text p-button-sm reset-button"
            @click="resetProcess"
          />
          <pv-button
            :label="t('adminCertification.logout')"
            icon="pi pi-sign-out"
            class="p-button-text p-button-sm logout-button"
            @click="handleLogout"
          />
        </div>
      </div>

      <div class="progress-steps">
        <div class="step" :class="{ 'completed': acceptedReservationData, 'active': !acceptedReservationData }">
          <div class="step-icon">
            <i class="pi pi-check" v-if="acceptedReservationData"></i>
            <span v-else>1</span>
          </div>
          <span class="step-label">{{ t('adminCertification.step1') }}</span>
        </div>

        <div class="step-connector" :class="{ 'completed': acceptedReservationData }"></div>

        <div class="step" :class="{
          'completed': isStep2Complete,
          'active': acceptedReservationData && !isStep2Complete
        }">
          <div class="step-icon">
            <i class="pi pi-check" v-if="isStep2Complete"></i>
            <span v-else>2</span>
          </div>
          <span class="step-label">{{ t('adminCertification.step2') }}</span>
        </div>

        <div class="step-connector" :class="{ 'completed': isStep2Complete }"></div>

        <div class="step" :class="{
          'completed': isStep3Complete,
          'active': acceptedReservationData && !isStep3Complete
        }">
          <div class="step-icon">
            <i class="pi pi-check" v-if="isStep3Complete"></i>
            <span v-else>3</span>
          </div>
          <span class="step-label">{{ t('adminCertification.step3') }}</span>
        </div>
      </div>
    </div>

    <!-- Components -->
    <div class="components-container">
      <!-- Step 1: Accept Reservation -->
      <div class="component-section">
        <div class="step-header">
          <h3 class="step-title">
            <span class="step-number">1</span>
            {{ t('adminCertification.step1Title') }}
          </h3>
          <div v-if="acceptedReservationData" class="step-status completed">
            <i class="pi pi-check-circle"></i>
            <span>{{ t('adminCertification.step1Completed') }}</span>
          </div>
        </div>
        <AcceptReservationComponent @reservationAccepted="handleReservationAccepted" />
      </div>

      <!-- Step 2: Vehicle Data -->
      <div class="component-section" :class="{ 'disabled': !acceptedReservationData }">
        <div class="step-header">
          <h3 class="step-title">
            <span class="step-number">2</span>
            {{ t('adminCertification.step2Title') }}
          </h3>
          <div v-if="isStep2Complete" class="step-status completed">
            <i class="pi pi-check-circle"></i>
            <span>{{ t('adminCertification.step2Completed') }}</span>
          </div>
          <div v-else-if="!acceptedReservationData" class="step-status disabled">
            <i class="pi pi-lock"></i>
            <span>{{ t('adminCertification.step2Locked') }}</span>
          </div>
        </div>
        <AdFormComponent
          :initialData="acceptedReservationData"
          @update:formData="handleAdFormUpdate"
        />
      </div>

      <!-- Step 3: Upload PDF -->
      <div class="component-section" :class="{ 'disabled': !acceptedReservationData }">
        <div class="step-header">
          <h3 class="step-title">
            <span class="step-number">3</span>
            {{ t('adminCertification.step3Title') }}
          </h3>
          <div v-if="isStep3Complete" class="step-status completed">
            <i class="pi pi-check-circle"></i>
            <span>{{ t('adminCertification.step3Completed') }}</span>
          </div>
          <div v-else-if="!acceptedReservationData" class="step-status disabled">
            <i class="pi pi-lock"></i>
            <span>{{ t('adminCertification.step3Locked') }}</span>
          </div>
        </div>
        <UploadCertificationComponent
          v-if="acceptedReservationData"
          @update:pdfData="handlePdfDataUpdate"
        />
        <div v-else class="placeholder-message">
          <div class="placeholder-content">
            <i class="pi pi-upload"></i>
            <h4>{{ t('adminCertification.pdfUploadLocked') }}</h4>
            <p>{{ t('adminCertification.completePreviousSteps') }}</p>
          </div>
        </div>
      </div>

      <!-- Final Save -->
      <div class="component-section final-save-section">
        <div v-if="createdCarId" class="final-save-success">
          <verified-seal size="lg" :label="t('adminCertification.carCreatedTitle')" />
          <div>
            <h4>{{ t('adminCertification.carCreatedTitle') }}</h4>
            <p>{{ t('adminCertification.step2CarId', { createdCarId }) }}</p>
          </div>
        </div>
        <pv-button
          v-else
          :label="t('adminCertification.finalSaveLabel')"
          icon="pi pi-save"
          class="p-button-lg final-save-button"
          @click="handleFinalizeCar"
          :disabled="!isReadyToFinalize || isSavingCar"
          :loading="isSavingCar"
        />
      </div>
    </div>
  </div>
</template>

<style scoped>
.admin-certification-container {
  box-sizing: border-box;
  max-width: 1400px;
  margin: 0 auto;
  padding: 2rem;
  background: var(--color-paper, #FCFCFA);
  min-height: 100vh;
  font-family: var(--font-body, 'Inter', sans-serif);
}

/* Progress Indicator */
.progress-indicator {
  background: var(--color-paper, #FCFCFA);
  border-radius: 12px;
  padding: 2rem;
  margin-bottom: 2rem;
  border: 1px solid var(--color-border, #D8DFDA);
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
  margin-bottom: 2rem;
}

.progress-title {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin: 0;
}

.progress-title i {
  color: var(--color-brand, #1B4B3A);
  font-size: 1.3rem;
}

.progress-stats {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.5rem;
  background: var(--color-brand-soft, #E8F0EC);
  padding: 0.75rem 1rem;
  border-radius: 10px;
  border: 1px solid var(--color-border, #D8DFDA);
}

.steps-completed {
  font-weight: 600;
  color: var(--color-ink, #12211C);
  font-size: 0.9rem;
}

:deep(.reset-button.p-button-text) {
  color: var(--color-brand, #1B4B3A) !important;
}

:deep(.logout-button.p-button-text) {
  color: #a02525 !important;
}

.progress-steps {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0;
}

.step {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
  position: relative;
  z-index: 2;
}

.step-icon {
  width: 2.75rem;
  height: 2.75rem;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 1.05rem;
  transition: border-color 0.2s ease, background-color 0.2s ease, color 0.2s ease;
  border: 2px solid var(--color-border, #D8DFDA);
  background: var(--color-paper, #FCFCFA);
  color: var(--color-graphite, #5C645F);
}

.step.completed .step-icon {
  background: var(--color-brand, #1B4B3A);
  border-color: var(--color-brand, #1B4B3A);
  color: var(--color-paper, #FCFCFA);
}

.step.active .step-icon {
  border-color: var(--color-brand, #1B4B3A);
  background: var(--color-brand-soft, #E8F0EC);
  color: var(--color-brand, #1B4B3A);
}

.step-label {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-graphite, #5C645F);
  text-align: center;
  white-space: nowrap;
}

.step.completed .step-label,
.step.active .step-label {
  color: var(--color-brand, #1B4B3A);
}

.step-connector {
  width: 8rem;
  height: 2px;
  background: var(--color-border, #D8DFDA);
  position: relative;
  z-index: 1;
  transition: background-color 0.3s ease;
}

.step-connector.completed {
  background: var(--color-brand, #1B4B3A);
}

/* Components Container */
.components-container {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.component-section {
  position: relative;
}

.component-section.disabled {
  opacity: 0.6;
  pointer-events: none;
}

/* Step Headers */
.step-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
  margin-bottom: 1rem;
  padding: 1rem 1.5rem;
  background: var(--color-paper, #FCFCFA);
  border-radius: 10px;
  border: 1px solid var(--color-border, #D8DFDA);
}

.step-title {
  display: flex;
  align-items: center;
  gap: 1rem;
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.15rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin: 0;
}

.step-number {
  width: 2rem;
  height: 2rem;
  background: var(--color-brand, #1B4B3A);
  color: var(--color-paper, #FCFCFA);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.9rem;
  font-weight: 700;
  flex-shrink: 0;
}

.step-status {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.4rem 0.9rem;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 600;
}

.step-status.completed {
  background: var(--color-brand-soft, #E8F0EC);
  color: var(--color-brand, #1B4B3A);
  border: 1px solid var(--color-brand, #1B4B3A);
}

.step-status.disabled {
  background: var(--color-paper, #FCFCFA);
  color: var(--color-graphite, #5C645F);
  border: 1px solid var(--color-border, #D8DFDA);
}

/* Placeholder Message */
.placeholder-message {
  background: var(--color-paper, #FCFCFA);
  border-radius: 12px;
  padding: 3rem;
  text-align: center;
  border: 2px dashed var(--color-border, #D8DFDA);
  margin-top: 1rem;
}

.placeholder-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  color: var(--color-graphite, #5C645F);
}

.placeholder-content i {
  font-size: 2.5rem;
  color: var(--color-graphite, #5C645F);
}

.placeholder-content h4 {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.2rem;
  font-weight: 600;
  margin: 0;
  color: var(--color-ink, #12211C);
}

.placeholder-content p {
  font-size: 1rem;
  margin: 0;
}

/* Final Save */
.final-save-section {
  background: var(--color-paper, #FCFCFA);
  border-radius: 12px;
  padding: 2.5rem;
  text-align: center;
  border: 1px solid var(--color-border, #D8DFDA);
}

:deep(.final-save-button) {
  background: var(--color-brand, #1B4B3A) !important;
  border: 1px solid var(--color-brand, #1B4B3A) !important;
  padding: 1rem 2rem !important;
  font-size: 1.05rem !important;
  font-weight: 600 !important;
  border-radius: 10px !important;
  transition: background-color 0.2s ease !important;
}

:deep(.final-save-button:hover:not(:disabled)) {
  background: var(--color-brand-strong, #123329) !important;
  border-color: var(--color-brand-strong, #123329) !important;
}

:deep(.final-save-button:disabled) {
  opacity: 0.5 !important;
  cursor: not-allowed !important;
}

.final-save-success {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  color: var(--color-brand, #1B4B3A);
}

.final-save-success h4 {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  margin: 0 0 0.25rem 0;
  font-size: 1.2rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  text-align: left;
}

.final-save-success p {
  margin: 0;
  color: var(--color-graphite, #5C645F);
  text-align: left;
}

/* Focus visibility */
:deep(.p-button:focus-visible) {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}

/* Responsive Design */
@media (max-width: 1024px) {
  .admin-certification-container {
    padding: 1.5rem;
  }

  .progress-header {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }

  .step-connector {
    width: 4rem;
  }
}

@media (max-width: 768px) {
  .admin-certification-container {
    padding: 1rem;
  }

  .progress-indicator {
    padding: 1.5rem;
  }

  .progress-title {
    font-size: 1.3rem;
    flex-direction: column;
    gap: 0.5rem;
  }

  .progress-steps {
    flex-direction: column;
    gap: 1rem;
  }

  .step-connector {
    width: 2px;
    height: 2rem;
  }

  .step-header {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }

  .final-save-success {
    flex-direction: column;
    text-align: center;
  }

  .final-save-success h4,
  .final-save-success p {
    text-align: center;
  }
}

@media (max-width: 480px) {
  .progress-title {
    font-size: 1.15rem;
  }

  .step-icon {
    width: 2.25rem;
    height: 2.25rem;
    font-size: 0.95rem;
  }

  .step-label {
    font-size: 0.8rem;
  }
}
</style>

<script setup>
import { ref, computed, watch, defineProps, defineEmits } from 'vue';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
const props = defineProps({
  initialData: {
    type: Object,
    default: null
  }
});

const emit = defineEmits(['update:formData']);

const formData = ref({
  title: '',
  owner: '',
  ownerEmail: '',
  year: null,
  brand: '',
  model: '',
  description: '',
  pdfCertification: {},
  imageUrl: '',
  price: '',
  licensePlate: ''
});

watch(() => props.initialData, (newData) => {
  if (newData) {
    formData.value.owner = newData.reservationName || '';
    formData.value.ownerEmail = newData.reservationEmail || '';
    formData.value.brand = newData.brand || '';
    formData.value.model = newData.model || '';
    formData.value.imageUrl = newData.imageUrl || '';
    formData.value.price = newData.price || '';
    formData.value.licensePlate = newData.licensePlate || '';
  }
}, { immediate: true });

const isFormValid = computed(() => {
  const currentYear = new Date().getFullYear();
  const year = formData.value.year;
  const licensePlate = formData.value.licensePlate;

  return formData.value.title &&
         formData.value.owner &&
         formData.value.ownerEmail &&
         year !== null && year >= 1900 && year <= currentYear + 1 &&
         formData.value.brand &&
         formData.value.model &&
         formData.value.description &&
         licensePlate && licensePlate.length >= 6 && licensePlate.length <= 10;
});

watch(formData, (newData) => {
  emit('update:formData', { data: newData, isValid: isFormValid.value });
}, { deep: true, immediate: true });

const formProgress = computed(() => {
  const fields = [
    formData.value.title,
    formData.value.owner,
    formData.value.ownerEmail,
    formData.value.year !== null ? 'filled' : '',
    formData.value.brand,
    formData.value.model,
    formData.value.description
  ];
  const filledFields = fields.filter(field => field && field.toString().trim()).length;
  return Math.round((filledFields / fields.length) * 100);
});
</script>

<template>
  <div class="form-container">
    <!-- Header Section -->
    <div class="form-header">
      <div class="header-content">
        <div class="header-icon">
          <i class="pi pi-megaphone"></i>
        </div>
        <div class="header-text">
          <h1 class="main-title">{{ t('adForm.creationTitle') }}</h1>
          <p class="subtitle">{{ t('adForm.creationSubtitle') }}</p>
        </div>
      </div>

      <!-- Progress Bar -->
      <div class="progress-section">
        <div class="progress-info">
          <span class="progress-label">{{ t('adForm.formProgress') }}</span>
          <span class="progress-percentage">{{ formProgress }}%</span>
        </div>
        <div class="progress-bar">
          <div
            class="progress-fill"
            :style="{ width: formProgress + '%' }"
          ></div>
        </div>
      </div>
    </div>

    <!-- Form Section -->
    <div class="form-content">
      <div class="section-header">
        <i class="pi pi-car section-icon"></i>
        <h2 class="section-title">{{ t('adForm.vehicleAdData') }}</h2>
      </div>

      <div class="form-grid">
        <!-- Título del anuncio -->
        <div class="field-group full-width">
          <div class="field-header">
            <label for="title" class="field-label">
              <i class="pi pi-tag label-icon"></i>
              {{ t('adForm.adTitle') }}
            </label>
            <span class="field-badge editable">{{ t('adForm.editable') }}</span>
          </div>
          <div class="input-wrapper">
            <pv-inputText
              id="title"
              v-model="formData.title"
              class="form-input editable-input"
              :placeholder="t('adForm.adTitlePlaceholder')"
            />
            <div class="input-hint">
              <i class="pi pi-info-circle"></i>
              <span>{{ t('adForm.adTitleHint') }}</span>
            </div>
          </div>
        </div>

        <!-- owner -->
        <div class="field-group">
          <div class="field-header">
            <label for="owner" class="field-label">
              <i class="pi pi-user label-icon"></i>
              {{ t('adForm.owner') }}
            </label>
            <span class="field-badge readonly">{{ t('adForm.autoCompleted') }}</span>
          </div>
          <div class="input-wrapper">
            <pv-inputText
              id="owner"
              v-model="formData.owner"
              class="form-input readonly-input"
              :placeholder="t('adForm.ownerPlaceholder')"
              readonly
            />
            <div class="readonly-indicator">
              <i class="pi pi-lock"></i>
            </div>
          </div>
        </div>

        <!-- Owner Email -->
        <div class="field-group">
          <div class="field-header">
            <label for="ownerEmail" class="field-label">
              <i class="pi pi-envelope label-icon"></i>
              {{ t('adForm.ownerEmail') }}
            </label>
            <span class="field-badge readonly">{{ t('adForm.autoCompleted') }}</span>
          </div>
          <div class="input-wrapper">
            <pv-inputText
              id="ownerEmail"
              v-model="formData.ownerEmail"
              class="form-input readonly-input"
              :placeholder="t('adForm.ownerEmailPlaceholder')"
              readonly
            />
            <div class="readonly-indicator">
              <i class="pi pi-lock"></i>
            </div>
          </div>
        </div>

        <!-- Año -->
        <div class="field-group">
          <div class="field-header">
            <label for="year" class="field-label">
              <i class="pi pi-calendar label-icon"></i>
              {{ t('adForm.year') }}
            </label>
            <span class="field-badge editable">{{ t('adForm.editable') }}</span>
          </div>
          <div class="input-wrapper">
            <pv-input-number
              id="year"
              v-model="formData.year"
              class="form-input editable-input"
              :placeholder="t('adForm.yearPlaceholder')"
              :useGrouping="false"
              mode="decimal"
              :maxlength="4"
              :min="1900"
              :max="new Date().getFullYear() + 1"
            />
             <div class="input-hint">
              <i class="pi pi-info-circle"></i>
              <span>{{ t('adForm.yearHint') }}</span>
            </div>
          </div>
        </div>

        <!-- brand -->
        <div class="field-group">
          <div class="field-header">
            <label for="brand" class="field-label">
              <i class="pi pi-bookmark label-icon"></i>
              {{ t('adForm.brand') }}
            </label>
            <span class="field-badge readonly">{{ t('adForm.autoCompleted') }}</span>
          </div>
          <div class="input-wrapper">
            <pv-inputText
              id="brand"
              v-model="formData.brand"
              class="form-input readonly-input"
              :placeholder="t('adForm.brandPlaceholder')"
              readonly
            />
            <div class="readonly-indicator">
              <i class="pi pi-lock"></i>
            </div>
          </div>
        </div>

        <!-- model -->
        <div class="field-group">
          <div class="field-header">
            <label for="model" class="field-label">
              <i class="pi pi-cog label-icon"></i>
              {{ t('adForm.model') }}
            </label>
            <span class="field-badge readonly">{{ t('adForm.autoCompleted') }}</span>
          </div>
          <div class="input-wrapper">
            <pv-inputText
              id="model"
              v-model="formData.model"
              class="form-input readonly-input"
              :placeholder="t('adForm.modelPlaceholder')"
              readonly
            />
            <div class="readonly-indicator">
              <i class="pi pi-lock"></i>
            </div>
          </div>
        </div>

        <!-- Placa (dato técnico de solo lectura, heredado de la reserva aceptada) -->
        <div class="field-group">
          <div class="field-header">
            <label for="licensePlate" class="field-label">
              <i class="pi pi-id-card label-icon"></i>
              {{ t('adForm.licensePlate') }}
            </label>
            <span class="field-badge readonly">{{ t('adForm.autoCompleted') }}</span>
          </div>
          <div class="input-wrapper">
            <pv-inputText
              id="licensePlate"
              v-model="formData.licensePlate"
              class="form-input readonly-input plate-input"
              :placeholder="t('adForm.licensePlatePlaceholder')"
              readonly
            />
            <div class="readonly-indicator">
              <i class="pi pi-lock"></i>
            </div>
          </div>
        </div>

        <!-- Descripción -->
        <div class="field-group full-width">
          <div class="field-header">
            <label for="description" class="field-label">
              <i class="pi pi-file-edit label-icon"></i>
              {{ t('adForm.detailedDescription') }}
            </label>
            <span class="field-badge editable">{{ t('adForm.editable') }}</span>
          </div>
          <div class="input-wrapper">
            <pv-textarea
              id="description"
              v-model="formData.description"
              class="form-textarea editable-input"
              rows="5"
              :placeholder="t('adForm.descriptionPlaceholder')"
            />
            <div class="textarea-counter">
              <span>{{ formData.description?.length || 0 }} {{ t('adForm.characters') }}</span>
            </div>
            <div class="input-hint">
              <i class="pi pi-lightbulb"></i>
              <span>{{ t('adForm.descriptionHint') }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Form Status -->
      <div class="form-status" :class="{ 'valid': isFormValid }">
        <div class="status-content">
          <div class="status-icon">
            <i :class="isFormValid ? 'pi pi-check-circle' : 'pi pi-exclamation-triangle'"></i>
          </div>
          <div class="status-text">
            <span class="status-title">
              {{ isFormValid ? t('adForm.formComplete') : t('adForm.formIncomplete') }}
            </span>
            <span class="status-description">
              {{ isFormValid
                ? t('adForm.allFieldsCompleted')
                : t('adForm.completeEditableFields')
              }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.form-container {
  box-sizing: border-box;
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
  background: var(--color-paper, #FCFCFA);
  font-family: var(--font-body, 'Inter', sans-serif);
}

/* Header Styles */
.form-header {
  background: var(--color-paper, #FCFCFA);
  border-radius: 12px;
  padding: 2rem;
  margin-bottom: 2rem;
  border: 1px solid var(--color-border, #D8DFDA);
}

.header-content {
  display: flex;
  align-items: center;
  gap: 1.25rem;
  margin-bottom: 2rem;
}

.header-icon {
  width: 3.5rem;
  height: 3.5rem;
  background: var(--color-brand, #1B4B3A);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-paper, #FCFCFA);
  font-size: 1.5rem;
  flex-shrink: 0;
}

.header-text {
  flex: 1;
  min-width: 0;
}

.main-title {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.9rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin: 0 0 0.4rem 0;
}

.subtitle {
  font-size: 1rem;
  color: var(--color-graphite, #5C645F);
  margin: 0;
  font-weight: 500;
}

/* Progress Section */
.progress-section {
  background: var(--color-brand-soft, #E8F0EC);
  border-radius: 10px;
  padding: 1.25rem;
  border: 1px solid var(--color-border, #D8DFDA);
}

.progress-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.progress-label {
  font-weight: 600;
  color: var(--color-ink, #12211C);
  font-size: 0.9rem;
}

.progress-percentage {
  font-weight: 700;
  color: var(--color-brand, #1B4B3A);
  font-size: 1rem;
}

.progress-bar {
  width: 100%;
  height: 8px;
  background: var(--color-border, #D8DFDA);
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: var(--color-brand, #1B4B3A);
  border-radius: 4px;
  transition: width 0.4s ease;
}

/* Form Content */
.form-content {
  background: var(--color-paper, #FCFCFA);
  border-radius: 12px;
  padding: 2rem;
  border: 1px solid var(--color-border, #D8DFDA);
}

.section-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid var(--color-brand, #1B4B3A);
}

.section-icon {
  color: var(--color-brand, #1B4B3A);
  font-size: 1.3rem;
}

.section-title {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.3rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin: 0;
}

/* Form Grid */
.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.75rem;
}

.field-group {
  display: flex;
  flex-direction: column;
}

.full-width {
  grid-column: 1 / -1;
}

/* Field Header */
.field-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.6rem;
}

.field-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  font-size: 0.9rem;
}

.label-icon {
  color: var(--color-brand, #1B4B3A);
  font-size: 0.9rem;
}

.field-badge {
  padding: 0.2rem 0.65rem;
  border-radius: 10px;
  font-size: 0.7rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.4px;
  white-space: nowrap;
}

.field-badge.editable {
  background: var(--color-brand-soft, #E8F0EC);
  color: var(--color-brand, #1B4B3A);
  border: 1px solid var(--color-brand, #1B4B3A);
}

.field-badge.readonly {
  background: var(--color-paper, #FCFCFA);
  color: var(--color-graphite, #5C645F);
  border: 1px solid var(--color-border, #D8DFDA);
}

/* Input Wrapper */
.input-wrapper {
  position: relative;
}

.readonly-indicator {
  position: absolute;
  right: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: var(--color-graphite, #5C645F);
  font-size: 0.85rem;
  pointer-events: none;
}

.input-hint {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-top: 0.5rem;
  font-size: 0.8rem;
  color: var(--color-graphite, #5C645F);
}

.input-hint i {
  color: var(--color-brand, #1B4B3A);
}

.textarea-counter {
  position: absolute;
  bottom: 0.75rem;
  right: 1rem;
  font-size: 0.75rem;
  color: var(--color-graphite, #5C645F);
  background: var(--color-paper, #FCFCFA);
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  border: 1px solid var(--color-border, #D8DFDA);
}

/* Form Status */
.form-status {
  margin-top: 2rem;
  padding: 1.25rem 1.5rem;
  border-radius: 10px;
  border: 2px solid var(--color-verified, #B08D3E);
  background: var(--color-verified-soft, #F5EDDC);
  transition: border-color 0.2s ease, background-color 0.2s ease;
}

.form-status.valid {
  border-color: var(--color-brand, #1B4B3A);
  background: var(--color-brand-soft, #E8F0EC);
}

.status-content {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.status-icon {
  font-size: 1.4rem;
  color: var(--color-verified, #B08D3E);
}

.form-status.valid .status-icon {
  color: var(--color-brand, #1B4B3A);
}

.status-text {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
}

.status-title {
  font-weight: 600;
  color: var(--color-ink, #12211C);
  font-size: 1rem;
}

.status-description {
  font-size: 0.88rem;
  color: var(--color-graphite, #5C645F);
}

/* PrimeVue Component Overrides */
:deep(.form-input) {
  width: 100%;
  padding: 0.85rem 1.1rem;
  border: 1px solid var(--color-border, #D8DFDA);
  border-radius: 8px;
  font-size: 1rem;
  font-family: var(--font-body, 'Inter', sans-serif);
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
  background: var(--color-paper, #FCFCFA);
  color: var(--color-ink, #12211C);
}

:deep(.form-input:focus) {
  outline: none;
  border-color: var(--color-brand, #1B4B3A);
  box-shadow: 0 0 0 3px var(--color-brand-soft, #E8F0EC);
}

:deep(.form-input:focus-visible) {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}

:deep(.readonly-input) {
  background: #F1F2EF;
  color: var(--color-graphite, #5C645F);
  cursor: not-allowed;
}

:deep(.plate-input.p-inputtext) {
  font-family: var(--font-mono, 'IBM Plex Mono', monospace);
  letter-spacing: 0.06em;
}

:deep(.form-textarea) {
  width: 100%;
  padding: 0.85rem 1.1rem;
  border: 1px solid var(--color-border, #D8DFDA);
  border-radius: 8px;
  font-size: 1rem;
  font-family: var(--font-body, 'Inter', sans-serif);
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
  background: var(--color-paper, #FCFCFA);
  color: var(--color-ink, #12211C);
  resize: vertical;
  min-height: 120px;
  line-height: 1.5;
}

:deep(.form-textarea:focus) {
  outline: none;
  border-color: var(--color-brand, #1B4B3A);
  box-shadow: 0 0 0 3px var(--color-brand-soft, #E8F0EC);
}

:deep(.form-textarea:focus-visible) {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}

/* Responsive Design */
@media (max-width: 768px) {
  .form-container {
    padding: 1rem;
  }

  .form-header,
  .form-content {
    padding: 1.5rem;
  }

  .header-content {
    flex-direction: column;
    text-align: center;
    gap: 1rem;
  }

  .main-title {
    font-size: 1.5rem;
  }

  .form-grid {
    grid-template-columns: 1fr;
    gap: 1.25rem;
  }

  .field-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.4rem;
  }
}
</style>

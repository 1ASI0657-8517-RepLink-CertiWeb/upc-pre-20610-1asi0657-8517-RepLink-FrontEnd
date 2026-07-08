<script setup>
import { ref, defineEmits, computed, watch } from 'vue';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
const selectedFile = ref(null);
const isDragOver = ref(false);
const isUploading = ref(false);
const uploadProgress = ref(0);
const base64Data = ref(null);

const emit = defineEmits(['update:pdfData']);

watch(base64Data, (newValue) => {
  emit('update:pdfData', newValue ? { pdfCertification: newValue, fileName: selectedFile.value?.name } : null);
});

const fileSize = computed(() => {
  if (!selectedFile.value) return '';
  const size = selectedFile.value.size;
  if (size < 1024) return `${size} B`;
  if (size < 1024 * 1024) return `${(size / 1024).toFixed(1)} KB`;
  return `${(size / (1024 * 1024)).toFixed(1)} MB`;
});

const isValidFile = computed(() => {
  return selectedFile.value && selectedFile.value.type === 'application/pdf';
});

const convertToBase64 = (file) => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => resolve(reader.result);
    reader.onerror = error => reject(error);
  });
};

const onSelect = async (event) => {
  selectedFile.value = event.files[0];
  try {
    const base64Result = await convertToBase64(selectedFile.value);
    base64Data.value = base64Result;

    console.log('PDF converted to base64:', base64Result.substring(0, 100) + '...');
  } catch (error) {
    console.error('Error converting file:', error);
  }
  simulateUpload();
};

const simulateUpload = () => {
  isUploading.value = true;
  uploadProgress.value = 0;

  const interval = setInterval(() => {
    uploadProgress.value += 10;
    if (uploadProgress.value >= 100) {
      clearInterval(interval);
      isUploading.value = false;
    }
  }, 100);
};

const removeFile = () => {
  selectedFile.value = null;
  base64Data.value = null;
  uploadProgress.value = 0;
  isUploading.value = false;
};

const downloadPreview = () => {
  if (base64Data.value) {
    const link = document.createElement('a');
    link.href = base64Data.value;
    link.download = selectedFile.value.name;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }
};

const openPreview = () => {
  if (base64Data.value) {
    window.open(base64Data.value, '_blank');
  }
};

const onDragEnter = () => {
  isDragOver.value = true;
};

const onDragLeave = () => {
  isDragOver.value = false;
};

const onDrop = () => {
  isDragOver.value = false;
};
</script>

<template>
  <div class="upload-container">
    <!-- Header Section -->
    <div class="upload-header">
      <div class="header-content">
        <div class="header-icon">
          <i class="pi pi-file-pdf"></i>
        </div>
        <div class="header-text">
          <h3 class="section-title">{{ t('uploadTechReport.title') }}</h3>
          <p class="section-subtitle">{{ t('uploadTechReport.subtitle') }}</p>
        </div>
      </div>
    </div>

    <!-- Upload Area -->
    <div class="upload-content">
      <!-- File Upload Zone -->
      <div
        v-if="!selectedFile"
        class="upload-zone"
        :class="{ 'drag-over': isDragOver }"
        @dragenter="onDragEnter"
        @dragleave="onDragLeave"
        @drop="onDrop"
      >
        <div class="upload-zone-content">
          <div class="upload-icon">
            <i class="pi pi-cloud-upload"></i>
          </div>

          <div class="upload-text">
            <h4 class="upload-title">{{ t('uploadZone.selectOrDrag') }}</h4>
            <p class="upload-description">
              {{ t('uploadZone.supportedFormats') }}
            </p>
          </div>

          <pv-fileupload
            mode="basic"
            name="informe"
            accept=".pdf"
            :maxFileSize="10000000"
            @select="onSelect"
            :chooseLabel="t('uploadZone.selectFile')"
            class="custom-file-upload"
            :auto="false"
          />

          <div class="upload-features">
            <div class="feature-item">
              <i class="pi pi-shield feature-icon"></i>
              <span>{{ t('uploadZone.features.secure') }}</span>
            </div>
            <div class="feature-item">
              <i class="pi pi-clock feature-icon"></i>
              <span>{{ t('uploadZone.features.fast') }}</span>
            </div>
            <div class="feature-item">
              <i class="pi pi-check feature-icon"></i>
              <span>{{ t('uploadZone.features.validation') }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- File Selected State -->
      <div v-if="selectedFile" class="file-selected">
        <!-- Upload Progress -->
        <div v-if="isUploading" class="upload-progress">
          <div class="progress-header">
            <span class="progress-text">{{ t('fileState.processing') }}</span>
            <span class="progress-percentage">{{ uploadProgress }}%</span>
          </div>
          <div class="progress-bar">
            <div
              class="progress-fill"
              :style="{ width: uploadProgress + '%' }"
            ></div>
          </div>
        </div>

        <!-- File Info Card -->
        <div class="file-card" :class="{ 'uploading': isUploading }">
          <div class="file-info">
            <div class="file-icon-wrapper">
              <div class="file-icon">
                <i class="pi pi-file-pdf"></i>
              </div>
              <div v-if="isValidFile" class="file-status valid">
                <i class="pi pi-check"></i>
              </div>
            </div>

            <div class="file-details">
              <h5 class="file-name">{{ selectedFile.name }}</h5>
              <div class="file-meta">
                <span class="file-size">{{ fileSize }}</span>
                <span class="file-type">{{ t('fileState.fileType') }}</span>
              </div>
              <div class="file-validation" :class="{ 'valid': isValidFile }">
                <i :class="isValidFile ? 'pi pi-check-circle' : 'pi pi-exclamation-triangle'"></i>
                <span>{{ isValidFile ? t('fileState.validFile') : t('fileState.invalidFormat') }}</span>
              </div>
              <div v-if="base64Data" class="base64-info">
                <i class="pi pi-database"></i>
                <span>{{ t('fileState.base64Generated', { size: Math.round(base64Data.length / 1024) }) }}</span>
              </div>
            </div>

            <pv-button
              v-if="!isUploading"
              @click="removeFile"
              class="remove-button"
              :aria-label="t('fileState.removeFile')"
              :title="t('fileState.removeFile')"
            >
              <i class="pi pi-times"></i>
            </pv-button>
          </div>
        </div>

        <!-- PDF Preview -->
        <div v-if="isValidFile && !isUploading && base64Data" class="pdf-preview">
          <div class="preview-header">
            <h5 class="preview-title">
              <i class="pi pi-eye"></i>
              {{ t('preview.title') }}
            </h5>
          </div>

          <div class="preview-content">
            <div class="preview-card">
              <div class="preview-icon">
                <i class="pi pi-file-pdf"></i>
              </div>
              <div class="preview-info">
                <h6 class="preview-filename">{{ selectedFile.name }}</h6>
                <p class="preview-description">
                  {{ t('preview.description') }}
                </p>
                <div class="preview-actions">
                  <pv-button class="preview-button" @click="downloadPreview">
                    <i class="pi pi-download"></i>
                    {{ t('preview.actions.download') }}
                  </pv-button>
                  <pv-button class="preview-button" @click="openPreview">
                    <i class="pi pi-external-link"></i>
                    {{ t('preview.actions.open') }}
                  </pv-button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Success Message -->
        <div v-if="!isUploading && isValidFile && base64Data" class="success-message">
          <div class="success-content">
            <verified-seal size="md" :label="t('successMessage.title')" />
            <div class="success-text">
              <h6 class="success-title">{{ t('successMessage.title') }}</h6>
              <p class="success-description">
                {{ t('successMessage.description') }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.upload-container {
  box-sizing: border-box;
  max-width: 800px;
  margin: 0 auto;
  padding: 1rem;
  background: var(--color-paper, #FCFCFA);
  font-family: var(--font-body, 'Inter', sans-serif);
}

/* Header Styles */
.upload-header {
  background: var(--color-paper, #FCFCFA);
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  border: 1px solid var(--color-border, #D8DFDA);
}

.header-content {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
}

.header-icon {
  width: 3rem;
  height: 3rem;
  background: var(--color-brand, #1B4B3A);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-paper, #FCFCFA);
  font-size: 1.25rem;
  flex-shrink: 0;
}

.header-text {
  flex: 1;
  min-width: 200px;
}

.section-title {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.35rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin: 0 0 0.4rem 0;
  line-height: 1.2;
}

.section-subtitle {
  font-size: 0.9rem;
  color: var(--color-graphite, #5C645F);
  margin: 0;
  font-weight: 500;
  line-height: 1.4;
}

/* Upload Content */
.upload-content {
  background: var(--color-paper, #FCFCFA);
  border-radius: 12px;
  padding: 1.5rem;
  border: 1px solid var(--color-border, #D8DFDA);
}

/* Upload Zone */
.upload-zone {
  border: 2px dashed var(--color-border, #D8DFDA);
  border-radius: 10px;
  padding: 2rem;
  text-align: center;
  transition: border-color 0.2s ease, background-color 0.2s ease;
  background: var(--color-brand-soft, #E8F0EC);
}

.upload-zone.drag-over {
  border-color: var(--color-brand, #1B4B3A);
}

.upload-zone-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.25rem;
}

.upload-icon {
  width: 3.5rem;
  height: 3.5rem;
  background: var(--color-brand, #1B4B3A);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-paper, #FCFCFA);
  font-size: 1.4rem;
}

.upload-text {
  text-align: center;
}

.upload-title {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.15rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin: 0 0 0.4rem 0;
}

.upload-description {
  font-size: 0.88rem;
  color: var(--color-graphite, #5C645F);
  margin: 0;
  line-height: 1.4;
}

.custom-file-upload {
  margin: 0.5rem 0;
}

.upload-features {
  display: flex;
  gap: 1.5rem;
  flex-wrap: wrap;
  justify-content: center;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.82rem;
  color: var(--color-graphite, #5C645F);
}

.feature-icon {
  color: var(--color-brand, #1B4B3A);
  font-size: 0.9rem;
}

/* File Selected State */
.file-selected {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

/* Upload Progress */
.upload-progress {
  background: var(--color-brand-soft, #E8F0EC);
  border-radius: 10px;
  padding: 1.25rem;
  border: 1px solid var(--color-border, #D8DFDA);
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.progress-text {
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

/* File Card */
.file-card {
  background: var(--color-paper, #FCFCFA);
  border: 1px solid var(--color-border, #D8DFDA);
  border-radius: 10px;
  padding: 1.25rem;
  transition: border-color 0.2s ease, background-color 0.2s ease;
}

.file-card.uploading {
  border-color: var(--color-brand, #1B4B3A);
  background: var(--color-brand-soft, #E8F0EC);
}

.file-info {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
}

.file-icon-wrapper {
  position: relative;
  flex-shrink: 0;
}

.file-icon {
  width: 2.75rem;
  height: 2.75rem;
  background: var(--color-brand, #1B4B3A);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-paper, #FCFCFA);
  font-size: 1.2rem;
}

.file-status {
  position: absolute;
  top: -0.25rem;
  right: -0.25rem;
  width: 1.2rem;
  height: 1.2rem;
  background: var(--color-brand, #1B4B3A);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-paper, #FCFCFA);
  font-size: 0.65rem;
  border: 2px solid var(--color-paper, #FCFCFA);
}

.file-details {
  flex: 1;
  min-width: 0;
}

.file-name {
  font-size: 1rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin: 0 0 0.5rem 0;
  word-break: break-word;
}

.file-meta {
  display: flex;
  gap: 1rem;
  margin-bottom: 0.75rem;
  flex-wrap: wrap;
}

.file-size,
.file-type {
  font-size: 0.78rem;
  color: var(--color-graphite, #5C645F);
  background: var(--color-brand-soft, #E8F0EC);
  padding: 0.2rem 0.5rem;
  border-radius: 6px;
}

.file-validation {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  color: #a02525;
  margin-bottom: 0.5rem;
}

.file-validation.valid {
  color: var(--color-brand, #1B4B3A);
}

.file-validation i {
  font-size: 0.9rem;
}

.base64-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.78rem;
  color: var(--color-graphite, #5C645F);
}

:deep(.remove-button) {
  background: #fdf2f2 !important;
  border: 1px solid #f0caca !important;
  color: #a02525 !important;
  padding: 0.5rem !important;
  border-radius: 8px !important;
  width: 2.5rem;
  height: 2.5rem;
  flex-shrink: 0;
}

:deep(.remove-button:hover) {
  background: #fbe2e2 !important;
  border-color: #e0a8a8 !important;
}

/* PDF Preview */
.pdf-preview {
  background: var(--color-brand-soft, #E8F0EC);
  border-radius: 10px;
  padding: 1.25rem;
  border: 1px solid var(--color-border, #D8DFDA);
}

.preview-header {
  margin-bottom: 1rem;
}

.preview-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.05rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin: 0;
}

.preview-title i {
  color: var(--color-brand, #1B4B3A);
}

.preview-content {
  background: var(--color-paper, #FCFCFA);
  border-radius: 8px;
  padding: 1rem;
  border: 1px solid var(--color-border, #D8DFDA);
}

.preview-card {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.preview-icon {
  width: 2.5rem;
  height: 2.5rem;
  background: var(--color-brand, #1B4B3A);
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-paper, #FCFCFA);
  font-size: 1rem;
  flex-shrink: 0;
}

.preview-info {
  flex: 1;
  min-width: 0;
}

.preview-filename {
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin: 0 0 0.5rem 0;
  word-break: break-word;
}

.preview-description {
  font-size: 0.8rem;
  color: var(--color-graphite, #5C645F);
  margin: 0 0 1rem 0;
  line-height: 1.4;
}

.preview-actions {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}

:deep(.preview-button) {
  background: var(--color-paper, #FCFCFA) !important;
  border: 1px solid var(--color-border, #D8DFDA) !important;
  color: var(--color-ink, #12211C) !important;
  padding: 0.5rem 1rem !important;
  font-size: 0.8rem !important;
  border-radius: 6px !important;
}

:deep(.preview-button:hover) {
  background: var(--color-brand-soft, #E8F0EC) !important;
  border-color: var(--color-brand, #1B4B3A) !important;
}

/* Success Message */
.success-message {
  background: var(--color-brand-soft, #E8F0EC);
  border: 1px solid var(--color-brand, #1B4B3A);
  border-radius: 10px;
  padding: 1.25rem;
}

.success-content {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
}

.success-text {
  flex: 1;
}

.success-title {
  font-weight: 600;
  color: var(--color-ink, #12211C);
  font-size: 1rem;
  margin: 0 0 0.4rem 0;
  line-height: 1.3;
}

.success-description {
  font-size: 0.9rem;
  color: var(--color-graphite, #5C645F);
  margin: 0;
  line-height: 1.4;
}

/* Focus visibility for interactive elements */
:deep(.p-button:focus-visible) {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}

/* Responsive Design */
@media (min-width: 576px) {
  .upload-container {
    padding: 1.5rem;
  }

  .upload-header,
  .upload-content {
    padding: 2rem;
  }

  .header-content {
    flex-wrap: nowrap;
  }

  .header-icon {
    width: 3.5rem;
    height: 3.5rem;
    font-size: 1.5rem;
  }

  .section-title {
    font-size: 1.6rem;
  }

  .section-subtitle {
    font-size: 1rem;
  }

  .upload-zone {
    padding: 3rem;
  }

  .upload-icon {
    width: 4.5rem;
    height: 4.5rem;
    font-size: 1.75rem;
  }

  .upload-title {
    font-size: 1.3rem;
  }

  .upload-description {
    font-size: 1rem;
  }
}

@media (min-width: 768px) {
  .upload-container {
    padding: 2rem;
  }

  .section-title {
    font-size: 1.75rem;
  }

  .preview-card {
    align-items: flex-start;
  }

  .success-content {
    align-items: center;
  }
}

@media (min-width: 992px) {
  .upload-header,
  .upload-content {
    padding: 2.5rem;
  }

  .section-title {
    font-size: 1.9rem;
  }

  .header-icon {
    width: 4rem;
    height: 4rem;
    font-size: 1.75rem;
  }
}

/* High contrast mode support */
@media (prefers-contrast: high) {
  .upload-header,
  .upload-content {
    border: 2px solid #000;
  }

  .section-title {
    color: #000;
  }
}

/* Reduced motion support */
@media (prefers-reduced-motion: reduce) {
  * {
    transition-duration: 0.01ms !important;
  }
}
</style>

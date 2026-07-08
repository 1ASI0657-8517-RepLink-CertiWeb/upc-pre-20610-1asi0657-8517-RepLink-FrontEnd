<script setup>
import { ref, onMounted } from 'vue'
import { userService } from '@/certifications/services/user.service'
import toolbarComponent from '../../../certifications/components/dashboard/toolbar/toolbar.component.vue'
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
const user = ref({
  name: '',
  email: '',
  plan: ''
});
const loading = ref(true);

onMounted(async () => {
  try {
    const userData = await userService.getCurrentUser();
    user.value = {
      name: userData.name || '',
      email: userData.email || '',
      plan: userData.plan || ''
    };
  } catch (e) {
    user.value = {
      name: 'No disponible',
      email: 'No disponible',
      plan: 'No disponible'
    };
  } finally {
    loading.value = false;
  }
});
</script>

<template>
  <toolbarComponent/>
  <div class="profile-wrapper">
      <pv-card class="profile-card">
          <template #header>
              <h2 class="profile-title">{{ t('profilePage.title') }}</h2>
          </template>
          <template #content>
              <div v-if="loading" class="profile-loading">
                  {{ t('profilePage.loading') }}
              </div>
              <div v-else class="profile-data">
                  <div class="profile-row">
                      <span class="profile-label">{{ t('profilePage.nameLabel') }}:</span>
                      <span class="profile-value">{{ user.name }}</span>
                  </div>
                  <div class="profile-row">
                      <span class="profile-label">{{ t('profilePage.emailLabel') }}:</span>
                      <span class="profile-value">{{ user.email }}</span>
                  </div>
                  <div class="profile-row">
                      <span class="profile-label">{{ t('profilePage.planLabel') }}:</span>
                      <span class="profile-value">{{ user.plan }}</span>
                  </div>
              </div>
              <div class="back-home">
                  <pv-button 
                      :label="t('profilePage.backButton')" 
                      icon="pi pi-home" 
                      class="p-button-text home-btn"
                      @click="$router.push('/')" 
                  />
              </div>
          </template>
      </pv-card>
  </div>
</template>

<style scoped>
.profile-wrapper,
.profile-wrapper * {
  box-sizing: border-box;
}

.profile-wrapper {
  min-height: 60vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: var(--color-brand-soft, #E8F0EC);
  padding: 2rem 1rem;
  font-family: var(--font-body, 'Inter', sans-serif);
}

:deep(.profile-card) {
  width: 100%;
  max-width: 500px;
  border-radius: 12px;
  box-shadow: 0 8px 30px rgba(18, 33, 28, 0.12);
  background: var(--color-paper, #FCFCFA);
  border: 1px solid var(--color-border, #D8DFDA);
  overflow: hidden;
}

:deep(.profile-card .p-card-header) {
  background: var(--color-brand, #1B4B3A);
  padding: 1.5rem;
}

:deep(.profile-card .p-card-content) {
  padding: 1.5rem;
}

.profile-title {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  color: var(--color-paper, #FCFCFA);
  font-size: 1.6rem;
  font-weight: 600;
  margin: 0;
  text-align: center;
  letter-spacing: -0.01em;
}

.profile-data {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.profile-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background-color: var(--color-brand-soft, #E8F0EC);
  border-radius: 8px;
  border-left: 4px solid var(--color-brand, #1B4B3A);
}

.profile-label {
  font-weight: 600;
  color: var(--color-brand, #1B4B3A);
  font-size: 1rem;
}

.profile-value {
  color: var(--color-ink, #12211C);
  font-weight: 500;
  word-break: break-all;
  max-width: 60%;
  text-align: right;
}

.profile-loading {
  text-align: center;
  color: var(--color-brand, #1B4B3A);
  font-weight: 500;
  padding: 2rem;
  font-size: 1.1rem;
}

.back-home {
  display: flex;
  justify-content: flex-start;
  margin-top: 2rem;
}

:deep(.home-btn) {
  color: var(--color-brand, #1B4B3A);
  font-weight: 600;
  font-size: 1rem;
  transition: background-color 0.2s ease;
  border-radius: 8px;
}

:deep(.home-btn:hover) {
  background-color: var(--color-brand-soft, #E8F0EC);
}

:deep(.home-btn:focus-visible) {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}

:deep(.home-btn .p-button-icon) {
  font-size: 1.1rem;
}

/* Responsive Styles */
@media (max-width: 768px) {
  .profile-wrapper {
    padding: 1.5rem 1rem;
    align-items: flex-start;
  }
  
  :deep(.profile-card) {
    max-width: 100%;
  }
  
  .profile-title {
    font-size: 1.5rem;
  }
  
  :deep(.profile-card .p-card-header) {
    padding: 1.25rem;
  }
  
  :deep(.profile-card .p-card-content) {
    padding: 1.25rem;
  }
}

@media (max-width: 576px) {
  .profile-wrapper {
    padding: 1rem 0.75rem;
    min-height: calc(100vh - 60px);
  }
  
  .profile-title {
    font-size: 1.35rem;
  }
  
  .profile-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
    padding: 0.875rem;
  }
  
  .profile-value {
    max-width: 100%;
    text-align: left;
    font-size: 0.95rem;
  }
  
  .profile-label {
    font-size: 0.9rem;
    color: var(--color-brand, #1B4B3A);
  }
  
  :deep(.profile-card .p-card-header) {
    padding: 1rem;
  }
  
  :deep(.profile-card .p-card-content) {
    padding: 1rem;
  }
  
  .back-home {
    justify-content: center;
  }
  
  :deep(.home-btn) {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 375px) {
  .profile-wrapper {
    padding: 0.75rem 0.5rem;
  }
  
  .profile-title {
    font-size: 1.25rem;
  }
  
  .profile-row {
    padding: 0.75rem;
  }
  
  .profile-loading {
    padding: 1.5rem;
    font-size: 1rem;
  }
  
  :deep(.profile-card .p-card-header) {
    padding: 0.875rem;
  }
  
  :deep(.profile-card .p-card-content) {
    padding: 0.875rem;
  }
}
</style>
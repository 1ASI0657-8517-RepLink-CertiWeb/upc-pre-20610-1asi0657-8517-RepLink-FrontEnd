<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { authService } from '../../services/auth.service.js';
import { useI18n } from 'vue-i18n';
import LanguageSwitcherComponent from '../../components/language-switcher/language-switcher.component.vue';

const router = useRouter();
const { t } = useI18n();

const email = ref('');
const password = ref('');
const errorMessage = ref('');
const successMessage = ref('');
const rememberMe = ref(false);
const isLoading = ref(false);

const validateForm = () => {
  if (!email.value || !password.value) {
    errorMessage.value = 'Por favor, completa todos los campos.';
    return false;
  }
  
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email.value)) {
    errorMessage.value = 'Por favor, introduce un correo electrónico válido.';
    return false;
  }
  
  errorMessage.value = '';
  return true;
};

const handleLogin = async () => {
  errorMessage.value = '';
  successMessage.value = '';
  
  if (!validateForm()) {
    return;
  }
  
  isLoading.value = true;
  
  try {
    const userResult = await authService.login(email.value, password.value);
    
    if (userResult.success) {
      await handleSuccessfulLogin(userResult.user, false);
      return;
    }
    
    const adminResult = await authService.loginAdmin(email.value, password.value);
    
    if (adminResult.success) {
      await handleSuccessfulLogin(adminResult.user, true);
      return;
    }
    
    errorMessage.value = 'Credenciales incorrectas. Por favor, verifica tu correo y contraseña.';
    
  } catch (error) {
    console.error('Error durante el login:', error);
    errorMessage.value = 'Error de conexión. Por favor, intenta de nuevo.';
  } finally {
    isLoading.value = false;
  }
};

const handleSuccessfulLogin = async (user, isAdmin) => {
  successMessage.value = '¡Inicio de sesión exitoso! Redirigiendo...';
  
  const sessionData = {
    userId: user.id,
    email: user.email,
    name: user.name,
    plan: user.plan,
    isLoggedIn: true,
    isAdmin: isAdmin,
    lastLogin: new Date().toISOString()
  };
  
  localStorage.setItem('currentSession', JSON.stringify(sessionData));
  
  setTimeout(() => {
    if (isAdmin) {
      router.push('/admin-certification');
    } else {
      router.push('/');
    }
  }, 1500);
};

const goToRegister = () => {
  router.push('/register');
};
</script>

<template>
  <LanguageSwitcherComponent/>
  <div class="login-wrapper">
    <div class="login-container">
      <pv-card class="login-card">
        <template #header>
          <div class="card-header">
            <h1 class="title">{{ t('loginPage.title') }}</h1>
            <p class="subtitle">{{ t('loginPage.subtitle') }}</p>
          </div>
        </template>
        
        <template #content>
          <form @submit.prevent="handleLogin" class="login-form">
            <div class="form-field">
              <label for="email">{{ t('loginPage.emailLabel') }}</label>
              <span class="p-input-icon-left w-full">
                <i class="pi pi-envelope"></i>
                <pv-inputText 
                  id="email" 
                  v-model="email" 
                  type="email" 
                  class="w-full" 
                  :placeholder="t('loginPage.emailPlaceholder')" 
                />
              </span>
            </div>
            
            <div class="form-field">
              <label for="password">{{ t('loginPage.passwordLabel') }}</label>
              <span class="p-input-icon-left w-full">
                <i class="pi pi-lock"></i>
                <pv-password 
                  id="password" 
                  v-model="password" 
                  toggleMask 
                  :feedback="false" 
                  class="w-full" 
                  :placeholder="t('loginPage.passwordPlaceholder')" 
                />
              </span>
            </div>
            
            <div class="form-options">
              <div class="remember-me">
                <pv-checkbox 
                  id="rememberMe" 
                  v-model="rememberMe" 
                  :binary="true" 
                  class="remember-checkbox"
                />
                <label for="rememberMe" class="remember-label">{{ t('loginPage.rememberMe') }}</label>
              </div>
              
              <a href="#" class="forgot-password">{{ t('loginPage.forgotPassword') }}</a>
            </div>
            
            <!-- Message Error or Success -->
            <pv-message v-if="errorMessage" severity="error" :closable="false" class="message-box">
              <i class="pi pi-exclamation-circle message-icon"></i>
              <span class="message-text">{{ errorMessage }}</span>
            </pv-message>
            
            <pv-message v-if="successMessage" severity="success" :closable="false" class="message-box">
              <i class="pi pi-check-circle message-icon"></i>
              <span class="message-text">{{ successMessage }}</span>
            </pv-message>
            
            <div class="form-actions">
              <pv-button 
                type="submit" 
                :label="isLoading ? 'Iniciando sesión...' : t('loginPage.loginButton')" 
                icon="pi pi-sign-in" 
                class="p-button-primary login-button"
                :loading="isLoading"
                :disabled="isLoading"
              />
            </div>
            
            <div class="register-prompt">
              <p>{{ t('loginPage.noAccountPrompt') }}</p>
              <pv-button 
                type="button" 
                :label="t('loginPage.registerButton')" 
                class="p-button-text register-link" 
                @click="goToRegister"
              />
            </div>
          </form>
        </template>
      </pv-card>
    </div>
  </div>
</template>

<style scoped>
.login-wrapper,
.login-wrapper * {
  box-sizing: border-box;
}

.login-wrapper {
  min-height: 100vh;
  background: var(--color-brand-soft, #E8F0EC);
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 2rem 1rem;
  font-family: var(--font-body, 'Inter', sans-serif);
}

.login-container {
  width: 100%;
  max-width: 500px;
  margin: 0 auto;
}

:deep(.login-card) {
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 8px 30px rgba(18, 33, 28, 0.12);
  background-color: var(--color-paper, #FCFCFA);
  border: 1px solid var(--color-border, #D8DFDA);
}

:deep(.login-card .p-card-header) {
  background: var(--color-brand, #1B4B3A);
  padding: 3rem 2rem;
  text-align: center;
}

.card-header .title {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  color: var(--color-paper, #FCFCFA);
  font-size: 2.25rem;
  font-weight: 600;
  margin-bottom: 0.75rem;
  letter-spacing: -0.01em;
}

.card-header .subtitle {
  color: rgba(252, 252, 250, 0.85);
  font-size: 1.05rem;
  font-weight: 400;
  line-height: 1.5;
}

:deep(.login-card .p-card-content) {
  padding: 0;
}

.login-form {
  padding: 2.5rem 2rem;
}

.form-field {
  margin-bottom: 1.75rem;
}

.form-field label {
  display: block;
  margin-bottom: 0.75rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  font-size: 0.95rem;
}

:deep(.p-inputtext) {
  width: 100%;
  padding: 1rem 1.25rem;
  border-radius: 8px;
  border: 1px solid var(--color-border, #D8DFDA);
  background-color: var(--color-paper, #FCFCFA);
  font-size: 1rem;
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
}

:deep(.p-inputtext:hover) {
  border-color: var(--color-graphite, #5C645F);
}

:deep(.p-inputtext:focus) {
  border-color: var(--color-brand, #1B4B3A);
  box-shadow: 0 0 0 3px var(--color-brand-soft, #E8F0EC);
  outline: none;
}

:deep(.p-inputtext:focus-visible),
:deep(.p-password input:focus-visible) {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}

:deep(.p-password) {
  width: 100%;
}

:deep(.p-password-input) {
  width: 100%;
}

:deep(.p-input-icon-left) {
  position: relative;
  width: 100%;
  display: block;
}

:deep(.p-input-icon-left i) {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  color: var(--color-graphite, #5C645F);
  left: 1rem;
  font-size: 1.1rem;
  pointer-events: none;
  z-index: 1;
}

:deep(.p-input-icon-left input) {
  padding-left: 3rem;
}

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.remember-me {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

:deep(.remember-checkbox) {
  margin-right: 0;
}

.remember-label {
  font-size: 0.9rem;
  color: var(--color-ink, #12211C);
  cursor: pointer;
  font-weight: 500;
}

.forgot-password {
  font-size: 0.9rem;
  color: var(--color-brand, #1B4B3A);
  text-decoration: none;
  transition: background-color 0.2s ease;
  font-weight: 500;
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
}

.forgot-password:hover {
  background-color: var(--color-brand-soft, #E8F0EC);
}

.forgot-password:focus-visible,
:deep(.remember-checkbox:focus-visible) {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}

/* Messages */
:deep(.message-box) {
  margin: 1.75rem 0;
  border-radius: 12px;
  display: flex;
  align-items: center;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

:deep(.message-box .p-message-wrapper) {
  padding: 1.25rem;
  width: 100%;
}

.message-icon {
  font-size: 1.25rem;
  margin-right: 0.75rem;
}

.message-text {
  font-weight: 500;
  line-height: 1.5;
}

/* Action Buttons */
.form-actions {
  margin-top: 2rem;
}

:deep(.login-button) {
  width: 100%;
  border-radius: 8px;
  padding: 1rem 1.5rem;
  font-weight: 700;
  font-size: 1.05rem;
  background: var(--color-brand, #1B4B3A);
  border-color: var(--color-brand, #1B4B3A);
  transition: background-color 0.2s ease;
}

:deep(.login-button:hover) {
  background: var(--color-brand-strong, #123329);
  border-color: var(--color-brand-strong, #123329);
}

:deep(.login-button:focus-visible) {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}

.register-prompt {
  margin-top: 2.5rem;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
}

.register-prompt p {
  color: var(--color-graphite, #5C645F);
  margin: 0;
  font-weight: 500;
}

:deep(.register-link) {
  color: var(--color-brand, #1B4B3A);
  font-weight: 700;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  transition: background-color 0.2s ease;
}

:deep(.register-link:hover) {
  background-color: var(--color-brand-soft, #E8F0EC);
}

:deep(.register-link:focus-visible),
:deep(.login-card .p-button:focus-visible) {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}

/* Responsive Design */
@media (max-width: 768px) {
  .login-wrapper {
    padding: 1rem 0.5rem;
  }
  
  .login-container {
    max-width: 100%;
  }
  
  :deep(.login-card .p-card-header) {
    padding: 2.5rem 1.5rem;
  }
  
  .card-header .title {
    font-size: 2.25rem;
  }
  
  .card-header .subtitle {
    font-size: 1rem;
  }
  
  .login-form {
    padding: 2rem 1.5rem;
  }
  
  .form-options {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
}

@media (max-width: 480px) {
  .login-wrapper {
    padding: 0.5rem;
  }
  
  :deep(.login-card) {
    border-radius: 16px;
  }
  
  :deep(.login-card .p-card-header) {
    padding: 2rem 1rem;
  }
  
  .card-header .title {
    font-size: 2rem;
  }
  
  .card-header .subtitle {
    font-size: 0.95rem;
  }
  
  .login-form {
    padding: 1.5rem 1rem;
  }
  
  .form-field {
    margin-bottom: 1.5rem;
  }
  
  :deep(.p-inputtext) {
    padding: 0.875rem 1rem;
    font-size: 0.95rem;
  }
  
  :deep(.p-input-icon-left input) {
    padding-left: 2.75rem;
  }
  
  :deep(.login-button) {
    padding: 0.875rem 1.25rem;
    font-size: 1rem;
  }
}

@media (max-width: 360px) {
  :deep(.login-card .p-card-header) {
    padding: 1.5rem 0.75rem;
  }
  
  .card-header .title {
    font-size: 1.75rem;
  }
  
  .login-form {
    padding: 1.25rem 0.75rem;
  }
  
  :deep(.p-inputtext) {
    padding: 0.75rem 0.875rem;
    font-size: 0.9rem;
  }
  
  .remember-label,
  .forgot-password {
    font-size: 0.85rem;
  }
}

.w-full {
  width: 100%;
}
</style>
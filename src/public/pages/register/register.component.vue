<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import LanguageSwitcherComponent from '../../components/language-switcher/language-switcher.component.vue';
import { authService } from '../../services/auth.service.js';

const router = useRouter();
const { t } = useI18n();

const currentStep = ref(0);
const items = ref([
    {
        label: t('registerPage.steps.personalInfo')
    },
    {
        label: t('registerPage.steps.selectPlan')
    },
    {
        label: t('registerPage.steps.payment')
    }
]);

const name = ref('');
const email = ref('');
const password = ref('');

const planOptions = ref([
    { name: t('registerPage.plans.free'), value: 'Free' },
    { name: t('registerPage.plans.monthly'), value: 'Mensual' },
    { name: t('registerPage.plans.yearly'), value: 'Anual' }
]);
const selectedPlan = ref(null);

// Payment Information
const cardNumber = ref('');
const expiryDate = ref('');
const cvv = ref('');

const errorMessage = ref('');
const successMessage = ref('');

const validateStep0 = () => {
  if (!name.value || !email.value || !password.value) {
    errorMessage.value = t('registerPage.errors.missingPersonalInfo');
    return false;
  }
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email.value)) {
    errorMessage.value = t('registerPage.errors.invalidEmail');
    return false;
  }
  errorMessage.value = '';
  return true;
};

const validateStep1 = () => {
  if (!selectedPlan.value) {
    errorMessage.value = t('registerPage.errors.missingPlan');
    return false;
  }
  errorMessage.value = '';
  return true;
};

const nextStep = () => {
  errorMessage.value = '';
  successMessage.value = '';

  if (currentStep.value === 0) {
    if (validateStep0()) {
      currentStep.value++;
    }
  } else if (currentStep.value === 1) {
    if (validateStep1()) {
      currentStep.value++;
    }
  }
};

const prevStep = () => {
  errorMessage.value = '';
  successMessage.value = '';
  if (currentStep.value > 0) {
    currentStep.value--;
  }
};

const handleRegistration = async () => {
  errorMessage.value = '';
  successMessage.value = '';

  if (selectedPlan.value !== 'Free' && (!cardNumber.value || !expiryDate.value || !cvv.value)) {
    errorMessage.value = t('registerPage.errors.missingPayment');
    return;
  }

  const userData = {
    name: name.value,
    email: email.value,
    password: password.value,
    plan: selectedPlan.value
  };

  try {
    // Use the new auth service register method
    const result = await authService.register(userData);
    
    if (result.success) {
      // Update localStorage for backward compatibility
      const users = JSON.parse(localStorage.getItem('users') || '[]');
      
      if (users.some(user => user.email === userData.email)) {
        const updatedUsers = users.map(user => 
          user.email === userData.email ? { ...user, ...userData, id: result.user.id } : user
        );
        localStorage.setItem('users', JSON.stringify(updatedUsers));
      } else {
        const newUser = { ...userData, id: result.user.id };
        users.push(newUser);
        localStorage.setItem('users', JSON.stringify(users));
      }
      
      successMessage.value = t('registerPage.success');
      
      // Clear form
      name.value = '';
      email.value = '';
      password.value = '';
      selectedPlan.value = null;
      cardNumber.value = '';
      expiryDate.value = '';
      cvv.value = '';
      currentStep.value = 0;
      
      setTimeout(() => {
        router.push('/login'); 
      }, 3000);
    } else {
      errorMessage.value = result.message || t('registerPage.errors.registrationFailed');
    }
  } catch (error) {
    console.error('Error en registro:', error);
    errorMessage.value = t('registerPage.errors.registrationFailed');
  }
};

const goToLogin = () => {
  router.push('/login');
};
</script>

<template>
  <LanguageSwitcherComponent/>
    <div class="register-wrapper">
      <div class="register-container">
        <pv-card class="register-card">
          <template #header>
            <div class="card-header">
              <h1 class="title">{{ t('registerPage.title') }}</h1>
              <p class="subtitle">{{ t('registerPage.subtitle') }}</p>
            </div>
          </template>
          
          <template #content>
            <div class="steps-container">
              <pv-steps :model="items" :activeStep="currentStep" class="custom-steps" :readonly="true"/>
            </div>
            
            <form @submit.prevent="currentStep === 2 ? handleRegistration() : nextStep()">
              <!-- Step 1: Personal Information -->
              <div v-if="currentStep === 0" class="step-content">
                <h2 class="step-title">{{ t('registerPage.steps.personalInfo') }}</h2>
                
                <div class="form-field">
                  <label for="name">{{ t('registerPage.formLabels.fullName') }}</label>
                  <span class="p-input-icon-left w-full">
                    <i class="pi pi-user"></i>
                    <pv-inputText id="name" v-model="name" type="text" class="w-full" :placeholder="t('registerPage.placeholders.fullName')" />
                  </span>
                </div>
                
                <div class="form-field">
                  <label for="email">{{ t('registerPage.formLabels.email') }}</label>
                  <span class="p-input-icon-left w-full">
                    <i class="pi pi-envelope"></i>
                    <pv-inputText id="email" v-model="email" type="email" class="w-full" :placeholder="t('registerPage.placeholders.email')" />
                  </span>
                </div>
                
                <div class="form-field">
                  <label for="password">{{ t('registerPage.formLabels.password') }}</label>
                  <span class="p-input-icon-left w-full">
                    <i class="pi pi-lock"></i>
                    <pv-password id="password" v-model="password" toggleMask :feedback="false" class="w-full" :placeholder="t('registerPage.placeholders.password')" />
                  </span>
                </div>
              </div>
              
              <!-- Step 2: Plan -->
              <div v-if="currentStep === 1" class="step-content">
                <h2 class="step-title">{{ t('registerPage.steps.selectPlan') }}</h2>
                
                <div class="plans-container" role="radiogroup" :aria-label="t('registerPage.steps.selectPlan')">
                  <div
                    class="plan-card"
                    :class="{ 'selected': selectedPlan === 'Free' }"
                    role="radio"
                    :aria-checked="selectedPlan === 'Free'"
                    tabindex="0"
                    @click="selectedPlan = 'Free'"
                    @keydown.enter="selectedPlan = 'Free'"
                    @keydown.space.prevent="selectedPlan = 'Free'"
                  >
                    <div class="plan-header">
                      <i class="pi pi-users plan-icon"></i>
                      <h3>{{ t('registerPage.plans.free') }}</h3>
                    </div>
                    <div class="plan-content">
                      <p class="plan-price">S/.0.00<span>/{{ t('registerPage.plans.forever') }}</span></p>
                      <ul class="plan-features">
                        <li><i class="pi pi-check"></i> {{ t('registerPage.planFeatures.contactBuyers') }}</li>
                        <li><i class="pi pi-check"></i> {{ t('registerPage.planFeatures.catalogView') }}</li>
                        <li><i class="pi pi-times"></i> {{ t('registerPage.planFeatures.noCarReservations') }}</li>
                        <li><i class="pi pi-times"></i> {{ t('registerPage.planFeatures.limitedFeatures') }}</li>
                      </ul>
                    </div>
                  </div>

                  <div
                    class="plan-card"
                    :class="{ 'selected': selectedPlan === 'Mensual' }"
                    role="radio"
                    :aria-checked="selectedPlan === 'Mensual'"
                    tabindex="0"
                    @click="selectedPlan = 'Mensual'"
                    @keydown.enter="selectedPlan = 'Mensual'"
                    @keydown.space.prevent="selectedPlan = 'Mensual'"
                  >
                    <div class="plan-header">
                      <i class="pi pi-calendar plan-icon"></i>
                      <h3>{{ t('registerPage.plans.monthly') }}</h3>
                    </div>
                    <div class="plan-content">
                      <p class="plan-price">S/.50<span>/{{ t('registerPage.plans.month') }}</span></p>
                      <ul class="plan-features">
                        <li><i class="pi pi-check"></i> {{ t('registerPage.planFeatures.fullAccess30') }}</li>
                        <li><i class="pi pi-check"></i> {{ t('registerPage.planFeatures.techSupport') }}</li>
                        <li><i class="pi pi-check"></i> {{ t('registerPage.planFeatures.updatesIncluded') }}</li>
                      </ul>
                    </div>
                  </div>

                  <div
                    class="plan-card"
                    :class="{ 'selected': selectedPlan === 'Anual' }"
                    role="radio"
                    :aria-checked="selectedPlan === 'Anual'"
                    tabindex="0"
                    @click="selectedPlan = 'Anual'"
                    @keydown.enter="selectedPlan = 'Anual'"
                    @keydown.space.prevent="selectedPlan = 'Anual'"
                  >
                    <div class="plan-badge">{{ t('registerPage.recommended') }}</div>
                    <div class="plan-header">
                      <i class="pi pi-calendar-plus plan-icon"></i>
                      <h3>{{ t('registerPage.plans.yearly') }}</h3>
                    </div>
                    <div class="plan-content">
                      <p class="plan-price">S/.250.00<span>/{{ t('registerPage.plans.year') }}</span></p>
                      <p class="plan-saving">{{ t('registerPage.plans.save16') }}</p>
                      <ul class="plan-features">
                        <li><i class="pi pi-check"></i> {{ t('registerPage.planFeatures.fullAccess365') }}</li>
                        <li><i class="pi pi-check"></i> {{ t('registerPage.planFeatures.prioritySupport') }}</li>
                        <li><i class="pi pi-check"></i> {{ t('registerPage.planFeatures.updatesIncluded') }}</li>
                        <li><i class="pi pi-check"></i> {{ t('registerPage.planFeatures.exclusiveFeatures') }}</li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
              
              <!-- Step 3: Payment Information -->
              <div v-if="currentStep === 2" class="step-content">
                <h2 class="step-title">{{ t('registerPage.steps.payment') }}</h2>
                <p class="payment-note" v-if="selectedPlan === 'Free'">{{ t('registerPage.paymentNote.freePlan') }}</p>
                
                <div v-if="selectedPlan !== 'Free'">
                <div class="form-field">
                  <label for="cardNumber">{{ t('registerPage.formLabels.cardNumber') }}</label>
                  <span class="p-input-icon-left w-full">
                    <i class="pi pi-credit-card"></i>
                    <pv-inputText id="cardNumber" v-model="cardNumber" class="w-full" :placeholder="t('registerPage.placeholders.cardNumber')" />
                  </span>
                </div>
                
                <div class="payment-row">
                  <div class="form-field">
                    <label for="expiryDate">{{ t('registerPage.formLabels.expiryDate') }}</label>
                    <pv-inputText id="expiryDate" v-model="expiryDate" :placeholder="t('registerPage.placeholders.expiryDate')" />
                  </div>
                  
                  <div class="form-field">
                    <label for="cvv">{{ t('registerPage.formLabels.cvv') }}</label>
                    <span class="p-input-icon-left">
                      <i class="pi pi-lock"></i>
                      <pv-inputText id="cvv" v-model="cvv" :placeholder="t('registerPage.placeholders.cvv')" />
                    </span>
                  </div>
                </div>
                
                <div class="payment-summary">
                  <h3>{{ t('registerPage.paymentSummary.title') }}</h3>
                  <div class="summary-row">
                    <span>{{ t('registerPage.paymentSummary.selectedPlan') }}:</span>
                    <span>{{ selectedPlan }}</span>
                  </div>
                  <div class="summary-row total">
                    <span>{{ t('registerPage.paymentSummary.total') }}:</span>
                    <span v-if="selectedPlan === 'Free'">$0.00</span>
                    <span v-else-if="selectedPlan === 'Mensual'">$19.99</span>
                    <span v-else-if="selectedPlan === 'Anual'">$199.99</span>
                  </div>
                </div>

              </div>
                
              </div>
              
              <!-- Message Error or Correct -->
              <pv-message v-if="errorMessage" severity="error" :closable="false" class="message-box">
                <i class="pi pi-exclamation-circle message-icon"></i>
                <span class="message-text">{{ errorMessage }}</span>
              </pv-message>
              
              <pv-message v-if="successMessage" severity="success" :closable="false" class="message-box">
                <i class="pi pi-check-circle message-icon"></i>
                <span class="message-text">{{ successMessage }}</span>
              </pv-message>
              
              <!-- Nav buttons -->
              <div class="form-actions">
                <pv-button 
                  v-if="currentStep > 0" 
                  type="button" 
                  :label="t('registerPage.buttons.previous')" 
                  icon="pi pi-arrow-left" 
                  class="p-button-outlined" 
                  @click="prevStep" 
                />
                
                <pv-button 
                  type="submit" 
                  :label="currentStep === 2 ? t('registerPage.buttons.complete') : t('registerPage.buttons.next')" 
                  :icon="currentStep === 2 ? 'pi pi-check' : 'pi pi-arrow-right'" 
                  iconPos="right" 
                  class="p-button-primary" 
                />
              </div>
              
              <!-- Login redirect -->
              <div class="login-prompt">
                <p>{{ t('registerPage.haveAccount') }}</p>
                <pv-button 
                  type="button" 
                  :label="t('registerPage.buttons.login')" 
                  class="p-button-text login-link" 
                  @click="goToLogin"
                />
              </div>
            </form>
          </template>
        </pv-card>
      </div>
    </div>
</template>
  
<style scoped>
.register-wrapper,
.register-wrapper * {
  box-sizing: border-box;
}

.register-wrapper {
  min-height: 100vh;
  background: var(--color-brand-soft, #E8F0EC);
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 2rem 1rem;
  font-family: var(--font-body, 'Inter', sans-serif);
}

.register-container {
  width: 100%;
  max-width: 900px;
  margin: 0 auto;
}

:deep(.register-card) {
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 8px 30px rgba(18, 33, 28, 0.12);
  background-color: var(--color-paper, #FCFCFA);
  border: 1px solid var(--color-border, #D8DFDA);
}

:deep(.register-card .p-card-header) {
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

:deep(.register-card .p-card-content) {
  padding: 0;
}

.steps-container {
  padding: 2rem;
  background: var(--color-brand-soft, #E8F0EC);
  border-bottom: 1px solid var(--color-border, #D8DFDA);
}

:deep(.custom-steps) {
  margin: 0;
}

:deep(.custom-steps .p-steps-item) {
  flex: 1;
}

:deep(.custom-steps .p-steps-item-link) {
  background: transparent;
}

:deep(.custom-steps .p-steps-item-number) {
  background-color: var(--color-paper, #FCFCFA);
  color: var(--color-graphite, #5C645F);
  border-radius: 50%;
  width: 3rem;
  height: 3rem;
  font-size: 1.1rem;
  font-weight: 700;
  border: 2px solid var(--color-border, #D8DFDA);
  transition: background-color 0.2s ease, border-color 0.2s ease;
}

:deep(.custom-steps .p-steps-item-active .p-steps-item-number) {
  background: var(--color-brand, #1B4B3A);
  color: var(--color-paper, #FCFCFA);
  border-color: var(--color-brand, #1B4B3A);
}

:deep(.custom-steps .p-steps-item-label) {
  color: var(--color-graphite, #5C645F);
  font-weight: 500;
  margin-top: 1rem;
  font-size: 0.9rem;
}

:deep(.custom-steps .p-steps-item-active .p-steps-item-label) {
  color: var(--color-ink, #12211C);
  font-weight: 700;
}

:deep(.custom-steps .p-steps-item-link:focus-visible) {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}

/* Steps Content */
.step-content {
  padding: 2.5rem;
  min-height: 400px;
}

.step-title {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.6rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin-bottom: 2rem;
  text-align: center;
  padding-bottom: 0.75rem;
  border-bottom: 2px solid var(--color-brand, #1B4B3A);
}

/* Form Fields */
.form-field {
  margin-bottom: 2rem;
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

/* Plan Selection */
.plans-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
  margin-top: 1.5rem;
}

.plan-card {
  border: 2px solid var(--color-border, #D8DFDA);
  border-radius: 12px;
  padding: 2rem;
  cursor: pointer;
  transition: border-color 0.2s ease, background-color 0.2s ease, box-shadow 0.2s ease;
  position: relative;
  background: var(--color-paper, #FCFCFA);
}

.plan-card:hover {
  border-color: var(--color-brand, #1B4B3A);
  box-shadow: 0 4px 16px rgba(18, 33, 28, 0.08);
}

.plan-card:focus-visible {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}

.plan-card.selected {
  border-color: var(--color-brand, #1B4B3A);
  background: var(--color-brand-soft, #E8F0EC);
  box-shadow: 0 4px 16px rgba(18, 33, 28, 0.1);
}

.plan-badge {
  position: absolute;
  top: -12px;
  right: 24px;
  background: var(--color-verified, #B08D3E);
  color: var(--color-paper, #FCFCFA);
  padding: 0.4rem 1rem;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.plan-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 1.5rem;
  text-align: center;
}

.plan-icon {
  font-size: 2.25rem;
  color: var(--color-brand, #1B4B3A);
  margin-bottom: 1rem;
}

.plan-header h3 {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.375rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin: 0;
}

.plan-content {
  text-align: center;
}

.plan-price {
  font-family: var(--font-mono, 'IBM Plex Mono', monospace);
  font-size: 2rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin-bottom: 0.75rem;
  line-height: 1;
}

.plan-price span {
  font-family: var(--font-body, 'Inter', sans-serif);
  font-size: 0.95rem;
  font-weight: 500;
  color: var(--color-graphite, #5C645F);
}

.plan-saving {
  color: var(--color-brand, #1B4B3A);
  font-weight: 700;
  font-size: 0.9rem;
  margin-bottom: 1.5rem;
  background: var(--color-brand-soft, #E8F0EC);
  padding: 0.4rem 1rem;
  border-radius: 20px;
  display: inline-block;
}

.plan-features {
  list-style: none;
  padding: 0;
  margin: 1.5rem 0 0;
  text-align: left;
}

.plan-features li {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  color: var(--color-graphite, #5C645F);
  font-weight: 500;
}

.plan-features li i {
  margin-right: 0.75rem;
  font-size: 1rem;
  width: 16px;
  text-align: center;
}

.plan-features li i.pi-check {
  color: var(--color-brand, #1B4B3A);
}

.plan-features li i.pi-times {
  color: var(--color-graphite, #5C645F);
}

/* Payment Information */
.payment-note {
  text-align: center;
  color: var(--color-brand, #1B4B3A);
  font-weight: 600;
  font-style: italic;
  margin-bottom: 2rem;
  background: var(--color-brand-soft, #E8F0EC);
  padding: 1.5rem;
  border-radius: 12px;
  border: 1px solid var(--color-border, #D8DFDA);
}

.payment-row {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.payment-row .form-field {
  margin-bottom: 0;
}

.payment-summary {
  background: var(--color-brand-soft, #E8F0EC);
  border-radius: 12px;
  padding: 2rem;
  margin-top: 2rem;
  border: 1px solid var(--color-border, #D8DFDA);
}

.payment-summary h3 {
  font-family: var(--font-display, 'Space Grotesk', sans-serif);
  font-size: 1.2rem;
  font-weight: 600;
  color: var(--color-ink, #12211C);
  margin-top: 0;
  margin-bottom: 1.5rem;
  text-align: center;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 1rem;
  color: var(--color-graphite, #5C645F);
  font-weight: 500;
}

.summary-row.total {
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid var(--color-border, #D8DFDA);
  font-weight: 700;
  color: var(--color-ink, #12211C);
  font-size: 1.25rem;
}

.summary-row.total span:last-child {
  font-family: var(--font-mono, 'IBM Plex Mono', monospace);
}

/* Messages */
:deep(.message-box) {
  margin: 2rem 0;
  border-radius: 12px;
  display: flex;
  align-items: center;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

:deep(.message-box .p-message-wrapper) {
  padding: 1.5rem;
  width: 100%;
}

.message-icon {
  font-size: 1.25rem;
  margin-right: 0.75rem;
}

.message-text {
  font-weight: 600;
  line-height: 1.5;
}

/* Action Buttons */
.form-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 2rem;
  padding: 2rem;
  background: var(--color-brand-soft, #E8F0EC);
  border-top: 1px solid var(--color-border, #D8DFDA);
  gap: 1rem;
}

:deep(.p-button) {
  border-radius: 8px;
  padding: 1rem 2rem;
  font-weight: 700;
  font-size: 1rem;
  transition: background-color 0.2s ease;
}

:deep(.p-button-primary) {
  background: var(--color-brand, #1B4B3A);
  border-color: var(--color-brand, #1B4B3A);
}

:deep(.p-button-primary:hover) {
  background: var(--color-brand-strong, #123329);
  border-color: var(--color-brand-strong, #123329);
}

:deep(.p-button-outlined) {
  color: var(--color-ink, #12211C);
  border-color: var(--color-border, #D8DFDA);
  background: var(--color-paper, #FCFCFA);
}

:deep(.p-button-outlined:hover) {
  background-color: var(--color-brand-soft, #E8F0EC);
  border-color: var(--color-brand, #1B4B3A);
}

:deep(.p-button:focus-visible) {
  outline: 2px solid var(--color-brand, #1B4B3A);
  outline-offset: 2px;
}

:deep(.p-button .p-button-icon-left) {
  margin-right: 0.75rem;
}

:deep(.p-button .p-button-icon-right) {
  margin-left: 0.75rem;
}

/* Login prompt */
.login-prompt {
  margin-top: 2rem;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 0 2rem 2rem;
  gap: 1rem;
}

.login-prompt p {
  color: var(--color-graphite, #5C645F);
  margin: 0;
  font-weight: 500;
}

:deep(.login-link) {
  color: var(--color-brand, #1B4B3A);
  font-weight: 700;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  transition: background-color 0.2s ease;
}

:deep(.login-link:hover) {
  background-color: var(--color-brand-soft, #E8F0EC);
}

/* Responsive Design */
@media (max-width: 1024px) {
  .register-container {
    max-width: 100%;
  }
  
  .plans-container {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }
  
  .step-content {
    padding: 2rem;
    min-height: 350px;
  }
  
  .steps-container {
    padding: 1.5rem;
  }
  
  :deep(.custom-steps .p-steps-item-number) {
    width: 2.5rem;
    height: 2.5rem;
    font-size: 1rem;
  }
  
  .step-title {
    font-size: 1.5rem;
    margin-bottom: 1.5rem;
  }
  
  .plan-card {
    padding: 1.5rem;
  }
  
  .plan-icon {
    font-size: 2rem;
  }
  
  .plan-price {
    font-size: 2rem;
  }
  
  .payment-row {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }
  
  .payment-summary {
    padding: 1.5rem;
  }
  
  .form-actions {
    flex-direction: column-reverse;
    gap: 1rem;
    padding: 1.5rem;
  }
  
  :deep(.p-button) {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 768px) {
  .register-wrapper {
    padding: 1rem 0.5rem;
  }
  
  :deep(.register-card .p-card-header) {
    padding: 2.5rem 1.5rem;
  }
  
  .card-header .title {
    font-size: 2.25rem;
  }
  
  .card-header .subtitle {
    font-size: 1rem;
  }
  
  .step-content {
    padding: 1.5rem;
    min-height: 300px;
  }
  
  .steps-container {
    padding: 1.25rem;
  }
  
  :deep(.custom-steps .p-steps-item-label) {
    display: none;
  }
  
  .step-title {
    font-size: 1.375rem;
    margin-bottom: 1.25rem;
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
  
  .plan-card {
    padding: 1.25rem;
  }
  
  .plan-header h3 {
    font-size: 1.25rem;
  }
  
  .plan-price {
    font-size: 1.75rem;
  }
  
  .plan-features li {
    margin-bottom: 0.75rem;
    font-size: 0.9rem;
  }
  
  .payment-summary {
    padding: 1.25rem;
  }
  
  :deep(.p-button) {
    padding: 0.875rem 1.5rem;
    font-size: 0.95rem;
  }
}

@media (max-width: 480px) {
  :deep(.register-card .p-card-header) {
    padding: 1.5rem 0.75rem;
  }
  
  .card-header .title {
    font-size: 1.75rem;
  }
  
  .step-content {
    padding: 1rem;
  }
  
  .steps-container {
    padding: 0.75rem;
  }
  
  .step-title {
    font-size: 1.25rem;
  }
  
  :deep(.p-inputtext) {
    padding: 0.75rem 0.875rem;
    font-size: 0.9rem;
  }
  
  .plan-card {
    padding: 1rem;
  }
  
  .plan-price {
    font-size: 1.5rem;
  }
  
  .payment-summary {
    padding: 1rem;
  }
  
  .form-actions {
    padding: 1rem;
  }
  
  :deep(.p-button) {
    padding: 0.75rem 1.25rem;
    font-size: 0.9rem;
  }
}

.w-full {
  width: 100%;
}
</style>
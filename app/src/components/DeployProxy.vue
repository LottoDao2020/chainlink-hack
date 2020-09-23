<template>
  <div>
    <q-dialog
      v-model="showDeploymentDialog"
      persistent
    >
      <q-card class="text-center q-pa-lg">
        <q-card-section>
          <h4 class="row justify-center items-center">
            <q-icon
              left
              name="fas fa-cogs"
              class="setup-icon vertical-middle"
            />
            <span v-if="isDeployed">You're All Set!</span>
            <span v-else>Finish Account Setup</span>
          </h4>
        </q-card-section>

        <q-card-section>
          <div v-if="isDeployed">
            Click the button below to continue.
          </div>
          <div v-else>
            Since this is your first visit, we just need to finish setting up your account.
            <p class="text-caption text-italic text-justify q-mt-md">
              This should only take about a minute, as we deploy a proxy contract for you.
              This proxy contract enables you to enter and exit Bancor Liquidity pools
              without having ETH for gas by utilizing the Gas Station Network.
            </p>
          </div>
          <p class="q-my-lg">
            <img
              v-if="isDeployed"
              src="statics/graphics/undraw_confirmation_2uy0.png"
              style="width:30vw;max-width:175px;"
            >
            <img
              v-else
              src="statics/graphics/undraw_Firmware_jw6u.png"
              style="width:30vw;max-width:175px;"
            >
          </p>
          <p v-if="!hasDeploymentStarted">
            Click the button below to get started!
          </p>
          <p v-else-if="!isDeployed">
            Please wait...
          </p>
          <p v-else />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn
            v-if="!hasDeploymentStarted"
            label="Finish setup"
            color="primary"
            @click="startDeployment()"
          />
          <q-btn
            v-else
            v-close-popup
            label="Continue"
            color="primary"
            :disabled="!isDeployed"
            :loading="!isDeployed"
            @click="closeDeploymentPopup()"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
/* eslint-disable global-require */
import { mapState } from 'vuex';
import Notify from 'bnc-notify';
import mixinHelpers from 'src/utils/mixinHelpers';

export default {
  name: 'DeployProxy',

  mixins: [mixinHelpers],

  data() {
    return {
      showDeploymentDialog: true,
      hasDeploymentStarted: false,
      isDeployed: false,
    };
  },

  computed: {
    ...mapState({
      userAddress: (state) => state.main.userAddress,
      signer: (state) => state.main.signer,
      provider: (state) => state.main.signer.provider,
      gasPrice: (state) => state.main.gasPrice,
      FactoryContract: (state) => state.main.contracts.Factory,
      LogicContract: (state) => state.main.contracts.Logic,
    }),
  },

  methods: {
    async startDeployment() {
      const notify = Notify({
        dappId: process.env.BLOCKNATIVE_API_KEY, // [String] The API key created by step one above
        networkId: 1, // [Integer] The Ethereum network ID your Dapp uses.
        darkMode: Boolean(this.$q.localStorage.getItem('isDark')),
      });

      /* eslint-disable no-console */
      console.log('Deployment of proxy starting...');
      this.hasDeploymentStarted = true;
      try {
        this.FactoryContract.methods.createContract(this.LogicContract.options.address)
          .send({ from: this.userAddress, gas: '1000000', gasPrice: this.gasPrice })
          .on('transactionHash', async (txHash) => {
            console.log('txHash: ', txHash);
            notify.hash(txHash);
          })
          .once('receipt', async (receipt) => {
            console.log('Transaction receipt: ', receipt);
            await this.$store.dispatch('main/getProxy', this.userAddress);
            this.isDeployed = true;
          })
          .catch((err) => {
            console.log('Something went wrong deploying proxy. See the error message below.');
            console.error(err);
            this.notifyUser('negative', err.message);
            this.hasDeploymentStarted = false;
          });
      } catch (err) {
        console.log('Something went wrong deploying proxy. See the error message below.');
        console.error(err);
        this.notifyUser('negative', err.message);
        this.hasDeploymentStarted = false;
      }
      /* eslint-disable no-console */
    },

    closeDeploymentPopup() {
      this.showDeploymentDialog = false;
    },
  },
};
</script>

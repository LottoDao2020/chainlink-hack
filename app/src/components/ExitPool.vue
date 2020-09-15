<template>
  <div>
    <!-- POOL EXITED -->
    <q-dialog
      v-model="isExitComplete"
      persistent
    >
      <q-card class="text-center q-pa-lg">
        <q-card-section>
          <h4 class="row justify-center items-center">
            <span>You Exited the Pool!</span>
          </h4>
        </q-card-section>

        <q-card-section>
          <div>
            You have successfully exited the pool!
          </div>
          <p class="q-mt-lg">
            <img
              src="statics/graphics/undraw_confirmation_2uy0.png"
              style="width:30vw;max-width:225px;"
            >
          </p>
          <div>
            Your funds are sitting in your proxy contrat, and you may
            now transfer them as desired.
          </div>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn
            v-close-popup
            flat
            label="Ok"
            :color="$q.dark.isActive ? 'white' : 'primary'"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- EXIT FORM -->
    <q-card
      class="col text-center q-px-lg q-py-md q-ma-md"
      style="max-width: 450px"
    >
      <q-card-section>
        <h6>Step 3 (After some time...)</h6>
        <h4 class="text-bold">
          Exit the Pool
        </h4>
      </q-card-section>

      <q-card-section>
        <div class="text-caption text-justify">
          Redeem all pool tokens as ETH to the specified the address. If you'd like to keep them
          in your proxy contract (i.e. if you want to enter into a different pool),
          use the "Keep in Proxy" button.
        </div>
      </q-card-section>

      <q-card-section>
        <q-input
          v-model="recipientAddress"
          class="q-mb-md"
          filled
          label="Address to withdraw to"
        >
          <template v-slot:append>
            <q-btn
              :color="$q.dark.isActive ? 'white' : 'primary'"
              flat
              label="Keep in proxy"
              @click="setRecipientAddressToProxy"
            />
          </template>
        </q-input>
        <q-btn
          color="primary"
          label="Exit Pool"
          :loading="isLoading"
          :disabled="ethBntBalance === 0"
          @click="exitPool"
        />
        <div
          v-if="ethBntBalance === 0"
          class="text-caption text-italic text-center q-mt-md"
        >
          You have no pool tokens to withdraw
        </div>
      </q-card-section>
    </q-card>
  </div>
</template>

<script>
import { mapState } from 'vuex';
import { ethers } from 'ethers';
import mixinHelpers from 'src/utils/mixinHelpers';
import Notify from 'bnc-notify';

const addresses = require('src/utils/addresses.json');

const ethBntAbi = require('src/abi/ethbnt.json');

export default {
  name: 'ExitPool',

  mixins: [mixinHelpers],

  data() {
    return {
      isLoading: false,
      isExitComplete: false,
      recipientAddress: undefined,
    };
  },

  computed: {
    ...mapState({
      // User account info
      provider: (state) => state.main.provider,
      userAddress: (state) => state.main.userAddress,
      proxyAddress: (state) => state.main.proxy.address,
      ethBntBalance: (state) => state.main.proxy.ethBntBalance,
      // Helpers
      FactoryContract: (state) => state.main.contracts.Factory,
    }),
  },

  methods: {
    setRecipientAddressToProxy() {
      this.recipientAddress = this.proxyAddress;
    },

    async exitPool() {
      /* eslint-disable no-console */
      this.isLoading = true;
      console.log('Initializing pool exit...');

      // Get ETHBNT balance
      const ethersProvider = new ethers.providers.Web3Provider(this.provider);
      const EthBntContract = new ethers.Contract(addresses.ETHBNT, ethBntAbi, ethersProvider);

      const ethBntBalance = (await EthBntContract.balanceOf(this.proxyAddress)).toString();

      const notify = Notify({
        dappId: process.env.BLOCKNATIVE_API_KEY, // [String] The API key created by step one above
        networkId: 1, // [Integer] The Ethereum network ID your Dapp uses.
        darkMode: Boolean(this.$q.localStorage.getItem('isDark')),
      });

      try {
        console.log('Requesting signature and sending transaction...');
        this.FactoryContract.methods.exitAndWithdraw(ethBntBalance, this.recipientAddress)
          .send({ from: this.userAddress, gas: '1000000', gasPrice: this.gasPrice })
          .on('transactionHash', async (txHash) => {
            console.log('txHash: ', txHash);
            notify.hash(txHash);
          })
          .once('receipt', async (receipt) => {
            console.log('Transaction receipt: ', receipt);
            await this.$store.dispatch('main/checkBalances', this.proxyAddress);
            this.isLoading = false;
            this.isExitComplete = true;
          })
          .catch((err) => {
            console.log('Something went wrong exiting pool. See the error message below.');
            console.error(err);
            this.notifyUser('negative', err.message);
            this.isLoading = false;
          });
      } catch (err) {
        console.log('Something went wrong exiting pool. See the error message below.');
        console.error(err);
        this.notifyUser('negative', err.message);
        this.isLoading = false;
      }
      /* eslint-disable no-console */
    },
  },
};
</script>

<style lang="stylus" scoped>
.card {
  max-width: 500px;
  padding: 1.5rem;
}
</style>

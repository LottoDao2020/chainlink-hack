<template>
  <div>
    <!-- EXIT FORM -->
    <q-card
      v-if="drawNo"
      class="col text-center q-px-lg q-py-md q-ma-md"
      style="max-width: 450px"
      :loading="isMainLoading"
    >
      <q-card-section>
        <h6>Step 2 </h6>
        <h4 class="text-bold">
          Check & Claim
        </h4>
      </q-card-section>

      <q-card-section>
        <div class="text-caption text-justify">
          Select a draw number to claim reward
        </div>
      </q-card-section>

      <q-card-section>
        <q-select
          v-model="selectedDrawNo"
          class="q-mb-md"
          filled
          label="Please select draw number"
          :options="options">
        </q-select>
        <div class="row">
          <q-btn
            color="primary"
            class="col-3"
            label="Check"
            :loading="isMainLoading"
            @click="check"
          />
          <div class="col-6"></div>
          <q-btn
            class="col-3"
            color="primary"
            label="Claim"
            :loading="isMainLoading"
            :disabled="results.length === 0"
            @click="claim"
          />
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

export default {
  name: 'ExitPool',

  mixins: [mixinHelpers],

  data() {
    return {
      isMainLoading: false,
      recipientAddress: undefined,
      selectedDrawNo: undefined,
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
      Lottery: (state) => state.main.contracts.Lottery,
      MagayoOracle: (state) => state.main.contracts.MagayoOracle,
      LotteryWeb3: (state) => state.main.contracts.LotteryWeb3,
      // Lottery
      options: (state) => state.main.lottery.options,
      drawNo: (state) => state.main.lottery.drawNo,
      results: (state) => state.main.lottery.results,
    }),
  },

  methods: {
    setRecipientAddressToProxy() {
      this.recipientAddress = this.proxyAddress;
    },

    async check() {
      this.isMainLoading = true;
      await this.$store.dispatch('main/setSelectedDrawNo', this.selectedDrawNo);
      await this.$store.dispatch('main/setLotteryData');
      await this.$store.dispatch('main/setCountdown');
      this.isMainLoading = false;
    },

    async claim({ commit }) {
      /* eslint-disable no-console */
      this.isMainLoading = true;
      console.log('selectedDrawNo: ', this.selectedDrawNo);

      const notify = Notify({
        dappId: process.env.BLOCKNATIVE_API_KEY, // [String] The API key created by step one above
        networkId: 4, // [Integer] The Ethereum network ID your Dapp uses.
        darkMode: Boolean(this.$q.localStorage.getItem('isDark')),
      });

      try {
        this.drawNo = this.selectedDrawNo;
        this.LotteryWeb3.methods.claim(this.selectedDrawNo)
          .send({ from: this.userAddress, gasLimit: 500000 })
          .on('transactionHash', async (txHash) => {
            console.log('txHash: ', txHash);
            notify.hash(txHash);
          })
          .once('receipt', async (receipt) => {
            console.log('Transaction receipt: ', receipt);
            this.isMainLoading = false;
          })
          .catch((err) => {
            console.log('Something went wrong. See the error message below.');
            console.error(err);
            this.notifyUser('negative', err.message);
            this.isMainLoading = false;
          });
      } catch (err) {
        console.log('Something went wrong. See the error message below.');
        console.error(err);
        this.notifyUser('negative', err.message);
        this.isMainLoading = false;
      }
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

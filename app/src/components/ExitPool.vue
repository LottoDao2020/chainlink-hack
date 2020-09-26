<template>
  <div>
    <!-- EXIT FORM -->
    <q-card
      class="col text-center q-px-lg q-py-md q-ma-md"
      style="max-width: 450px"
    >
      <q-card-section>
        <h6>Step 3 (After game finish)</h6>
        <h4 class="text-bold">
          Claim
        </h4>
      </q-card-section>

      <q-card-section>
        <div class="text-caption text-justify">
          Select a draw number to claim reward
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
          label="Claim"
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
      Lottery: (state) => state.main.contracts.Lottery,
      MagayoOracle: (state) => state.main.contracts.MagayoOracle,
      LotteryWeb3: (state) => state.main.contracts.LotteryWeb3,
    }),
  },

  methods: {
    setRecipientAddressToProxy() {
      this.recipientAddress = this.proxyAddress;
    },

    async exitPool({ commit }) {
      /* eslint-disable no-console */
      this.isLoading = true;
      console.log('Initializing pool exit...');

      const notify = Notify({
        dappId: process.env.BLOCKNATIVE_API_KEY, // [String] The API key created by step one above
        networkId: 4, // [Integer] The Ethereum network ID your Dapp uses.
        darkMode: Boolean(this.$q.localStorage.getItem('isDark')),
      });

      try {
        console.log('Lottery: ', this.Lottery);
        console.log('MagayoOracle: ', this.MagayoOracle);
        // const drawNo = await this.Lottery.drawNo();
        const drawNo = 1;
        console.log(drawNo);
        console.log('getEntries: ', await this.Lottery.getEntries(drawNo));
        console.log('getResults: ', await this.Lottery.getResults(drawNo));
        console.log('getDrawState: ', await this.Lottery.getDrawState(drawNo));
        console.log('getDrawRewards: ', await this.Lottery.getDrawRewards(drawNo));
        console.log('getDrawNumbers: ', await this.Lottery.getDrawNumbers(drawNo));

        const game = await this.MagayoOracle.game();
        const gameInfo = await this.MagayoOracle.games(game);
        console.log(gameInfo);
        console.log(gameInfo.name);

        console.log(ethers.utils.parseBytes32String(gameInfo.name));
        console.log(gameInfo.mainDrawn);

        this.LotteryWeb3.methods.claim(drawNo)
          .send({ from: this.userAddress, gasLimit: 500000 })
          .on('transactionHash', async (txHash) => {
            console.log('txHash: ', txHash);
            notify.hash(txHash);
          })
          .once('receipt', async (receipt) => {
            console.log('Transaction receipt: ', receipt);
            // await this.$store.dispatch('main/checkResults', drawNo);
            // const tx = await this.provider.getTransaction(receipt);
            // console.log(tx);
            // const code = await this.provider.call(tx, tx.blockNumber);
            // const reason = ethers.utils.toUtf8String(code);
            // console.log(reason);
            this.isLoading = false;
            // this.isExitComplete = true;
          })
          .catch((err) => {
            console.log('Something went wrong. See the error message below.');
            console.error(err);
            this.notifyUser('negative', err.message);
            this.isLoading = false;
          });
      } catch (err) {
        console.log('Something went wrong. See the error message below.');
        console.error(err);
        this.notifyUser('negative', err.message);
        this.isLoading = false;
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

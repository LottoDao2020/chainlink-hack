<template>
  <div>
    <div
      v-if="magayoInfo"
      class="row justify-center"
      style="max-width: 900px"
    >
      <!-- START THE DRAW -->
      <q-card
        class="col text-center q-px-lg q-py-md q-ma-md"
        style="max-width: 400px"
      >
        <q-card-section>
          <h6>Step 1</h6>
          <h4 class="text-bold">
            Start Your Lucky Draw
          </h4>
        </q-card-section>
        <!-- <q-card-section>
          <q-input
            v-model.number="ticketsAmount"
            class="input"
            filled
            label="How many Tickets"
          />
        </q-card-section> -->
        <q-card-section>
          <q-btn
            color="primary"
            label="Enter with 0.01 ETH"
            :loading="isDepositLoading"
            @click="startLuckyDraw"
          />
          <div class="text-caption text-italic q-mt-md">
            We will generate random number for you
          </div>
          <div class="row justify-between">
            <div class="col-xs-5 text-left text-bold">
              Ticket Number:
            </div>
            <div class="col text-left">
              {{ ticketNumber }}
            </div>
          </div>
        </q-card-section>
      </q-card>

    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex';
import mixinHelpers from 'src/utils/mixinHelpers';
import Notify from 'bnc-notify';
import { ethers } from 'ethers';

export default {
  name: 'DepositWithWyre',

  mixins: [mixinHelpers],

  data() {
    return {
      isDepositLoading: false,
      isEntryLoading: false,
      isEntryComplete: false,
      isWaitingForPurchase: false,
      contractAddress: undefined,
      pools: [
        { label: 'ETH-BNT', value: 'eth-bnt' },
      ],
      // User options
      ticketsAmount: undefined,
      selectedPool: null,
    };
  },

  computed: {
    ...mapState({
      // User account info
      signer: (state) => state.main.signer,
      userAddress: (state) => state.main.userAddress,
      proxyAddress: (state) => state.main.proxy.address,
      ticketNumber: (state) => state.main.proxy.ticketNumber,
      // User balances
      ethBalance: (state) => state.main.proxy.ethBalance,
      bntBalance: (state) => state.main.proxy.bntBalance,
      ethTokenBalance: (state) => state.main.proxy.ethTokenBalance,
      ethBntBalance: (state) => state.main.proxy.ethBntBalance,
      // Helpers
      gasPrice: (state) => state.main.gasPrice,
      FactoryContract: (state) => state.main.contracts.Factory,
      LotteryWeb3: (state) => state.main.contracts.LotteryWeb3,
      // Magayo
      magayoInfo: (state) => state.main.proxy.magayoInfo,
    }),
  },

  methods: {
    async startLuckyDraw() {
      this.isDepositLoading = true;
      await this.$store.dispatch('main/showTickets', this.magayoInfo);
      console.log(this.ticketNumber);

      const notify = Notify({
        dappId: process.env.BLOCKNATIVE_API_KEY, // [String] The API key created by step one above
        networkId: 4, // [Integer] The Ethereum network ID your Dapp uses.
        darkMode: Boolean(this.$q.localStorage.getItem('isDark')),
      });

      try {
        this.LotteryWeb3.methods.buy(this.ticketNumber)
          .send({
            from: this.userAddress,
            gasLimit: 500000,
            value: ethers.utils.parseEther('0.01'),
          })
          .on('transactionHash', async (txHash) => {
            console.log('txHash: ', txHash);
            notify.hash(txHash);
          })
          .once('receipt', async (receipt) => {
            console.log('Transaction receipt: ', receipt);
            await this.$store.dispatch('main/setLotteryData');
            this.isDepositLoading = false;
          })
          .catch((err) => {
            console.log('Something went wrong. See the error message below.');
            console.error(err);
            this.notifyUser('negative', err.message);
            this.isDepositLoading = false;
          });
      } catch (err) {
        console.log('Something went wrong. See the error message below.');
        console.error(err);
        this.notifyUser('negative', err.message);
        this.isDepositLoading = false;
      }
    },

  },
};
</script>

<style lang="stylus" scoped>
.input {
  max-width: 200px;
  margin: 0 auto;
}
</style>

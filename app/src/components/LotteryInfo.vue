<template>
  <div>
    <div class="row justify-center">
      <q-card
        class="col text-center q-px-lg q-py-md q-ma-md"
        style="max-width: 400px"
      >
        <q-card-section>
          <h4 class="q-mb-md">
            Lottery Info
          </h4>
        </q-card-section>
        <q-card-section>
          <div class="row justify-between">
            <div class="col-xs-5 text-left text-bold">
              Game time:
            </div>
            <div class="col text-left">
              {{ countdown }}
              <q-btn
                v-if="drawState == 0"
                color="primary"
                class="col-3"
                label="Start New Game"
                :loading="isStartLoading"
                @click="start"
              />
              <small
                v-if="drawState == 0"
              >
                Please note: More than 0.1 Link is required in the Lottery contract balance in order to start a new game
              </small>
            </div>
          </div>
          <div class="row justify-between">
            <div class="col-xs-5 text-left text-bold">
              Draw Number:
            </div>
            <div class="col text-left">
              {{ drawNo }}
            </div>
          </div>
          <div class="row justify-between">
            <div class="col-xs-5 text-left text-bold">
              Entries
            </div>
            <div class="col text-left">
              {{ entries }}
            </div>
          </div>
          <div class="row justify-between">
            <div class="col-xs-5 text-left text-bold">
              Reward Results
            </div>
            <div class="col text-left">
              {{ results }}
            </div>
          </div>
          <div class="row justify-between">
            <div class="col-xs-5 text-left text-bold">
              Draw State:
            </div>
            <div class="col text-left">
              {{ drawState }}
            </div>
          </div>
          <div class="row justify-between">
            <div class="col-xs-5 text-left text-bold">
              Total Draw Rewards:
            </div>
            <div class="col text-left">
              {{ drawRewards }}
            </div>
          </div>
          <div class="row justify-between">
            <div class="col-xs-5 text-left text-bold">
              Drawn Numbers:
            </div>
            <div class="col text-left">
              {{ drawNumbers }}
            </div>
          </div>
        </q-card-section>
      </q-card>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex';
import Notify from 'bnc-notify';

export default {
  name: 'LotteryInfo',

  data() {
    return {
      isStartLoading: false,
      countdown: undefined,
    };
  },

  async mounted() {
    const x = setInterval(async () => {
      // Get today's date and time
      const now = new Date().getTime();
      const countDownDate = new Date(this.startTime * 1000 + this.duration * 1000).getTime();
      // Find the distance between now and the count down date
      const distance = countDownDate - now;

      // Time calculations for days, hours, minutes and seconds
      const days = Math.floor(distance / (1000 * 60 * 60 * 24));
      const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((distance % (1000 * 60)) / 1000);
      this.countdown = `${days} Days ${hours} Hours ${minutes} Minutes ${seconds} Seconds`;
      // If the count down is over, write some text
      if (distance < 0) {
        clearInterval(x);
        this.countdown = 'No Active Game';
      }
    }, 1000);
  },

  computed: {
    ...mapState({
      startTime: (state) => state.main.lottery.startTime,
      duration: (state) => state.main.lottery.duration,
      drawNo: (state) => state.main.lottery.drawNo,
      drawState: (state) => state.main.lottery.drawState,
      entries: (state) => state.main.lottery.entries,
      results: (state) => state.main.lottery.results,
      drawRewards: (state) => state.main.lottery.drawRewards,
      drawNumbers: (state) => state.main.lottery.drawNumbers,
      LotteryWeb3: (state) => state.main.contracts.LotteryWeb3,
      userAddress: (state) => state.main.userAddress,
    }),
  },

  methods: {
    async start({ commit }) {
      /* eslint-disable no-console */
      this.isStartLoading = true;

      const notify = Notify({
        dappId: process.env.BLOCKNATIVE_API_KEY, // [String] The API key created by step one above
        networkId: 4, // [Integer] The Ethereum network ID your Dapp uses.
        darkMode: Boolean(this.$q.localStorage.getItem('isDark')),
      });

      try {
        this.LotteryWeb3.methods.startNewLottery()
          .send({ from: this.userAddress, gasLimit: 500000 })
          .on('transactionHash', async (txHash) => {
            console.log('txHash: ', txHash);
            notify.hash(txHash);
          })
          .once('receipt', async (receipt) => {
            console.log('Transaction receipt: ', receipt);
            await this.$store.dispatch('main/setLotteryData');
            this.isStartLoading = false;
          })
          .catch((err) => {
            console.log('Something went wrong. See the error message below.');
            console.error(err);
            this.notifyUser('negative', err.message);
            this.isStartLoading = false;
          });
      } catch (err) {
        console.log('Something went wrong. See the error message below.');
        console.error(err);
        this.notifyUser('negative', err.message);
        this.isStartLoading = false;
      }
    },
  }
};
</script>

<style lang="stylus" scoped>
.card {
  max-width: 550px;
  padding: 1.5rem;
}
</style>

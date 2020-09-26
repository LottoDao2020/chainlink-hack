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

export default {
  name: 'LotteryInfo',

  data() {
    return {
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
    }),
  },
};
</script>

<style lang="stylus" scoped>
.card {
  max-width: 550px;
  padding: 1.5rem;
}
</style>

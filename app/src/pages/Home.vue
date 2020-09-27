<template>
  <q-page padding>
    <div class="text-center">
      <h2 class="text-bold q-mt-lg">
        Enter Lottery
      </h2>
      <h6 class="q-mt-md">
        Play lottery on-chain with off-chain game info
      </h6>
    </div>

    <!-- Contract Interataction -->
    <div
      class="row justify-center "
    >
      <lottery-info v-if="drawNo"/>
      <magayo-oracle-info v-if="magayoInfo" />
    </div>
    <div class="container q-py-xl">
      <div
        v-if="!userAddress"
        class="text-center"
      >
        <connect-wallet />
      </div>
      <div
        v-else-if="isLoading"
        class="row justify-center"
      >
        <q-spinner
          :color="color"
          size="4em"
        />
        <div class="col-xs-12 text-center q-mt-md">
          Loading...
        </div>
      </div>
      <div v-else>
        <div
          class="row justify-center "
        >
          <!-- TWO CARDS FOR DEPOSITING -->
          <deposit-with-wyre />
          <!-- ONE CARD FOR WITHDRAWING -->
          <exit-pool />
        </div>
      </div>
    </div>

  </q-page>
</template>

<script>
import { mapState } from 'vuex';
import ConnectWallet from 'components/ConnectWallet';
import DepositWithWyre from 'components/DepositWithWyre';
import ExitPool from 'components/ExitPool';
import MagayoOracleInfo from 'components/MagayoOracleInfo';
import LotteryInfo from 'components/LotteryInfo';

export default {
  name: 'Home',

  components: {
    ConnectWallet,
    DepositWithWyre,
    ExitPool,
    MagayoOracleInfo,
    LotteryInfo,
  },

  computed: {
    ...mapState({
      userAddress: (state) => state.main.userAddress,
      proxyAddress: (state) => state.main.proxy.address,
      drawNo: (state) => state.main.lottery.drawNo,
      magayoInfo: (state) => state.main.proxy.magayoInfo,
    }),

    isLoading() {
      return this.magayoInfo === undefined;
    },

    color() {
      return this.$q.dark.isActive ? 'accent' : 'primary';
    },
  },
};
</script>

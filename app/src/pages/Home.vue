<template>
  <q-page padding>
    <div class="text-center">
      <h2 class="text-bold q-mt-lg">
        Enter Liquidity Pools
      </h2>
      <h6 class="q-mt-md">
        Deposit into Bancor liquidity pools with fiat
      </h6>
    </div>

    <!-- Contract Interataction -->
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
          v-if="!proxyAddress || proxyAddress === '0x0000000000000000000000000000000000000000'"
          class="row justify-center "
        >
          <deploy-proxy />
        </div>
        <div
          v-else
          class="row justify-center "
        >
          <!-- TWO CARDS FOR DEPOSITING -->
          <deposit-with-wyre />
          <!-- ONE CARD FOR WITHDRAWING -->
          <exit-pool />
        </div>
      </div>
    </div>

    <user-account-info v-if="proxyAddress && proxyAddress !== '0x0000000000000000000000000000000000000000'" />
  </q-page>
</template>

<script>
import { mapState } from 'vuex';
import ConnectWallet from 'components/ConnectWallet';
import DeployProxy from 'components/DeployProxy';
import DepositWithWyre from 'components/DepositWithWyre';
import ExitPool from 'components/ExitPool';
import UserAccountInfo from 'components/UserAccountInfo';

export default {
  name: 'Home',

  components: {
    ConnectWallet,
    DeployProxy,
    DepositWithWyre,
    ExitPool,
    UserAccountInfo,
  },

  computed: {
    ...mapState({
      userAddress: (state) => state.main.userAddress,
      proxyAddress: (state) => state.main.proxy.address,
    }),

    isLoading() {
      return this.proxyAddress === undefined;
    },

    color() {
      return this.$q.dark.isActive ? 'accent' : 'primary';
    },
  },
};
</script>

<template>
  <div>
    <div class="row justify-center">
      <q-card class="text-center col-auto card">
        <q-card-section>
          <h4 class="q-mb-md">
            Account Balances
          </h4>
          <div class="text-caption text-italic">
            Balances of your proxy contract which is used to enter and exit liquidity
            pools and hold the associated funds
          </div>
        </q-card-section>
        <q-card-section>
          <div class="row justify-between">
            <div class="col-xs-5 text-left text-bold">
              Ether:
            </div>
            <div class="col text-left">
              {{ ethBalance }} ETH
            </div>
          </div>
          <div class="row justify-between">
            <div class="col-xs-5 text-left text-bold">
              Bancor Network Token:
            </div>
            <div class="col text-left">
              {{ bntBalance }} BNT
            </div>
          </div>
          <div class="row justify-between">
            <div class="col-xs-5 text-left text-bold">
              Ether Token:
            </div>
            <div class="col text-left">
              {{ ethTokenBalance }} ETH Token
            </div>
          </div>
          <div class="row justify-between">
            <div class="col-xs-5 text-left text-bold">
              ETHBNT Pool Token:
            </div>
            <div class="col text-left">
              {{ ethBntBalance }} ETHBNT
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
  name: 'UserAccountInfo',

  data() {
    return {};
  },

  computed: {
    ...mapState({
      // User account info
      signer: (state) => state.main.signer,
      userAddress: (state) => state.main.userAddress,
      proxyAddress: (state) => state.main.proxy.address,
      // User balances
      ethBalance: (state) => state.main.proxy.ethBalance,
      bntBalance: (state) => state.main.proxy.bntBalance,
      ethTokenBalance: (state) => state.main.proxy.ethTokenBalance,
      ethBntBalance: (state) => state.main.proxy.ethBntBalance,
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

<template>
  <div>
    <!-- Connect Wallet -->
    <div class="row justify-center">
      <q-card class="col-auto card q-ma-md">
        <h4 class="q-mb-md">
          Have a Wallet?
        </h4>
        <p>Login with the wallet provider of your choice</p>
        <br>
        <q-btn
          label="Connect Wallet"
          class="q-my-md"
          color="primary"
          :loading="isMainLoading"
          @click="connectWallet()"
        />
      </q-card>
      <!-- Create new wallet -->
      <q-card class="col-auto card q-ma-md">
        <h4 class="q-mb-md">
          Need a Wallet?
        </h4>
        <p>Use Torus to connect with Google, Facebook, Reddit, Discord, or Twitch</p>
        <q-btn
          label="Create Wallet"
          class="q-my-md"
          color="primary"
          :loading="isBackupLoading"
          @click="connectWallet(true)"
        />
      </q-card>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex';
import { ethers } from 'ethers';
import Onboard from 'bnc-onboard';

let provider;
const allWallets = [
  { walletName: 'metamask' },
  { walletName: 'torus' },
  // { walletName: 'fortmatic', apiKey: process.env.FORTMATIC_API_KEY },
  // { walletName: 'walletConnect', infuraKey: process.env.INFURA_ID },
  // { walletName: 'portis', apiKey: process.env.PORTIS_API_KEY },
  // { walletName: 'authereum' },
  // { walletName: 'squarelink', apiKey: process.env.SQUARELINK_API_KEY },
  { walletName: 'opera' },
  { walletName: 'dapper' },
];
const easyWallets = [
  { walletName: 'torus' },
];

export default {
  name: 'ConnectWallet',

  data() {
    return {
      isMainLoading: false,
      isBackupLoading: false,
    };
  },

  computed: {
    ...mapState({
      signer: (state) => state.main.signer,
      userAddress: (state) => state.main.userAddress,
      Lottery: (state) => state.main.contracts.Lottery,
      MagayoOracle: (state) => state.main.contracts.MagayoOracle,
    }),
  },

  methods: {
    async connectWallet(isEasy = false) {
      try {
        // Prompt user to connect wallet of their choice
        let onboard;
        if (!isEasy) {
          this.isMainLoading = true;
          // Show all wallets
          onboard = Onboard({
            walletSelect: { wallets: allWallets },
            dappId: process.env.BLOCKNATIVE_API_KEY, // [String] The API key created by step one above
            networkId: 4, // [Integer] The Ethereum network ID your Dapp uses.
            darkMode: Boolean(this.$q.localStorage.getItem('isDark')),
            subscriptions: {
              wallet: (wallet) => { provider = wallet.provider; },
            },
          });
        } else {
          // Show only Torus
          this.isBackupLoading = true;
          onboard = Onboard({
            walletSelect: { wallets: easyWallets },
            dappId: process.env.BLOCKNATIVE_API_KEY, // [String] The API key created by step one above
            networkId: 4, // [Integer] The Ethereum network ID your Dapp uses.
            darkMode: Boolean(this.$q.localStorage.getItem('isDark')),
            subscriptions: {
              wallet: (wallet) => { provider = wallet.provider; },
            },
          });
        }
        await onboard.walletSelect();
        await onboard.walletCheck();
        await this.$store.dispatch('main/setEthereumData', provider);

        console.log('MagayoOracle: ', this.MagayoOracle);
        const game = await this.MagayoOracle.game();
        const gameInfo = await this.MagayoOracle.games(game);
        console.log(gameInfo);
        console.log(gameInfo.name);
        
        console.log(ethers.utils.parseBytes32String(gameInfo.name));
        console.log(gameInfo.mainDrawn);
        const magayoInfo = {
          'Game Name': ethers.utils.parseBytes32String(gameInfo.name),
          Country: ethers.utils.parseBytes32String(gameInfo.country),
          State: ethers.utils.parseBytes32String(gameInfo.state),
          Duration: gameInfo.duration,
          Drawn: gameInfo.drawn,
          'Main Drawn': gameInfo.mainDrawn,
          'Main Max': gameInfo.mainMax,
          'Main Min': gameInfo.mainMin,
          'Bonus Drawn': gameInfo.bonusDrawn,
          'Bonus Max': gameInfo.bonusMax,
          'Bonus Min': gameInfo.bonusMin,
        };
        console.log(magayoInfo);
        await this.$store.dispatch('main/setMagayoInfo', magayoInfo);
      } catch (err) {
        console.error(err); // eslint-disable-line no-console
      } finally {
        this.isMainLoading = false;
        this.isBackupLoading = false;
      }
    },
  },
};
</script>

<style lang="stylus" scoped>
.card {
  max-width 350px
  padding 1.5rem
}
</style>

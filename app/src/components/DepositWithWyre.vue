<template>
  <div>
    <div
      class="row justify-center"
      style="max-width: 900px"
    >
      <!-- DEPOSIT -->
      <q-card
        class="col text-center q-px-lg q-py-md q-ma-md"
        style="max-width: 400px"
      >
        <q-card-section>
          <h6>Step 1</h6>
          <h4 class="text-bold">
            Deposit Funds
          </h4>
        </q-card-section>
        <q-card-section>
          <q-input
            v-model.number="depositAmount"
            class="input"
            filled
            label="Deposit Amount"
            prefix="$"
          />
        </q-card-section>
        <q-card-section>
          <q-btn
            color="primary"
            label="Deposit Funds"
            :loading="isDepositLoading"
            :disabled="!Boolean(depositAmount) || depositAmount <= 0"
            @click="startDeposit"
          />
          <div class="text-caption text-italic q-mt-md">
            You will be redirected to Wyre to complete your purchase. Afterwards, Wyre
            will redirect you back here for you to complete Step 2.
          </div>
        </q-card-section>
      </q-card>

      <!-- ENTER POOL -->
      <q-card
        class="col text-center q-px-lg q-py-md q-ma-md"
        style="max-width: 400px"
      >
        <q-card-section>
          <h6>Step 2</h6>
          <h4 class="text-bold">
            Enter Pool
          </h4>
        </q-card-section>
        <q-card-section>
          <q-select
            v-model="selectedPool"
            class="input"
            :disabled="ethBalance === 0"
            :options="pools"
            label="Select Pool"
          />
        </q-card-section>
        <q-card-section>
          <q-btn
            color="primary"
            label="Enter Pool"
            :loading="isEntryLoading"
            :disabled="!Boolean(selectedPool) || ethBalance === 0"
            @click="enterPool"
          />
          <div
            v-if="ethBalance === 0"
            class="text-caption text-italic q-mt-md"
          >
            You have no balance to deposit
          </div>
          <div
            v-else
            class="text-caption text-italic q-mt-md"
          >
            All of your
            {{ formatCurrency(ethBalance, false, 2, 5) }}
            ETH will be used to enter this pool
          </div>
        </q-card-section>
      </q-card>

      <!-- POOL ENTERED -->
      <q-dialog
        v-model="isEntryComplete"
        persistent
      >
        <q-card class="text-center q-pa-lg">
          <q-card-section>
            <h4 class="row justify-center items-center">
              <q-icon
                left
                name="fas fa-check"
                class="setup-icon vertical-middle"
              />
              <span>You Entered the Pool!</span>
            </h4>
          </q-card-section>

          <q-card-section>
            <div>
              You have successfully deposited funds into the liquidity pool!
            </div>
            <p class="q-mt-lg">
              <img
                src="statics/graphics/undraw_celebration_0jvk.png"
                style="width:30vw;max-width:225px;"
              >
            </p>
            <div>
              Now sit back and relax as you earn some money.
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
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex';
import mixinHelpers from 'src/utils/mixinHelpers';
import Notify from 'bnc-notify';

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
      depositAmount: undefined,
      selectedPool: null,
    };
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
      // Helpers
      gasPrice: (state) => state.main.gasPrice,
      FactoryContract: (state) => state.main.contracts.Factory,
    }),
  },

  mounted() {
    try {
    // Get query params (right now there is only one)
      const string = window.location.search;
      const parts = string.slice(1).split('=');
      this.isWaitingForPurchase = parts[1]; // eslint-disable-line prefer-destructuring
    } catch (err) {
      //
    }
    if (this.isWaitingForPurchase) {
      // Check for a balance each block
      this.$store.dispatch('main/checkBalances', this.proxyAddress);
      this.signer.provider.on('block', () => this.$store.dispatch('main/checkBalances', this.proxyAddress));
    }
  },

  methods: {
    startDeposit() {
      this.isDepositLoading = true;
      try {
        // Check if we are in dev or prod
        let wyreUrlPrefix = 'sendwyre';
        if (process.env.WYRE_ENV === 'dev') {
          wyreUrlPrefix = 'testwyre';
        }

        // Define where to redirect to once hosted Widget flow is completed
        const widgetRedirectUrl = `${window.location.origin}/?isWaitingForPurchase=true`;

        // Define and temporarily save off options used to load the widget
        const widgetOptions = {
          dest: `ethereum:${this.proxyAddress}`,
          destCurrency: 'ETH',
          sourceAmount: this.depositAmount,
          paymentMethod: 'debit-card',
          redirectUrl: widgetRedirectUrl,
          accountId: process.env.WYRE_ACCOUNT_ID,
        };
        this.$q.localStorage.set('widgetDepositOptions', widgetOptions);

        // Load the new page and exit this function
        const widgetUrl = `https://pay.${wyreUrlPrefix}.com/purchase?dest=${widgetOptions.dest}&destCurrency=${widgetOptions.destCurrency}&sourceAmount=${widgetOptions.sourceAmount}&paymentMethod=${widgetOptions.paymentMethod}&redirectUrl=${widgetOptions.redirectUrl}&accountId=${widgetOptions.accountId}`;
        window.location.href = widgetUrl;
      } catch (err) {
        console.error(err); // eslint-disable-line no-console
        this.notifyUser('negative', err.message);
      } finally {
        this.isDepositLoading = false;
      }
    },

    async enterPool() {
      /* eslint-disable no-console */
      this.isEntryLoading = true;
      console.log('Initializing pool entry...');

      const notify = Notify({
        dappId: process.env.BLOCKNATIVE_API_KEY, // [String] The API key created by step one above
        networkId: 1, // [Integer] The Ethereum network ID your Dapp uses.
        darkMode: Boolean(this.$q.localStorage.getItem('isDark')),
      });

      try {
        console.log('Requesting signature and sending transaction...');
        this.FactoryContract.methods.enterPool()
          .send({ from: this.userAddress, gas: '1000000', gasPrice: this.gasPrice })
          .on('transactionHash', async (txHash) => {
            console.log('txHash: ', txHash);
            notify.hash(txHash);
          })
          .once('receipt', async (receipt) => {
            console.log('Transaction receipt: ', receipt);
            await this.$store.dispatch('main/checkBalances', this.proxyAddress);
            this.isEntryLoading = false;
            this.isEntryComplete = true;
          })
          .catch((err) => {
            console.log('Something went wrong entering pool. See the error message below.');
            console.error(err);
            this.notifyUser('negative', err.message);
            this.isEntryLoading = false;
          });
      } catch (err) {
        console.log('Something went wrong entering pool. See the error message below.');
        console.error(err);
        this.notifyUser('negative', err.message);
        this.isEntryLoading = false;
      }
      /* eslint-disable no-console */
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

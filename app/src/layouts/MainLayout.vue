<template>
  <q-layout view="hhh Lpr fff">
    <!-- HEADER -->
    <q-header
      class="q-mx-md q-mt-md"
      style="color: #000000; background-color: rgba(0,0,0,0)"
    >
      <div class="row justify-between items-center">
        <div class="col-auto">
          <!-- LOGO AND TITLE -->
          <div
            class="row justify-start items-center"
            style="cursor: pointer;"
          >
            <img
              alt="Dai logo"
              class="q-mx-md"
              src="statics/icons/icon-256x256.png"
              style="max-width: 50px;"
            >
            <div class="text-h5 dark-toggle">
              Bancor Liquidity Pool Ramps
            </div>
          </div>
        </div>
        <!-- BLOCK NUMBER AND SETTINGS -->
        <div class="col-auto q-mr-md">
          <div>
            <div
              v-if="userAddress"
              class="text-caption text-right dark-toggle"
            >
              Address: {{ userAddress }}
            </div>
          </div>

          <div class="row justify-end q-mt-xs">
            <q-icon
              v-if="!$q.dark.isActive"
              class="col-auto dark-toggle"
              name="fas fa-moon"
              style="cursor: pointer;"
              @click="toggleNightMode()"
            />
            <q-icon
              v-else
              class="col-auto dark-toggle"
              name="fas fa-sun"
              style="cursor: pointer;"
              @click="toggleNightMode()"
            />
          </div>
        </div>
      </div>
    </q-header>
    <!-- MAIN CONTENT -->
    <q-page-container>
      <router-view />
    </q-page-container>
    <!-- FOOTER -->
    <q-footer
      bordered
      class="q-mt-xl"
      style="color: #000000; background-color: rgba(0,0,0,0)"
    >
      <div class="row justify-center text-center items-center dark-toggle q-my-xl">
        <div
          class="text-caption"
          style="max-width: 800px;"
        >
          Built by
          <a
            href="https://twitter.com/msolomon44"
            target="_blank"
            class="hyperlink"
          >Matt Solomon</a>
          for Bancor's Fiat On-Ramp For Liqudity Pools challenge of
          Gitcoin's Funding the Future Hackathon
        </div>
      </div>
    </q-footer>
  </q-layout>
</template>

<script>
import { mapState } from 'vuex';

export default {
  name: 'BaseLayout',

  data() {
    return {
    };
  },

  computed: {
    ...mapState({
      userAddress: (state) => state.main.userAddress,
    }),
  },

  created() {
    // Check local storage for a dark mode setting
    const isDark = this.$q.localStorage.getItem('isDark');
    this.$q.dark.set(isDark);
  },

  methods: {
    toggleNightMode() {
      const isDark = !this.$q.dark.isActive;
      this.$q.dark.set(isDark);
      this.$q.localStorage.set('isDark', isDark);
    },
  },
};
</script>

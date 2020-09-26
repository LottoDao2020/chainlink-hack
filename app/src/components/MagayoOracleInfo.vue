<template>
  <div>
    <q-card class="text-center col q-px-lg q-py-md q-ma-md" style="max-width: 400px">
      <q-card-section>
        <h4 class="q-mb-md">
          Magayo Oracle
        </h4>
      </q-card-section>
      <q-card-section>
        <div class="row justify-between">
          <div class="col-xs-5 text-left text-bold">
            Name:
          </div>
          <div class="col text-left">
            {{ magayoInfo.name }}
          </div>
        </div>
        <div class="row justify-between">
          <div class="col-xs-5 text-left text-bold">
            Country:
          </div>
          <div class="col text-left">
            {{ magayoInfo.country }}
          </div>
        </div>
        <div class="row justify-between">
          <div class="col-xs-5 text-left text-bold">
            State:
          </div>
          <div class="col text-left">
            {{ magayoInfo.state }}
          </div>
        </div>
        <div class="row justify-between">
          <div class="col-xs-5 text-left text-bold">
            Main Drawn:
          </div>
          <div class="col text-left">
            {{ magayoInfo.mainDrawn }}
          </div>
        </div>
        <div class="row justify-between">
          <div class="col-xs-5 text-left text-bold">
            Main Min:
          </div>
          <div class="col text-left">
            {{ magayoInfo.mainMin }}
          </div>
        </div>
        <div class="row justify-between">
          <div class="col-xs-5 text-left text-bold">
            Main Max:
          </div>
          <div class="col text-left">
            {{ magayoInfo.mainMax }}
          </div>
        </div>
        <div class="row justify-between">
          <div class="col-xs-5 text-left text-bold">
            Bonus Drawn:
          </div>
          <div class="col text-left">
            {{ magayoInfo.bonusDrawn }}
          </div>
        </div>
        <div class="row justify-between">
          <div class="col-xs-5 text-left text-bold">
            Bonus Min:
          </div>
          <div class="col text-left">
            {{ magayoInfo.bonusMin }}
          </div>
        </div>
        <div class="row justify-between">
          <div class="col-xs-5 text-left text-bold">
            Bonus Max:
          </div>
          <div class="col text-left">
            {{ magayoInfo.bonusMax }}
          </div>
        </div>
      </q-card-section>
    </q-card>
  </div>
</template>

<script>
import { mapState } from 'vuex';

export default {
  name: 'MagayoOracleInfo',

  data() {
    return {};
  },

  computed: {
    ...mapState({
      magayoInfo: (state) => state.main.proxy.magayoInfo,
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

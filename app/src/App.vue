<template>
  <div id="q-app">
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'App',

  async mounted() {
    // Load Wyre script
    const wyreScript = document.createElement('script');
    wyreScript.setAttribute('src', 'https://verify.sendwyre.com/js/verify-module-init-beta.js');
    document.head.appendChild(wyreScript);
  },
};
</script>

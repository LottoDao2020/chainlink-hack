require('dotenv').config()
usePlugin("@nomiclabs/buidler-etherscan");

module.exports = {
  networks: {
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/" + process.env.INFURA_KEY,
      accounts: [process.env.MNEMONIC]
    }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: process.env.ETHERSCAN_KEY
  },
  // This is a sample solc configuration that specifies which version of solc to use
  solc: {
    version: '0.6.12',
  },
};

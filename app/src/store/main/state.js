export default function () {
  return {
    userAddress: undefined,
    proxy: {
      address: undefined,
      ethBalance: undefined,
      bntBalance: undefined,
      ethBntBalance: undefined,
      ethTokenBalance: undefined,
    },
    provider: {}, // raw provider for GSN
    signer: {}, // ethers.js signer
    gasPrice: undefined,
    data: {
      blockNumber: undefined,
      networkId: undefined,
    },
    contracts: {
      Logic: undefined,
      Factory: undefined,
    },
  };
}

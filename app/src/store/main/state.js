export default function () {
  return {
    userAddress: undefined,
    proxy: {
      address: undefined,
      ethBalance: undefined,
      bntBalance: undefined,
      ethBntBalance: undefined,
      ethTokenBalance: undefined,
      ticketNumber: undefined,
      magayoInfo: undefined,
    },
    lottery: {
      startTime: undefined,
      duration: undefined,
      drawNo: undefined,
      selectedDrawNo: undefined,
      countdown: undefined,
      options: [],
      entries: [],
      results: [],
      drawState: undefined,
      drawRewards: undefined,
      drawNumbers: [],
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

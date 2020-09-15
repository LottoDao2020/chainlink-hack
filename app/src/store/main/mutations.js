export function setWallet(state, wallet) {
  try {
    // Object.assign fails if signer is undefined
    Object.assign(state.signer, wallet.signer);
    Object.assign(state.provider, wallet.provider);
    state.userAddress = '0'; // not reactive without this from initial undefined state
    state.userAddress = wallet.userAddress;
  } catch {
    state.signer = wallet.signer;
    state.provider = wallet.provider;
    state.userAddress = '0';
    state.userAddress = wallet.userAddress;
  }
}

export function setContracts(state, contracts) {
  try {
    Object.assign(state.contracts, contracts);
  } catch {
    state.contracts = contracts;
  }
}

export function setProxyData(state, proxyData) {
  state.proxy.address = proxyData.address;
  state.proxy.ethBalance = proxyData.ethBalance;
  state.proxy.bntBalance = proxyData.bntBalance;
  state.proxy.ethBntBalance = proxyData.ethBntBalance;
  state.proxy.ethTokenBalance = proxyData.ethTokenBalance;
}

export function setProxyAddress(state, address) {
  state.proxy.address = address;
}

export function setGasPrice(state, gasPrice) {
  state.gasPrice = gasPrice;
}

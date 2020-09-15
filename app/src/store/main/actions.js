/* eslint-disable global-require */
import { ethers } from 'ethers';

const { utils } = ethers;

const addresses = require('src/utils/addresses.json');
const Web3 = require('web3'); // required for Open Zeppelin GSN provider
const { GSNProvider } = require('@openzeppelin/gsn-provider');
const { proxies } = require('src/../../.openzeppelin/mainnet.json');

const abi = {
  // logic: require('src/../../build/contracts/ProvideLiquidity.json').abi,
  // factory: require('src/../../build/contracts/ProvideLiquidityFactory.json').abi,
};

addresses.logic = proxies['bancor-fiat-on-ramp/ProvideLiquidity'][0].address;
addresses.factory = proxies['bancor-fiat-on-ramp/ProvideLiquidityFactory'][0].address;


/**
 * @notice Simple helper function fetch data from an API
 */
const jsonFetch = (url) => fetch(url).then((res) => res.json());

/**
 * @notice Returns ethers.js contract instance
 */
const createContract = (address, name, provider) => {
  // eslint-disable-next-line
  const abi = require(`src/abi/${name}.json`);
  return new ethers.Contract(address, abi, provider);
};

/**
 * @notice Gets gas cost to use transaction
 * @dev Defaults to fast to provide optimal UX
 * @param {string} speed Specify the speed to use, unspecified means use fastest. Options are
 * fastest, fast, average, and safeLow
 * @returns String, gas price in gwei to use for fastest
 */
async function getGasPrice(speed = 'fast') {
  /* eslint-disable no-console */
  console.log('Querying EthGasStation API...');
  const gasData = await jsonFetch('https://ethgasstation.info/json/ethgasAPI.json');

  let gasPrice; // to convert to gwei, later divide by 10, source: https://docs.ethgasstation.info/

  if (speed === 'safeLow' || speed === 'average') {
    gasPrice = gasData[speed] / 10;
    console.log(`Using the '${speed}' price of ${gasPrice} gwei`);
  } else {
    gasPrice = gasData.fast / 10;
    console.log(`Using the 'fast' price of ${gasPrice} gwei`);
  }
  // gasPrice is now in gwei, let's convert to string for web3
  const scale = utils.bigNumberify('100000000'); // 1e8 to get to gwei below (we x10 there)
  const web3gasPrice = (utils.bigNumberify(String(gasPrice * 10)).mul(scale)).toString();
  console.log('Gas price in wei: ', web3gasPrice);
  /* eslint-enable no-console */
  return web3gasPrice;
}


export async function setEthereumData({ commit }, provider) {
  // Get wallet info
  const ethersProvider = new ethers.providers.Web3Provider(provider);
  const signer = ethersProvider.getSigner();
  const userAddress = await signer.getAddress();
  commit('setWallet', { signer, provider, userAddress });

  // Create GSN contract instances
  const web3gsn = new Web3(new GSNProvider(provider));
  const contracts = {
    Logic: new web3gsn.eth.Contract(abi.logic, addresses.logic),
    Factory: new web3gsn.eth.Contract(abi.factory, addresses.factory),
  };
  commit('setContracts', contracts);

  // Get regular contract instances with ethers to check user's proxy address
  const Factory = new ethers.Contract(addresses.factory, abi.factory, ethersProvider);
  const proxyAddress = await Factory.getContract(userAddress);

  // If they have a proxy, get proxy data
  let ethBalance;
  let ethTokenBalance;
  let bntBalance;
  let ethBntBalance;

  const BntContract = createContract(addresses.BNT, 'bnt', ethersProvider);
  const EtherTokenContract = createContract(addresses.EtherToken, 'etherToken', ethersProvider);
  const EthBntContract = createContract(addresses.ETHBNT, 'ethbnt', ethersProvider);
  if (proxyAddress !== ethers.constants.AddressZero) {
    ethBalance = parseFloat(utils.formatEther(await ethersProvider.getBalance(proxyAddress)));
    bntBalance = parseFloat(utils.formatEther(await BntContract.balanceOf(proxyAddress)));
    ethTokenBalance = parseFloat(utils.formatEther(await EtherTokenContract.balanceOf(proxyAddress)));
    ethBntBalance = parseFloat(utils.formatEther(await EthBntContract.balanceOf(proxyAddress)));
  }

  const proxyData = {
    address: proxyAddress,
    ethBalance,
    ethTokenBalance,
    bntBalance,
    ethBntBalance,
  };
  console.log('User proxy data: ', proxyData); // eslint-disable-line no-console
  commit('setProxyData', proxyData);

  // Get gas price to use
  const gasPrice = await getGasPrice('fast');
  commit('setGasPrice', gasPrice);
}

export async function getProxy({ commit }, userAddress) {
  // Get regular contract instances with ethers to check user's proxy address
  const provider = ethers.getDefaultProvider('homestead');
  const Factory = new ethers.Contract(addresses.factory, abi.factory, provider);
  const userProxy = await Factory.getContract(userAddress);
  commit('setProxyAddress', userProxy);
}

export async function checkBalances({ commit, state }, proxyAddress) {
  console.log('Checking for balance updates...'); // eslint-disable-line no-console
  const ethersProvider = new ethers.providers.Web3Provider(state.provider);
  let ethBalance;
  let ethTokenBalance;
  let bntBalance;
  let ethBntBalance;

  const BntContract = createContract(addresses.BNT, 'bnt', ethersProvider);
  const EtherTokenContract = createContract(addresses.EtherToken, 'etherToken', ethersProvider);
  const EthBntContract = createContract(addresses.ETHBNT, 'ethbnt', ethersProvider);
  if (proxyAddress !== ethers.constants.AddressZero) {
    ethBalance = parseFloat(utils.formatEther(await ethersProvider.getBalance(proxyAddress)));
    bntBalance = parseFloat(utils.formatEther(await BntContract.balanceOf(proxyAddress)));
    ethTokenBalance = parseFloat(utils.formatEther(await EtherTokenContract.balanceOf(proxyAddress)));
    ethBntBalance = parseFloat(utils.formatEther(await EthBntContract.balanceOf(proxyAddress)));
  }

  const proxyData = {
    address: proxyAddress,
    ethBalance,
    ethTokenBalance,
    bntBalance,
    ethBntBalance,
  };

  commit('setProxyData', proxyData);
}

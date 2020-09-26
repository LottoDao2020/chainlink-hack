/* eslint-disable global-require */
import { ethers } from 'ethers';

const { utils } = ethers;

const addresses = require('src/utils/addresses.json');
const Web3 = require('web3'); // required for Open Zeppelin GSN provider
const { GSNProvider } = require('@openzeppelin/gsn-provider');

const abi = {
  lottery: require('src/../../build/contracts/Lottery.json').abi,
  magayoOracle: require('src/../../build/contracts/MagayoOracle.json').abi,
};

/**
 * @notice Simple helper function fetch data from an API
 */
const jsonFetch = (url) => fetch(url).then((res) => res.json());

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

  const web3 = new Web3(provider);

  const contracts = {
    Lottery: new ethers.Contract(addresses.lottery, abi.lottery, signer),
    MagayoOracle: new ethers.Contract(addresses.magayoOracle, abi.magayoOracle, signer),
    LotteryWeb3: new web3.eth.Contract(abi.lottery, addresses.lottery),
    MagayoOracleWeb3: new web3.eth.Contract(abi.magayoOracle, addresses.magayoOracle),
  };
  console.log('CONTRACTS');
  console.log(contracts);
  commit('setContracts', contracts);

  let ethBalance;
  let ethTokenBalance;
  let bntBalance;
  let ethBntBalance;
  let ticketNumber;

  if (userAddress) {
    ethBalance = parseFloat(utils.formatEther(await ethersProvider.getBalance(userAddress)));
  }

  const proxyData = {
    address: '0xea3Dd3cC5F4AF2b6adD5A6bCF77bc05d1C1800a0',
    ethBalance,
    ethTokenBalance,
    bntBalance,
    ethBntBalance,
    ticketNumber,
  };
  console.log('User proxy data: ', proxyData); // eslint-disable-line no-console
  commit('setProxyData', proxyData);

  // Get gas price to use
  // const gasPrice = await getGasPrice('fast');
  // commit('setGasPrice', gasPrice);
}

export async function setLotteryData({ commit, state }) {
  let { drawNo, options } = state.lottery;
  if (!drawNo) {
    options = [];
    drawNo = await state.contracts.Lottery.drawNo();
    for (let i = 1; i <= drawNo; i += 1) {
      options.push(i);
    }
  }
  const startTime = await state.contracts.Lottery.startTime();
  const duration = await state.contracts.Lottery.duration();
  const drawState = await state.contracts.Lottery.getDrawState(drawNo);
  const entries = await state.contracts.Lottery.getEntries(drawNo);
  const results = await state.contracts.Lottery.getResults(drawNo);
  const drawRewards = await state.contracts.Lottery.getDrawRewards(drawNo);
  const drawNumbers = await state.contracts.Lottery.getDrawNumbers(drawNo);

  const lotteryData = {
    startTime, duration, drawNo, options, drawState, entries, results, drawRewards, drawNumbers,
  };
  commit('setLotteryData', lotteryData);
}

export async function getProxy({ commit }, userAddress) {
  // Get regular contract instances with ethers to check user's proxy address
  const provider = ethers.getDefaultProvider('homestead');
  const Factory = new ethers.Contract(addresses.factory, abi.factory, provider);
  const userProxy = await Factory.getContract(userAddress);
  commit('setProxyAddress', userProxy);
}

export async function checkResults({ commit, state }, drawNo) {
  console.log('Checking for updates...'); // eslint-disable-line no-console
  const ethersProvider = new ethers.providers.Web3Provider(state.provider);
  let results;

  if (drawNo && drawNo > 0) {
    results = await this.Lottery.getResults(drawNo);
  }

  commit('setResults', results);
}

export async function setRewardBalance({ commit, state }, proxyAddress, rewardBalance) {
  console.log('Set Reward Balance...'); // eslint-disable-line no-console
  const ethersProvider = new ethers.providers.Web3Provider(state.provider);
  let ethBalance;
  // let ethTokenBalance;
  // let bntBalance;
  let ethBntBalance;

  if (proxyAddress !== ethers.constants.AddressZero) {
    ethBalance = parseFloat(utils.formatEther(await ethersProvider.getBalance(proxyAddress)));
    // bntBalance = parseFloat(utils.formatEther(await BntContract.balanceOf(proxyAddress)));
    // ethTokenBalance = parseFloat(utils.formatEther(await EtherTokenContract.balanceOf(proxyAddress)));
    ethBntBalance = rewardBalance;
  }

  const proxyData = {
    address: proxyAddress,
    ethBalance,
    ethTokenBalance: 0,
    bntBalance: 0,
    ethBntBalance,
  };

  commit('setProxyData', proxyData);
}

function createGround(mainDrawn, mainMin, mainMax, bonusDrawn, bonusMin, bonusMax) {
  const result = [];
  const checkMain = [];
  const checkBonus = [];
  let main;
  let bonus;
  // let i;
  // let j;
  // for (i = 0; i < width; i += 1) {
  //   result[i] = [];
  //   for (j = 0; j < height; j += 1) {
  //     result[i][j] = Math.floor(Math.random() * 35) + 1;
  //   }
  // }

  while (result.length < mainDrawn) {
    main = Math.floor(Math.random() * (mainMax - mainMin)) + 1;
    if (checkMain.indexOf(main) === -1) {
      result.push(main);
    }
  }
  while (result.length < (Number(mainDrawn) + Number(bonusDrawn))) {
    bonus = Math.floor(Math.random() * (bonusMax - bonusMin)) + 1;
    if (checkBonus.indexOf(bonus) === -1) {
      result.push(bonus);
    }
  }

  return result;
}

export async function setMagayoInfo({ commit }, info) {
  commit('setMagayoInfo', info);
}

export async function showTickets({ commit }, magayoInfo) {
  let arr = [];
  arr = createGround(
    magayoInfo.mainDrawn, magayoInfo.mainMin, magayoInfo.mainMax,
    magayoInfo.bonusDrawn, magayoInfo.bonusMin, magayoInfo.bonusMax,
  );
  const proxyData = {
    address: '0xea3Dd3cC5F4AF2b6adD5A6bCF77bc05d1C1800a0',
    ethBalance: 0,
    ethTokenBalance: 0,
    bntBalance: 0,
    ethBntBalance: 0,
    ticketNumber: arr,
  };

  commit('setProxyData', proxyData);
}

export async function setDrawNo({ commit }, drawNo) {
  commit('setDrawNo', drawNo);
}

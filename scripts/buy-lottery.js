const Lottery = artifacts.require('Lottery');

module.exports = async callback => {
  let lottery = await Lottery.deployed();
  let tx = await lottery.buy([1,3,6,34,32,23,14,17], {value: web3.utils.toWei('0.01', 'ether')})
  callback(tx.tx)
}

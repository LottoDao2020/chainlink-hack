const Lottery = artifacts.require('Lottery');

module.exports = async callback => {
  let lottery = await Lottery.deployed();
  let tx = await lottery.startNewLottery(120)
  callback(tx.tx)
}

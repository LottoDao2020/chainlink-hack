const Lottery = artifacts.require('Lottery');

module.exports = async callback => {
  let lottery = await Lottery.deployed();
  let tx = await lottery.startNewLottery(1800)
  callback(tx.tx)
}

const MagayoOracle = artifacts.require('MagayoOracle')

module.exports = async callback => {
  let magayoOracle = await MagayoOracle.deployed()
  let game = await magayoOracle.game();
  // let tx = await magayoOracle.requestAll(process.env.MAGAYO_API_KEY, "au_powerball")
  let tx = await magayoOracle.requestBonusDrawn(process.env.MAGAYO_API_KEY, "au_powerball")
  tx = await magayoOracle.requestSameBalls(process.env.MAGAYO_API_KEY, "au_powerball")
  tx = await magayoOracle.requestDigits(process.env.MAGAYO_API_KEY, "au_powerball")
  tx = await magayoOracle.requestDrawn(process.env.MAGAYO_API_KEY, "au_powerball")
  callback(tx.tx)
}

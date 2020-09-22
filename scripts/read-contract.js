const MagayoOracle = artifacts.require('MagayoOracle')
const Governance = artifacts.require('Governance')

/*
  This script makes it easy to read the data variable
  of the requesting contract.
*/

module.exports = async callback => {
  const magayoOracle = await MagayoOracle.deployed()
  const governance = await Governance.deployed()
  const tx = await governance.setMagayoOracle(magayoOracle.address)
  callback(tx.tx)
}

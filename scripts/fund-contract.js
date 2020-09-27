const LinkTokenInterface = artifacts.require('LinkTokenInterface')
const MagayoOracle = artifacts.require('MagayoOracle')
const Lottery = artifacts.require('Lottery')
const RandomNumber = artifacts.require('RandomNumber')

/*
  This script is meant to assist with funding the requesting
  contract with LINK. It will send 1 LINK to the requesting
  contract for ease-of-use. Any extra LINK present on the contract
  can be retrieved by calling the withdrawLink() function.
*/

const magayoOraclePayment = process.env.TRUFFLE_CL_BOX_PAYMENT || '1100000000000000000' // 11 Link
const payment = process.env.TRUFFLE_CL_BOX_PAYMENT || '1000000000000000000' // 1 Link

module.exports = async callback => {
  try {
    // fund magayoOracle
    let magayoOracle = await MagayoOracle.deployed()
    const tokenAddress = await magayoOracle.getChainlinkToken();
    const token = await LinkTokenInterface.at(tokenAddress)
    // console.log('Funding magayoOracle contract:', magayoOracle.address)
    // let tx = await token.transfer(magayoOracle.address, magayoOraclePayment)

    // fund lottery
    let lottery = await Lottery.deployed()
    console.log('Funding lottery:', lottery.address)
    tx = await token.transfer(lottery.address, payment)

    // fund randomNumber
    // let randomNumber = await RandomNumber.deployed()
    // console.log('Funding randomNumber:', randomNumber.address)
    // tx = await token.transfer(randomNumber.address, payment)

    callback(tx.tx)
  } catch (err) {
    callback(err)
  }
}

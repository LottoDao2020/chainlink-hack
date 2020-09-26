const Lottery = artifacts.require('Lottery')
const RandomNumber = artifacts.require('RandomNumber')
const Governance = artifacts.require('Governance')

module.exports = async (deployer, network, [defaultAccount]) => {
  deployer.then(async () => {
    await deployer.deploy(Lottery, (1 * 10 ** 16).toString(), Governance.address);
    let governance = await Governance.deployed();
    await governance.setLottery(Lottery.address);
  });
}


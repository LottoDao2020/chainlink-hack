const RandomNumber = artifacts.require('RandomNumber')
const Governance = artifacts.require('Governance')

module.exports = async (deployer, network, [defaultAccount]) => {
  deployer.then(async () => {
    await deployer.deploy(RandomNumber, Governance.address);
    let governance = await Governance.deployed();
    await governance.setRandomNumber(RandomNumber.address);
  });
}


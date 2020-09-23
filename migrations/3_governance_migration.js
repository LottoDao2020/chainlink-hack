const MagayoOracle = artifacts.require('MagayoOracle')
const Governance = artifacts.require('Governance')

module.exports = async (deployer, network, [defaultAccount]) => {
  deployer.then(async () => {
    await deployer.deploy(Governance, MagayoOracle.address);
  });
}


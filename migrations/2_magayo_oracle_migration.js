const MagayoOracle = artifacts.require('MagayoOracle')

module.exports = async (deployer, network, [defaultAccount]) => {
  deployer.then(async () => {
    await deployer.deploy(MagayoOracle, "au_powerball", 604800);
  });
}

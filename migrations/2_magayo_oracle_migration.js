const MagayoOracle = artifacts.require('MagayoOracle')

module.exports = async (deployer, network, [defaultAccount]) => {
  // deployer.deploy(MagayoOracle, "au_powerball", 604800).then(function(){
  //   return deployer.deploy(Governance, MagayoOracle.address).then(function(){
  //     deployer.deploy(RandomNumber, Governance.address)
  //     deployer.deploy(Lottery, 0.01 * 10 ** 18, Governance.address)
  //   })
  // })
  deployer.then(async () => {
    await deployer.deploy(MagayoOracle, "au_powerball", 604800);
  });
}

const MagayoOracle = artifacts.require('MagayoOracle')
const Governance = artifacts.require('Governance')

module.exports = async (deployer, network, [defaultAccount]) => {
  deployer.then(async () => {
    await deployer.deploy(MagayoOracle, "au_powerball", 604800);
    let magayoOracle = await MagayoOracle.deployed()
    let governance = await Governance.deployed()
    if(governance && governance.address){
      await governance.setMagayoOracle(magayoOracle.address)
    }
  });
}

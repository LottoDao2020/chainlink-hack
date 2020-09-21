const MagayoOracle = artifacts.require('MagayoOracle')

module.exports = async (deployer, network, [defaultAccount]) => {
  deployer.deploy(MagayoOracle, 'chainlink', "0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e", "50fc4215f89443d185b061e5d7af9490", "29fa9aa13bf1468788b7cc4a500a45b8", "6d914edc36e14d6c880c9c55bda5bc04", "au_powerball", {gas: 5000000})
}

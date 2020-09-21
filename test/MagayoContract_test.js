require('dotenv').config()

const {
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
  time
} = require('@openzeppelin/test-helpers');

const ERC20ABI = require('./abi/ERC20.js');

const MagayoOracle = artifacts.require('MagayoOracle');

contract('MagayoOracle', accounts => {
  const [sender, receiver] =  accounts;
  const LinkTokenAddress = "0xa36085f69e2889c224210f603d836748e7dc0088";
  let magayoOracle, linkToken;

  before(async function () {
    magayoOracle = await MagayoOracle.deployed();
    linkToken = new web3.eth.Contract(ERC20ABI, LinkTokenAddress);
    await linkToken.methods.transfer(magayoOracle.address, web3.utils.toWei('0.1')).send({from: sender})
  });

  it('can request name from Magayo API', async function () {
    const game = await magayoOracle.games[web3.utils.asciiToHex('au_powerball')]
    console.log(game);
    if(game){
      await expectRevert(
        await magayoOracle.requestName(
          process.env.MAGAYO_API_KEY, "au_powerball", { from: sender }
        ),
        "already-got-value"
      )
    }else{
      const requestReceipt = await magayoOracle.requestName(
        process.env.MAGAYO_API_KEY, "au_powerball", { from: sender }
      );

      setTimeout(( async () =>{
        expect(await magayoOracle.games[web3.utils.asciiToHex('au_powerball')].name)
          .to.equal("Powerball");
      } ), 5000);
    }

  });

  it('can request country from Magayo API', async function () {
    const game = await magayoOracle.games[web3.utils.asciiToHex('au_powerball')]
    console.log(game);
    if(game){
      await expectRevert(
        await magayoOracle.requestCountry(
          process.env.MAGAYO_API_KEY, "au_powerball", { from: sender }
        ),
        "already-got-value"
      )
    }else{
      const requestReceipt = await magayoOracle.requestCountry(
        process.env.MAGAYO_API_KEY, "au_powerball", { from: sender }
      );

      setTimeout(( async () =>{
        expect(await magayoOracle.games[web3.utils.asciiToHex('au_powerball')].country)
          .to.equal("Australia");
      } ), 5000);
    }

  });

  it('can request state from Magayo API', async function () {
    const game = await magayoOracle.games[web3.utils.asciiToHex('au_powerball')]
    console.log(game);
    if(game){
      await expectRevert(
        await magayoOracle.requestState(
          process.env.MAGAYO_API_KEY, "au_powerball", { from: sender }
        ),
        "already-got-value"
      )
    }else{
      const requestReceipt = await magayoOracle.requestState(
        process.env.MAGAYO_API_KEY, "au_powerball", { from: sender }
      );

      setTimeout(( async () =>{
        expect(await magayoOracle.games[web3.utils.asciiToHex('au_powerball')].state)
          .to.equal("nationwide");
      } ), 5000);
    }

  });

  it('can request mainMin from Magayo API', async function () {
    const game = await magayoOracle.games[web3.utils.asciiToHex('au_powerball')]
    console.log(game);
    if(game){
      await expectRevert(
        await magayoOracle.requestMainMin(
          process.env.MAGAYO_API_KEY, "au_powerball", { from: sender }
        ),
        "already-got-value"
      )
    }else{
      const requestReceipt = await magayoOracle.requestMainMin(
        process.env.MAGAYO_API_KEY, "au_powerball", { from: sender }
      );

      setTimeout(( async () =>{
        expect(await magayoOracle.games[web3.utils.asciiToHex('au_powerball')].mainMin)
          .to.equal("1");
      } ), 5000);
    }

  });
});

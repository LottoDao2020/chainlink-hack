# Chainlink Truffle Box

Implementation of a [Chainlink requesting contract](https://docs.chain.link/docs/create-a-chainlinked-project).

## Requirements

- NPM

## Installation

Package installation should have occurred for you during the Truffle Box setup. However, if you add dependencies, you'll need to add them to the project by running:

```bash
npm install
```

Or

```bash
yarn install
```

## Test

```bash
npm test
```

## Deploy

If needed, edit the `truffle-config.js` config file to set the desired network to a different port. It assumes any network is running the RPC port on 8545.

```bash
npm run migrate:dev
```

For deploying to live networks, Truffle will use `truffle-hdwallet-provider` for your mnemonic and an RPC URL. Set your environment variables `$RPC_URL` and `$MNEMONIC` before running:

```bash
npm run migrate:live
```

## Helper Scripts

There are 3 helper scripts provided with this box in the scripts directory:

- `fund-contract.js`
- `request-data.js`
- `read-contract.js`

They can be used by calling them from `npx truffle exec`, for example:

```bash
npx truffle exec scripts/fund-contract.js --network live
```

The CLI will output something similar to the following:

```
Using network 'live'.

Funding contract: 0x972DB80842Fdaf6015d80954949dBE0A1700705E
0xd81fcf7bfaf8660149041c823e843f0b2409137a1809a0319d26db9ceaeef650
Truffle v5.0.25 (core: 5.0.25)
Node v10.16.3
```

In the `request-data.js` script, example parameters are provided for you. You can change the oracle address, Job ID, and parameters based on the information available on [our documentation](https://docs.chain.link/docs/testnet-oracles).

```bash
npx truffle exec scripts/request-data.js --network live
```

This creates a request and will return the transaction ID, for example:

```
Using network 'live'.

Creating request on contract: 0x972DB80842Fdaf6015d80954949dBE0A1700705E
0x828f256109f22087b0804a4d1a5c25e8ce9e5ac4bbc777b5715f5f9e5b181a4b
Truffle v5.0.25 (core: 5.0.25)
Node v10.16.3
```

After creating a request on a live network, you will want to wait 3 blocks for the Chainlink node to respond. Then call the `read-contract.js` script to read the contract's state.

```bash
npx truffle exec scripts/read-contract.js --network live
```

Once the oracle has responded, you will receive a value similar to the one below:

```
Using network 'live'.

21568
Truffle v5.0.25 (core: 5.0.25)
Node v10.16.3
```

Project taglines:

1. What's LottoDAO?

LottoDAO is a decentralised lottery application based on the Ethereum blockchain and synchronised with Global major lottery platforms.

2. What's the difference between LottoDAO and other lottery platforms?

LottoDAO uses blockchain and Chainlink, the pivotal data is base on smart contracts, which is safe and won't be interfered by any third party.

3. What's the main advantage of LottoDAO?

With the advantage of utilising blockchain, LottoDAO is bringing off-chain data into on-chain. And it is more independent, as well as autonomous; also it allows lottery participants to purchase lotto entries in a secure way and makes the lottery transparent.

## Inspiration
It was inspired by other lottery game

## What it does
We want to enhance lottery game with off-chain lottery information such as rules.

## How I built it
We built it with Solidity to create smart contract. Frontend running vue.js 

## Challenges I ran into
- Using Chainlink to get off-chain data to on-chain
- Using Chainlink to with alarm job and getting VRF random number

## Accomplishments that I'm proud of
It's an on-chain lottery game with off-chain game information but secured by blockchain with transparent and non-changeable. 

## What I learned
Solidity, Chainlink, Vuejs

## What's next for Lottery DAO
get traction and feedback from users. 

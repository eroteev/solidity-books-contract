# Hardhat Library Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
npx hardhat deploy
```

Deploying and verifying the contract on Sepolia network
```
npx hardhat --network sepolia deploy-with-pk --private-key <DEPLOYER_PK>
Deploying contract from account: 0x31351f3e205F5840B65D0a21F40d9Ffb6B55ca7d
The contract is deployed to 0x631fb9AC66245bfbeb607F5820B1569AB34F7c48
The contract owner is 0x31351f3e205F5840B65D0a21F40d9Ffb6B55ca7d

npx hardhat verify 0x631fb9AC66245bfbeb607F5820B1569AB34F7c48 --network sepolia
Successfully submitted source code for contract
contracts/Library.sol:Library at 0x631fb9AC66245bfbeb607F5820B1569AB34F7c48
for verification on the block explorer. Waiting for verification result...

Successfully verified contract Library on the block explorer.
https://sepolia.etherscan.io/address/0x631fb9AC66245bfbeb607F5820B1569AB34F7c48#code

```

Verified contract link: https://sepolia.etherscan.io/address/0x631fb9AC66245bfbeb607F5820B1569AB34F7c48#code


Coverage report
```
--------------|----------|----------|----------|----------|----------------|
File          |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
--------------|----------|----------|----------|----------|----------------|
 contracts/   |      100 |      100 |      100 |      100 |                |
  Library.sol |      100 |      100 |      100 |      100 |                |
  Lock.sol    |      100 |      100 |      100 |      100 |                |
--------------|----------|----------|----------|----------|----------------|
All files     |      100 |      100 |      100 |      100 |                |
--------------|----------|----------|----------|----------|----------------|
```
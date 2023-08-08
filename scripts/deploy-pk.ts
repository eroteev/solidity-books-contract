import { ethers } from "hardhat";

export async function main(privateKey: string) {
  const wallet = new ethers.Wallet(privateKey, ethers.provider); // New wallet with the privateKey passed from CLI as param
  console.log(`Deploying contract from account: ${wallet.address}`); // We are printing the address of the deployer
  
  const factory = await ethers.getContractFactory("Library");
  const contract = await factory.connect(wallet).deploy();
  await contract.waitForDeployment();
  console.log(`The contract is deployed to ${contract.target}`);
  const owner = await contract.owner();
  console.log(`The contract owner is ${owner}`);
}
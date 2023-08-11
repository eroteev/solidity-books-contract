import { ethers } from "hardhat";

export async function main() {
  const library = await ethers.deployContract("Library");
  await library.waitForDeployment();
  console.log(`The Library contract is deployed to ${library.target}`);
}

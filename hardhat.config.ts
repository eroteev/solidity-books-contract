import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const lazyImport = async(module: any) => {
  return await import(module);
}

task("deploy", "Deploys contract").setAction(async() => {
  const { main } = await lazyImport("./scripts/deploy.ts");
  await main();
})

const config: HardhatUserConfig = {
  solidity: "0.8.19",
};

export default config;

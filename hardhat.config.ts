import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const lazyImport = async(module: any) => {
  return await import(module);
}

task("deploy", "Deploys contract").setAction(async() => {
  const { main } = await lazyImport("./scripts/deploy");
  await main();
})

task("deploy-with-pk", "Deploys contract with pk")
  .addParam("privateKey", "Please provide the private key")
  .setAction(async ({ privateKey }) => {
    const { main } = await lazyImport("./scripts/deploy-pk");
    await main(privateKey);
  });

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/72990efc86764d69b6402052ee02824c`,
    }
  },
  etherscan: {
    apiKey: {
      sepolia: 'CHIRAADNUI814XIT9ST36R63UFNBNDKBDY'
    }
  }
};

export default config;

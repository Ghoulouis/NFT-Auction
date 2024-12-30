import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts } = hre;
    const { deploy, diamond, read, execute, get } = deployments;
    const { deployer, deployer2 } = await getNamedAccounts();

    const USDTDeployment = await get("USDT");
    const NFTDeployment = await get("NFT");
    const NFTShopDeployment = await get("ShopNFT");

    const receipt = await deploy("NFTAuction", {
        contract: "NFTAuction",
        from: deployer,
        log: true,
        proxy: {
            owner: deployer,
        },
    });
};

deploy.tags = ["A"];
export default deploy;

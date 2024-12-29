import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts } = hre;
    const { deploy, diamond, read, execute, get } = deployments;
    const { deployer, deployer2 } = await getNamedAccounts();

    const USDTDeployment = await get("USDT");
    const NFTDeployment = await get("NFT");
    const NFTShopDeployment = await get("ShopNFT");

    const receipt = await deploy("NFTAdmin", {
        contract: "NFTAdmin",
        from: deployer,
        log: true,
        proxy: {
            owner: deployer,
            execute: {
                init: {
                    methodName: "initialize",
                    args: [NFTDeployment.address, USDTDeployment.address, NFTShopDeployment.address],
                },
            },
        },
    });

    //minter
    const MINTER_ROLE = await read("NFT", { from: deployer }, "MINTER_ROLE");
    await execute("NFT", { from: deployer, log: true }, "grantRole", MINTER_ROLE, receipt.address);
    //admin shop
    const ADMIN_ROLE = await read("ShopNFT", { from: deployer }, "ADMIN_ROLE");
    await execute("ShopNFT", { from: deployer, log: true }, "grantRole", ADMIN_ROLE, receipt.address);
};

deploy.tags = ["A"];
export default deploy;

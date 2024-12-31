import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts } = hre;
    const { deploy, diamond, read, execute } = deployments;
    const { deployer, deployer2 } = await getNamedAccounts();

    await deploy("ShopNFT", {
        contract: "ShopNFT",
        from: deployer,
        log: true,
        proxy: {
            owner: deployer,
            execute: {
                init: {
                    methodName: "initialize",
                    args: [],
                },
            },
        },
    });
};

deploy.tags = ["A"];
export default deploy;

import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts } = hre;
    const { deploy, diamond, read, execute } = deployments;
    const { deployer, deployer2 } = await getNamedAccounts();

    console.log("deployer: ", deployer);

    await deploy("USDT", {
        contract: "ERC20Mintable",
        from: deployer,
        log: true,
        args: ["Tether USD", "USDT", 6],
        skipIfAlreadyDeployed: true,
    });
};

deploy.tags = ["USDT"];
export default deploy;

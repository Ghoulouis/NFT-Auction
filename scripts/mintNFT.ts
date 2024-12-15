import hre from "hardhat";

async function mintNFT(name: string, description: string, ipsfHash: string, owner: string) {
    const { deployments, getNamedAccounts } = hre;
    const { deploy, diamond, get, read, execute } = deployments;
    const { deployer, deployer2 } = await getNamedAccounts();

    const metadata = {
        name,
        description,
        image: `https://gateway.pinata.cloud/ipfs/${ipsfHash}`,
    };

    await execute("NFT", { from: deployer }, "mint", owner, JSON.stringify(metadata));
}

mintNFT(
    "Chillguy",
    "Chillguy NFT",
    "bafybeieirpi3ve5gy775llytqh2vdeqhh5sdkvzpm6zmlcu6fvhdzqa7j4",
    "0xa5369b879dD025B7B9548BCEc2B990357879fda2"
);

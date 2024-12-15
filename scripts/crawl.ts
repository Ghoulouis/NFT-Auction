import hre from "hardhat";
import { NFT__factory } from "../typechain-types";

export async function crawl() {
    const { deployments, getNamedAccounts } = hre;

    const { get } = deployments;
    const { deployer } = await getNamedAccounts();
    const NFTDeployment = await get("NFT");

    const nft = NFT__factory.connect(NFTDeployment.address, hre.ethers.provider);

    const counter = await nft.getTokenIdCounter();
    console.log("Number of NFTs:", counter.toString());

    for (let tokenId = 0; tokenId < counter; tokenId++) {
        try {
            // Lấy địa chỉ owner của NFT
            const owner = await nft.ownerOf(tokenId);

            // Lấy tokenURI
            const tokenURI = await nft.tokenURI(tokenId);

            console.log(`NFT #${tokenId}`);
            console.log(`Owner: ${owner}`);
            console.log(`Metadata URI: ${tokenURI}`);
        } catch (error) {
            console.log(`Error retrieving data for NFT #${tokenId}:`, error);
        }
    }
}

crawl();

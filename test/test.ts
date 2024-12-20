import { NFT } from "./../typechain-types/contracts/NFT";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { NFT, NFT__factory, NFTAdmin, NFTAdmin__factory, ShopNFT, ShopNFT__factory } from "../typechain-types";
import { takeSnapshot } from "@nomicfoundation/hardhat-network-helpers";
import hre, { ethers } from "hardhat";
import { parseUnits, ZeroAddress } from "ethers";

describe("Testing", () => {
    const { deployments, getNamedAccounts, getChainId } = hre;
    const { deploy, get, execute, read } = deployments;

    let deployer: HardhatEthersSigner;
    let bob: HardhatEthersSigner;
    let alice: any;

    let nft: NFT;
    let shop: ShopNFT;
    let admin: NFTAdmin;

    let snapshot: any;

    let tokenURI = "https://gateway.pinata.cloud/ipfs/bafybeieirpi3ve5gy775llytqh2vdeqhh5sdkvzpm6zmlcu6fvhdzqa7j4";

    let usdt = ZeroAddress;

    before(async () => {
        await deployments.fixture();
        snapshot = await takeSnapshot();
    });

    beforeEach(async () => {
        await snapshot.restore();
        deployer = await hre.ethers.provider.getSigner(0);
        alice = await hre.ethers.provider.getSigner(2);
        [deployer, bob, alice] = await ethers.getSigners();

        const nftDeployment = await get("NFT");
        nft = NFT__factory.connect(nftDeployment.address, deployer);

        const shopDeployment = await get("ShopNFT");
        shop = ShopNFT__factory.connect(shopDeployment.address, deployer);

        const adminDeployment = await get("NFTAdmin");
        admin = NFTAdmin__factory.connect(adminDeployment.address, deployer);
    });

    describe("should create multi NFT and list Shop", () => {
        it("list multi NFT", async () => {
            await execute(
                "NFTAdmin",
                { from: deployer.address, log: true },
                "createNFTAndListShop",
                "Chill NFT",
                "CHILL",
                tokenURI,
                [40, 41],
                [5, 5],
                parseUnits("100", 6)
            );

            const countNFT = await nft.getTokenIdCounter();
            expect(countNFT).to.be.equal(10);

            for (let tokenId = 0; tokenId < countNFT; tokenId++) {
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
        });
    });
});

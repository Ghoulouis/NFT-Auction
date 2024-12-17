import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { NFT, ShopNFT } from "../typechain-types";
import { takeSnapshot } from "@nomicfoundation/hardhat-network-helpers";
import hre, { ethers } from "hardhat";
import { ZeroAddress } from "ethers";

describe("Testing", () => {
    const { deployments, getNamedAccounts, getChainId } = hre;
    const { deploy, get, execute, read } = deployments;

    let deployer: HardhatEthersSigner;
    let bob: HardhatEthersSigner;
    let alice: any;

    let nft: NFT;
    let shop: ShopNFT;
    let snapshot: any;

    let tokenURI = "https://token.com";

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
    });

    describe("test SHOP", () => {
        beforeEach(async () => {
            await execute("NFT", { from: deployer.address, log: true }, "mint", deployer.address, tokenURI);
        });

        it("list a NFT", async () => {
            await execute("NFT", { from: deployer.address, log: true }, "approve", (await get("ShopNFT")).address, 0);

            await execute(
                "ShopNFT",
                { from: deployer.address, log: true },
                "listNFT",
                (
                    await get("NFT")
                ).address,
                0,
                usdt,
                1000
            );
            const ownerNFT = await read("NFT", "ownerOf", 0);
            expect(ownerNFT).to.be.equal((await get("ShopNFT")).address);
        });
    });
});

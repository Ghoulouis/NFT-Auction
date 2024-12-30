import { Address } from "./../typechain-types/@openzeppelin/contracts/utils/Address";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import {
    ERC20Mintable,
    ERC20Mintable__factory,
    NFT,
    NFT__factory,
    NFTAdmin,
    NFTAdmin__factory,
    NFTAuction,
    NFTAuction__factory,
    ShopNFT,
    ShopNFT__factory,
} from "../typechain-types";
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

    let usdt: ERC20Mintable;

    let auction: NFTAuction;
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

        const usdtDeploymeny = await get("USDT");
        usdt = ERC20Mintable__factory.connect(usdtDeploymeny.address, deployer);

        const auctionDeployment = await get("NFTAuction");
        auction = NFTAuction__factory.connect(auctionDeployment.address, deployer);
    });

    describe("should create multi NFT and list Shop", () => {
        describe("list multi NFT", () => {
            beforeEach(async () => {
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
            });

            it("should create NFT", async () => {
                const countNFT = await nft.getTokenIdCounter();
                expect(countNFT).to.be.equal(10);
            });

            it("should list NFT in Shop", async () => {
                const counterInShop = await shop.listingCounter();
                expect(counterInShop).to.be.equal(10);
                for (let i = 0; i < counterInShop; i++) {
                    const data = await shop.listings(i);
                    expect(data[1]).to.be.equal(i);
                }
            });
        });
    });

    describe("should buy NFT", () => {
        // listing
        it("should buy NFT", async () => {
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
            const nft_buy = await shop.listings(1);

            await usdt.mint(alice.address, parseUnits("100", 6));
            await usdt.connect(alice).approve(await shop.getAddress(), parseUnits("100", 6));
            await shop.connect(alice).buyNFT(nft_buy[1]);
            const info_nft = await nft.ownerOf(1);
            //  console.log("info_nft", info_nft);
            expect(info_nft).to.be.equal(alice.address);
        });
    });

    describe(" Auction test ", () => {
        beforeEach(async () => {
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
            const nft_buy = await shop.listings(1);
            await usdt.mint(alice.address, parseUnits("100", 6));
            await usdt.connect(alice).approve(await shop.getAddress(), parseUnits("100", 6));
            await shop.connect(alice).buyNFT(nft_buy[1]);
            const info_nft = await nft.ownerOf(1);
            expect(info_nft).to.be.equal(alice.address);
        });

        it("should create auction", async () => {
            const owner = await nft.ownerOf(1);
            expect(owner).to.be.equal(alice.address);
            await nft.connect(alice).approve(await auction.getAddress(), 1);
            await auction
                .connect(alice)
                .createAuction(
                    await nft.getAddress(),
                    1,
                    await usdt.getAddress(),
                    parseUnits("100", 6),
                    parseUnits("1000", 6),
                    Math.round(Date.now() / 1000),
                    Math.round(Date.now() / 1000) + 3600
                );
            const auctionInfo = await auction.auctions(0);
            expect(auctionInfo[0]).to.be.equal(alice.address);
        });

        describe("should bid auction", () => {
            let id;

            beforeEach(async () => {
                const owner = await nft.ownerOf(1);
                expect(owner).to.be.equal(alice.address);
                await nft.connect(alice).approve(await auction.getAddress(), 1);
                await auction
                    .connect(alice)
                    .createAuction(
                        await nft.getAddress(),
                        1,
                        await usdt.getAddress(),
                        parseUnits("100", 6),
                        parseUnits("1000", 6),
                        Math.round(Date.now() / 1000),
                        Math.round(Date.now() / 1000) + 3600
                    );
                const auctionInfo = await auction.auctions(0);
                expect(auctionInfo[0]).to.be.equal(alice.address);
                id = 0;
            });
        });
    });
});

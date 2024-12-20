// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/INFT.sol";
import "./interfaces/INFTShop.sol";

import "hardhat/console.sol";

contract NFTAdmin is Initializable {
    address public nftAddress;
    address public usdtAddress;
    address public nftShop;

    struct Metadata {
        string name;
        string description;
        string image;
        uint256 size;
        uint256 id;
    }

    function initialize(
        address _nftAddress,
        address _usdtAddress,
        address _nftShop
    ) public initializer {
        nftAddress = _nftAddress;
        usdtAddress = _usdtAddress;
        nftShop = _nftShop;
    }

    function createNFTAndListShop(
        string calldata name,
        string calldata description,
        string calldata imageURL,
        uint256[] calldata sizes,
        uint256[] calldata amounts,
        uint256 price
    ) external {
        require(sizes.length == amounts.length, "Invalid input");

        uint256 id = 0;
        for (uint256 i = 0; i < sizes.length; i++) {
            uint256 size = sizes[i];
            for (uint256 j = 1; j <= amounts[i]; j++) {
                console.log("size: %s, j: %s", size, j);
                id++;
                string memory metadataJson = string(
                    abi.encodePacked(
                        '{"name":"',
                        name,
                        '","description":"',
                        description,
                        '","image":"',
                        imageURL,
                        '","size":',
                        Strings.toString(size),
                        ',"id":',
                        Strings.toString(id),
                        "}"
                    )
                );
                console.log("metadataJson: %s", metadataJson);
                uint256 tokenId = INFT(nftAddress).mint(
                    address(this),
                    metadataJson
                );
                console.log("tokenId: %s", tokenId);
                INFT(nftAddress).approve(nftShop, tokenId);

                console.log("nftShop: %s", nftShop);

                INFTShop(nftShop).listNFT(
                    nftAddress,
                    tokenId,
                    usdtAddress,
                    price
                );
            }
        }
        // listShop(price);
    }
}

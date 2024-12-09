// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./NFT.sol";

contract NFTFactory is Ownable {
    address[] public nftContracts;

    event NFTContractCreated(
        address contractAddress,
        string name,
        string symbol
    );

    function createNFTContract(
        string memory _name,
        string memory _symbol
    ) public onlyOwner returns (address) {
        NFTContract newContract = new NFTContract(_name, _symbol, msg.sender);
        nftContracts.push(address(newContract));

        emit NFTContractCreated(address(newContract), _name, _symbol);
        return address(newContract);
    }

    function getNFTContracts() public view returns (address[] memory) {
        return nftContracts;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTContract is ERC721, Ownable {
    uint256 public tokenCounter;
    mapping(uint256 => string) private _tokenURIs;

    constructor(
        string memory _name,
        string memory _symbol,
        address _creator
    ) ERC721(_name, _symbol) Ownable(_creator) {
        transferOwnership(_creator);
        tokenCounter = 0;
    }

    function mintNFT(
        address _to,
        string memory _tokenURI
    ) public onlyOwner returns (uint256) {
        uint256 newTokenId = tokenCounter;
        _safeMint(_to, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        tokenCounter++;
        return newTokenId;
    }

    function _setTokenURI(
        uint256 _tokenId,
        string memory _tokenURI
    ) internal virtual {
        require(_exists(_tokenId), "ERROR: 01");
        _tokenURIs[_tokenId] = _tokenURI;
    }

    function tokenURI(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERROR: 02");
        return _tokenURIs[_tokenId];
    }
}

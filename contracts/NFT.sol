// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract NFT is ERC721URIStorageUpgradeable, AccessControlUpgradeable {
    uint256 private _tokenIdCounter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER");

    event NFTMinted(
        address indexed to,
        uint256 indexed tokenId,
        string tokenURI
    );

    function initialize() public initializer {
        __ERC721URIStorage_init();
        __AccessControl_init();
        _tokenIdCounter = 0;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    /**
     * @dev Mint a new NFT with a specific tokenURI.
     * @param to The address that will own the minted NFT.
     * @param tokenURI The metadata URI associated with the NFT.
     */
    function mint(
        address to,
        string memory tokenURI
    ) external onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        emit NFTMinted(to, tokenId, tokenURI);
    }

    /**
     * @dev Override the transfer function to allow custom logic if needed.
     * @param from The current owner of the NFT.
     * @param to The new owner of the NFT.
     * @param tokenId The ID of the NFT being transferred.
     */
    function transferOwnership(
        address from,
        address to,
        uint256 tokenId
    ) external {
        require(ownerOf(tokenId) == from, "Caller is not the owner");
        _transfer(from, to, tokenId);
    }

    /**
     * @dev Get the current counter value (useful for debugging or frontend integration).
     */
    function getTokenIdCounter() external view returns (uint256) {
        return _tokenIdCounter;
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721URIStorageUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

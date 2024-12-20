// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INFT is IERC721 {
    event NFTMinted(
        address indexed to,
        uint256 indexed tokenId,
        string tokenURI
    );

    function initialize() external;

    function mint(
        address to,
        string memory tokenURI
    ) external returns (uint256);

    function transferOwnership(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function getTokenIdCounter() external view returns (uint256);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

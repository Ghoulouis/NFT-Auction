// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ShopNFT is Initializable, AccessControlUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    struct Listing {
        address nftContract;
        uint256 tokenId;
        address paymentToken;
        uint256 price;
        bool active;
    }

    // Mapping để lưu thông tin NFT được bán
    mapping(uint256 => Listing) public listings;
    uint256 public listingCounter;

    event NFTListed(
        uint256 indexed listingId,
        address indexed nftContract,
        uint256 tokenId,
        address paymentToken,
        uint256 price
    );

    event NFTSold(
        uint256 indexed listingId,
        address indexed buyer,
        address indexed nftContract,
        uint256 tokenId,
        uint256 price
    );

    function initialize() public initializer {
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        listingCounter = 0;
    }

    /// @dev Chỉ ADMIN mới có quyền gọi
    function listNFT(
        address nftContract,
        uint256 tokenId,
        address paymentToken,
        uint256 price
    ) external onlyRole(ADMIN_ROLE) {
        // require(price > 0, "Price must be greater than zero");
        // // Transfer NFT từ ADMIN sang contract
        // ERC721Upgradeable(nftContract).transferFrom(
        //     msg.sender,
        //     address(this),
        //     tokenId
        // );
        // // Tạo listing mới
        // listings[listingCounter] = Listing({
        //     nftContract: nftContract,
        //     tokenId: tokenId,
        //     paymentToken: paymentToken,
        //     price: price,
        //     active: true
        // });
        // emit NFTListed(
        //     listingCounter,
        //     nftContract,
        //     tokenId,
        //     paymentToken,
        //     price
        // );
        // listingCounter++;
    }

    /// @dev Hàm mua NFT, bất kỳ ai cũng gọi được
    function buyNFT(uint256 listingId) external payable {
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing is not active");

        // Kiểm tra thanh toán
        if (listing.paymentToken == address(0)) {
            // Thanh toán bằng native ETH
            require(msg.value >= listing.price, "Insufficient ETH sent");
        } else {
            // Thanh toán bằng token ERC20
            IERC20(listing.paymentToken).transferFrom(
                msg.sender,
                address(this),
                listing.price
            );
        }

        // Chuyển NFT đến người mua
        ERC721Upgradeable(listing.nftContract).safeTransferFrom(
            address(this),
            msg.sender,
            listing.tokenId
        );

        // Đánh dấu listing là không hoạt động
        listing.active = false;

        emit NFTSold(
            listingId,
            msg.sender,
            listing.nftContract,
            listing.tokenId,
            listing.price
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Nft is ReentrancyGuard {
    struct Listing {
        uint256 price;
        address seller;
    }
    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    event ListingCancelled(
        address indexed owner,
        address indexed nftAddress,
        uint256 indexed tokenId
    );

    mapping(address => mapping(uint256 => Listing)) private s_listings;
    mapping(address => uint256) private s_proceeds;

    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        require(listing.price > 0, "not listed");
        _;
    }
    modifier notListed(
        address nftAddress,
        uint256 tokenId,
        address owner
    ) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        require(listing.price <= 0, "already listed");
        _;
    }
    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        require(spender == owner, "not owner");
        _;
    }

    function listItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    )
        external
        isOwner(nftAddress, tokenId, msg.sender)
        notListed(nftAddress, tokenId, msg.sender)
    {
        require(price > 0, "price must be more than zero");
        IERC721 nft = IERC721(nftAddress);
        require(nft.getApproved(tokenId) == address(this), "not approved for marketplace");
        s_listings[nftAddress][tokenId] = Listing(price, msg.sender);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }

    function cancelListng(address nftAddress, uint256 tokenId)
        external
        isListed(nftAddress, tokenId)
        isOwner(nftAddress, tokenId, msg.sender)
    {
        delete (s_listings[nftAddress][tokenId]);
        emit ListingCancelled(msg.sender, nftAddress, tokenId);
    }
}

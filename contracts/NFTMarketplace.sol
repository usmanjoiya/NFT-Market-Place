// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
// Internal import for NFT OPENZIPLINE

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";

contract NFTMarketPlace is ERC721URIStorage {
      using Counters for Counters.Counter;
      Counters.Counter private _tokenIds;
      Counters.Counter private _itemsSold;

      uint256 listingPrice = 0.0015 ether;
      address payable owner;

      mapping(uint256=> MarketItem) private idMarketItem;

      struct MarketItem{

        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;

      }

      event idMarketItemCreated(

        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
      );

      modifier onlyowner {
        require(
            msg.sender == owner
         // Only owner will be able to do certain changes
        );
        _; // continue this when it is owner onlt
        
       }

      constructor() ERC721("NFT METAVERSE TOKEN", "MYNFT"){

        owner == payable(msg.sender);

      }

      function updateListingsPrice(uint256 _listingPrice) public payable onlyowner
       {
        listingPrice = _listingPrice;


        
      }

     function getListingPrice() public view returns (uint256) {

        return listingPrice;
     }

     // Lets create a NFT TOKEN

     function createToken(string memory tokenURI, uint256 price) public payable returns(uint256)
     {
         _tokenIds.increment();

         uint256 newTokenId = _tokenIds.current();
         _mint(msg.sender, newTokenId);
         _setTokenURI(newTokenId, tokenURI);

         createMarketItem(newTokenId, price);
            return newTokenId;
     } 

     // creating marketitem 
     function createMarketItem(uint256 tokenId, uint256 price) private 
     {
        require(price > 0, "Price must be greater than 1");
        require(msg.value == listingPrice, "Price must be equal to Listing");

        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false 
        );
        _transfer(msg.sender, address(this), tokenId);
        emit idMarketItemCreated(tokenId, msg.sender , address(this), price, false);

     }

     //function for resale nft
     function resellToken(uint256 tokenId, uint256 price) public payable {

      require(idMarketItem[tokenId].owner == msg.sender, "only Item Onwer can perform this");
      require(msg.value == listingPrice, "Price msut be equal to listing price");
      idMarketItem[tokenId].sold = false;
      idMarketItem[tokenId].price = price;
      idMarketItem[tokenId].seller = payable(msg.sender);
      idMarketItem[tokenId].owner = payable(address(this));
      _itemsSold.decrement();

      _transfer(msg.sender, address(this), tokenId);

     }
     // fucntion create market item sale

     function createMarketSale(uint256 tokenId) public payable{
      uint256 price = idMarketItem[tokenId].price;

      require(msg.value == price, "Submit Asking price in order to complete purchase");

      idMarketItem[tokenId].owner = payable(msg.sender);
      idMarketItem[tokenId].sold = true;
      idMarketItem[tokenId].owner = payable(address(0));
      
      _itemsSold.increment();

      _transfer(address(this), msg.sender, tokenId);

      payable(owner).transfer(listingPrice);
      payable(idMarketItem[tokenId].seller).transfer(msg.value);

     }

     // Getting unsold  NFT Data.

     function fetchMarketItem() public view returns (MarketItem[] memory)
     {
       uint256 itemcount = _tokenIds.current();
       uint256 unSoldItemCount = _tokenIds.current() - _itemsSold.current();
       uint256 currentIndex = 0;

       MarketItem[] memory items = new MarketItem[](unSoldItemCount);
       for (uint256 i=0; i<itemcount; i++)
       {
        if (idMarketItem[i+1].owner == address(this))
        {
          uint256 currentId = i + 1;
          MarketItem storage currentItem = idMarketItem[currentId];
          items[currentIndex]= currentItem;
          currentIndex +=1;

        }
       }
       return items;
     }

     // Purchase items for fetching an NFT

     function fetchMyNFT() public view returns(MarketItem[] memory)
     {
      uint256 totalCount = _tokenIds.current();
      uint256 itemCount = 0;
      uint256 currentIndex = 0;

       for (uint256 i=0; i<totalCount; i++)
       {
        if(idMarketItem[i+1].owner == msg.sender)
        {
          itemCount +=1;

        }
       } 

       MarketItem[] memory items = new MarketItem[](itemCount);
       for(uint256 i=0; i<totalCount; i++)
       {
        if(idMarketItem[i+1].owner == msg.sender)
        {
        uint256 currentId = i + 1;
        MarketItem storage currentItem = idMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex +=1;
        }

       }
       return items;

     }


     // Single User Item

     function fetchItemsListed() public view returns (MarketItem[] memory)
     {
        uint256 totalCount= _tokenIds.current();
        uint256 itemCount= 0;
        uint256 currentIndex= 0;

      for(uint256 i=0; i<totalCount; i++)
      {
        if(idMarketItem[i+1].seller == msg.sender)
        {
          itemCount +=1;

        }
      }

         MarketItem[] memory items = new MarketItem[](itemCount);
       for(uint256 i=0; i<totalCount; i++)
       {
         if(idMarketItem[i+1].seller == msg.sender)
         {
          uint256 currentId = i+1;

          MarketItem storage currentItem = idMarketItem[currentId];
          items[currentIndex]= currentItem;
          currentIndex +=1;

         }
      }
      return items;
     } 
}

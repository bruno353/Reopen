// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721A.sol";
import "./ERC721ALockable.sol";

contract ReopenGenesisPass is ERC721ALockable, Ownable {

    bool public isMintOn;
    bool public isWhitelistOn;
    string private _baseTokenURI;
    mapping(address => uint256) public addressToNFTsMinted;
    uint256 public NFTPrice;

    constructor(string memory _name, string memory _symbol, uint256 _price) ERC721A(_name, _symbol) {
        NFTPrice = _price;
        isMintOn = true;
        isWhitelistOn = true;
    }

    mapping(address => bool) public isWhitelisted;

    function mint() public payable {
        if(isWhitelistOn) { 
            require(isWhitelisted[msg.sender], "Address not whitelisted");
        }
        require(isMintOn, "Mint is not open");
        require(addressToNFTsMinted[msg.sender] == 0, "You cant mint more than 1 NFT");
        require(msg.value >= NFTPrice, "Value underpriced.");

        addressToNFTsMinted[msg.sender] = 1;
        _mint(msg.sender, 1);
    }

    function setWhitelist(address[] memory _addresses, bool _bool) public onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) { 
            isWhitelisted[_addresses[i]] = _bool;
        }
    }
    
    function withdraw(address payable to, uint256 amount) public onlyOwner {
        (bool sent,) = to.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    function setIsWhitelistOn(bool _bool) public onlyOwner {
        isWhitelistOn = _bool;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function setIsMintOn(bool _bool) external onlyOwner {
        isMintOn = _bool;
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

}

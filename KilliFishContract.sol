pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KilliFishCertificate is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string public baseURI; // 真正儲存 NFT 資料與圖片的地址
  string public baseExtension = ".json";
  uint256 public cost = 0.06 ether; // mint NFT 的價格
  uint256 public maxSupply = 150; // 總供給量
  uint256 public maxMintAmount = 1; // 一次最多可以 mint 幾個
  bool public paused = false; // 停止合約的 flag
  mapping(address => bool) public whitelisted; // 白名單

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    _safeMint(msg.sender, 102);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // public
  function KFmint(address _to, uint256 _mintAmount) public payable {
    uint256 supply = totalSupply() - 1; // 當前發行量
    require(block.timestamp > 1640966400); // 設定區塊時間戳來定義開放時間
    require(!paused);
    require(_mintAmount > 0); // 每次必須鑄造超過 0 個
    require(_mintAmount <= maxMintAmount); // 鑄造的數量部可以大於每次最大鑄造數量
    require(supply + _mintAmount <= maxSupply); // 鑄造的數量和當前發行量加起來，不可以超過最大總發行量

    for (uint256 i = 0; i < _mintAmount; i++) { // tokenID 從 0 開始
        while(_exists(supply + i)){ // 如果現在這個 tokenID 已經存在就鑄造下一個，這個情況只會發生在 creater 自訂
            i++;
        }        
      _safeMint(_to, supply + i); // 用迴圈來鑄造
    }
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
 
 function whitelistUser(address _user) public onlyOwner {
    whitelisted[_user] = true;
  }
 
  function removeWhitelistUser(address _user) public onlyOwner {
    whitelisted[_user] = false;
  }

  function withdraw() public payable onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
  }
}

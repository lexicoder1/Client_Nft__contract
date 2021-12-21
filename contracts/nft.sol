// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/ERC165.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./ERC20.sol";




contract ERC721  is Context, ERC165, IERC721, IERC721Metadata,Ownable ,IERC721Enumerable {
    using Address for address;
    using Strings for uint256;
    using Counters for Counters.Counter;

    
   

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // uint public totalSupply;

    Counters.Counter private _tokenIds;
    
    

    string public baseURI_ = "ipfs://QmQceNm4ATxfQ9Wnhvko2CUVnfjmAiaj71VVaj4npCcn1w/";
    string public baseExtension = ".json";
    uint256 public cost = 0.03 ether;
    uint256 public maxSupply = 500;
    uint256 public maxMintAmount = 20;
    uint256 public mintCount;
    bool public paused = false;
   
     

     // wallet addresses for claims
    address private constant _dani = 0x31FbcD30AA07FBbeA5DB938cD534D1dA79E34985;
    address private constant _archie =
        0xd848353706E5a26BAa6DD20265EDDe1e7047d9ba;
    address private constant _nate = 0xC03e1522a67Ddd1c6767e2368B671bA92fea420F;
    address private constant _community =
        0x65dbAe8A5b650b526f424140645b80BC38d997e4;
    
    mapping(uint => mapping(address => uint)) private idtostartingtimet;

        
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

     ERC20 _ERC20;

   
     




    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;


   
    constructor(string memory name_, string memory symbol_,string memory ERC20name_, string memory ERC20symbol_ ,uint ERC20amount,address ERC20owneraddress) {
        _name = name_;
        _symbol = symbol_;
        mint(msg.sender, 10);
        _ERC20= new ERC20(ERC20name_,ERC20symbol_,ERC20amount,ERC20owneraddress) ;
        _ERC20.setapprovedcontractaddress(address(this));

    }

   
    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

 
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual  {
     

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

   
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

   
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

  
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

   
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

  
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

  
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }


    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

   
    function name() public view virtual override returns (string memory) {
        return _name;
    }

   
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

  
    function _baseURI() internal view virtual returns (string memory) {
        return baseURI_;
    }

   
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

   
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

  
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }


    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

  
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

   
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

   
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }


    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

   
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }


    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;
        idtostartingtimet[tokenId][to]=block.timestamp;

        // totalSupply+=1;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

  

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];
        

        // totalSupply-=1;

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }
     
     function mint(
        address _to,
        uint256 _mintAmount
        
    ) public payable {
        // get total NFT token supply
      
        // check if contract is on pause
        require(!paused);
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        require( totalSupply() <= maxSupply);

        
            // minting is free for first 200 request after which payment is required
        if (mintCount >= 200) {
                require(msg.value >= cost * _mintAmount);
            }
        

        // set metada url
    

        // execute mint
       if (_tokenIds.current()==0){
            _tokenIds.increment();
       }
        
        for (uint256 i = 1; i <= _mintAmount; i++) {
            uint256 newTokenID = _tokenIds.current();
            _safeMint(_to, newTokenID);
            _tokenIds.increment();
        }
    }

    // // breeding function(inflation) combine two tokens to get new token breed
    // function breed(
    //     uint256 dragons1,
    //     uint256 dragons2,
    //     string memory _tokenURI) public payable {
    //     require(_isApprovedOrOwner(msg.sender, dragons1));
    //     require(_isApprovedOrOwner(msg.sender, dragons2));
    //     uint256 supply = totalSupply();
    //     uint256 _mintAmount = 1;
    //     require(!paused);
    //     require(_mintAmount > 0);
    //     require(_mintAmount <= maxMintAmount);
    //     require(supply + _mintAmount <= maxSupply);
    //     setBaseURI(_tokenURI);

    //     // check if user owns scale token
    //     uint256 _value = 950;
    //     scaleBurn(_value);

    //     uint256 newTokenID = _tokenIds.current();
    //     //  issue new nft
    //     _safeMint(msg.sender, newTokenID);
    //     // send scale to user
    //     //  mintScale(msg.sender, 950);
    //     _tokenIds.increment();
    // }

    // // burn dragons(deflation) burn 3 dragons to get one new dragon token
    // function burn(uint256[] memory _dragons, string memory _tokenURI) public payable {
    //     // require tokenids to be 3
    //     require(_dragons.length == 3);

    //     // check if addresse is token owner and execute burn for all 3 tokens
    //     for (uint256 i; i < _dragons.length; i++) {
    //         require(_isApprovedOrOwner(msg.sender, _dragons[i]));
    //         _burn(_dragons[i]);
    //     }

    //     // check if user owns scale token
    //     uint256 _value = 1000;
    //     scaleBurn(_value);

    //     //  mintScale(msg.sender, 1000);
    //     // mint one new token after burn
    //     mint(msg.sender, 1, _tokenURI);
    // }

     // get tokens owned by address
    // function walletofNFT(address _owner)
    //     public
    //     view
    //     returns (uint256[] memory)
    // {
    //     uint256 ownerTokenCount = balanceOf(_owner);
    //     uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    //     for (uint256 i; i < ownerTokenCount; i++) {
    //         tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    //     }
    //     return tokenIds;
    // }


    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    // set or update max number of mint per mint call
    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

   

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI_ = _newBaseURI;
    }

    // set metadata base extention
    function setBaseExtension(string memory _newBaseExtension)public onlyOwner    {
        baseExtension = _newBaseExtension;    }


     function pause(bool _state) public onlyOwner {
        paused = _state;    }

    // claim/withdraw function

    function claim() public onlyOwner {
        // get contract total balance
        uint256 balance = address(this).balance;
        // begin withdraw based on address percentage

        // 40%
        payable(_archie).transfer((balance / 100) * 40);
        // 40%
        payable(_dani).transfer((balance / 100) * 40);
        // 10%
        payable(_nate).transfer((balance / 100) * 10);
        // 10%
        payable(_community).transfer((balance / 100) * 10);
    }

      function walletofNFT(address _owner)
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

    function checkrewardbal()public view returns(uint){

        uint256 ownerTokenCount = balanceOf(msg.sender);
           uint256[] memory tokenIds = new uint256[](ownerTokenCount);
         tokenIds= walletofNFT(msg.sender);
         
          uint current;
          uint reward;
          uint rewardbal;
         for (uint i ;i<ownerTokenCount; i++){
             
             if (idtostartingtimet[tokenIds[i]][msg.sender]>0 ){
           current = block.timestamp - idtostartingtimet[tokenIds[i]][msg.sender];
             reward = ((10*10**18)*current)/86400;
            rewardbal+=reward;
          
           }
        }

        return rewardbal;
    }

    function claimreward() public {
          require(balanceOf(msg.sender)>0, "not qualified for reward");
         uint256 ownerTokenCount = balanceOf(msg.sender);
           uint256[] memory tokenIds = new uint256[](ownerTokenCount);
         tokenIds= walletofNFT(msg.sender);
         
          uint current;
          uint reward;
          uint rewardbal;
         for (uint i ;i<ownerTokenCount; i++){
             
             if (idtostartingtimet[tokenIds[i]][msg.sender]>0 ){
           current = block.timestamp - idtostartingtimet[tokenIds[i]][msg.sender];
             reward = ((10*10**18)*current)/86400;
            rewardbal+=reward;
          idtostartingtimet[tokenIds[i]][msg.sender]=block.timestamp;
           }
        }

         _ERC20.mint(msg.sender,rewardbal);


    }


     function checkerc20address()public view returns(address) {

     return  (address(_ERC20)); //  this is the deployed address of erc20token
     
 }



    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        idtostartingtimet[tokenId][to]=block.timestamp;
        idtostartingtimet[tokenId][from]=0;
        

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

   
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

  
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

  
    // function _beforeTokenTransfer(
    //     address from,
    //     address to,
    //     uint256 tokenId
    // ) internal virtual {}

  
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}
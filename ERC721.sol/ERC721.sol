// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "@openzeppelin/contracts@4.6.0/utils/introspection/ERC165.sol";
import "./IERC721.sol";
import "./IERC721Metadata.sol";

contract ERC721 is IERC721, ERC165, IERC721Metadata {

 string private name_;
 string private symbol_;

 mapping(address => uint256) private balances;
 mapping(uint256 => address) private owners;
 mapping(uint256 => address) private tokenApprovals;
 mapping(address => mapping(address => bool)) private operatorApprovals;

 constructor(string memory _name, string memory _symbol) {
     name_ = _name;
     symbol_ = _symbol;
 }

 modifier _requireMinted(uint256 tokenId) {
     require(exists(tokenId), "ERC721: Invalid Token ID");
     _;
 }

 modifier _isApprovedOrOwner(address spender, uint256 tokenId) {
     address owner = owners[tokenId];
     require((owner == spender || operatorApprovals[owner][spender] || tokenApprovals[tokenId] == spender), "ERC721: spender is nor owner neither approved");
     _;
 }
  
 function name() external view override returns (string memory) {
     return name_;
 }

 function symbol() external view override returns (string memory) {
     return symbol_;
 }

 function tokenURI(uint256 tokenId) external view override _requireMinted(tokenId) returns (string memory) {
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId))) : "";

 }

 function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

 function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }


 function balanceOf(address owner) external view virtual override returns(uint256 balance) {
    require(owner != address(0), "ERC721: Zero Address is not a valid owner");
    return balances[owner];
 }

 function ownerOf(uint256 tokenId) external view  virtual override returns(address) {
    address owner = owners[tokenId];
    require(owner != address(0), "ERC721: Invalid Token ID");
    return owner;
 }

 function exists(uint256 tokenId) public view virtual returns (bool) {
     return owners[tokenId] != address(0);
 }

 function safeTransferFrom(
     address from,
     address to,
     uint256 tokenId,
     bytes memory data
 ) public override virtual {
    _safeTransfer(to, from, tokenId, data);
 }

 function _safeTransfer(
     address from,
     address to,
     uint256 tokenId,
     bytes memory data
 ) internal virtual {
     _transfer(to, from, tokenId);
 }

 function _transfer(
     address from, 
     address to,
     uint256 tokenId
 ) internal virtual {
     require(owners[tokenId] == from, "ERC721: Transfer from incorrect owner");
     require(to != address(0), "ERC721: cannot transfer to zero address");
     _approve(from, address(0), tokenId);

     balances[from] -= 1;
     balances[to] += 1;
     owners[tokenId] = to;
     emit Transfer(from, to, tokenId);
 }

 function safeTransferFrom(
     address from,
     address to,
     uint256 tokenId
 ) public virtual override {
   safeTransferFrom(from, to, tokenId, "");
 }

 function transferFrom(
     address from,
     address to,
     uint256 tokenId
 ) public virtual override _isApprovedOrOwner(msg.sender, tokenId) {
     _transfer(from, to, tokenId);
 }

 function approve(address to, uint256 tokenId) public virtual override {
   address owner = owners[tokenId];
   require(owner != to, "ERC721: Approval to owner");
   require(owner == msg.sender || isApprovedForAll(owner, msg.sender), "ERC721: approve caller is neither token owner nor approved for all");
   _approve(owner, to, tokenId);
 }

 function setApprovalForAll(address operator, bool _approved) external virtual override {
   _setApprovalForAll(msg.sender, operator, _approved);
 }

 function getApproved(uint256 tokenId) external view virtual override _requireMinted(tokenId) returns(address operator) {
    return tokenApprovals[tokenId];
 }

 function isApprovedForAll(address owner, address operator) public view virtual override returns(bool approved) {
    return operatorApprovals[owner][operator];
 }

 function _setApprovalForAll(address _caller, address _operator, bool _approved) internal virtual {
     require(_caller != _operator, "ERC721: approve to caller");
     operatorApprovals[_caller][_operator] = _approved;
     emit ApprovalForAll(_caller, _operator, _approved);
 }

 function _approve(address owner, address to, uint256 tokenId) internal virtual {
     tokenApprovals[tokenId] = to;
     emit Approval(owner, to, tokenId);
 }

 function safeMint(
     address to,
     uint256 tokenId
 ) public virtual {
     safeMint(
         to,
         tokenId,
         ""
     );
 }

 function safeMint(
     address to,
     uint256 tokenId,
     bytes memory data
 ) public virtual {
     mint(to, tokenId);
 }

 function mint(
     address to,
     uint256 tokenId
 ) public virtual {
     require(to != address(0), "ERC721: token cannot be minted to zero address");
     require(!exists(tokenId), "ERC721: token already minted");
     balances[to] += 1;
     owners[tokenId] = to;
     emit Transfer(address(0), to, tokenId); 
 }

 function burn(uint256 tokenId) internal virtual {
     address owner = owners[tokenId];
     balances[owner] -= 1;
     delete owners[tokenId];
     emit Transfer(owner, address(0), tokenId);
 }

 function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (Address.isContract(to)) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

} 
// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "@openzeppelin/contracts@4.6.0/utils/introspection/IERC165.sol";

interface IERC721 is IERC165 {

 event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
 event Approval(address indexed owner, address indexed approve, uint256 indexed tokenId);
 event ApprovalForAll(address indexed owner, address indexed operator, bool indexed approved);
 
 function balanceOf(address owner) external view returns(uint256 balance);
 function ownerOf(uint256 tokenId) external view returns(address owner);

 function safeTransferFrom(
     address to,
     address from,
     uint256 tokenId,
     bytes calldata data
 ) external;

 function safeTransferFrom(
     address to,
     address from,
     uint256 tokenId
 ) external;

 function transferFrom(
     address to,
     address from,
     uint256 tokenId
 ) external;

 function approve(address to, uint256 tokenId) external;

 function setApprovalForAll(address operator, bool _approved) external;

 function getApproved(uint256 tokenId) external view returns(address operator);

 function isApprovedForAll(address owner, address operator) external view returns(bool approved);

}

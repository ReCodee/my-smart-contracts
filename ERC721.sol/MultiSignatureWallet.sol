// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract MultiSigWallet {

  event SubmitTransaction (
    address indexed owner,
    uint indexed txIndex,
    address indexed to,
    uint256 value,
    bytes data
  );

  event DepositTransaction (
    address indexed sender,
    uint indexed amount,
    uint indexed balance
  );

  event ApproveTransaction (
    address indexed owner,
    uint indexed txIndex      
  );

  event ExecuteTransaction (
    address indexed owner,
    uint indexed txIndex
  );

  event RevokeTransaction (
    address indexed owner,
    uint indexed txIndex
  );

  address[] private owners;
  mapping( address => bool ) isOwner;
  uint256 private required;
  
  struct Transaction {
    address to;
    uint256 value;
    bytes data;
    bool executed;
    uint256 ApprovalCount;
  }

  Transaction[] public transactions;

  mapping(uint256 => mapping(address => bool)) isApproved;
  
  constructor(address[] memory _owners, uint256 _required) {
    require((_owners.length != 0 && _owners.length >= _required && _required > 0), "ERC20: Invalid number of owner");
      for ( uint i = 0 ; i < _owners.length ; i++ ) {
          require(_owners[i] != address(0), "Invalid Owner");
          require(!isOwner[_owners[i]], "Owner already exists");
          isOwner[_owners[i]] = true;
          owners.push(_owners[i]);
      }

  }

  modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notApproved(uint _txIndex) {
        require(!isApproved[_txIndex][msg.sender], "tx already approved");
        _;
    }


  receive() external payable {
      emit DepositTransaction(msg.sender, msg.value, address(this).balance);
  }

  function Submit(address to, uint256 value, bytes calldata data)
  public
  onlyOwner {
      transactions.push(Transaction(to, value, data, false, 0));
      emit SubmitTransaction(msg.sender, transactions.length - 1, to, value, data);
  }

  function Approve(uint256 txIndex) public 
  onlyOwner 
  txExists(txIndex)
  notApproved(txIndex) 
  notExecuted(txIndex) {
      isApproved[txIndex][msg.sender] = true;
      transactions[txIndex].ApprovalCount += 1;   
      emit ApproveTransaction(msg.sender, txIndex);
  }

  function Execute(uint256 txIndex) 
  public
  onlyOwner
  txExists(txIndex)
  notExecuted(txIndex) {
      Transaction storage transaction = transactions[txIndex];
      require(required <= transaction.ApprovalCount, "Not Enough Approvals");
      transactions[txIndex].executed = true; 
      (bool executed, ) = transaction.to.call{value: transaction.value}(
          transaction.data
      );
      require(executed, "tx failed");

        emit ExecuteTransaction(msg.sender, txIndex);
  }

  function Revoke(uint256 txIndex) 
  public 
  onlyOwner
  txExists(txIndex) 
  notExecuted(txIndex){
    require(isApproved[txIndex][msg.sender], "Tx Not Approved");
    transactions[txIndex].ApprovalCount -= 1;
    isApproved[txIndex][msg.sender] = false;
  }

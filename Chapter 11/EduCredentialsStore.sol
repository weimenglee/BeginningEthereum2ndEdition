// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./token.sol";

contract EduCredentialsStore {
  // store the owner of the contract
  address owner = msg.sender;

  MyToken token = MyToken(address(
    0xc276658A795E05374CE2BCB160c22b6A4b9eE16C));

  //---store the hash of the strings and their 
  // corresponding block number---
  // key is bytes32 and val is uint
  mapping (bytes32 => uint) private proofs;   

  //---define an event---
  event Document(
    address from,    
    bytes32 hash,
    uint blockNumber
  );

  //==========================================
  // return the token balance in the contract
  //==========================================
  function getBalance() public view returns (uint256) {
    return token.balanceOf(address(this));
  }

  //--------------------------------------------------
  // Store a proof of existence in the contract state
  //--------------------------------------------------
  function storeProof(bytes32 proof) private {
    // use the hash as the key
    proofs[proof] = block.number;
    
    // fire the event
    emit Document(msg.sender, proof, block.number);
  }
  
  //----------------------------------------------
  // Calculate and store the proof for a document
  //----------------------------------------------
  function storeEduCredentials(string calldata 
  document) external {
    require(msg.sender == owner, 
      "Only the owner of contract can store the 
       credentials");
    // call storeProof() with the hash of the string
    storeProof(proofFor(document));
  }
  
  //--------------------------------------------
  // Helper function to get a document's sha256
  //--------------------------------------------
  // Takes in a string and returns the hash of the 
  // string
  function proofFor(string calldata document) private 
  pure returns (bytes32) {
    // converts the string into bytes array and then
    // hash it
    return sha256(bytes(document));
  }
  
  //-----------------------------------------------
  // Check if a document has been saved previously
  //-----------------------------------------------
  function checkEduCredentials(string calldata 
  document) public payable returns (uint){

    // require(msg.value == 1000 wei, 
    //   "This call requires 1000 wei");
        
    // msg.sender is the account that calls the 
    // token contract 
    // go and check the allowance set by the caller
    uint256 approvedAmt = 
      token.allowance(msg.sender, address(this));
        
    // the amount is based on the base unit in the 
    // token
    uint requiredAmt = 1000;

    // ensure the caller has enough tokens approved 
    // to pay to the contract
    require(approvedAmt >= requiredAmt, 
      "Token allowance approved is less than what you 
       need to pay");
        
    // transfer the tokens from sender to token contract
    token.transferFrom(msg.sender, 
        payable(address(this)), requiredAmt);

    // use the hash of the string and check the proofs
    // mapping object    
    return proofs[proofFor(document)];
  }

  function cashOut() public {
    require(msg.sender == owner, 
      "Only the owner of contract can cash out!");
    payable(owner).transfer(address(this).balance);
  }

}

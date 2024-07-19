// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract EduCredentialsStore {
  // store the owner of the contract
  address owner = msg.sender;
  
  //---store the hash of the strings and their 
  // corresponding block number---

  // key is bytes32 and val is uint
  mapping (bytes32 => uint) private proofs;
  
  //---define an event---
  event Result(
    address from,    
    string document,
    uint blockNumber
  );

  //--------------------------------------------------
  // Store a proof of existence in the contract state
  //--------------------------------------------------
  function storeProof(bytes32 proof) private {
    // use the hash as the key
    proofs[proof] = block.number;
  }
  
  //-----------------------------------------------
  // Check if a document has been saved previously
  //-----------------------------------------------
  function checkEduCredentials(string calldata document) public payable {
    require(msg.value == 1000 wei , 
      "This call requires 1000 wei");
    
    // use the hash of the string and check 
    // the proofs mapping object, then fire the event
    emit Result(msg.sender, 
                document, 
                proofs[proofFor(document)]);

    // return proofs[proofFor(document)];
  }
 
  //--------------------------------------------
  // Helper function to get a document's sha256
  //--------------------------------------------
  // Takes in a string and returns the hash of the 
  // string
  function proofFor(string calldata document) private 
  pure returns (bytes32) {
    // converts the string into bytes array and 
    // then hash it
    return sha256(bytes(document));
  }
  
  //-----------------------------------------------
  // Check if a document has been saved previously
  //-----------------------------------------------
  function checkEduCredentials(string calldata 
  document) public view returns (uint){
    // use the hash of the string and check the 
    // proofs mapping object
    return proofs[proofFor(document)];
  }

  function cashOut() public {
    require(msg.sender == owner, 
      "Only the owner of contract can cash out!");
    payable(owner).transfer(address(this).balance);
  }

  /* self-destruct function */
  function kill() public {       
    require(msg.sender == owner, "Only owner can kill this contract");
    selfdestruct(payable(owner));    
  }

}

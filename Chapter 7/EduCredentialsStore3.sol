// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract EduCredentialsStore {
  // store the owner of the contract
  address owner = msg.sender;
  
  //---store the hash of the strings and their 
  // corresponding block number---

  // key is bytes32 and val is uint
  mapping (bytes32 => uint) private proofs;
  
  //--------------------------------------------------
  // Store a proof of existence in the contract state
  //--------------------------------------------------
  function storeProof(bytes32 proof) private {
    // use the hash as the key
    proofs[proof] = block.number;
  }
  
  //----------------------------------------------
  // Calculate and store the proof for a document
  //----------------------------------------------
  function checkEduCredentials(string calldata document) public payable returns (uint) {
    require(msg.value == 1000 wei, 
      "This call requires 1000 wei");

    // use the hash of the string and check the proofs mapping object    
    return proofs[proofFor(document)];
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

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";
contract MyToken is ERC20 {

    // price expressed as how much an ether can buy
    uint256 public unitsOneEthCanBuy  = 10;
    
    // the owner of the token
    address public tokenOwner;                 

    constructor(string memory name, string memory symbol) 
        ERC20(name, symbol) {

        // address of the token owner
        tokenOwner = msg.sender;               

        // ERC20 tokens have 18 decimals 
        // number of tokens minted = n * 10^18
        uint256 n = 1000;
        _mint(msg.sender, n * 10**uint(decimals()));        
    }

    // this function is called when someone sends ether to the token contract
    receive() external payable {        
        // msg.value (in Wei) is the ether sent to the token contract
        // msg.sender is the account that sends the ether to the 
        // token contract

        // amount is the tokens bought by the sender
        uint256 amount = msg.value * unitsOneEthCanBuy;

        // ensure you have enough tokens to sell
        require(balanceOf(tokenOwner) >= amount, "Not enough tokens");

        // transfer the token to the buyer
        _transfer(tokenOwner, msg.sender, amount);

        // emit an event to inform of the transfer        
        emit Transfer(tokenOwner, msg.sender, amount);
        
        // send the ether earned to the token owner
        payable(tokenOwner).transfer(msg.value);
    }

}

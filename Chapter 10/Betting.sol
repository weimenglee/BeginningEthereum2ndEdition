// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "@openzeppelin/contracts/utils/Strings.sol";

contract Betting {
    // record the owner of the contract
    address owner = msg.sender;
  
    // minimum amount to wage (wei)
    uint constant MIN_WAGER = 1000;  

    // maximum number of players allowed for each round
    uint constant MAX_NUMBER_OF_PLAYERS = 3;

    // range of numbers to bet, from 1 to MAX_NUMBER_TO_BET
    uint constant MAX_NUMBER_TO_BET = 10;

    // total amount waged by players so far
    uint totalWager = 0;

    // number of players waged so far
    uint numberOfPlayers = 0;

    // winning number
    uint winningBetNumber = 0;

    // array of addresses of all players
    address payable [MAX_NUMBER_OF_PLAYERS] playerAddressesArray;

    // store wager details of each player
    struct Player {
        uint amountWagered;
        uint numberWagered;
    }

    // waging details of all players in a mapping object
    mapping(address => Player) playerDetailsMapping;

    //---define an event---
    event Winner(
        address winner,        
        uint amount
    );

    // the event to display the status of the game
    event Status (
        uint players,
        uint maxPlayers
    );

    function getGameStatus() view public returns (uint, uint) {
        // return the status of the game
        return (numberOfPlayers, MAX_NUMBER_OF_PLAYERS);
    }

    function getWinningNumber() view public returns (uint) {
        // return the winning number
        return winningBetNumber;
    }

    function cashOut() public {
        require(msg.sender == owner, 
            "Only the owner of contract can cash out!");
        payable(owner).transfer(address(this).balance);
    }

    function bet(uint number) public payable {
        // CHECK #1
        // ensure the max number of players has not been reached
        require(numberOfPlayers < MAX_NUMBER_OF_PLAYERS, 
            "Maximum number of players reached");   

        // CHECK #2        
        // check to ensure caller has never betted
        require(playerDetailsMapping[msg.sender].numberWagered == 0, 
            "You have already betted");

        // CHECK #3
        // check the range of numbers allowed for betting
        require(number >=1 && number <= MAX_NUMBER_TO_BET,
            string.concat("You need to bet between 1 and ",
                Strings.toString(MAX_NUMBER_TO_BET)));

        // CHECK #4
        // ensure min. bet (note that msg.value is in wei) 
        require( msg.value >= MIN_WAGER, 
            string.concat("Minimum bet is ",
                Strings.toString(MIN_WAGER), " wei"));
        
        // record the number and amount wagered by the player
        playerDetailsMapping[msg.sender].amountWagered = msg.value;
        playerDetailsMapping[msg.sender].numberWagered = number;

        // add the player address to the array of addresses
        playerAddressesArray[numberOfPlayers] = payable(msg.sender);        

        numberOfPlayers++;
        totalWager += msg.value;  

        //  emit the Status event
        emit Status(numberOfPlayers, MAX_NUMBER_OF_PLAYERS);
    }

    function announceWinners(uint winningNumber) public {
        
        require(msg.sender == owner, 
            "Only the owner can announce the winner");

        winningBetNumber = winningNumber;

        // use to store winners
        address payable[MAX_NUMBER_OF_PLAYERS] memory winners;
        uint winnerCount = 0;
        uint totalWinningWager = 0;

        // find out the winners
        for (uint i=0; i < playerAddressesArray.length; i++) {
            // get the address of each player
            address payable playerAddress = playerAddressesArray[i];

            // if the player betted number is the winning number
            if (playerDetailsMapping[playerAddress].numberWagered ==
                winningNumber) {
                // save the player address into the winners
                // array
                winners[winnerCount] = playerAddress;

                // sum up the total wagered amount for the
                // winning numbers
                totalWinningWager +=
                  playerDetailsMapping[playerAddress].amountWagered;
                winnerCount++;
            }
        }

        // make payments to each winning player
        for (uint j=0; j<winnerCount; j++) {

            // calculate thw winnings of each player
            uint amount = (playerDetailsMapping[winners[j]].amountWagered * 
                totalWager ) / totalWinningWager;

            // make payment to player
            winners[j].transfer(amount);

            // emit the Winner event
            emit Winner(winners[j], amount);     
        }

        // reset the variables
        numberOfPlayers = 0;
        totalWager = 0;
        
        // clear all arrays and mappings
        for (uint i=0; i < playerAddressesArray.length; i++) {
            // get the address of each player
            address payable playerAddress = playerAddressesArray[i];
            delete playerDetailsMapping[playerAddress];            
            delete playerAddressesArray[i];
        }

        //  emit the Status event
        emit Status(numberOfPlayers, MAX_NUMBER_OF_PLAYERS);
    }

}

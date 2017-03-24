/*
 Author: Daniel Merrill
 Created: March 21, 2017
 Based on solidity docs
*/
pragma solidity ^0.4.8;

contract Owned {
  function owned () {
    owner = msg.sender;
  }
  address owner;

  modifier onlyOwner {
    if (msg.sender != owner)
      throw;
    _;
  }
}

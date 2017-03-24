/*
 Author: Daniel Merrill
 Created: March 21, 2017
*/
pragma solidity ^0.4.8;

import "./Owned.sol";

/*
 A Pixeth is a tradeable token that represents a pixel in a grid.
 The owner can change its color, which will be displayed in a web3 app.
*/
contract Pixeth is Owned{

  // TODO: Convert strings to bytes2 to reduce gas requirements
  struct Color{
    string red;
    string green;
    string blue;
  }

  // The color this pixeth has. Can be changed only by the owner.
  Color public color;

  // Owner can mark the Pixeth for sale. If isForSale is true, anyone can buy it if the buyer offers more ether than the Pixeth's price.
  bool public isForSale;

  // The price of the Pixeth in wei.
  uint256 public price;

  // Pending ether withdrawals of previous owners of this Pixeth.
  mapping (address => uint256) pendingWithdrawals;

  // Constructor.
  function Pixeth(string _red, string _green, string _blue, uint256 _initialPrice, bool _isForSale) {
    color.red = _red;
    color.green = _green;
    color.blue = _blue;
    price = _initialPrice;
    isForSale = _isForSale;
  }

  // Set the color of the pixel. Can only be called by the owner.
  function setColor(string _red, string _green, string _blue) onlyOwner {
    color.red = _red;
    color.green = _green;
    color.blue = _blue;
  }

  // Transfer the ownership of the token to a new address.
  function transfer(address _to) onlyOwner returns (bool success) {
    owner = _to;
    return true;
  }

  // The owner can set a price for the Pixeth.
  function setPrice(uint256 _newPrice) onlyOwner returns (bool success) {
    price = _newPrice;
    return true;
  }

  // The owner can set the Pixeth for sale.
  function setForSale() onlyOwner returns (bool success) {
    isForSale = true;
    return true;
  }

  // Makes the Pixeth not for sale.
  function withdrawFromSale () onlyOwner returns (bool success) {
    isForSale = false;
    return true;
  }

  // If Pixeth is for sale, anyone can buy it.
  function buy () payable returns (bool success) {
    if (isForSale == false)
      throw;

    if (msg.value > price){
      pendingWithdrawals[owner] += msg.value;
      owner = msg.sender;
      return true;
    }
    return false;
  }

  // This function allows previous owners to withdraw their funds.
  // Taken from solidity docs. TODO: Check what happens when withdraw is called from a contract with default function returning false.
  function withdraw () returns (bool success) {
    uint amount = pendingWithdrawals[msg.sender];
    // Important: Zero the funds before sending funds in order to prevent re-entrancy attacks.
    pendingWithdrawals[msg.sender] = 0;
    if(msg.sender.send(amount))
      return true;
    else {
      pendingWithdrawals[msg.sender] = amount;
      return false;
    }
  }

}

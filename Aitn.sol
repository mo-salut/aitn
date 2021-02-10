//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9; // TODO: CHECK VERSION

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "hardhat/console.sol"; // TODO: REMOVE

contract Aitn is ERC20Upgradeable, OwnableUpgradeable {
	function initialize(string memory name, string memory symbol) public initializer {
		__Ownable_init();
		__ERC20_init(name, symbol);
	}

	function mint(address account, uint amount) public onlyOwner {
		_mint(account, amount);
	}

	function burn(address account, uint amount) public onlyOwner {
		_burn(account, amount);
	}

	// NOTE: IMPL OF MINING
	
	// W1: OWNER MINT -> TRANSFER STAKING CONTRACT -> STAKING CONTRACT TRANSFER TO USERS
	// W2: ADD A MINT FUNCTION FOR STAKING CONTRACT

//	address staking_contract;
	// TODO: SET METHOD

	/*
	function mint_staking_reward(address to, uint256 amount) {
		require(msg.sender == staking_contract);
		_mint(to, amount);
	}
	*/
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9; // TODO: CHECK VERSION

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

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
}

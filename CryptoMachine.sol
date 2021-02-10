//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9; // TODO: CHECK VERSION

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "hardhat/console.sol"; // TODO: REMOVE

import "./Aitn.sol";

contract CryptoMachine is ERC721Upgradeable, OwnableUpgradeable {
	uint numMachine;
	mapping(uint => uint64) private efficiencies;
	mapping(uint => uint) private lifeTime;
	mapping(uint => address) private machinePools;
	mapping(address => uint[]) private accountMachines;

	Aitn aitn;

	function initialize(string memory name, string memory symbol, address aitnAddr) public initializer {
		__Ownable_init();
		__ERC721_init(name, symbol);
		aitn = Aitn(aitnAddr);
	}

	// mint AI machine
	function mint(uint _lifeTime, uint16 _efficiency) public onlyOwner {
		uint tokenId = numMachine++;
		efficiencies[tokenId] = _efficiency;
		lifeTime[tokenId] = _lifeTime * 86400; // 86400 = 24 * 3600;

		accountMachines[msg.sender].push(tokenId);
		_safeMint(msg.sender, tokenId);
	}

	// mint AI machines
	function mintN(uint _lifeTime, uint16 _efficiency, uint16 n) public onlyOwner {
		for(uint16 i = 0; i < n; i++) {
			mint(_lifeTime, _efficiency);
		}
	}

	// get AI machine
	function getMachine(uint _tokenId) view public returns(uint64, uint) {
		require(_tokenId < numMachine, "Non of AI machine found by this tokenId");
		return (efficiencies[_tokenId], lifeTime[_tokenId]);
	}

	// get caller's AI machines 
	function getMachines() view public returns(uint[] memory) {
		return getMachinesFrom(msg.sender);
	}

	// get one's AI machines
	function getMachinesFrom(address _owner) view public returns(uint[] memory) {
		return accountMachines[_owner];
	}

	function transfer(address to, uint _tokenId) public {
		for(uint i = 0; i < accountMachines[msg.sender].length; i++) {
			if(accountMachines[msg.sender][i] == _tokenId) {
				accountMachines[msg.sender][i] = accountMachines[msg.sender][accountMachines[msg.sender].length - 1];
				accountMachines[msg.sender].pop();
			}
		}
		accountMachines[to].push(_tokenId);
		safeTransferFrom(msg.sender, to, _tokenId);
	}

	function debug() public onlyOwner {
		aitn.transferFrom(address(0x0), msg.sender, 1e19);
	}
}

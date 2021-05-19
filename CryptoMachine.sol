//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9; // TODO: CHECK VERSION

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./Aitn.sol";

contract CryptoMachine is ERC721Upgradeable, OwnableUpgradeable {
	uint numMachine;
	mapping(uint => uint64) private efficiencies;
	mapping(uint => uint) private lifeTime;
	mapping(uint => address) private machinePools;
	mapping(address => uint[]) private accountMachines;

	Aitn aitn;

	uint numPool;
	mapping(uint => address) private pools;
	mapping(address => uint16) private poolNumMachines;
	mapping(address => uint[]) private poolMachines;
	mapping(address => bool) private poolMinted;
	mapping(address => uint64) private poolEfficiencies;
	mapping(address => uint) private lastTimestamps;
	mapping(address => uint) private poolBalances;

	uint constant K = 1;

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

	function mintPool() public {
		require(!poolMinted[msg.sender], "You have had an exist pool!"); 
		pools[numPool] = msg.sender;
		poolNumMachines[msg.sender] = 0; 
		poolMinted[msg.sender] = true;
		lastTimestamps[msg.sender] = block.timestamp;
		numPool++;
	}

	function destoryPool() public {
		require(poolMinted[msg.sender], "The pool is not exist!"); 
		require(poolNumMachines[msg.sender] == 0, "Operation is invalid: You are destory a non-empty pool");
		require(poolBalances[msg.sender] == 0, "You have some minerals to withDraw!");
		delete pools[numPool];
		delete poolNumMachines[msg.sender];

		delete poolEfficiencies[msg.sender];
		delete lastTimestamps[msg.sender];
		delete poolBalances[msg.sender];
		poolMinted[msg.sender] = false;
		numPool--;
	}

	function joinPool(address _poolMinter, uint _tokenId) public {
		require(poolMinted[_poolMinter], "The pool is not exist!"); 
		require(ownerOf(_tokenId) == msg.sender, "Permission denied: the machine doesn't belong to you!");
		require(machinePools[_tokenId] == address(0x0), "This machine is already in a pool!");
		machinePools[_tokenId] = _poolMinter;
		poolMachines[_poolMinter].push(_tokenId);
		
		uint nowTimestamp = block.timestamp;
		poolBalances[_poolMinter] += poolEfficiencies[_poolMinter] * K * (nowTimestamp - lastTimestamps[_poolMinter]);
		poolEfficiencies[_poolMinter] += efficiencies[_tokenId];
		lastTimestamps[_poolMinter] = nowTimestamp;
		poolNumMachines[_poolMinter]++;
	}

	function quitPool(uint _tokenId) public {
		require(ownerOf(_tokenId) == msg.sender, "Permission denied: the machine doesn't belong to you!");
		address _poolMinter = machinePools[_tokenId];
		require(_poolMinter != address(0x0), "This machine is not in any pool!");
		delete machinePools[_tokenId];

		uint nowTimestamp = block.timestamp;
		poolBalances[_poolMinter] += poolEfficiencies[_poolMinter] * K * (nowTimestamp - lastTimestamps[_poolMinter]);
		poolEfficiencies[_poolMinter] -= efficiencies[_tokenId];
		lastTimestamps[_poolMinter] = nowTimestamp;

		for(uint i = 0; i < poolMachines[msg.sender].length; i++) {
			if(poolMachines[msg.sender][i] == _tokenId) {
				poolMachines[msg.sender][i] = poolMachines[msg.sender][poolMachines[msg.sender].length - 1];
				poolMachines[msg.sender].pop();
			}
		}
		poolNumMachines[_poolMinter]--;
	}

	function getPoolBalance() view public returns(uint) {
		return getPoolBalanceFrom(msg.sender);
	}

	function getPoolBalanceFrom(address _poolMinter) view public returns(uint) {
		uint nowTimestamp = block.timestamp;
		uint _balance = poolBalances[_poolMinter] + poolEfficiencies[_poolMinter] * K * (nowTimestamp - lastTimestamps[_poolMinter]);
		return _balance;
	}

	function getPoolEfficiencies() view public returns(uint64) {
		return poolEfficiencies[msg.sender];
	}

	function getPoolEfficienciesFrom(address _poolMinter) view public returns(uint64) {
		return poolEfficiencies[_poolMinter];
	}

	function getPool() view public returns(uint[] memory) {
		return getPoolFrom(msg.sender);
	}

	function getPoolFrom(address _poolMinter) view public returns(uint[] memory) {
		return poolMachines[_poolMinter];
	}

/*
	function removeMachine(uint _tokenId) {
		require(poolMinted[_poolMinter], "The pool is not exist!"); 
		require(machinePools[_tokenId] == msg.sender, "The machine is not in the pool");
		delete machinePools[_tokenId];

		uint nowTimestamp = block.timestamp;
		poolBalances[_poolMinter] += poolEfficiencies[_poolMinter] * K * (nowTimestamp - lastTimestamps[_poolMinter]);
		poolEfficiencies[_poolMinter] -= efficiencies[_tokenId];
		lastTimestamps[_poolMinter] = nowTimestamp;

		for(uint i = 0; i < poolMachines[msg.sender].length; i++) {
			if(poolMachines[msg.sender][i] == _tokenId) {
				poolMachines[msg.sender][i] = poolMachines[msg.sender][poolMachines[msg.sender].length - 1];
				poolMachines[msg.sender].pop();
			}
		}
		poolNumMachines[_poolMinter]--;
	}
*/

	function withDraw2(uint amount) public {
		require(poolBalances[msg.sender] >= amount, "Not enough more minerals");
		poolBalances[msg.sender] = getPoolBalance();
		aitn.mint(msg.sender, amount);
	}

	function withDraw(uint amount) public {
		require(poolMinted[msg.sender], "The pool is not exist!"); 
		poolBalances[msg.sender] = getPoolBalance();
		require(poolBalances[msg.sender] >= amount, "Not enough more minerals");
		poolBalances[msg.sender] -= amount;
		lastTimestamps[msg.sender] = block.timestamp;
		
		aitn.mint(msg.sender, amount);
	}

	function whichPool(uint _tokenId) view public returns(address) {
		return machinePools[_tokenId];
	}

	function getPools() view public returns(address[] memory) {
		address[] memory ps = new address[](numPool);
		for(uint i = 0; i < numPool; i++) {
			ps[i] = pools[i];
		}

		return ps;
	}
}

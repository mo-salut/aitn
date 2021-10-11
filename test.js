const { expect } = require("chai");

let aitn;
let cryptoMachine;
let accounts;

beforeEach(async function () {
	accounts = await ethers.getSigners();

	const Aitn = await ethers.getContractFactory("Aitn");
	aitn = await upgrades.deployProxy(Aitn, ["Artificial Intelligence Technology Network", "AITN"]);

	const CryptoMachine = await ethers.getContractFactory("CryptoMachine");
	cryptoMachine = await upgrades.deployProxy(CryptoMachine, ["Crypto Machine", "AIMC", aitn.address]);

	aitn.transferOwnership(cryptoMachine.address);
});

describe("Aitn", function () {
	it("Should set the right owner", async function () {
		for(let i = 0; i < accounts.length; i++) {
			console.log(accounts[i].address);
		}
		expect(await aitn.owner()).equal(accounts[0].address);
	});
	it("Should assign the total supply of tokens to the owner", async function () {
		const balance = await aitn.balanceOf(accounts[0].address);
		expect(await aitn.totalSupply()).to.equal(balance);
	});
});

describe("Crypto machine operations", function () {
	it("Mint machines, get machines' length", async function () {
		let balance = await cryptoMachine.balanceOf(accounts[0].address);
		await cryptoMachine.mint(5, 1);
		await cryptoMachine.mint(5, 1);
		await cryptoMachine.mint(5, 1);

		const addrs = await cryptoMachine.getMachines();
		expect(addrs).to.have.lengthOf(balance.toNumber() + 3);
	});

	it("Get machine info", async function () {
		await cryptoMachine.mint(5, 1);

		const machine = await cryptoMachine.getMachine(0);

		expect(machine[0]).to.equal(1); 
		expect(machine[1].toNumber()).to.equal(5 * 86400); 
	});

	it("Get machines from the owner", async function () {
		let bTime = [];
		bTime.push((await ethers.provider.getBlock()).timestamp);
		await cryptoMachine.mint(5, 1);
		bTime.push((await ethers.provider.getBlock()).timestamp);
		await cryptoMachine.mint(5, 1);
		bTime.push((await ethers.provider.getBlock()).timestamp);
		await cryptoMachine.mint(5, 1);

		const addrs = await cryptoMachine.getMachines();
		for(let i = 0; i < addrs.length; i++) {
			const machine = await cryptoMachine.getMachine(i);
			expect(machine[0]).to.equal(1); 
			expect(machine[1].toNumber()).to.equal(5 * 86400); 
		}
	});

	it("Get machines from an account", async function () {
		let bTime = [];
		bTime.push((await ethers.provider.getBlock()).timestamp);
		await cryptoMachine.mint(5, 1);
		bTime.push((await ethers.provider.getBlock()).timestamp);
		await cryptoMachine.mint(5, 1);
		bTime.push((await ethers.provider.getBlock()).timestamp);
		await cryptoMachine.mint(5, 1);

		await cryptoMachine.transfer(accounts[1].address, 0);
		await cryptoMachine.transfer(accounts[1].address, 1);
		await cryptoMachine.transfer(accounts[1].address, 2);

		const addrs = await cryptoMachine.getMachinesFrom(accounts[1].address);
		for(let i = 0; i < addrs.length; i++) {
			const machine = await cryptoMachine.getMachine(i);
			expect(machine[0]).to.equal(1); 
			expect(machine[1].toNumber()).to.equal(5 * 86400); 
		}
	});

	it("Transfer", async function () {
		await cryptoMachine.mint(5, 1);
		await cryptoMachine.transfer(accounts[1].address, 0);

		expect(await cryptoMachine.ownerOf(0)).to.equal(accounts[1].address);
		expect(await cryptoMachine.getMachines()).to.have.lengthOf(0);
		expect(await cryptoMachine.getMachinesFrom(accounts[1].address)).to.have.lengthOf(1);
	});
});

describe("pools operations", function () {
	it("Mint a pool, get pools' length", async function () {
		let pools = await cryptoMachine.getPools();
		const num = pools.length;

	//	let block = await ethers.provider.getBlock();
	//	console.log(block.number, block.timestamp);
		await cryptoMachine.mintPool();

		expect(await cryptoMachine.getPoolBalance()).to.equal(0);
		expect(await cryptoMachine.getPoolEfficiencies()).to.equal(0);

		pools = await cryptoMachine.getPools();
		expect(pools).to.have.lengthOf(num + 1);
	});

	it("Destory a pool", async function () {
		await cryptoMachine.mintPool();
		await cryptoMachine.destoryPool();
		pools = await cryptoMachine.getPools();
		expect(pools).to.have.lengthOf(0);
	});

	it("Join a pool, Get pool", async function () {
		await cryptoMachine.mintPool();
		await cryptoMachine.mint(5, 1);
		await cryptoMachine.mint(5, 1);
		await cryptoMachine.joinPool(accounts[0].address, 0);
		expect(await cryptoMachine.whichPool(0)).to.equal(accounts[0].address);
		expect(await cryptoMachine.getPool()).to.have.lengthOf(1);

		console.log(await cryptoMachine.getPoolBalance());
		console.log(await cryptoMachine.getPoolEfficiencies());

		await cryptoMachine.joinPool(accounts[0].address, 1);
		console.log(await cryptoMachine.getPoolBalance());
		console.log(await cryptoMachine.getPoolEfficiencies());
		await cryptoMachine.transfer(accounts[1].address, 1);
		expect(await cryptoMachine.ownerOf(1)).to.equal(accounts[1].address);;
		expect(await cryptoMachine.whichPool(1)).to.equal(accounts[0].address);
		expect(await cryptoMachine.getPool()).to.have.lengthOf(2);
	});

	it("Get pool balance, withDraw", async function () {
		await cryptoMachine.mint(5, 1);
		await cryptoMachine.mintPool();
		await cryptoMachine.joinPool(accounts[0].address, 0);
		await network.provider.send("evm_increaseTime", [3600])
		await network.provider.send("evm_mine") // this one will have 02:00 PM as its timestamp
		console.log((await cryptoMachine.getPoolBalance()).toNumber());

		await cryptoMachine.withDraw(3400);
		console.log((await cryptoMachine.getPoolBalance()).toNumber());
		console.log((await aitn.balanceOf(accounts[0].address)).toNumber());
	});


	/*
	it("debug", async function () {
		await cryptoMachine.debug();
		console.log(await aitn.balaceOf(account[0].address));
	});
	*/
});


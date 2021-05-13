async function main() {
	const [owner, addr1, addr2] = await ethers.getSigners();
	await deployAitn();
	await deployCryptoMachine([owner.address, addr1.address, addr2.address]);
}

main().then(() => process.exit(0)).catch((error) => {
	console.error(error);
	process.exit(1);
});

var aitn;
var cryptoMachine;
async function deployAitn() {
	const Aitn = await hre.ethers.getContractFactory("Aitn");
	aitn = await Aitn.deploy("AI crypto machine token", "AITN");
	await aitn.deployed();

	await console.log("aitn deployed to:", aitn.address);
	await console.log("config:", hre.network.config);
}

async function deployCryptoMachine(addrs) {
	const CryptoMachine = await hre.ethers.getContractFactory("CryptoMachine");
	cryptoMachine = await CryptoMachine.deploy("CryptoMachine", "AIMC", aitn.address);
	await cryptoMachine.deployed();

	await console.log("cryptoMachine deployed to:", cryptoMachine.address);
	await console.log("config:", hre.network.config);

	await console.log("账号:");
	await console.log(addrs);

//	await cryptoMachine.mint("robin0", "speakable", "google.com", 5, 1); // 创建AI
//	await cryptoMachine.getMachine(tokenId).then(r => {res = r});

//	console.log(await ethers.provider.getBlock());
//	await network.provider.send("evm_mine")
//	console.log(await ethers.provider.getBlock());

//	await cryptoMachine.mintPool(); // 创建矿池
//	await console.log("矿池:");
//	await cryptoMachine.getPools().then(console.log);

//	await mintMachines();

//	await getMachine(0).then(console.log);
//	await getMachine(1).then(console.log);
//	await getMachine(2).then(console.log);
//	await getMachine(3).then(console.log);

	/*
	await cryptoMachine.getMachines().then(r => {machines = r}); // 获取该地址下所有AI
		await cryptoMachine.joinPool(addrs[0], machines[0].tokenId); // 将AI加入矿池
		await cryptoMachine.transferFrom("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266", "0x70997970c51812dc3a010c7d01b50e0d17dc79c8", machines[1].tokenId); // 将AI转给其他钱包
		await cryptoMachine.joinPool("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266", machines[1].tokenId); // 将AI加入矿池

	
	await cryptoMachine.quitPool(1);
	await cryptoMachine.getPool().then(r => {res = r});
	for(let i = 0; i < res.length; i++) {
		await cryptoMachine.getMachine(res[i]).then(console.log);
	}
	*/

//	await cryptoMachine.getPool("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266").then(console.log); // 获取某个矿池下所有的AI, 参数为创建者钱包地址，也是矿池唯一标识
	/*
	for(let i = 0; i < machines.length; i++) {
		// 查看某个AI所在矿池，返回矿池创建者钱包地址，如果返回0x0000000000000000000000000000000000000000地址，说明没有加入任何矿池
		await cryptoMachine.whichPool(machines[i].tokenId).then(console.log);
	}
	*/

//	await cryptoMachine.balanceOf("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266").then(console.log);
	/*
	await cryptoMachine.getPoolLogs().then(r => {res = r});
	for(let i = 0; i < res.length; i++) {
		console.log(res[i].tokenId, res[i].timestamp, res[i].join);
	}
//	await cryptoMachine.validation(0).then(console.log);
	await cryptoMachine.quitPool(2);
	await cryptoMachine.getPoolLogs().then(r => {res = r});
	for(let i = 0; i < res.length; i++) {
		console.log(res[i].tokenId, res[i].timestamp, res[i].join);
	}
	*/
}

// 单元测试

async function mintMachines() {
	await cryptoMachine.mint("robin0", "speakable", "google.com", 5, 1); // 创建AI
	await cryptoMachine.mint("robin1", "speakable", "google.com", 5, 1); // 创建AI
	await cryptoMachine.mint("robin2", "speakable", "google.com", 5, 1); // 创建AI
}

async function mintMachinesN(n) {
	await cryptoMachine.mint("robin0", "speakable", "google.com", 5, 1, n); // 批量创建AI
}

async function getMachines(account) {
	await cryptoMachine.getMachinesFrom(account).then(r => {res = r});
	return res;
}


async function getMachine(tokenId) {
	await cryptoMachine.getMachine(tokenId).then(r => {res = r})
	return res;
}

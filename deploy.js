async function main() {
	await deployAitn();
	await deployCryptoMachine();
}

main().then(() => process.exit(0)).catch((error) => {
	console.error(error);
	process.exit(1);
});

var aitn;
async function deployAitn() {
	const Aitn = await hre.ethers.getContractFactory("Aitn");
	aitn = await Aitn.deploy("AI crypto machine token", "AITN");
	await aitn.deployed();

	await console.log("aitn deployed to:", aitn.address);
}

async function deployCryptoMachine(addrs) {
	const CryptoMachine = await hre.ethers.getContractFactory("CryptoMachine");
	const cryptoMachine = await CryptoMachine.deploy("CryptoMachine", "AIMC", aitn.address);
	await cryptoMachine.deployed();

	await console.log("cryptoMachine deployed to:", cryptoMachine.address);
}

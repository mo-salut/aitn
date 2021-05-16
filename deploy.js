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
	aitn = await upgrades.deployProxy(Aitn, ["Artificial Intelligence Technology Network", "AITN"]);

	await console.log("aitn deployed to:", aitn.address);
}

async function deployCryptoMachine(addrs) {
	const CryptoMachine = await hre.ethers.getContractFactory("CryptoMachine");
	const cryptoMachine = await upgrades.deployProxy(CryptoMachine, ["Crypto Machine", "AIMC", aitn.address]);

	await console.log("cryptoMachine deployed to:", cryptoMachine.address);
}

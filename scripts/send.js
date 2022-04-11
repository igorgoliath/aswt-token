const { ethers } = require("hardhat");
const provider = ethers.provider;
const token = require("../artifacts/@openzeppelin/contracts/token/ERC20/IERC20.sol/IERC20.json");

const TOKEN_ADDRESS = "0xeE0164F96850F9D0209d4D31B7Ea562E51f0f3b6";

async function main() {
    const [deployer] = await ethers.getSigners();

    let baseNonce = provider.getTransactionCount(deployer.address);
    let nonceOffset = 0;
  
    function getNonce() {
      return baseNonce.then((nonce) => (nonce + (nonceOffset++)));
    }
  
    console.log("Account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const contract = new ethers.Contract(TOKEN_ADDRESS, token.abi, provider);

    await contract.transfer(alici, amount * 20);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
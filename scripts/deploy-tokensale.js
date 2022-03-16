async function main() {
  let admin = '0xb06C23E4729615976378EF7A1699Ce6B79acD4f1';
  let tokenAddress = '0x3F50Ba973fD0B9a100fa7729630146E76CaD56A4';
  const Token = await ethers.getContractFactory('TokenSale');
  const contract = await Token.deploy(admin, tokenAddress);

  console.log('Contract deployed at:', contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

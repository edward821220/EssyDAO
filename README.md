# Easy DAO

[Website URL](https://easy-dao-beige.vercel.app/)

- DiamondFactory [Sepolia](https://sepolia.etherscan.io/address/0xd829336caE107E5Ae675976A8693024c4AAce061) | [Holesky](https://holesky.etherscan.io/address/0xd829336caE107E5Ae675976A8693024c4AAce061)
- DiamondCutFacet [Sepolia](https://sepolia.etherscan.io/address/0x9cE63b19cD81dfd19987428E504EB4798a96fF28) | [Holesky](https://holesky.etherscan.io/address/0x9cE63b19cD81dfd19987428E504EB4798a96fF28)
- DiamondLoupeFacet [Sepolia](https://sepolia.etherscan.io/address/0x520368386a2726422821773A32BE369e05e5e579) | [Holesky](https://holesky.etherscan.io/address/0x520368386a2726422821773A32BE369e05e5e579)
- DaoFacet [Sepolia](https://sepolia.etherscan.io/address/0x7Db2A483C84d4b49Da487E0E0fAe256Aa29e33C4) | [Holesky](https://holesky.etherscan.io/address/0x7Db2A483C84d4b49Da487E0E0fAe256Aa29e33C4)
- DaoInit [Sepolia](https://sepolia.etherscan.io/address/0x95F87F7c7120364c18F8d8c7c78A06B0C9C21d13) | [Holesky](https://holesky.etherscan.io/address/0x95F87F7c7120364c18F8d8c7c78A06B0C9C21d13)
- OwnershipFacet [Sepolia](https://sepolia.etherscan.io/address/0x16c16C6bB7548Cac5d0b45cfBC7fB559aBcc7030) | [Holesky](https://holesky.etherscan.io/address/0x16c16C6bB7548Cac5d0b45cfBC7fB559aBcc7030)
- OwnershipInit [Sepolia](https://sepolia.etherscan.io/address/0x9363313bf642b0648dF45b649B342ee3fDDF1b38) | [Holesky](https://holesky.etherscan.io/address/0x9363313bf642b0648dF45b649B342ee3fDDF1b38)
- DividendFacet [Sepolia](https://sepolia.etherscan.io/address/0xC1d94a2C3b3be8FC2970478b393f1549524aA9D7) | [Holesky](https://holesky.etherscan.io/address/0xC1d94a2C3b3be8FC2970478b393f1549524aA9D7)
- DividendInit [Sepolia](https://sepolia.etherscan.io/address/0x11148f6ABb7d6879d11eE037Ca47A0fBB82d855d) | [Holesky](https://holesky.etherscan.io/address/0x11148f6ABb7d6879d11eE037Ca47A0fBB82d855d)
- VaultFacet [Sepolia](https://sepolia.etherscan.io/address/0x75CeCF600f6C3Da7e663Cfb38Bb3A95AB0D8eF0D) | [Holesky](https://holesky.etherscan.io/address/0x75CeCF600f6C3Da7e663Cfb38Bb3A95AB0D8eF0D)
- VaultInit [Sepolia](https://sepolia.etherscan.io/address/0x9b5Bcb397C9429953E37143EADe9f7F7Bc3998B4) | [Holesky](https://holesky.etherscan.io/address/0x9b5Bcb397C9429953E37143EADe9f7F7Bc3998B4)
- Market [Sepolia](https://sepolia.etherscan.io/address/0x44536FE6e02928A7381776F2285Ef6155a3fFC4c) | [Holesky](https://holesky.etherscan.io/address/0x44536FE6e02928A7381776F2285Ef6155a3fFC4c)

## 1. Introduction

The Easy DAO project empowers users to effortlessly establish their own DAO (requiring a minimum of three participants). Subsequently, users can harness functionalities such as proposals and voting, enabling them to seamlessly experience the benefits of blockchain, including decentralization, transparency, and immutability.

In addition to the fundamental features mentioned earlier, each DAO can tailor additional functionalities to meet its specific needs. For example, if a trusted individual is preferred to manage specific functions, consider upgrading to the Ownership feature. For those aiming to distribute dividends to all governance token holders, upgrading to the Dividend feature is essential. Moreover, for those seeking to raise funds for larger endeavors and enable their DAO to support the receipt and transfer of NFTs and ERC20 tokens, the Vault feature is a key asset.

In summary, embark on the journey of decentralized decision-making and empowerment with us.

## 2. Contracts Architecture

![Architecture](https://github.com/edward821220/EssyDAO/assets/105776097/b8c1183c-4ea2-4747-90f5-e96fe9d93817)

### 2.1 Diamond Factory

The Factory contract serves as the initial interaction for users looking to create a DAO. To create a DAO, users need to provide parameters such as DAO name, token name, token symbol, founder data (a minimum of 3 individuals), and the initial token quantity for each founder. With these parameters, users can deploy a DAO contract through the Factory contract.

It's worth mentioning that the project owner will be the admin role of Factory contract during deployment. Subsequently, when each DAO has upgrade capabilities, 0.06 ETH will be transferred to the Factory contract. The project owner can execute the withdraw function to retrieve the funds.

![Create DAO](https://github.com/edward821220/EssyDAO/assets/105776097/654ff8a9-35f4-4bcd-8ae3-ad9926d64a1d)

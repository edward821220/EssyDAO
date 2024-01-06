# Easy DAO

[Website URL](https://easy-dao-beige.vercel.app/)

[Frontend Repo](https://github.com/edward821220/EasyDAO-web)

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

### 2.2 Diamond (DAO)

Each DAO is represented by a Diamond contract, which, by default, includes three logical contracts (Facets):

- DAO Facet:
  The DAO Facet provides functionalities for proposing and voting. It inherits from ERC20 snapshot, allowing it to record the historical state of tokens. When creating a proposal, the DAO Facet records the balance and total supply of the previous block, using these values as the basis for voting. Each voter's stake is determined by the formula: BalanceAtSnapshot / TotalSupplyAtSnapshot.

![Proposal and Vote](https://github.com/edward821220/EssyDAO/assets/105776097/ca630fd4-29b5-48e3-a370-b19a099b09b4)

- Diamond Loupe Facet:
  The Diamond Loupe Facet enables querying of the current Facets and available functions.

- Diamond Cut Facet:
  The Diamond Cut Facet empowers the addition and removal of Facets for the Diamond contract. It is a crucial contract that enables DAOs to upgrade their functionalities.

![Upgrade By Proposal](https://github.com/edward821220/EssyDAO/assets/105776097/5b886f07-e349-496e-8f31-641e69c93d72)

### 2.3 Optional Facets

After establishing a DAO, users can upgrade optional Facets through proposals:

- Ownership Facet:
  If there is a desire to appoint a person trusted by everyone as the Owner, upgrading this Facet allows future upgrades to be determined solely by the Owner, bypassing the proposal and voting process.

![Ownership Facet](https://github.com/edward821220/EssyDAO/assets/105776097/7dc496bc-65e5-47a9-baa5-139bf3328a62)

- Dividend Facet:
  To implement a dividend system for all governance token holders (organization members), this Facet can be upgraded. Users can set the annual interest rate and duration, and the system will adopt a linear release method. Holders can proportionally claim the amount available at that time. Similar to proposals, a snapshot is taken when executing this upgrade, and the total amount available for distribution is allocated based on the token quantities held at that time.

![Dividend Facet](https://github.com/edward821220/EssyDAO/assets/105776097/b948826b-d003-4a48-bc0d-3abb907d290a)

- Vault Facet:
  The original DAO lacks support for receiving any ERC20 and NFT functionalities. If tokens are accidentally transferred into the contract, they may become stuck. Upgrading the Vault Facet not only rescues trapped funds but also introduces fundraising capabilities. Users can crowdfund in ETH or ERC20 tokens to contribute to the growth of the organization.

![Vault Facet](https://github.com/edward821220/EssyDAO/assets/105776097/94b969b6-0cad-422c-a39d-0986084e2563)

### 2.4 Market

Most organizations are likely to be niche and may have limited liquidity. If you wish to give strangers the opportunity to join the organization or exchange governance tokens for ETH, you can utilize our provided market. This market allows you to either auction tokens to the highest bidder or sell them at a fixed price. It's also a great method for those who simply want to join the organization by contributing financially. Using the market is a viable option!

![Market](https://github.com/edward821220/EssyDAO/assets/105776097/4d8e69f6-04fd-42f6-a82a-0e5a32916751)

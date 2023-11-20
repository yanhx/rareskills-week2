- [ ]  **Markdown file 1:** Answer these questions
    - [ ]  How does ERC721A save gas?
    - [ ]  Where does it add cost?
- [ ]  **Markdown file 2:** Besides the examples listed in the code and the reading, what might the wrapped NFT pattern be used for?
- [ ]  **Markdown file 3:** Revisit the solidity events tutorial. How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable? Explain how you would accomplish this if you were creating an NFT marketplace

- [ ]  **Smart contract ecosystem 1:** Smart contract trio: NFT with merkle tree discount, ERC20 token, staking contract
    - [ ]  Create an ERC721 NFT with a supply of 1000.
    - [ ]  Include ERC 2918 royalty in your contract to have a reward rate of 2.5% for any NFT in the collection. Use the openzeppelin implementation.
    - [ ]  Addresses in a merkle tree can mint NFTs at a discount. Use the bitmap methodology described above. Use openzeppelin’s bitmap, don’t implement it yourself.
    - [ ]  Create an ERC20 contract that will be used to reward staking
    - [ ]  Create and a third smart contract that can mint new ERC20 tokens and receive ERC721 tokens. A classic feature of NFTs is being able to receive them to stake tokens. Users can send their NFTs and withdraw 10 ERC20 tokens every 24 hours. Don’t forget about decimal places! The user can withdraw the NFT at any time. The smart contract must take possession of the NFT and only the user should be able to withdraw it. **IMPORTANT**: your staking mechanism must follow the sequence in the video I recorded above (stake NFTs with safetransfer).
    - [ ]  Make the funds from the NFT sale in the contract withdrawable by the owner. Use Ownable2Step.
    - [ ]  **Important:** Use a combination of unit tests and the gas profiler in foundry or hardhat to measure the gas cost of the various operations.
- [ ]  **Smart contract ecosystem 2:** NFT Enumerable Contracts
    - [ ]  Create a new NFT collection with 20 items using ERC721Enumerable. The token ids should be [1..100] inclusive.
    - [ ]  Create a second smart contract that has a function which accepts an address and returns how many NFTs are owned by that address which have tokenIDs that are prime numbers. For example, if an address owns tokenIds 10, 11, 12, 13, it should return 2. In a real blockchain game, these would refer to special items, but we only care about the abstract functionality for this exercise. Don’t hardcode the prime values, this should work for numbers arbitrarily larger than 20. ****************************************************************************************************There is a lot of opportunity to gas optimize this routine. Read tricks in our gas optimization book:**************************************************************************************************** https://www.rareskills.io/post/gas-optimization
- [ ]  **CTFs**
    - [ ]  Solve solidity riddles Overmint1 ([link](https://github.com/RareSkills/solidity-riddles))
    - [ ]  Solve solidity riddles Overmint2 ([link](https://github.com/RareSkills/solidity-riddles))


# Coverage
| File                                     | % Lines          | % Statements     | % Branches      | % Funcs        |
|------------------------------------------|------------------|------------------|-----------------|----------------|
| src/EnumNFT.sol                          | 75.00% (3/4)     | 42.86% (3/7)     | 50.00% (2/4)    | 50.00% (1/2)   |
| src/MyNFT.sol                            | 100.00% (16/16)  | 100.00% (21/21)  | 100.00% (12/12) | 100.00% (5/5)  |
| src/PrimeCounter.sol                     | 80.00% (16/20)   | 77.42% (24/31)   | 66.67% (8/12)   | 100.00% (2/2)  |
| src/RewardToken.sol                      | 66.67% (2/3)     | 66.67% (2/3)     | 100.00% (0/0)   | 66.67% (2/3)   |
| src/StakingContract.sol                  | 86.67% (26/30)   | 82.86% (29/35)   | 70.00% (7/10)   | 85.71% (6/7)   |
| Total                                    | 90.00% (108/120) | 86.79% (138/159) | 70.83% (34/48)  | 85.71% (30/35) |
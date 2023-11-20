
# NFT Events

# **How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable?**

OpenSea should have a database that stores indexed NFT addresses. Perhaps it gathers all the info by monitoring the block or [etherscan.info](http://etherscan.info/) or other third-party services like Morails.

It is based on the NFT smart contract addresses and one owner address. When one NFT mints or transfers, the listeners involved with the transfer events on their service will be triggered. ERC721 dictates that whenever an NFT is transferred or minted (transferred from the zero-address) an event is emitted detailing the relevant info.

The demo code is below: tokenAddress is the NFT address, and filterAddress is the owner address. So when the event was triggered, the owner's NFT info can be rendered.

```solidity
const ethers = require('ethers');

const tokenAddress = '0x...';

const filterAddress = '0x...';

const abi = [
  "event Transfer(address indexed from, address indexed to, uint256 value)"
];

const tokenContract = new ethers.Contract(tokenAddress, tokenAbi, provider);

// this line filters for Trasnfer for a particular address.
const filter = tokenContract.filters.Transfer(filterAddress, null, null);

tokenContract.queryFilter(filter).then((events) => {
  console.log(events);
});
```

Suppose however that we *do not* have up-to-date records for some NFT collection of interest. We then may have to go back through ethereum history to the point where the minting begins and collect all relevant events from that point forward until we get caught up to the present.

# **Explain how you would accomplish this if you were creating an NFT marketplace?**

how to know the owner's latest NFT info?

One solution is maintaining a centralized service that should store all the NFT addresses and listen to the NFT transfer event just like Opensea. Each time the listening event was triggered, the related NFT info should be updated.

But this solution needs more resources, such as cloud service, databases, IT operators. Some other services, and maybe some of them are decentralized services that can listen to the events so we can integrate these services. Like subgraph, Moralis. However, reliability and consistency should also be considered in some circumstances.
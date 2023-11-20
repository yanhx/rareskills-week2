# ERC721A

# **How does ERC721A save gas?**

1. **Batch minting:** ERC721A allows for batch minting of multiple NFTs in a single transaction. This can save a significant amount of gas, as each individual mint operation incurs a gas cost.
    
    It updates owner's balance once per batch mint request instead of per minted NFT.
    
2. **Efficient storage:** ERC721A uses more efficient storage for token metadata when compared to ***ERC721 Enumerable***. This reduces the amount of gas needed to read and write metadata, which can be a significant cost for operations such as transferring or listing NFTs.
    
    Decreasing each token's write storage operations comparing the ERC721Enumerable. As we know, storage write operations are very expensive. ERC721Enumerable maintains allToken and ownerToken info, while ERC721A uses the bit info as far as possible.
    
3. **Reduced ownership updates:** ERC721A only updates the owner of an NFT once per batch mint operation, and the balance of NFTs an address owns. This can save gas, as each individual ownership update incurs a gas cost.
    
    It writes that address in ownership mapping just *once* in the case that multiple contiguous NFTs are owned.
    

# **Where does ERC721A add cost?**

1. **Initial deployment:** The ERC721A contract is more complex than the ERC721 contract, so it requires more gas to deploy.
    
    Contract size is larger.
    
2. **Enumerable implementation:** The ERC721A contract includes an enumerable implementation, which allows for efficient iteration over all of the NFTs in a collection. However, this implementation can add some gas cost, especially for large collections.

3. `transferFrom` and `safeTransferFrom` transactions cost more gas, which means it may cost more to gift or sell an ERC721A NFT after minting.
    
    Transferring a tokenID that does not have an explicit owner address set, the contract has to run a loop across all of the tokenIDs until it reaches the first NFT with an explicit owner address to find the owner that has the right to transfer it, and then set a new owner, thus modifying ownership state more than once to maintain correct groupings.
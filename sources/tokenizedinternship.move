module NFTMarket::SimpleMarketplace {
    use std::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::string::String;

    // Error codes
    const ENFT_ALREADY_LISTED: u64 = 1;
    const ENFT_NOT_LISTED: u64 = 2;
    const EINSUFFICIENT_FUNDS: u64 = 3;

    // Struct to represent a listed NFT
    struct ListedNFT has key, store {
        creator: address,
        price: u64,
        name: String,
        is_listed: bool
    }

    // Struct to track marketplace state
    struct MarketplaceData has key {
        listings_count: u64
    }

    // List an NFT for sale
    public fun list_nft(
        seller: &signer,
        nft_name: String,
        price: u64
    ) {
        let seller_addr = signer::address_of(seller);
        
        let nft = ListedNFT {
            creator: seller_addr,
            price,
            name: nft_name,
            is_listed: true
        };
        
        // Move the NFT to seller's account
        move_to(seller, nft);
    }

    // Buy a listed NFT
    public fun buy_nft(
        buyer: &signer,
        seller_addr: address
    ) acquires ListedNFT {
        let nft = borrow_global_mut<ListedNFT>(seller_addr);
        assert!(nft.is_listed, ENFT_NOT_LISTED);
        
        // Transfer payment
        let payment = coin::withdraw<AptosCoin>(buyer, nft.price);
        coin::deposit(seller_addr, payment);
        
        // Update NFT status
        nft.is_listed = false;
    }
}
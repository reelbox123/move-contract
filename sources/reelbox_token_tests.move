#[test_only]
module reelbox::reelbox_token_tests {
    use std::signer;
    use aptos_framework::account;
    use aptos_framework::coin;
    use reelbox::reelbox_token;

    // Test helper function to create a test account
    fun create_test_account(): signer {
        account::create_account_for_test(@0x1)
    }

    #[test]
    fun test_initialize() {
        let admin = create_test_account();
        reelbox_token::initialize(&admin);
        
        assert!(coin::is_coin_initialized<reelbox_token::ReelboxToken>(), 0);
        assert!(coin::name<reelbox_token::ReelboxToken>() == std::string::utf8(b"Reelbox Token"), 1);
        assert!(coin::symbol<reelbox_token::ReelboxToken>() == std::string::utf8(b"REELBOX"), 2);
        assert!(coin::decimals<reelbox_token::ReelboxToken>() == 6, 3);
    }

    #[test]
    fun test_mint() {
        let admin = create_test_account();
        let user = create_test_account();
        
        reelbox_token::initialize(&admin);
        
        let user_address = signer::address_of(&user);
        reelbox_token::mint(&user, 1000000); // Mint 1 REELBOX token (considering 6 decimals)
        
        assert!(coin::balance<reelbox_token::ReelboxToken>(user_address) == 1000000, 4);
    }

    #[test]
    fun test_transfer() {
        let admin = create_test_account();
        let user1 = create_test_account();
        let user2 = create_test_account();
        
        reelbox_token::initialize(&admin);
        
        let user1_address = signer::address_of(&user1);
        let user2_address = signer::address_of(&user2);
        
        reelbox_token::mint(&user1, 2000000); // Mint 2 REELBOX tokens
        reelbox_token::transfer(&user1, user2_address, 1000000); // Transfer 1 REELBOX token
        
        assert!(coin::balance<reelbox_token::ReelboxToken>(user1_address) == 1000000, 5);
        assert!(coin::balance<reelbox_token::ReelboxToken>(user2_address) == 1000000, 6);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = aptos_framework::coin)]
    fun test_transfer_insufficient_balance() {
        let admin = create_test_account();
        let user1 = create_test_account();
        let user2 = create_test_account();
        
        reelbox_token::initialize(&admin);
        
        let user2_address = signer::address_of(&user2);
        
        reelbox_token::mint(&user1, 500000); // Mint 0.5 REELBOX tokens
        reelbox_token::transfer(&user1, user2_address, 1000000); // Try to transfer 1 REELBOX token
    }
}

module reelbox::reelbox_token {
    use std::string;
    use std::signer;
    use aptos_framework::coin;
    use aptos_framework::account;

    struct ReelboxToken {}

    struct Capabilities has key {
        burn_cap: coin::BurnCapability<ReelboxToken>,
        freeze_cap: coin::FreezeCapability<ReelboxToken>,
        mint_cap: coin::MintCapability<ReelboxToken>,
    }

    const DECIMALS: u8 = 6;

    public fun initialize(account: &signer) {
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<ReelboxToken>(
            account,
            string::utf8(b"Reelbox Token"),
            string::utf8(b"REELBOX"),
            DECIMALS,
            true
        );

        move_to(account, Capabilities {
            burn_cap,
            freeze_cap,
            mint_cap,
        });
    }

    public entry fun mint(account: &signer, amount: u64) acquires Capabilities {
        let capabilities = borrow_global<Capabilities>(@reelbox);
        let coins = coin::mint(amount, &capabilities.mint_cap);
        coin::deposit(signer::address_of(account), coins);
    }

    public entry fun transfer(from: &signer, to: address, amount: u64) {
        coin::transfer<ReelboxToken>(from, to, amount);
    }

    // Additional functions for burning tokens, checking balances, etc.
}
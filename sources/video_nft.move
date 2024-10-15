module reelbox::video_nft {
    use std::signer;
    use std::string::{Self, String};
    use std::option;
    use aptos_framework::object::{Self, Object};
    use aptos_framework::timestamp;
    use aptos_token_objects::collection;
    use aptos_token_objects::token;
    use aptos_token_objects::royalty;

    const COLLECTION_NAME: vector<u8> = b"Reelbox Videos";
    const COLLECTION_DESCRIPTION: vector<u8> = b"A collection of video NFTs on Reelbox";
    const COLLECTION_URI: vector<u8> = b"https://reelbox.com/collection";
    const MAXIMUM_SUPPLY: u64 = 1000000; // Adjust as needed

    struct VideoNFTCollection has key {
        video_tokens: Object<token::Token>,
    }

    public fun initialize_collection(creator: &signer) {
        collection::create_fixed_collection(
            creator,
            string::utf8(COLLECTION_DESCRIPTION),
            MAXIMUM_SUPPLY,
            string::utf8(COLLECTION_NAME),
            option::none<royalty::Royalty>(),
            string::utf8(COLLECTION_URI),
        );
    }

    public entry fun create_video_nft(
        creator: &signer,
        name: String,
        description: String,
        uri: String,
    ) {
        let token_constructor_ref = token::create_named_token(
            creator,
            string::utf8(COLLECTION_NAME),
            description,
            name,
            option::none(),
            uri,
        );

        let token_signer = object::generate_signer(&token_constructor_ref);
        let token = object::object_from_constructor_ref<token::Token>(&token_constructor_ref);

        move_to(
            &token_signer,
            VideoNFTCollection {
                video_tokens: token,
            }
        );
    }

    #[view]
    public fun get_token_name(token: Object<token::Token>): String {
        token::name(token)
    }

    #[view]
    public fun get_token_description(token: Object<token::Token>): String {
        token::description(token)
    }

    #[view]
    public fun get_token_uri(token: Object<token::Token>): String {
        token::uri(token)
    }
}
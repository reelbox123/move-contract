#[test_only]
module reelbox::app_operations_tests {
    use std::signer;
    use std::string;
    use aptos_framework::account;
    use aptos_framework::timestamp;
    use reelbox::app_operations;
    use reelbox::reelbox_token;
    use reelbox::video_nft;

    // Test helper function to create a test account
    fun create_test_account(): signer {
        account::create_account_for_test(@0x1)
    }

    #[test]
    fun test_initialize() {
        let admin = create_test_account();
        app_operations::initialize(&admin);
        // Add assertions to check if the AppState is properly initialized
    }

    #[test]
    fun test_upload_video() {
        let admin = create_test_account();
        let user = create_test_account();
        
        // Initialize the app and token
        app_operations::initialize(&admin);
        reelbox_token::initialize(&admin);
        
        // Set up timestamp for testing
        timestamp::set_time_has_started_for_testing(&admin);
        
        // Upload a video
        app_operations::upload_video(&user, string::utf8(b"Test Video"), string::utf8(b"Description"), string::utf8(b"content_uri"));
        
        // Add assertions to check if the video was uploaded correctly and rewards were given
    }

    #[test]
    fun test_like_video() {
        let admin = create_test_account();
        let creator = create_test_account();
        let liker = create_test_account();
        
        // Initialize the app and token
        app_operations::initialize(&admin);
        reelbox_token::initialize(&admin);
        
        // Set up timestamp for testing
        timestamp::set_time_has_started_for_testing(&admin);
        
        // Upload a video
        app_operations::upload_video(&creator, string::utf8(b"Test Video"), string::utf8(b"Description"), string::utf8(b"content_uri"));
        
        // Like the video
        app_operations::like_video(&liker, 1);
        
        // Add assertions to check if the like was recorded and rewards were given
    }

    #[test]
    fun test_comment_on_video() {
        let admin = create_test_account();
        let creator = create_test_account();
        let commenter = create_test_account();
        
        // Initialize the app and token
        app_operations::initialize(&admin);
        reelbox_token::initialize(&admin);
        
        // Set up timestamp for testing
        timestamp::set_time_has_started_for_testing(&admin);
        
        // Upload a video
        app_operations::upload_video(&creator, string::utf8(b"Test Video"), string::utf8(b"Description"), string::utf8(b"content_uri"));
        
        // Comment on the video
        app_operations::comment_on_video(&commenter, 1, string::utf8(b"Great video!"));
        
        // Add assertions to check if the comment was added and rewards were given
    }
}

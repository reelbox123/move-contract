module reelbox::app_operations {
    use std::string;
    use std::signer;
    use aptos_framework::account;
    use aptos_framework::timestamp;
    use aptos_std::table::{Self, Table};
    use reelbox::reelbox_token;
    use reelbox::video_nft;

    struct AppState has key {
        videos: Table<u64, VideoInfo>,
        comments: Table<u64, Table<u64, Comment>>,
        likes: Table<u64, Table<address, bool>>,
        video_count: u64,
        comment_count: u64,
    }

    struct VideoInfo has store {
        creator: address,
        timestamp: u64,
        like_count: u64,
        comment_count: u64,
    }

    struct Comment has store, drop {
        author: address,
        content: string::String,
        timestamp: u64,
    }

    const UPLOAD_REWARD: u64 = 100 * 1000000; // 100 tokens
    const LIKE_REWARD: u64 = 1 * 1000000; // 1 token
    const COMMENT_REWARD: u64 = 5 * 1000000; // 5 tokens

    public fun initialize(account: &signer) {
        let app_state = AppState {
            videos: table::new(),
            comments: table::new(),
            likes: table::new(),
            video_count: 0,
            comment_count: 0,
        };
        move_to(account, app_state);
    }

    public entry fun upload_video(account: &signer, title: string::String, description: string::String, content_uri: string::String) acquires AppState {
        let app_state = borrow_global_mut<AppState>(@reelbox);
        let video_id = app_state.video_count + 1;

        // Mint the video NFT
        video_nft::create_video_nft(account, title, description, content_uri);

        // Store video info
        table::add(&mut app_state.videos, video_id, VideoInfo {
            creator: signer::address_of(account),
            timestamp: timestamp::now_seconds(),
            like_count: 0,
            comment_count: 0,
        });

        // Initialize comments and likes tables for this video
        table::add(&mut app_state.comments, video_id, table::new());
        table::add(&mut app_state.likes, video_id, table::new());

        app_state.video_count = video_id;

        // Reward the creator
        reelbox_token::mint(account, UPLOAD_REWARD);
    }

    public entry fun like_video(account: &signer, video_id: u64) acquires AppState {
        let app_state = borrow_global_mut<AppState>(@reelbox);
        let video_info = table::borrow_mut(&mut app_state.videos, video_id);
        let likes = table::borrow_mut(&mut app_state.likes, video_id);
        let user_address = signer::address_of(account);

        assert!(!table::contains(likes, user_address), 1); // User hasn't liked this video before

        table::add(likes, user_address, true);
        video_info.like_count = video_info.like_count + 1;

        // Reward the user for liking
        reelbox_token::mint(account, LIKE_REWARD);
    }

    public entry fun comment_on_video(account: &signer, video_id: u64, content: string::String) acquires AppState {
        let app_state = borrow_global_mut<AppState>(@reelbox);
        let video_info = table::borrow_mut(&mut app_state.videos, video_id);
        let comments = table::borrow_mut(&mut app_state.comments, video_id);

        let comment_id = app_state.comment_count + 1;
        table::add(comments, comment_id, Comment {
            author: signer::address_of(account),
            content,
            timestamp: timestamp::now_seconds(),
        });

        video_info.comment_count = video_info.comment_count + 1;
        app_state.comment_count = comment_id;

        // Reward the user for commenting
        reelbox_token::mint(account, COMMENT_REWARD);
    }

    // Additional functions for querying video info, comments, etc.
}
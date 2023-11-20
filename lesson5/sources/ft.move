module lesson5::FT_TOKEN {
    use std::option;
    use std::string;
    use std::ascii;
    use 0x2::url;
    use sui::coin::{Self, Coin, CoinMetadata, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::event;
    use sui::pay;


    struct FT_TOKEN has drop {}

    fun init(witness: FT_TOKEN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<FT_TOKEN>(witness, 3, b"FTT", b"FT_TOKEN", b"", option::none(), ctx);
        transfer::public_transfer(metadata, tx_context::sender(ctx));
        transfer::public_share_object(treasury_cap);
    }

    public entry fun mint(_: &CoinMetadata<FT_TOKEN>, treasury_cap: &mut TreasuryCap<FT_TOKEN>, recipient: address, ctx: &mut TxContext) {
        let amount = 10_000_000;
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx);
    }

    public entry fun burn(treasury_cap: &mut TreasuryCap<FT_TOKEN>, coin: Coin<FT_TOKEN>) {
        coin::burn(treasury_cap, coin);
    }

    public entry fun transfer_coin_owner(metadata: CoinMetadata<FT_TOKEN>, recipient: address) {
        transfer::public_transfer(metadata, recipient);
    }

    public fun split_token(token: &mut Coin<FT_TOKEN>, split_amount: u64, ctx: &mut TxContext): Coin<FT_TOKEN> {
        coin::split(token, split_amount, ctx)
    }

    public entry fun split_vec_token(token: &mut Coin<FT_TOKEN>, amount: vector<u64>, ctx: &mut TxContext) {
        pay::split_vec<FT_TOKEN>(token, amount, ctx);
    }

    public entry fun transfer_token(token: Coin<FT_TOKEN>, recipient: address) {
        transfer::public_transfer(token, recipient);
    }

    // EVENT
    struct UpdateEvent<T> has copy, drop {
        success: bool,
        data: T
    }

    // UPDATE
    public entry fun update_name(metadata: &mut CoinMetadata<FT_TOKEN>, treasury_cap: &mut TreasuryCap<FT_TOKEN>, new_name: string::String) {
        coin::update_name<FT_TOKEN>(treasury_cap, metadata, new_name);
        event::emit(UpdateEvent {
            success: true,
            data: new_name
        })
    }
    public entry fun update_description(metadata: &mut CoinMetadata<FT_TOKEN>, treasury_cap: &mut TreasuryCap<FT_TOKEN>, new_description: string::String) {
        coin::update_description<FT_TOKEN>(treasury_cap, metadata, new_description);
        event::emit(UpdateEvent {
            success: true,
            data: new_description
        })
    }
    public entry fun update_symbol(metadata: &mut CoinMetadata<FT_TOKEN>, treasury_cap: &mut TreasuryCap<FT_TOKEN>, new_symbol: ascii::String) {
        coin::update_symbol<FT_TOKEN>(treasury_cap, metadata, new_symbol);
        event::emit(UpdateEvent {
            success: true,
            data: new_symbol
        })
    }
    public entry fun update_icon_url(metadata: &mut CoinMetadata<FT_TOKEN>, treasury_cap: &mut TreasuryCap<FT_TOKEN>, new_icon_url: ascii::String) {
        coin::update_icon_url<FT_TOKEN>(treasury_cap, metadata, new_icon_url);
        event::emit(UpdateEvent {
            success: true,
            data: new_icon_url
        })
    }

    // GET
    public fun get_token_name(metadata: &mut CoinMetadata<FT_TOKEN>): string::String {
        coin::get_name<FT_TOKEN>(metadata)
    }
    public fun get_token_description(metadata: &mut CoinMetadata<FT_TOKEN>): string::String {
        coin::get_description<FT_TOKEN>(metadata)
    }
    public fun get_token_symbol(metadata: &mut CoinMetadata<FT_TOKEN>): ascii::String {
        coin::get_symbol<FT_TOKEN>(metadata)
    }
    public fun get_token_icon_url(metadata: &mut CoinMetadata<FT_TOKEN>): option::Option<url::Url> {
        coin::get_icon_url<FT_TOKEN>(metadata)
    }
}
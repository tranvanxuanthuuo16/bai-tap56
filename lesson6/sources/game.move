module lesson6::hero_game {
    use std::option::{Self, Option};
    use std::string::String;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::transfer;
    use sui::event;
    use lesson6::random::rand_u64_range;

    struct Hero has key, store {
        id: UID,
        name: String,
        hp: u64,
        experience: u64,
        sword: Option<Sword>,
        armor: Option<Armor>,
        game_id: ID
    }

    struct Sword  has key, store {
        id: UID,
        strenght: u64,
        game_id: ID
    }

    struct Armor has key, store {
        id: UID,
        defense: u64,
        game_id: ID
    }

    struct Monter has key, store{
        id: UID,
        hp: u64,
        strenght: u64,
        game_id: ID
    }

    struct GameInfo has key {
        id: UID,
        admin: address
    }

    struct GameAdmin has key {
        id: UID,
        game_id: ID,
        monters: u64
    }

    fun new_game(ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let id = object::new(ctx);
        let game_id = object::uid_to_inner(&id);
        transfer::freeze_object(GameInfo {
            id,
            admin: sender
        });
        transfer::transfer(GameAdmin {
            id: object::new(ctx),
            game_id,
            monters: 0
        }, sender);
    }

    fun init(ctx: &mut TxContext) {
        new_game(ctx);
    }

    public fun get_game_id(gameinfo: &GameInfo): ID {
        object::id(gameinfo)
    }

    public fun create_hero(game: &GameInfo, name: String, sword: Sword, armor: Armor, ctx: &mut TxContext): Hero {
        Hero {
            id: object::new(ctx),
            name,
            hp: 100,
            experience: 0,
            sword: option::some(sword),
            armor: option::some(armor),
            game_id: get_game_id(game)
        }
    }

    /// Price for Sword
    const SWORD_PRICE: u64 = 1;
    /// Price for Armor
    const ARMOR_PRICE: u64 = 1;
    /// Not enough funds to pay for the good in question
    const EInsufficientFunds: u64 = 0;

    public fun total_sword_strength(sword: &Sword): u64 {
        sword.strenght
    }

    public fun total_armor_defense(armor: &Armor): u64 {
        armor.defense
    }

    public fun hero_strength(hero: &Hero): u64 {
        let strenght = if (option::is_some(&hero.sword)) {
            total_sword_strength(option::borrow(&hero.sword))
        } else {
            0
        };
        strenght
    }

    public fun hero_hp(hero: &Hero): u64 {
        let hp = if (option::is_some(&hero.armor)) {
            hero.hp + total_armor_defense(option::borrow(&hero.armor))
        } else {
            hero.hp
        };
        hp
    }

    public fun create_sword(game: &GameInfo, payment: Coin<SUI>, ctx: &mut TxContext): Sword {
        let value = coin::value(&payment);
        assert!(value >= SWORD_PRICE, EInsufficientFunds);
        transfer::public_transfer(payment, game.admin);
        let strenght = rand_u64_range(10, 20, ctx);
        Sword {
            id: object::new(ctx),
            strenght,
            game_id: get_game_id(game)
        }
    }

    public fun create_armor(game: &GameInfo, payment: Coin<SUI>, ctx: &mut TxContext): Armor {
        let value = coin::value(&payment);
        assert!(value >= ARMOR_PRICE, EInsufficientFunds);
        transfer::public_transfer(payment, game.admin);
        let defense = rand_u64_range(10, 20, ctx);
        Armor {
            id: object::new(ctx),
            defense,
            game_id: get_game_id(game)
        }
    }

    public entry fun create_monter(admin: &mut GameAdmin, game: &GameInfo, hp: u64, strenght: u64, player: address, ctx: &mut TxContext) {
        admin.monters = admin.monters + 1;
        transfer::transfer(Monter {
            id: object::new(ctx),
            hp,
            strenght,
            game_id: get_game_id(game)
        }, player);
    }

    fun level_up_hero(hero: &mut Hero, amount: u64) {
        hero.hp = 100;
        hero.experience = hero.experience + amount;
    }
    fun level_up_sword(sword: &mut Sword, amount: u64) {
        sword.strenght = sword.strenght + amount;
    }
    fun level_up_armor(armor: &mut Armor, amount: u64) {
        armor.defense = armor.defense + amount;
    }



    const MONTER_WON: u64 = 1;

    struct AttackedEvent has copy, drop {
        player: address,
        hero: ID,
        monter: ID,
        game_id: ID
    }

    public entry fun attack(game: &GameInfo, hero: &mut Hero, monter: Monter, ctx: &mut TxContext) {
        let Monter {id: monter_id, hp: monter_hp, strenght: monter_strength, game_id: _} = monter;
        let hero_hp = hero_hp(hero);
        let hero_strength = hero_strength(hero);

        while (monter_hp > 0 || hero_hp > 0) {
            monter_hp = monter_hp - hero_strength;
            hero_hp = hero_hp - monter_strength;
            assert!(hero_hp > 0, MONTER_WON);
        };

        hero.hp = hero_hp;
        hero.experience = hero.experience + monter_strength;
        if (option::is_some(&hero.sword)) {
            level_up_sword(option::borrow_mut(&mut hero.sword), 2);
        };

        event::emit(AttackedEvent {
            player: tx_context::sender(ctx),
            hero: object::uid_to_inner(&hero.id),
            monter: object::uid_to_inner(&monter_id),
            game_id: get_game_id(game)
        });
        object::delete(monter_id);
    }
}
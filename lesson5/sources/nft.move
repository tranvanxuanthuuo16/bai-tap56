module lesson5::discount_coupon {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::event;

    struct DiscountCoupon has key {
        id: UID,
        owner: address,
        discount: u8,
        expiration: u64,
    }

    struct ManagerCap has key {
        id: UID
    }

    const WRONG_DISCOUNT_VALUE: u64 = 0;
    const WRONG_DISCOUNT_OWNER: u64 = 1;

    fun init(ctx: &mut TxContext) {
        let manager = ManagerCap {
            id: object::new(ctx)
        };
        transfer::transfer(manager, tx_context::sender(ctx));
    }

    public entry fun mint_and_topup(_: &ManagerCap, discount: u8, expiration: u64, recipient: address, ctx: &mut TxContext,) {
        assert!(discount > 0 && discount <= 100, WRONG_DISCOUNT_VALUE);
        let coupon = DiscountCoupon {
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            discount,
            expiration
        };
        transfer::transfer(coupon, recipient);
    }

    public entry fun transfer_coupon(coupon: DiscountCoupon, recipient: address) {
        transfer::transfer(coupon, recipient);
    }

    public entry fun burn(coupon: DiscountCoupon) {
        let DiscountCoupon {id, owner: _, discount: _, expiration: _} = coupon;
        object::delete(id);
    }

    public fun owner(coupon: &DiscountCoupon): address {
        coupon.owner
    }

    public fun discount(coupon: &DiscountCoupon): u8 {
        coupon.discount
    }

    // EVENT
    struct ScanEvent<T> has copy, drop {
        success: bool,
        discount: T
    }

    public entry fun scan(coupon: DiscountCoupon, owner: address) {
        let DiscountCoupon {id, owner: coupon_owner, discount: coupon_discount, expiration: coupon_expriration} = coupon;
        //burn(coupon);
        object::delete(id); //BURN
    }
}

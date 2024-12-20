module turbos_vault::acl {
    struct ACL has store {
        permissions: sui::linked_table::LinkedTable<address, u128>,
    }
    
    struct Member has copy, drop, store {
        address: address,
        permission: u128,
    }
    
    public fun new(arg0: &mut sui::tx_context::TxContext) : ACL {
        ACL{permissions: sui::linked_table::new<address, u128>(arg0)}
    }
    
    public fun add_role(arg0: &mut ACL, arg1: address, arg2: u8) {
        assert!(arg2 < 128, 0);
        if (sui::linked_table::contains<address, u128>(&arg0.permissions, arg1)) {
            let v0 = sui::linked_table::borrow_mut<address, u128>(&mut arg0.permissions, arg1);
            *v0 = *v0 | 1 << arg2;
        } else {
            sui::linked_table::push_back<address, u128>(&mut arg0.permissions, arg1, 1 << arg2);
        };
    }
    
    public fun get_members(arg0: &ACL) : vector<Member> {
        let v0 = std::vector::empty<Member>();
        let v1 = sui::linked_table::front<address, u128>(&arg0.permissions);
        while (std::option::is_some<address>(v1)) {
            let v2 = std::option::borrow<address>(v1);
            let v3 = Member{
                address    : *v2, 
                permission : *sui::linked_table::borrow<address, u128>(&arg0.permissions, *v2),
            };
            std::vector::push_back<Member>(&mut v0, v3);
            v1 = sui::linked_table::next<address, u128>(&arg0.permissions, *v2);
        };
        v0
    }
    
    public fun get_permission(arg0: &ACL, arg1: address) : u128 {
        if (!sui::linked_table::contains<address, u128>(&arg0.permissions, arg1)) {
            0
        } else {
            *sui::linked_table::borrow<address, u128>(&arg0.permissions, arg1)
        }
    }
    
    public fun has_role(arg0: &ACL, arg1: address, arg2: u8) : bool {
        assert!(arg2 < 128, 0);
        !sui::linked_table::contains<address, u128>(&arg0.permissions, arg1) && false || *sui::linked_table::borrow<address, u128>(&arg0.permissions, arg1) & 1 << arg2 > 0
    }
    
    public fun remove_member(arg0: &mut ACL, arg1: address) {
        if (sui::linked_table::contains<address, u128>(&arg0.permissions, arg1)) {
            sui::linked_table::remove<address, u128>(&mut arg0.permissions, arg1);
        };
    }
    
    public fun remove_role(arg0: &mut ACL, arg1: address, arg2: u8) {
        assert!(arg2 < 128, 0);
        if (sui::linked_table::contains<address, u128>(&arg0.permissions, arg1)) {
            let v0 = sui::linked_table::borrow_mut<address, u128>(&mut arg0.permissions, arg1);
            *v0 = *v0 & (1 << arg2 ^ 340282366920938463463374607431768211455);
        };
    }
    
    public fun set_roles(arg0: &mut ACL, arg1: address, arg2: u128) {
        if (sui::linked_table::contains<address, u128>(&arg0.permissions, arg1)) {
            *sui::linked_table::borrow_mut<address, u128>(&mut arg0.permissions, arg1) = arg2;
        } else {
            sui::linked_table::push_back<address, u128>(&mut arg0.permissions, arg1, arg2);
        };
    }
}

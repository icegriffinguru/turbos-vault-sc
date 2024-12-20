module turbos_vault::config {
    friend turbos_vault::router;

    ////////////////////////////////////////////////
    /// Structs
    ////////////////////////////////////////////////
    
    struct AdminCap has store, key {
        id: sui::object::UID,
    }
    
    struct OperatorCap has key {
        id: sui::object::UID,
    }
    
    struct Tier has copy, drop, store {
        rebate: u64,
        discount: u64,
    }
    
    struct GlobalConfig has store, key {
        id: sui::object::UID,
        acl: turbos_vault::acl::ACL,
        package_version: u64,
        user_tiers: sui::vec_map::VecMap<address, Tier>,
    }
    
    struct UserTierConfig has store, key {
        id: sui::object::UID,
        user_tiers: sui::table::Table<address, Tier>,
    }
    
    ////////////////////////////////////////////////
    /// Events
    ////////////////////////////////////////////////
    
    struct InitConfigEvent has copy, drop {
        admin_cap_id: sui::object::ID,
        global_config_id: sui::object::ID,
    }
    
    struct AddOperatorEvent has copy, drop {
        operator_cap_id: sui::object::ID,
        recipient: address,
        roles: u128,
    }
    
    struct SetRolesEvent has copy, drop {
        member: address,
        roles: u128,
    }
    
    struct AddRoleEvent has copy, drop {
        member: address,
        role: u8,
    }
    
    struct RemoveRoleEvent has copy, drop {
        member: address,
        role: u8,
    }
    
    struct RemoveMemberEvent has copy, drop {
        member: address,
    }
    
    struct SetPackageVersion has copy, drop {
        new_version: u64,
        old_version: u64,
    }
    
    struct SetTierEvent has copy, drop {
        user: address,
        rebate: u64,
        discount: u64,
    }
    
    struct InitUserTierConfigEvent has copy, drop {
        admin_cap_id: sui::object::ID,
        user_tier_config_id: sui::object::ID,
    }
    
    ////////////////////////////////////////////////
    /// Functions
    ////////////////////////////////////////////////

    fun init(ctx: &mut sui::tx_context::TxContext) {
        let admin_cap = AdminCap{id: sui::object::new(ctx)};
        let global_config = GlobalConfig{
            id              : sui::object::new(ctx), 
            acl             : turbos_vault::acl::new(ctx), 
            package_version : 1, 
            user_tiers      : sui::vec_map::empty<address, Tier>(),
        };
        let admin_cap_id = sui::object::id<AdminCap>(&admin_cap);
        let global_config_id = sui::object::id<GlobalConfig>(&global_config);
        sui::transfer::public_transfer<AdminCap>(admin_cap, sui::tx_context::sender(ctx));
        sui::transfer::public_share_object<GlobalConfig>(global_config);
        let event = InitConfigEvent{
            admin_cap_id     : admin_cap_id, 
            global_config_id : global_config_id,
        };
        sui::event::emit<InitConfigEvent>(event);
    }

    public(friend) fun add_role(_: &AdminCap, arg1: &mut GlobalConfig, arg2: address, arg3: u8) {
        checked_package_version(arg1);
        turbos_vault::acl::add_role(&mut arg1.acl, arg2, arg3);
        let v0 = AddRoleEvent{
            member : arg2, 
            role   : arg3,
        };
        sui::event::emit<AddRoleEvent>(v0);
    }
    
    public fun get_members(arg0: &GlobalConfig) : vector<turbos_vault::acl::Member> {
        turbos_vault::acl::get_members(&arg0.acl)
    }
    
    public(friend) fun remove_member(_: &AdminCap, arg1: &mut GlobalConfig, arg2: address) {
        checked_package_version(arg1);
        turbos_vault::acl::remove_member(&mut arg1.acl, arg2);
        let v0 = RemoveMemberEvent{member: arg2};
        sui::event::emit<RemoveMemberEvent>(v0);
    }
    
    public(friend) fun remove_role(_: &AdminCap, arg1: &mut GlobalConfig, arg2: address, arg3: u8) {
        checked_package_version(arg1);
        turbos_vault::acl::remove_role(&mut arg1.acl, arg2, arg3);
        let v0 = RemoveRoleEvent{
            member : arg2, 
            role   : arg3,
        };
        sui::event::emit<RemoveRoleEvent>(v0);
    }
    
    public(friend) fun set_roles(_: &AdminCap, arg1: &mut GlobalConfig, arg2: address, arg3: u128) {
        checked_package_version(arg1);
        turbos_vault::acl::set_roles(&mut arg1.acl, arg2, arg3);
        let v0 = SetRolesEvent{
            member : arg2, 
            roles  : arg3,
        };
        sui::event::emit<SetRolesEvent>(v0);
    }
    
    public(friend) fun add_operator(
        _: &AdminCap,
        arg1: &mut GlobalConfig,
        arg2: u128,
        arg3: address,
        arg4: &mut sui::tx_context::TxContext
    ) {
        checked_package_version(arg1);
        let v0 = OperatorCap{id: sui::object::new(arg4)};
        let operator_cap_id = sui::object::id<OperatorCap>(&v0);
        turbos_vault::acl::set_roles(&mut arg1.acl, sui::object::id_address<OperatorCap>(&v0), arg2);
        sui::transfer::transfer<OperatorCap>(v0, arg3);
        let v1 = AddOperatorEvent{
            operator_cap_id : operator_cap_id, 
            recipient       : arg3, 
            roles           : arg2,
        };
        sui::event::emit<AddOperatorEvent>(v1);
    }
    
    public fun check_rebalance_manager_role(arg0: &GlobalConfig, arg1: address) {
        assert!(turbos_vault::acl::has_role(&arg0.acl, arg1, 2), 3);
    }
    
    public fun check_reward_manager_role(arg0: &GlobalConfig, arg1: address) {
        assert!(turbos_vault::acl::has_role(&arg0.acl, arg1, 1), 2);
    }
    
    public fun check_vault_manager_role(arg0: &GlobalConfig, arg1: address) {
        assert!(turbos_vault::acl::has_role(&arg0.acl, arg1, 0), 1);
    }
    
    public fun checked_package_version(arg0: &GlobalConfig) {
        assert!(arg0.package_version == 3, 0);
    }
    
    // public fun get_tier(arg0: &GlobalConfig, arg1: address) : (u64, u64) {
    //     abort 0
    // }
    
    public fun get_tier_v2(arg0: &GlobalConfig, arg1: &mut UserTierConfig, arg2: address) : (u64, u64) {
        checked_package_version(arg0);
        if (sui::table::contains<address, Tier>(&arg1.user_tiers, arg2)) {
            let v2 = sui::table::borrow<address, Tier>(&arg1.user_tiers, arg2);
            (v2.rebate, v2.discount)
        } else {
            (0, 0)
        }
    }
    
    public(friend) fun new_user_tier_config(admin_cap: &AdminCap, arg1: &mut sui::tx_context::TxContext) {
        let v0 = UserTierConfig{
            id         : sui::object::new(arg1), 
            user_tiers : sui::table::new<address, Tier>(arg1),
        };
        let user_tier_config_id = sui::object::id<UserTierConfig>(&v0);
        sui::transfer::public_share_object<UserTierConfig>(v0);
        let event = InitUserTierConfigEvent{
            admin_cap_id        : sui::object::id<AdminCap>(admin_cap), 
            user_tier_config_id : user_tier_config_id,
        };
        sui::event::emit<InitUserTierConfigEvent>(event);
    }
    
    public(friend) fun set_package_version(_: &AdminCap, arg1: &mut GlobalConfig, arg2: u64) {
        let v0 = arg1.package_version;
        assert!(arg2 > v0, 0);
        arg1.package_version = arg2;
        let v1 = SetPackageVersion{
            new_version : arg2, 
            old_version : v0,
        };
        sui::event::emit<SetPackageVersion>(v1);
    }
    
    // public(friend) fun set_tier(_: &AdminCap, arg1: &mut GlobalConfig, arg2: address, arg3: u64, arg4: u64, arg5: &mut sui::tx_context::TxContext) {
    //     abort 0
    // }
    
    public(friend) fun set_tier_v2(
        _: &AdminCap,
        arg1: &GlobalConfig,
        arg2: &mut UserTierConfig,
        arg3: address,
        arg4: u64,
        arg5: u64,
        _: &mut sui::tx_context::TxContext
    ) {
        checked_package_version(arg1);
        assert!(arg4 <= 1000000, 4);
        assert!(arg5 <= 1000000, 5);
        if (sui::table::contains<address, Tier>(&arg2.user_tiers, arg3)) {
            let v0 = sui::table::borrow_mut<address, Tier>(&mut arg2.user_tiers, arg3);
            v0.rebate = arg4;
            v0.discount = arg5;
        } else {
            let v1 = Tier{
                rebate   : arg4, 
                discount : arg5,
            };
            sui::table::add<address, Tier>(&mut arg2.user_tiers, arg3, v1);
        };
        let v2 = SetTierEvent{
            user     : arg3, 
            rebate   : arg4, 
            discount : arg5,
        };
        sui::event::emit<SetTierEvent>(v2);
    }
}

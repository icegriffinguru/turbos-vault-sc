module turbos_vault::rewarder {
    struct StrategyRewarderInfo has store {
        allocate_point: u64,
        acc_per_share: u128,
        last_reward_time: u64,
    }
    
    struct Rewarder has store {
        reward_coin: std::type_name::TypeName,
        total_allocate_point: u64,
        emission_per_second: u64,
        last_reward_time: u64,
        total_reward_released: u128,
        total_reward_harvested: u64,
        strategys: sui::linked_table::LinkedTable<sui::object::ID, StrategyRewarderInfo>,
    }
    
    struct RewarderManager has store, key {
        id: sui::object::UID,
        vault: sui::bag::Bag,
        strategy_shares: sui::linked_table::LinkedTable<sui::object::ID, u128>,
        rewarders: sui::linked_table::LinkedTable<std::type_name::TypeName, Rewarder>,
        black_list: vector<address>,
    }
    
    struct InitRewarderManagerEvent has copy, drop {
        id: sui::object::ID,
    }
    
    struct CreateRewarderEvent has copy, drop {
        reward_coin: std::type_name::TypeName,
        emission_per_second: u64,
    }
    
    struct UpdateRewarderEvent has copy, drop {
        reward_coin: std::type_name::TypeName,
        emission_per_second: u64,
    }
    
    struct DepositEvent has copy, drop {
        reward_type: std::type_name::TypeName,
        deposit_amount: u64,
        after_amount: u64,
    }
    
    public(friend) fun accumulate_rewarder_released(
        arg0: &mut Rewarder,
        arg1: u64
    ) {
        if (arg0.last_reward_time < arg1) {
            if (arg0.emission_per_second > 0) {
                arg0.total_reward_released = arg0.total_reward_released + ((arg0.emission_per_second * (arg1 - arg0.last_reward_time)) as u128);
            };
            arg0.last_reward_time = arg1;
        };
    }
    
    public(friend) fun accumulate_strategy_reward(
        arg0: &mut Rewarder,
        arg1: sui::object::ID,
        arg2: u128,
        arg3: u64
    ) : u128 {
        let v0 = sui::linked_table::borrow_mut<sui::object::ID, StrategyRewarderInfo>(&mut arg0.strategys, arg1);
        if (arg3 > v0.last_reward_time && arg0.emission_per_second > 0) {
            if (arg2 > 0) {
                v0.acc_per_share = v0.acc_per_share + turbos_clmm::full_math_u128::mul_div_floor((arg0.emission_per_second * (arg3 - v0.last_reward_time) * v0.allocate_point / arg0.total_allocate_point) as u128, 1000000000, arg2);
            } else {
                v0.acc_per_share = 0;
            };
        };
        v0.last_reward_time = arg3;
        v0.acc_per_share
    }
    
    public(friend) fun accumulate_strategys_reward<T0>(
        arg0: &mut RewarderManager,
        arg1: u64
    ) {
        let v0 = sui::linked_table::borrow_mut<std::type_name::TypeName, Rewarder>(&mut arg0.rewarders, std::type_name::get<T0>());
        let v1 = sui::linked_table::front<sui::object::ID, StrategyRewarderInfo>(&v0.strategys);
        while (std::option::is_some<sui::object::ID>(v1)) {
            let v2 = *std::option::borrow<sui::object::ID>(v1);
            accumulate_strategy_reward(v0, v2, *sui::linked_table::borrow<sui::object::ID, u128>(&arg0.strategy_shares, v2), arg1);
            v1 = sui::linked_table::next<sui::object::ID, StrategyRewarderInfo>(&v0.strategys, v2);
        };
        v0.last_reward_time = arg1;
    }
    
    public fun add_reward_black_list(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut RewarderManager,
        arg3: vector<address>,
        arg4: &mut sui::tx_context::TxContext
    ) {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_reward_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        while (std::vector::length<address>(&arg3) > 0) {
            let v0 = std::vector::pop_back<address>(&mut arg3);
            if (!std::vector::contains<address>(&arg2.black_list, &v0)) {
                std::vector::push_back<address>(&mut arg2.black_list, v0);
                continue
            };
        };
    }
    
    public(friend) fun add_strategy<T0>(
        arg0: &mut RewarderManager,
        arg1: sui::object::ID,
        arg2: u64,
        arg3: &sui::clock::Clock
    ) {
        assert!(is_strategy_registered(arg0, arg1), 2);
        let v0 = std::type_name::get<T0>();
        assert!(!is_strategy_in_rewarder(arg0, v0, arg1), 2);
        let v1 = sui::clock::timestamp_ms(arg3) / 1000;
        accumulate_strategys_reward<T0>(arg0, v1);
        let v2 = sui::linked_table::borrow_mut<std::type_name::TypeName, Rewarder>(&mut arg0.rewarders, v0);
        accumulate_rewarder_released(v2, v1);
        let v3 = StrategyRewarderInfo{
            allocate_point   : arg2, 
            acc_per_share    : 0, 
            last_reward_time : v1,
        };
        sui::linked_table::push_back<sui::object::ID, StrategyRewarderInfo>(&mut v2.strategys, arg1, v3);
        v2.total_allocate_point = v2.total_allocate_point + arg2;
    }
    
    public fun create_rewarder<T0>(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut RewarderManager,
        arg3: u64,
        arg4: &sui::clock::Clock,
        arg5: &mut sui::tx_context::TxContext
    ) {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_reward_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        let v0 = std::type_name::get<T0>();
        assert!(!sui::linked_table::contains<std::type_name::TypeName, Rewarder>(&arg2.rewarders, v0), 1);
        let v1 = Rewarder{
            reward_coin            : v0, 
            total_allocate_point   : 0, 
            emission_per_second    : arg3, 
            last_reward_time       : sui::clock::timestamp_ms(arg4) / 1000, 
            total_reward_released  : 0, 
            total_reward_harvested : 0, 
            strategys              : sui::linked_table::new<sui::object::ID, StrategyRewarderInfo>(arg5),
        };
        sui::linked_table::push_back<std::type_name::TypeName, Rewarder>(&mut arg2.rewarders, v0, v1);
        let v2 = CreateRewarderEvent{
            reward_coin         : v0, 
            emission_per_second : arg3,
        };
        sui::event::emit<CreateRewarderEvent>(v2);
    }
    
    public fun deposit_rewarder<T0>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut RewarderManager,
        arg2: sui::coin::Coin<T0>,
        arg3: &mut sui::tx_context::TxContext
    ) {
        turbos_vault::config::checked_package_version(arg0);
        assert!(sui::coin::value<T0>(&arg2) > 0, 6);
        let v0 = std::type_name::get<T0>();
        if (!sui::bag::contains<std::type_name::TypeName>(&arg1.vault, v0)) {
            sui::bag::add<std::type_name::TypeName, sui::balance::Balance<T0>>(&mut arg1.vault, v0, sui::balance::zero<T0>());
        };
        let v1 = DepositEvent{
            reward_type    : v0, 
            deposit_amount : sui::coin::value<T0>(&arg2), 
            after_amount   : sui::balance::join<T0>(sui::bag::borrow_mut<std::type_name::TypeName, sui::balance::Balance<T0>>(&mut arg1.vault, v0), sui::coin::into_balance<T0>(arg2)),
        };
        sui::event::emit<DepositEvent>(v1);
    }
    
    fun init(arg0: &mut sui::tx_context::TxContext) {
        let v0 = RewarderManager{
            id              : sui::object::new(arg0), 
            vault           : sui::bag::new(arg0), 
            strategy_shares : sui::linked_table::new<sui::object::ID, u128>(arg0), 
            rewarders       : sui::linked_table::new<std::type_name::TypeName, Rewarder>(arg0), 
            black_list      : std::vector::empty<address>(),
        };
        sui::transfer::share_object<RewarderManager>(v0);
        let v1 = InitRewarderManagerEvent{id: sui::object::id<RewarderManager>(&v0)};
        sui::event::emit<InitRewarderManagerEvent>(v1);
    }
    
    public(friend) fun is_in_black_list(arg0: &RewarderManager, arg1: address) : bool {
        let (v0, _) = std::vector::index_of<address>(&arg0.black_list, &arg1);
        v0
    }
    
    fun is_strategy_in_rewarder(
        arg0: &RewarderManager,
        arg1: std::type_name::TypeName,
        arg2: sui::object::ID
    ) : bool {
        sui::linked_table::contains<sui::object::ID, StrategyRewarderInfo>(&sui::linked_table::borrow<std::type_name::TypeName, Rewarder>(&arg0.rewarders, arg1).strategys, arg2)
    }
    
    public fun is_strategy_registered(arg0: &RewarderManager, arg1: sui::object::ID) : bool {
        sui::linked_table::contains<sui::object::ID, u128>(&arg0.strategy_shares, arg1)
    }
    
    public(friend) fun register_strategy(arg0: &mut RewarderManager, arg1: sui::object::ID) {
        assert!(!is_strategy_registered(arg0, arg1), 3);
        sui::linked_table::push_back<sui::object::ID, u128>(&mut arg0.strategy_shares, arg1, 0);
    }
    
    public fun remove_reward_black_list(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut RewarderManager,
        arg3: vector<address>,
        arg4: &mut sui::tx_context::TxContext
    ) {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_reward_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        while (std::vector::length<address>(&arg3) > 0) {
            let v0 = std::vector::pop_back<address>(&mut arg3);
            let (v1, v2) = std::vector::index_of<address>(&arg2.black_list, &v0);
            if (v1) {
                std::vector::remove<address>(&mut arg2.black_list, v2);
                continue
            };
        };
    }
    
    public(friend) fun set_strategy_share(
        arg0: &mut RewarderManager,
        arg1: sui::object::ID,
        arg2: u128
    ) {
        *sui::linked_table::borrow_mut<sui::object::ID, u128>(&mut arg0.strategy_shares, arg1) = arg2;
    }
    
    public(friend) fun strategy_rewards_settle(
        arg0: &mut RewarderManager,
        arg1: vector<std::type_name::TypeName>,
        arg2: sui::object::ID,
        arg3: &sui::clock::Clock
    ) : sui::vec_map::VecMap<std::type_name::TypeName, u128> {
        assert!(is_strategy_registered(arg0, arg2), 2);
        let v0 = sui::clock::timestamp_ms(arg3) / 1000;
        let v1 = sui::vec_map::empty<std::type_name::TypeName, u128>();
        while (std::vector::length<std::type_name::TypeName>(&arg1) > 0) {
            let v2 = std::vector::pop_back<std::type_name::TypeName>(&mut arg1);
            let v3 = sui::linked_table::borrow_mut<std::type_name::TypeName, Rewarder>(&mut arg0.rewarders, v2);
            accumulate_rewarder_released(v3, v0);
            sui::vec_map::insert<std::type_name::TypeName, u128>(&mut v1, v2, accumulate_strategy_reward(v3, arg2, *sui::linked_table::borrow<sui::object::ID, u128>(&arg0.strategy_shares, arg2), v0));
        };
        v1
    }
    
    public fun update_rewarder<T0>(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut RewarderManager,
        arg3: u64,
        arg4: &sui::clock::Clock
    ) {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_reward_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        let v0 = std::type_name::get<T0>();
        assert!(sui::linked_table::contains<std::type_name::TypeName, Rewarder>(&arg2.rewarders, v0), 1);
        let v1 = sui::clock::timestamp_ms(arg4) / 1000;
        accumulate_strategys_reward<T0>(arg2, v1);
        let v2 = sui::linked_table::borrow_mut<std::type_name::TypeName, Rewarder>(&mut arg2.rewarders, v0);
        accumulate_rewarder_released(v2, v1);
        v2.emission_per_second = arg3;
        let v3 = UpdateRewarderEvent{
            reward_coin         : v0, 
            emission_per_second : arg3,
        };
        sui::event::emit<UpdateRewarderEvent>(v3);
    }
    
    public(friend) fun withdraw_reward<T0>(
        arg0: &mut RewarderManager,
        arg1: sui::object::ID,
        arg2: u64
    ) : sui::balance::Balance<T0> {
        let v0 = std::type_name::get<T0>();
        assert!(is_strategy_registered(arg0, arg1), 2);
        assert!(is_strategy_in_rewarder(arg0, v0, arg1), 4);
        assert!(sui::bag::contains<std::type_name::TypeName>(&arg0.vault, v0), 1);
        let v1 = sui::bag::borrow_mut<std::type_name::TypeName, sui::balance::Balance<T0>>(&mut arg0.vault, v0);
        assert!(sui::balance::value<T0>(v1) >= arg2, 5);
        let v2 = sui::linked_table::borrow_mut<std::type_name::TypeName, Rewarder>(&mut arg0.rewarders, v0);
        v2.total_reward_harvested = v2.total_reward_harvested + arg2;
        sui::balance::split<T0>(v1, arg2)
    }
}

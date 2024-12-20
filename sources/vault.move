module turbos_vault::vault {
    friend turbos_vault::config;
    friend turbos_vault::rewarder;
    friend turbos_vault::router;

    struct VAULT has drop {
        dummy_field: bool,
    }
    
    struct Account has store {
        clmm_base_nft: std::option::Option<turbos_clmm::position_nft::TurbosPositionNFT>,
        clmm_limit_nft: std::option::Option<turbos_clmm::position_nft::TurbosPositionNFT>,
        balances: sui::bag::Bag,
    }
    
    struct Strategy has store, key {
        id: sui::object::UID,
        clmm_pool_id: sui::object::ID,
        effective_tick_lower: turbos_clmm::i32::I32,
        effective_tick_upper: turbos_clmm::i32::I32,
        total_share: u128,
        rewarders: vector<std::type_name::TypeName>,
        coin_a_type_name: std::type_name::TypeName,
        coin_b_type_name: std::type_name::TypeName,
        fee_type_name: std::type_name::TypeName,
        vaults: sui::linked_table::LinkedTable<sui::object::ID, VaultInfo>,
        vault_index: u64,
        accounts: sui::table::Table<sui::object::ID, Account>,
        management_fee_rate: u64,
        performance_fee_rate: u64,
        protocol_fees: sui::bag::Bag,
        image_url: std::string::String,
        tick_spacing: u32,
        default_base_rebalance_percentage: u32,
        default_limit_rebalance_percentage: u32,
        base_tick_step_minimum: u32,
        limit_tick_step_minimum: u32,
        status: u8,
    }
    
    struct Vault has store, key {
        id: sui::object::UID,
        index: u64,
        strategy_id: sui::object::ID,
        coin_a_type_name: std::type_name::TypeName,
        coin_b_type_name: std::type_name::TypeName,
        name: std::string::String,
        description: std::string::String,
        url: std::string::String,
    }
    
    struct VaultRewardInfo has copy, drop, store {
        reward: u128,
        reward_debt: u128,
        reward_harvested: u128,
    }
    
    struct VaultInfo has copy, drop, store {
        vault_id: sui::object::ID,
        strategy_id: sui::object::ID,
        coin_a_type_name: std::type_name::TypeName,
        coin_b_type_name: std::type_name::TypeName,
        base_clmm_position_id: sui::object::ID,
        base_lower_index: turbos_clmm::i32::I32,
        base_upper_index: turbos_clmm::i32::I32,
        base_liquidity: u128,
        limit_clmm_position_id: sui::object::ID,
        limit_lower_index: turbos_clmm::i32::I32,
        limit_upper_index: turbos_clmm::i32::I32,
        limit_liquidity: u128,
        sqrt_price: u128,
        base_last_tick_index: turbos_clmm::i32::I32,
        limit_last_tick_index: turbos_clmm::i32::I32,
        base_rebalance_threshold: u32,
        limit_rebalance_threshold: u32,
        base_tick_step: u32,
        limit_tick_step: u32,
        share: u128,
        rewards: sui::vec_map::VecMap<std::type_name::TypeName, VaultRewardInfo>,
        management_fee_rate: std::option::Option<u64>,
        performance_fee_rate: std::option::Option<u64>,
    }
    
    struct CheckRebalance has copy, drop {
        vault_id: sui::object::ID,
        rebalance: bool,
        base_lower_index: turbos_clmm::i32::I32,
        base_upper_index: turbos_clmm::i32::I32,
        base_just_increase: bool,
        limit_lower_index: turbos_clmm::i32::I32,
        limit_upper_index: turbos_clmm::i32::I32,
    }
    
    struct CreateStrategyEvent has copy, drop {
        strategy_id: sui::object::ID,
        clmm_pool_id: sui::object::ID,
        effective_tick_lower: turbos_clmm::i32::I32,
        effective_tick_upper: turbos_clmm::i32::I32,
        coin_a_type_name: std::type_name::TypeName,
        coin_b_type_name: std::type_name::TypeName,
        fee_type_name: std::type_name::TypeName,
    }
    
    struct OpenVaultEvent has copy, drop {
        vault_id: sui::object::ID,
        strategy_id: sui::object::ID,
        clmm_pool_id: sui::object::ID,
    }
    
    struct CloseVaultEvent has copy, drop {
        vault_id: sui::object::ID,
        strategy_id: sui::object::ID,
    }
    
    struct DepositEvent has copy, drop {
        vault_id: sui::object::ID,
        strategy_id: sui::object::ID,
        clmm_pool_id: sui::object::ID,
        amount_a: u64,
        amount_b: u64,
    }
    
    struct WithdrawEvent has copy, drop {
        vault_id: sui::object::ID,
        strategy_id: sui::object::ID,
        clmm_pool_id: sui::object::ID,
        percentage: u64,
        burn_clmm_nft: bool,
        amount_a: u64,
        amount_b: u64,
        protocol_fee_a_amount: u64,
        protocol_fee_b_amount: u64,
    }
    
    struct RebalanceEvent has copy, drop {
        vault_id: sui::object::ID,
        strategy_id: sui::object::ID,
        clmm_pool_id: sui::object::ID,
        checkRebalance: CheckRebalance,
        sqrt_price: u128,
        amount_a_left: u64,
        amount_b_left: u64,
        base_amount_a: u64,
        base_amount_b: u64,
        limit_amount_a: u64,
        limit_amount_b: u64,
    }
    
    struct CollectRebalanceFeeEvent has copy, drop {
        vault_id: sui::object::ID,
        strategy_id: sui::object::ID,
        fee_amount_a: u64,
        fee_amount_b: u64,
        remaining_fee_amount_a: u64,
        remaining_fee_amount_b: u64,
    }
    
    struct AddRewardEvent has copy, drop {
        strategy_id: sui::object::ID,
        clmm_pool_id: sui::object::ID,
        rewarder_type: std::type_name::TypeName,
        allocate_point: u64,
    }
    
    struct UpdateStrategyManagementFeeRateEvent has copy, drop {
        strategy_id: sui::object::ID,
        old_rate: u64,
        new_rate: u64,
    }
    
    struct UpdateStrategyPerformanceFeeRateEvent has copy, drop {
        strategy_id: sui::object::ID,
        old_rate: u64,
        new_rate: u64,
    }
    
    struct UpdateVaultPerformanceFeeRateEvent has copy, drop {
        strategy_id: sui::object::ID,
        vault_id: sui::object::ID,
        old_rate: u64,
        new_rate: u64,
    }
    
    struct UpdateVaultManagementFeeRateEvent has copy, drop {
        strategy_id: sui::object::ID,
        vault_id: sui::object::ID,
        old_rate: u64,
        new_rate: u64,
    }
    
    struct ClmmRewardClaimedEvent has copy, drop {
        vault_id: sui::object::ID,
        strategy_id: sui::object::ID,
        clmm_pool_id: sui::object::ID,
        clmm_nft_id: sui::object::ID,
        amount: u64,
        performance_fee: u64,
        reward_type_name: std::type_name::TypeName,
    }
    
    struct VaultRewardClaimedEvent has copy, drop {
        vault_id: sui::object::ID,
        strategy_id: sui::object::ID,
        amount: u64,
        reward_type_name: std::type_name::TypeName,
    }
    
    struct ClmmFeeClaimedEvent has copy, drop {
        vault_id: sui::object::ID,
        strategy_id: sui::object::ID,
        clmm_pool_id: sui::object::ID,
        clmm_nft_id: sui::object::ID,
        amount_a: u64,
        amount_b: u64,
        performance_fee_a: u64,
        performance_fee_b: u64,
        coin_a_type_name: std::type_name::TypeName,
        coin_b_type_name: std::type_name::TypeName,
    }
    
    public fun add_rewarder<T0>(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut turbos_vault::rewarder::RewarderManager,
        arg3: &mut Strategy,
        arg4: u64,
        arg5: &sui::clock::Clock
    ) {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_vault_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        let v0 = std::type_name::get<T0>();
        assert!(!std::vector::contains<std::type_name::TypeName>(&arg3.rewarders, &v0), 3);
        let v1 = sui::object::id<Strategy>(arg3);
        turbos_vault::rewarder::add_strategy<T0>(arg2, v1, arg4, arg5);
        std::vector::push_back<std::type_name::TypeName>(&mut arg3.rewarders, v0);
        let v2 = AddRewardEvent{
            strategy_id    : v1, 
            clmm_pool_id   : arg3.clmm_pool_id, 
            rewarder_type  : v0, 
            allocate_point : arg4,
        };
        sui::event::emit<AddRewardEvent>(v2);
    }
    
    fun borrow_clmm_base_nft(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : &turbos_clmm::position_nft::TurbosPositionNFT {
        std::option::borrow<turbos_clmm::position_nft::TurbosPositionNFT>(&borrow_vault_account(arg0, arg1).clmm_base_nft)
    }
    
    fun borrow_clmm_limit_nft(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : &turbos_clmm::position_nft::TurbosPositionNFT {
        std::option::borrow<turbos_clmm::position_nft::TurbosPositionNFT>(&borrow_vault_account(arg0, arg1).clmm_limit_nft)
    }
    
    fun borrow_mut_clmm_base_nft(
        arg0: &mut Strategy,
        arg1: sui::object::ID
    ) : &mut turbos_clmm::position_nft::TurbosPositionNFT {
        std::option::borrow_mut<turbos_clmm::position_nft::TurbosPositionNFT>(&mut borrow_mut_vault_account(arg0, arg1).clmm_base_nft)
    }
    
    fun borrow_mut_clmm_limit_nft(
        arg0: &mut Strategy,
        arg1: sui::object::ID
    ) : &mut turbos_clmm::position_nft::TurbosPositionNFT {
        std::option::borrow_mut<turbos_clmm::position_nft::TurbosPositionNFT>(&mut borrow_mut_vault_account(arg0, arg1).clmm_limit_nft)
    }
    
    fun borrow_mut_vault_account(
        arg0: &mut Strategy,
        arg1: sui::object::ID
    ) : &mut Account {
        sui::table::borrow_mut<sui::object::ID, Account>(&mut arg0.accounts, arg1)
    }
    
    fun borrow_mut_vault_info(
        arg0: &mut Strategy,
        arg1: sui::object::ID
    ) : &mut VaultInfo {
        sui::linked_table::borrow_mut<sui::object::ID, VaultInfo>(&mut arg0.vaults, arg1)
    }
    
    public fun borrow_vault_account(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : &Account {
        sui::table::borrow<sui::object::ID, Account>(&arg0.accounts, arg1)
    }
    
    public fun borrow_vault_info(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : &VaultInfo {
        sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1)
    }
    
    fun burn_clmm_base_nft<T0, T1, T2>(
        arg0: &mut Strategy,
        arg1: sui::object::ID,
        arg2: &mut turbos_clmm::position_manager::Positions,
        arg3: &turbos_clmm::pool::Versioned,
        arg4: &mut sui::tx_context::TxContext
    ) {
        turbos_clmm::position_manager::burn<T0, T1, T2>(arg2, extract_clmm_base_nft(arg0, arg1), arg3, arg4);
    }
    
    fun burn_clmm_limit_nft<T0, T1, T2>(
        arg0: &mut Strategy,
        arg1: sui::object::ID,
        arg2: &mut turbos_clmm::position_manager::Positions,
        arg3: &turbos_clmm::pool::Versioned,
        arg4: &mut sui::tx_context::TxContext
    ) {
        turbos_clmm::position_manager::burn<T0, T1, T2>(arg2, extract_clmm_limit_nft(arg0, arg1), arg3, arg4);
    }
    
    fun calculate_liquidity(
        arg0: u128,
        arg1: turbos_clmm::i32::I32,
        arg2: turbos_clmm::i32::I32,
        arg3: u64,
        arg4: u64
    ) : u128 {
        turbos_clmm::math_liquidity::get_liquidity_for_amounts(arg0, turbos_clmm::math_tick::sqrt_price_from_tick_index(arg1), turbos_clmm::math_tick::sqrt_price_from_tick_index(arg2), arg3 as u128, arg4 as u128)
    }
    
    public fun calculate_position_share(
        arg0: turbos_clmm::i32::I32,
        arg1: turbos_clmm::i32::I32,
        arg2: u128,
        arg3: u128,
        arg4: turbos_clmm::i32::I32,
        arg5: turbos_clmm::i32::I32
    ) : u128 {
        assert!(turbos_clmm::i32::lt(arg0, arg1), 4);
        assert!(turbos_clmm::i32::lt(arg4, arg5), 4);
        let v0 = (turbos_clmm::i32::lte(arg1, arg4) || turbos_clmm::i32::gte(arg0, arg5)) && false || true;
        if (!v0) {
            return 0
        };
        let v1 = if (turbos_clmm::i32::lt(arg0, arg4)) {
            arg4
        } else {
            arg0
        };
        let v2 = if (turbos_clmm::i32::lt(arg1, arg5)) {
            arg1
        } else {
            arg5
        };
        let (v3, v4) = turbos_clmm::math_liquidity::get_amount_for_liquidity(arg3, turbos_clmm::math_tick::sqrt_price_from_tick_index(v1), turbos_clmm::math_tick::sqrt_price_from_tick_index(v2), arg2);
        (((v3 as u256) * (arg3 as u256) * (arg3 as u256) * 1000000000 / 340282366920938463463374607431768211455 / 1000000000) as u128) + v4
    }
    
    public fun calculate_tick_index(
        arg0: turbos_clmm::i32::I32,
        arg1: u32,
        arg2: u32
    ) : (turbos_clmm::i32::I32, turbos_clmm::i32::I32) {
        let v0 = turbos_clmm::i32::sub(arg0, turbos_clmm::i32::mod(arg0, turbos_clmm::i32::from_u32(arg1)));
        let v1 = turbos_clmm::i32::from_u32(arg2 + 1);
        (turbos_clmm::i32::sub(v0, turbos_clmm::i32::mul(turbos_clmm::i32::from_u32(arg1), v1)), turbos_clmm::i32::add(v0, turbos_clmm::i32::mul(turbos_clmm::i32::from_u32(arg1), v1)))
    }
    
    public fun check_rebalance<T0, T1, T2>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut Strategy,
        arg2: sui::object::ID,
        arg3: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg4: &mut sui::tx_context::TxContext
    ) : CheckRebalance {
        turbos_vault::config::checked_package_version(arg0);
        assert!(arg1.status == 0, 15);
        assert!(arg1.clmm_pool_id == sui::object::id<turbos_clmm::pool::Pool<T0, T1, T2>>(arg3), 17);
        let v0 = false;
        let v1 = borrow_vault_info(arg1, arg2);
        let v2 = turbos_clmm::pool::get_pool_current_index<T0, T1, T2>(arg3);
        let v3 = v1.base_last_tick_index;
        let v4 = false;
        let v5 = v1.base_lower_index;
        let v6 = v1.base_upper_index;
        let v7 = v1.base_tick_step;
        let v8 = v1.limit_tick_step;
        let v9 = if (turbos_clmm::i32::gt(v2, v3)) {
            turbos_clmm::i32::abs_u32(turbos_clmm::i32::sub(v2, v3))
        } else {
            turbos_clmm::i32::abs_u32(turbos_clmm::i32::sub(v3, v2))
        };
        if (v9 >= turbos_clmm::full_math_u32::mul_div_floor(v7 * arg1.tick_spacing, v1.base_rebalance_threshold, 100)) {
            v0 = true;
        };
        let v10 = v1.limit_lower_index;
        let v11 = v1.limit_upper_index;
        if (!v0 && is_clmm_limit_nft_exists(arg1, arg2)) {
            let v12 = v1.limit_last_tick_index;
            let v13 = if (turbos_clmm::i32::gt(v2, v12)) {
                turbos_clmm::i32::abs_u32(turbos_clmm::i32::sub(v2, v12))
            } else {
                turbos_clmm::i32::abs_u32(turbos_clmm::i32::sub(v12, v2))
            };
            if (v13 >= turbos_clmm::full_math_u32::mul_div_floor(v8 * arg1.tick_spacing, v1.limit_rebalance_threshold, 100)) {
                v0 = true;
                if (is_clmm_base_nft_exists(arg1, arg2)) {
                    v4 = true;
                };
            };
        };
        if (v0 && !v4) {
            let (v14, v15) = calculate_tick_index(v2, arg1.tick_spacing, v7);
            v6 = v15;
            v5 = v14;
        };
        if (v0) {
            let (v16, v17) = calculate_tick_index(v2, arg1.tick_spacing, v8);
            v11 = v17;
            v10 = v16;
        };
        CheckRebalance{
            vault_id           : arg2, 
            rebalance          : v0, 
            base_lower_index   : v5, 
            base_upper_index   : v6, 
            base_just_increase : v4, 
            limit_lower_index  : v10, 
            limit_upper_index  : v11,
        }
    }
    
    public fun check_rebalance_loop<T0, T1, T2>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut Strategy, arg2: sui::object::ID,
        arg3: u64,
        arg4: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg5: &mut sui::tx_context::TxContext
    ) : (vector<CheckRebalance>, std::option::Option<sui::object::ID>) {
        turbos_vault::config::checked_package_version(arg0);
        assert!(arg1.status == 0, 15);
        assert!(arg3 > 0, 19);
        let v0 = std::vector::empty<CheckRebalance>();
        let v1 = 0;
        let v2 = std::option::some<sui::object::ID>(arg2);
        let v3 = &v2;
        let v4 = 0;
        while (!std::option::is_none<sui::object::ID>(v3) && v1 < arg3 && v4 < 200) {
            let v5 = *std::option::borrow<sui::object::ID>(v3);
            let v6 = check_rebalance<T0, T1, T2>(arg0, arg1, v5, arg4, arg5);
            if (v6.rebalance) {
                std::vector::push_back<CheckRebalance>(&mut v0, v6);
                v1 = v1 + 1;
            };
            v3 = sui::linked_table::next<sui::object::ID, VaultInfo>(&arg1.vaults, v5);
            v4 = v4 + 1;
        };
        (v0, *v3)
    }
    
    fun check_tick_range(
        arg0: u32,
        arg1: turbos_clmm::i32::I32,
        arg2: turbos_clmm::i32::I32,
        arg3: turbos_clmm::i32::I32,
        arg4: u32
    ) {
        turbos_clmm::i32::from_u32(arg4);
        assert!(turbos_clmm::i32::lt(arg2, arg1) && turbos_clmm::i32::lt(arg1, arg3), 4);
        let (v0, v1) = calculate_tick_index(arg1, arg4, arg0 - 1);
        assert!(turbos_clmm::i32::lte(arg2, v0), 14);
        assert!(turbos_clmm::i32::gte(arg3, v1), 14);
    }
    
    public fun close_vault<T0, T1>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut Strategy,
        arg2: Vault,
        arg3: &mut sui::tx_context::TxContext
    ) {
        turbos_vault::config::checked_package_version(arg0);
        assert!(arg1.status == 0, 15);
        assert!(sui::object::id<Strategy>(arg1) == arg2.strategy_id, 18);
        let v0 = sui::object::id<Vault>(&arg2);
        borrow_vault_account(arg1, v0);
        assert!(!is_clmm_base_nft_exists(arg1, v0), 7);
        assert!(!is_clmm_limit_nft_exists(arg1, v0), 8);
        assert!(get_vault_balance<T0>(arg1, v0) == 0, 9);
        assert!(get_vault_balance<T1>(arg1, v0) == 0, 10);
        remove_vault_info(arg1, v0);
        let Vault {
            id               : v1,
            index            : _,
            strategy_id      : _,
            coin_a_type_name : _,
            coin_b_type_name : _,
            name             : _,
            description      : _,
            url              : _,
        } = arg2;
        sui::object::delete(v1);
        let v9 = CloseVaultEvent{
            vault_id    : v0, 
            strategy_id : sui::object::id<Strategy>(arg1),
        };
        sui::event::emit<CloseVaultEvent>(v9);
    }
    
    fun coin_to_vec<T0>(arg0: sui::coin::Coin<T0>) : vector<sui::coin::Coin<T0>> {
        let v0 = std::vector::empty<sui::coin::Coin<T0>>();
        std::vector::push_back<sui::coin::Coin<T0>>(&mut v0, arg0);
        v0
    }
    
    fun collect_clmm_base_fees<T0, T1, T2>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut Strategy,
        arg2: sui::object::ID,
        arg3: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg4: &mut turbos_clmm::position_manager::Positions,
        arg5: &sui::clock::Clock,
        arg6: &turbos_clmm::pool::Versioned,
        arg7: &mut sui::tx_context::TxContext
    ) {
        let v0 = borrow_mut_clmm_base_nft(arg1, arg2);
        let (v1, v2) = turbos_clmm::position_manager::collect_with_return_<T0, T1, T2>(arg3, arg4, v0, 18446744073709551615, 18446744073709551615, sui::object::id_to_address(&arg2), sui::clock::timestamp_ms(arg5) + 60000, arg5, arg6, arg7);
        let v3 = v2;
        let v4 = v1;
        let v5 = get_performance_fee_rate(arg0, arg1, arg2, arg7);
        let (v6, v7) = if (v5 == 0) {
            (0, 0)
        } else {
            let v8 = turbos_clmm::full_math_u64::mul_div_ceil(sui::coin::value<T0>(&v4), v5, 1000000);
            let v9 = turbos_clmm::full_math_u64::mul_div_ceil(sui::coin::value<T1>(&v3), v5, 1000000);
            merge_protocol_asset<T0>(arg1, sui::coin::into_balance<T0>(sui::coin::split<T0>(&mut v4, v8, arg7)));
            merge_protocol_asset<T1>(arg1, sui::coin::into_balance<T1>(sui::coin::split<T1>(&mut v3, v9, arg7)));
            (v8, v9)
        };
        merge_vault_balance<T0>(arg1, arg2, sui::coin::into_balance<T0>(v4));
        merge_vault_balance<T1>(arg1, arg2, sui::coin::into_balance<T1>(v3));
        let v10 = ClmmFeeClaimedEvent{
            vault_id          : arg2, 
            strategy_id       : sui::object::id<Strategy>(arg1), 
            clmm_pool_id      : sui::object::id<turbos_clmm::pool::Pool<T0, T1, T2>>(arg3), 
            clmm_nft_id       : sui::object::id<turbos_clmm::position_nft::TurbosPositionNFT>(v0), 
            amount_a          : sui::coin::value<T0>(&v4), 
            amount_b          : sui::coin::value<T1>(&v3), 
            performance_fee_a : v6, 
            performance_fee_b : v7, 
            coin_a_type_name  : std::type_name::get<T0>(), 
            coin_b_type_name  : std::type_name::get<T1>(),
        };
        sui::event::emit<ClmmFeeClaimedEvent>(v10);
    }
    
    fun collect_clmm_base_reward<T0, T1, T2, T3>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut Strategy,
        arg2: sui::object::ID,
        arg3: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg4: &mut turbos_clmm::position_manager::Positions,
        arg5: &mut turbos_clmm::pool::PoolRewardVault<T3>,
        arg6: u64,
        arg7: address,
        arg8: &sui::clock::Clock,
        arg9: &turbos_clmm::pool::Versioned,
        arg10: &mut sui::tx_context::TxContext
    ) : sui::coin::Coin<T3> {
        let v0 = borrow_mut_clmm_base_nft(arg1, arg2);
        let v1 = turbos_clmm::position_manager::collect_reward_with_return_<T0, T1, T2, T3>(arg3, arg4, v0, arg5, arg6, 18446744073709551615, arg7, sui::clock::timestamp_ms(arg8) + 60000, arg8, arg9, arg10);
        let v2 = get_performance_fee_rate(arg0, arg1, arg2, arg10);
        let v3 = if (v2 == 0) {
            0
        } else {
            let v4 = turbos_clmm::full_math_u64::mul_div_ceil(sui::coin::value<T3>(&v1), v2, 1000000);
            merge_protocol_asset<T3>(arg1, sui::coin::into_balance<T3>(sui::coin::split<T3>(&mut v1, v4, arg10)));
            v4
        };
        let v5 = ClmmRewardClaimedEvent{
            vault_id         : arg2, 
            strategy_id      : sui::object::id<Strategy>(arg1), 
            clmm_pool_id     : sui::object::id<turbos_clmm::pool::Pool<T0, T1, T2>>(arg3), 
            clmm_nft_id      : sui::object::id<turbos_clmm::position_nft::TurbosPositionNFT>(v0), 
            amount           : sui::coin::value<T3>(&v1), 
            performance_fee  : v3, 
            reward_type_name : std::type_name::get<T3>(),
        };
        sui::event::emit<ClmmRewardClaimedEvent>(v5);
        v1
    }
    
    fun collect_clmm_fees<T0, T1, T2>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut Strategy,
        arg2: sui::object::ID,
        arg3: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg4: &mut turbos_clmm::position_manager::Positions,
        arg5: &sui::clock::Clock,
        arg6: &turbos_clmm::pool::Versioned,
        arg7: &mut sui::tx_context::TxContext
    ) {
        if (is_clmm_base_nft_exists(arg1, arg2)) {
            collect_clmm_base_fees<T0, T1, T2>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
        };
        if (is_clmm_limit_nft_exists(arg1, arg2)) {
            collect_clmm_limit_fees<T0, T1, T2>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
        };
    }
    
    fun collect_clmm_limit_fees<T0, T1, T2>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut Strategy,
        arg2: sui::object::ID,
        arg3: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg4: &mut turbos_clmm::position_manager::Positions,
        arg5: &sui::clock::Clock,
        arg6: &turbos_clmm::pool::Versioned,
        arg7: &mut sui::tx_context::TxContext
    ) {
        let v0 = borrow_mut_clmm_limit_nft(arg1, arg2);
        let (v1, v2) = turbos_clmm::position_manager::collect_with_return_<T0, T1, T2>(arg3, arg4, v0, 18446744073709551615, 18446744073709551615, sui::object::id_to_address(&arg2), sui::clock::timestamp_ms(arg5) + 60000, arg5, arg6, arg7);
        let v3 = v2;
        let v4 = v1;
        let v5 = get_performance_fee_rate(arg0, arg1, arg2, arg7);
        let (v6, v7) = if (v5 == 0) {
            (0, 0)
        } else {
            let v8 = turbos_clmm::full_math_u64::mul_div_ceil(sui::coin::value<T0>(&v4), v5, 1000000);
            let v9 = turbos_clmm::full_math_u64::mul_div_ceil(sui::coin::value<T1>(&v3), v5, 1000000);
            merge_protocol_asset<T0>(arg1, sui::coin::into_balance<T0>(sui::coin::split<T0>(&mut v4, v8, arg7)));
            merge_protocol_asset<T1>(arg1, sui::coin::into_balance<T1>(sui::coin::split<T1>(&mut v3, v9, arg7)));
            (v8, v9)
        };
        merge_vault_balance<T0>(arg1, arg2, sui::coin::into_balance<T0>(v4));
        merge_vault_balance<T1>(arg1, arg2, sui::coin::into_balance<T1>(v3));
        let v10 = ClmmFeeClaimedEvent{
            vault_id          : arg2, 
            strategy_id       : sui::object::id<Strategy>(arg1), 
            clmm_pool_id      : sui::object::id<turbos_clmm::pool::Pool<T0, T1, T2>>(arg3), 
            clmm_nft_id       : sui::object::id<turbos_clmm::position_nft::TurbosPositionNFT>(v0), 
            amount_a          : sui::coin::value<T0>(&v4), 
            amount_b          : sui::coin::value<T1>(&v3), 
            performance_fee_a : v6, 
            performance_fee_b : v7, 
            coin_a_type_name  : std::type_name::get<T0>(), 
            coin_b_type_name  : std::type_name::get<T1>(),
        };
        sui::event::emit<ClmmFeeClaimedEvent>(v10);
    }
    
    fun collect_clmm_limit_reward<T0, T1, T2, T3>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut Strategy,
        arg2: sui::object::ID,
        arg3: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg4: &mut turbos_clmm::position_manager::Positions,
        arg5: &mut turbos_clmm::pool::PoolRewardVault<T3>,
        arg6: u64, arg7: address,
        arg8: &sui::clock::Clock,
        arg9: &turbos_clmm::pool::Versioned,
        arg10: &mut sui::tx_context::TxContext
    ) : sui::coin::Coin<T3> {
        let v0 = borrow_mut_clmm_limit_nft(arg1, arg2);
        let v1 = turbos_clmm::position_manager::collect_reward_with_return_<T0, T1, T2, T3>(arg3, arg4, v0, arg5, arg6, 18446744073709551615, arg7, sui::clock::timestamp_ms(arg8) + 60000, arg8, arg9, arg10);
        let v2 = get_performance_fee_rate(arg0, arg1, arg2, arg10);
        let v3 = if (v2 == 0) {
            0
        } else {
            let v4 = turbos_clmm::full_math_u64::mul_div_ceil(sui::coin::value<T3>(&v1), v2, 1000000);
            merge_protocol_asset<T3>(arg1, sui::coin::into_balance<T3>(sui::coin::split<T3>(&mut v1, v4, arg10)));
            v4
        };
        let v5 = ClmmRewardClaimedEvent{
            vault_id         : arg2, 
            strategy_id      : sui::object::id<Strategy>(arg1), 
            clmm_pool_id     : sui::object::id<turbos_clmm::pool::Pool<T0, T1, T2>>(arg3), 
            clmm_nft_id      : sui::object::id<turbos_clmm::position_nft::TurbosPositionNFT>(v0), 
            amount           : sui::coin::value<T3>(&v1), 
            performance_fee  : v3, 
            reward_type_name : std::type_name::get<T3>(),
        };
        sui::event::emit<ClmmRewardClaimedEvent>(v5);
        v1
    }
    
    fun collect_clmm_reward<T0, T1, T2, T3>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut Strategy, arg2: sui::object::ID,
        arg3: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg4: &mut turbos_clmm::position_manager::Positions,
        arg5: &mut turbos_clmm::pool::PoolRewardVault<T3>,
        arg6: u64, arg7: address,
        arg8: &sui::clock::Clock,
        arg9: &turbos_clmm::pool::Versioned,
        arg10: &mut sui::tx_context::TxContext
    ) : sui::balance::Balance<T3> {
        let v0 = sui::balance::zero<T3>();
        if (is_clmm_base_nft_exists(arg1, arg2)) {
            sui::balance::join<T3>(&mut v0, sui::coin::into_balance<T3>(collect_clmm_base_reward<T0, T1, T2, T3>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)));
        };
        if (is_clmm_limit_nft_exists(arg1, arg2)) {
            sui::balance::join<T3>(&mut v0, sui::coin::into_balance<T3>(collect_clmm_limit_reward<T0, T1, T2, T3>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)));
        };
        v0
    }
    
    public fun collect_clmm_reward_direct_return<T0, T1, T2, T3>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut Strategy,
        arg2: &Vault,
        arg3: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg4: &mut turbos_clmm::position_manager::Positions,
        arg5: &mut turbos_clmm::pool::PoolRewardVault<T3>,
        arg6: u64,
        arg7: address,
        arg8: &sui::clock::Clock,
        arg9: &turbos_clmm::pool::Versioned,
        arg10: &mut sui::tx_context::TxContext
    ) : sui::coin::Coin<T3> {
        turbos_vault::config::checked_package_version(arg0);
        assert!(arg1.status == 0, 15);
        assert!(arg1.clmm_pool_id == sui::object::id<turbos_clmm::pool::Pool<T0, T1, T2>>(arg3), 17);
        assert!(sui::object::id<Strategy>(arg1) == arg2.strategy_id, 18);
        let v0 = std::type_name::get<T3>();
        let v1 = collect_clmm_reward<T0, T1, T2, T3>(arg0, arg1, sui::object::id<Vault>(arg2), arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
        let v2 = borrow_mut_vault_account(arg1, sui::object::id<Vault>(arg2));
        let v3 = get_type_name_str<T3>();
        if (v0 != arg2.coin_a_type_name && v0 != arg2.coin_b_type_name) {
            if (sui::bag::contains<std::string::String>(&v2.balances, v3)) {
                sui::balance::join<T3>(&mut v1, sui::bag::remove<std::string::String, sui::balance::Balance<T3>>(&mut v2.balances, v3));
            };
        };
        sui::coin::from_balance<T3>(v1, arg10)
    }
    
    public fun collect_clmm_reward_to_vault<T0, T1, T2, T3>(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut Strategy,
        arg3: sui::object::ID,
        arg4: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg5: &mut turbos_clmm::position_manager::Positions,
        arg6: &mut turbos_clmm::pool::PoolRewardVault<T3>,
        arg7: u64,
        arg8: address,
        arg9: &sui::clock::Clock,
        arg10: &turbos_clmm::pool::Versioned,
        arg11: &mut sui::tx_context::TxContext
    ) {
        turbos_vault::config::checked_package_version(arg1);
        assert!(arg2.status == 0, 15);
        assert!(arg2.clmm_pool_id == sui::object::id<turbos_clmm::pool::Pool<T0, T1, T2>>(arg4), 17);
        turbos_vault::config::check_rebalance_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        merge_vault_balance<T3>(arg2, arg3, collect_clmm_reward<T0, T1, T2, T3>(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11));
    }
    
    public(friend) fun collect_protocol_fee<T0>(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut Strategy,
        arg3: u64,
        arg4: &mut sui::tx_context::TxContext
    ) : sui::coin::Coin<T0> {
        turbos_vault::config::checked_package_version(arg1);
        assert!(arg2.status == 0, 15);
        turbos_vault::config::check_vault_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        sui::coin::from_balance<T0>(take_protocol_asset_by_amount<T0>(arg2, arg3), arg4)
    }
    
    fun collect_rebalance_fee<T0, T1>(
        arg0: &mut Strategy,
        arg1: sui::object::ID,
        arg2: u64,
        arg3: u64,
        arg4: &mut sui::balance::Balance<T0>,
        arg5: &mut sui::balance::Balance<T1>
    ) {
        let v0 = arg2 - sui::balance::value<T0>(arg4);
        let v1 = arg3 - sui::balance::value<T1>(arg5);
        if (v0 > 0) {
            sui::balance::join<T0>(arg4, take_vault_balance_by_amount<T0>(arg0, arg1, v0));
        };
        if (v1 > 0) {
            sui::balance::join<T1>(arg5, take_vault_balance_by_amount<T1>(arg0, arg1, v1));
        };
        let v2 = CollectRebalanceFeeEvent{
            vault_id               : arg1, 
            strategy_id            : sui::object::id<Strategy>(arg0), 
            fee_amount_a           : arg2, 
            fee_amount_b           : arg3, 
            remaining_fee_amount_a : arg2 - sui::balance::value<T0>(arg4), 
            remaining_fee_amount_b : arg3 - sui::balance::value<T1>(arg5),
        };
        sui::event::emit<CollectRebalanceFeeEvent>(v2);
    }
    
    public fun collect_reward<T0>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut turbos_vault::rewarder::RewarderManager,
        arg2: &mut Strategy,
        arg3: &Vault,
        arg4: &sui::clock::Clock,
        arg5: &mut sui::tx_context::TxContext
    ) : sui::coin::Coin<T0> {
        turbos_vault::config::checked_package_version(arg0);
        assert!(arg2.status == 0, 15);
        assert!(sui::object::id<Strategy>(arg2) == arg3.strategy_id, 18);
        let v0 = std::type_name::get<T0>();
        assert!(std::vector::contains<std::type_name::TypeName>(&arg2.rewarders, &v0), 16);
        let v1 = sui::object::id<Strategy>(arg2);
        let v2 = sui::object::id<Vault>(arg3);
        update_vault_reward_info(arg2, v2, turbos_vault::rewarder::strategy_rewards_settle(arg1, arg2.rewarders, v1, arg4), borrow_vault_info(arg2, v2).share);
        let v3 = update_vault_reward_info_on_claim(arg2, v2, v0);
        let v4 = VaultRewardClaimedEvent{
            vault_id         : v2, 
            strategy_id      : v1, 
            amount           : v3, 
            reward_type_name : v0,
        };
        sui::event::emit<VaultRewardClaimedEvent>(v4);
        sui::coin::from_balance<T0>(turbos_vault::rewarder::withdraw_reward<T0>(arg1, v1, v3), arg5)
    }
    
    public fun create_strategy<T0, T1, T2>(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut turbos_vault::rewarder::RewarderManager,
        arg3: &turbos_clmm::pool::Pool<T0, T1, T2>,
        arg4: u32,
        arg5: bool,
        arg6: u32,
        arg7: bool,
        arg8: std::string::String,
        arg9: u32,
        arg10: u32,
        arg11: u32,
        arg12: u32,
        arg13: &mut sui::tx_context::TxContext
    ) : Strategy {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_vault_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        let v0 = turbos_clmm::i32::from_u32_neg(arg4, arg5);
        let v1 = turbos_clmm::i32::from_u32_neg(arg6, arg7);
        let v2 = sui::object::id<turbos_clmm::pool::Pool<T0, T1, T2>>(arg3);
        let v3 = std::type_name::get<T0>();
        let v4 = std::type_name::get<T1>();
        let v5 = std::type_name::get<T2>();
        let v6 = Strategy{
            id                                 : sui::object::new(arg13), 
            clmm_pool_id                       : v2, 
            effective_tick_lower               : v0, 
            effective_tick_upper               : v1, 
            total_share                        : 0, 
            rewarders                          : std::vector::empty<std::type_name::TypeName>(), 
            coin_a_type_name                   : v3, 
            coin_b_type_name                   : v4, 
            fee_type_name                      : v5, 
            vaults                             : sui::linked_table::new<sui::object::ID, VaultInfo>(arg13), 
            vault_index                        : 0, 
            accounts                           : sui::table::new<sui::object::ID, Account>(arg13), 
            management_fee_rate                : 0, 
            performance_fee_rate               : 0, 
            protocol_fees                      : sui::bag::new(arg13), 
            image_url                          : arg8, 
            tick_spacing                       : turbos_clmm::pool::get_pool_tick_spacing<T0, T1, T2>(arg3), 
            default_base_rebalance_percentage  : arg9, 
            default_limit_rebalance_percentage : arg10, 
            base_tick_step_minimum             : arg11, 
            limit_tick_step_minimum            : arg12, 
            status                             : 0,
        };
        let v7 = sui::object::id<Strategy>(&v6);
        turbos_vault::rewarder::register_strategy(arg2, v7);
        let v8 = CreateStrategyEvent{
            strategy_id          : v7, 
            clmm_pool_id         : v2, 
            effective_tick_lower : v0, 
            effective_tick_upper : v1, 
            coin_a_type_name     : v3, 
            coin_b_type_name     : v4, 
            fee_type_name        : v5,
        };
        sui::event::emit<CreateStrategyEvent>(v8);
        v6
    }
    
    fun decrease_clmm_liquidity<T0, T1, T2>(
        arg0: &mut turbos_clmm::position_nft::TurbosPositionNFT,
        arg1: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg2: &mut turbos_clmm::position_manager::Positions,
        arg3: u128,
        arg4: &sui::clock::Clock,
        arg5: &turbos_clmm::pool::Versioned,
        arg6: &mut sui::tx_context::TxContext
    ) : (sui::coin::Coin<T0>, sui::coin::Coin<T1>) {
        turbos_clmm::position_manager::decrease_liquidity_with_return_<T0, T1, T2>(arg1, arg2, arg0, arg3, 0, 0, sui::clock::timestamp_ms(arg4) + 60000, arg4, arg5, arg6)
    }
    
    public fun deposit<T0, T1, T2>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut turbos_vault::rewarder::RewarderManager,
        arg2: &mut Strategy,
        arg3: &mut Vault,
        arg4: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg5: &mut turbos_clmm::position_manager::Positions,
        arg6: sui::coin::Coin<T0>,
        arg7: sui::coin::Coin<T1>,
        arg8: &sui::clock::Clock,
        arg9: &turbos_clmm::pool::Versioned,
        arg10: &mut sui::tx_context::TxContext
    ) {
        turbos_vault::config::checked_package_version(arg0);
        assert!(arg2.status == 0, 15);
        assert!(arg2.clmm_pool_id == sui::object::id<turbos_clmm::pool::Pool<T0, T1, T2>>(arg4), 17);
        assert!(sui::object::id<Strategy>(arg2) == arg3.strategy_id, 18);
        sui::tx_context::sender(arg10);
        let v0 = sui::object::id<Vault>(arg3);
        let v1 = sui::coin::value<T0>(&arg6);
        let v2 = sui::coin::value<T1>(&arg7);
        assert!(v1 > 0 || v2 > 0, 1);
        merge_vault_balance<T0>(arg2, v0, sui::coin::into_balance<T0>(arg6));
        merge_vault_balance<T1>(arg2, v0, sui::coin::into_balance<T1>(arg7));
        let v3 = turbos_clmm::pool::get_pool_sqrt_price<T0, T1, T2>(arg4);
        let v4 = get_vault_base_lower_index(arg2, v0);
        let v5 = v4;
        let v6 = get_vault_base_upper_index(arg2, v0);
        let v7 = v6;
        let v8 = get_vault_base_clmm_position_id(arg2, v0);
        let v9 = get_vault_base_liquidity(arg2, v0);
        let v10 = get_vault_base_last_tick_index(arg2, v0);
        if (is_clmm_base_nft_exists(arg2, v0)) {
            if (calculate_liquidity(v3, v4, v6, get_vault_balance<T0>(arg2, v0), get_vault_balance<T1>(arg2, v0)) > 0) {
                let (v11, v12, v13, v14, v15) = increase_clmm_liquidity<T0, T1, T2>(arg2, v0, true, arg4, arg5, sui::coin::from_balance<T0>(take_vault_balance<T0>(arg2, v0), arg10), sui::coin::from_balance<T1>(take_vault_balance<T1>(arg2, v0), arg10), arg8, arg9, arg10);
                v9 = v15;
                v7 = v14;
                v5 = v13;
                merge_vault_balance<T0>(arg2, v0, sui::coin::into_balance<T0>(v11));
                merge_vault_balance<T1>(arg2, v0, sui::coin::into_balance<T1>(v12));
            };
        } else {
            if (calculate_liquidity(v3, v4, v6, get_vault_balance<T0>(arg2, v0), get_vault_balance<T1>(arg2, v0)) > 0) {
                let (v16, v17, v18) = mint_clmm_liquidity<T0, T1, T2>(arg4, arg5, sui::coin::from_balance<T0>(take_vault_balance<T0>(arg2, v0), arg10), sui::coin::from_balance<T1>(take_vault_balance<T1>(arg2, v0), arg10), v4, v6, arg8, arg9, arg10);
                let v19 = v16;
                merge_vault_balance<T0>(arg2, v0, sui::coin::into_balance<T0>(v17));
                merge_vault_balance<T1>(arg2, v0, sui::coin::into_balance<T1>(v18));
                let (v20, v21, v22) = turbos_clmm::position_manager::get_position_info(arg5, sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(&v19));
                v9 = v22;
                v7 = v21;
                v5 = v20;
                v8 = turbos_clmm::position_nft::position_id(&v19);
                fill_clmm_base_nft(arg2, v0, v19);
            };
            v10 = turbos_clmm::pool::get_pool_current_index<T0, T1, T2>(arg4);
        };
        let v23 = get_vault_limit_lower_index(arg2, v0);
        let v24 = v23;
        let v25 = get_vault_limit_upper_index(arg2, v0);
        let v26 = v25;
        let v27 = get_vault_limit_liquidity(arg2, v0);
        if (is_clmm_limit_nft_exists(arg2, v0)) {
            if (calculate_liquidity(v3, v23, v25, get_vault_balance<T0>(arg2, v0), get_vault_balance<T1>(arg2, v0)) > 0) {
                let (v28, v29, v30, v31, v32) = increase_clmm_liquidity<T0, T1, T2>(arg2, v0, false, arg4, arg5, sui::coin::from_balance<T0>(take_vault_balance<T0>(arg2, v0), arg10), sui::coin::from_balance<T1>(take_vault_balance<T1>(arg2, v0), arg10), arg8, arg9, arg10);
                v27 = v32;
                v26 = v31;
                v24 = v30;
                merge_vault_balance<T0>(arg2, v0, sui::coin::into_balance<T0>(v28));
                merge_vault_balance<T1>(arg2, v0, sui::coin::into_balance<T1>(v29));
            };
        };
        update_vault_info_with_tick_range(arg2, v0, v8, v5, v7, v9, get_vault_limit_clmm_position_id(arg2, v0), v24, v26, v27, v3, v10, get_vault_limit_last_tick_index(arg2, v0));
        update_strategy_reward_info(arg1, arg2, v0, arg8);
        let v33 = DepositEvent{
            vault_id     : v0, 
            strategy_id  : sui::object::id<Strategy>(arg2), 
            clmm_pool_id : sui::object::id<turbos_clmm::pool::Pool<T0, T1, T2>>(arg4), 
            amount_a     : v1, 
            amount_b     : v2,
        };
        sui::event::emit<DepositEvent>(v33);
    }
    
    fun extract_clmm_base_nft(
        arg0: &mut Strategy,
        arg1: sui::object::ID
    ) : turbos_clmm::position_nft::TurbosPositionNFT {
        std::option::extract<turbos_clmm::position_nft::TurbosPositionNFT>(&mut borrow_mut_vault_account(arg0, arg1).clmm_base_nft)
    }
    
    fun extract_clmm_limit_nft(
        arg0: &mut Strategy,
        arg1: sui::object::ID
    ) : turbos_clmm::position_nft::TurbosPositionNFT {
        std::option::extract<turbos_clmm::position_nft::TurbosPositionNFT>(&mut borrow_mut_vault_account(arg0, arg1).clmm_limit_nft)
    }
    
    fun fill_clmm_base_nft(
        arg0: &mut Strategy,
        arg1: sui::object::ID,
        arg2: turbos_clmm::position_nft::TurbosPositionNFT
    ) {
        std::option::fill<turbos_clmm::position_nft::TurbosPositionNFT>(&mut borrow_mut_vault_account(arg0, arg1).clmm_base_nft, arg2);
    }
    
    fun fill_clmm_limit_nft(
        arg0: &mut Strategy,
        arg1: sui::object::ID,
        arg2: turbos_clmm::position_nft::TurbosPositionNFT
    ) {
        std::option::fill<turbos_clmm::position_nft::TurbosPositionNFT>(&mut borrow_mut_vault_account(arg0, arg1).clmm_limit_nft, arg2);
    }
    
    public fun floor_tick_index(
        arg0: turbos_clmm::i32::I32,
        arg1: u32,
        arg2: bool
    ) : turbos_clmm::i32::I32 {
        let v0 = turbos_clmm::i32::from(arg1);
        if (turbos_clmm::i32::eq(turbos_clmm::i32::mod(arg0, v0), turbos_clmm::i32::zero())) {
            if (arg2) {
                return turbos_clmm::i32::sub(arg0, v0)
            };
            return turbos_clmm::i32::add(arg0, v0)
        };
        let v1 = turbos_clmm::i32::sub(arg0, turbos_clmm::i32::mod(arg0, v0));
        let v2 = v1;
        if (turbos_clmm::i32::gt(arg0, turbos_clmm::i32::zero())) {
            if (!arg2) {
                v2 = turbos_clmm::i32::add(v1, v0);
            };
        } else {
            if (arg2) {
                v2 = turbos_clmm::i32::sub(v1, v0);
            };
        };
        v2
    }
    
    public fun get_check_rebalance_info(arg0: &CheckRebalance) : (bool, turbos_clmm::i32::I32, turbos_clmm::i32::I32, bool, turbos_clmm::i32::I32, turbos_clmm::i32::I32) {
        (arg0.rebalance, arg0.base_lower_index, arg0.base_upper_index, arg0.base_just_increase, arg0.limit_lower_index, arg0.limit_upper_index)
    }
    
    // deprecated
    public fun get_management_fee_rate(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &Strategy,
        arg2: sui::object::ID,
        arg3: &mut sui::tx_context::TxContext
    ) : u64 {
        abort 0
    }
    
    public fun get_management_fee_rate_v2(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut turbos_vault::config::UserTierConfig,
        arg2: &Strategy,
        arg3: sui::object::ID,
        arg4: &mut sui::tx_context::TxContext
    ) : u64 {
        turbos_vault::config::checked_package_version(arg0);
        let v0 = borrow_vault_info(arg2, arg3);
        let v1 = if (!std::option::is_none<u64>(&v0.management_fee_rate)) {
            *std::option::borrow<u64>(&v0.management_fee_rate)
        } else {
            arg2.management_fee_rate
        };
        let v2 = v1;
        let (_, v4) = turbos_vault::config::get_tier_v2(arg0, arg1, sui::tx_context::sender(arg4));
        if (v4 > 0) {
            v2 = v1 * (1000000 - v4) / 1000000;
        };
        v2
    }
    
    public fun get_performance_fee_rate(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &Strategy,
        arg2: sui::object::ID,
        arg3: &mut sui::tx_context::TxContext
    ) : u64 {
        let v0 = borrow_vault_info(arg1, arg2);
        if (!std::option::is_none<u64>(&v0.performance_fee_rate)) {
            *std::option::borrow<u64>(&v0.performance_fee_rate)
        } else {
            arg1.performance_fee_rate
        }
    }
    
    public fun get_strategy_status(arg0: &Strategy) : u8 {
        arg0.status
    }
    
    public fun get_strategy_tick_spacing(arg0: &Strategy) : u32 {
        arg0.tick_spacing
    }
    
    public fun get_strategy_total_share(arg0: &Strategy) : u128 {
        arg0.total_share
    }
    
    fun get_type_name_str<T0>() : std::string::String {
        std::string::from_ascii(std::type_name::into_string(std::type_name::get<T0>()))
    }
    
    public fun get_vault_amount<T0, T1, T2>(
        arg0: &Strategy,
        arg1: &turbos_clmm::pool::Pool<T0, T1, T2>,
        arg2: sui::object::ID
    ) : (u64, u64, u64, u64, u64, u64) {
        let v0 = sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg2);
        let v1 = v0.base_liquidity;
        let v2 = v0.limit_liquidity;
        let v3 = turbos_clmm::pool::get_pool_sqrt_price<T0, T1, T2>(arg1);
        let v4 = 0;
        let v5 = 0;
        if (v1 > 0) {
            let (v6, v7) = turbos_clmm::math_liquidity::get_amount_for_liquidity(v3, turbos_clmm::math_tick::sqrt_price_from_tick_index(v0.base_lower_index), turbos_clmm::math_tick::sqrt_price_from_tick_index(v0.base_upper_index), v1);
            v4 = v7;
            v5 = v6;
        };
        let v8 = 0;
        let v9 = 0;
        if (v2 > 0) {
            let (v10, v11) = turbos_clmm::math_liquidity::get_amount_for_liquidity(v3, turbos_clmm::math_tick::sqrt_price_from_tick_index(v0.limit_lower_index), turbos_clmm::math_tick::sqrt_price_from_tick_index(v0.limit_upper_index), v2);
            v8 = v11;
            v9 = v10;
        };
        (get_vault_balance<T0>(arg0, arg2), get_vault_balance<T1>(arg0, arg2), v5 as u64, v4 as u64, v9 as u64, v8 as u64)
    }
    
    public fun get_vault_balance<T0>(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : u64 {
        let v0 = borrow_vault_account(arg0, arg1);
        let v1 = get_type_name_str<T0>();
        if (sui::bag::contains<std::string::String>(&v0.balances, v1)) {
            sui::balance::value<T0>(sui::bag::borrow<std::string::String, sui::balance::Balance<T0>>(&v0.balances, v1))
        } else {
            0
        }
    }
    
    public fun get_vault_base_clmm_position_id(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : sui::object::ID {
        sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1).base_clmm_position_id
    }
    
    public fun get_vault_base_last_tick_index(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : turbos_clmm::i32::I32 {
        sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1).base_last_tick_index
    }
    
    public fun get_vault_base_liquidity(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : u128 {
        sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1).base_liquidity
    }
    
    public fun get_vault_base_lower_index(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : turbos_clmm::i32::I32 {
        sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1).base_lower_index
    }
    
    public fun get_vault_base_tick_step(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : u32 {
        sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1).base_tick_step
    }
    
    public fun get_vault_base_upper_index(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : turbos_clmm::i32::I32 {
        sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1).base_upper_index
    }
    
    public fun get_vault_info(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : (turbos_clmm::i32::I32, turbos_clmm::i32::I32, u128, turbos_clmm::i32::I32, turbos_clmm::i32::I32, u128, u128, u128, sui::vec_map::VecMap<std::type_name::TypeName, VaultRewardInfo>) {
        let v0 = sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1);
        (v0.base_lower_index, v0.base_upper_index, v0.base_liquidity, v0.limit_lower_index, v0.limit_upper_index, v0.limit_liquidity, v0.sqrt_price, v0.share, v0.rewards)
    }
    
    public fun get_vault_limit_clmm_position_id(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : sui::object::ID {
        sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1).limit_clmm_position_id
    }
    
    public fun get_vault_limit_last_tick_index(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : turbos_clmm::i32::I32 {
        sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1).limit_last_tick_index
    }
    
    public fun get_vault_limit_liquidity(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : u128 {
        sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1).limit_liquidity
    }
    
    public fun get_vault_limit_lower_index(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : turbos_clmm::i32::I32 {
        sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1).limit_lower_index
    }
    
    public fun get_vault_limit_tick_step(arg0: &Strategy, arg1: sui::object::ID) : u32 {
        sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1).limit_tick_step
    }
    
    public fun get_vault_limit_upper_index(arg0: &Strategy, arg1: sui::object::ID) : turbos_clmm::i32::I32 {
        sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1).limit_upper_index
    }
    
    public fun get_vault_share(arg0: &Strategy, arg1: sui::object::ID) : u128 {
        sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1).share
    }
    
    public fun get_vault_sqrt_price(arg0: &Strategy, arg1: sui::object::ID) : u128 {
        sui::linked_table::borrow<sui::object::ID, VaultInfo>(&arg0.vaults, arg1).sqrt_price
    }
    
    public fun get_vault_total_amount<T0, T1, T2>(arg0: &Strategy, arg1: &turbos_clmm::pool::Pool<T0, T1, T2>, arg2: sui::object::ID) : (u64, u64) {
        let (v0, v1, v2, v3, v4, v5) = get_vault_amount<T0, T1, T2>(arg0, arg1, arg2);
        (v0 + v2 + v4, v1 + v3 + v5)
    }
    
    fun increase_clmm_liquidity<T0, T1, T2>(
        arg0: &mut Strategy,
        arg1: sui::object::ID,
        arg2: bool,
        arg3: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg4: &mut turbos_clmm::position_manager::Positions,
        arg5: sui::coin::Coin<T0>,
        arg6: sui::coin::Coin<T1>,
        arg7: &sui::clock::Clock,
        arg8: &turbos_clmm::pool::Versioned,
        arg9: &mut sui::tx_context::TxContext
    ) : (sui::coin::Coin<T0>, sui::coin::Coin<T1>, turbos_clmm::i32::I32, turbos_clmm::i32::I32, u128) {
        let v0 = if (arg2) {
            borrow_mut_clmm_base_nft(arg0, arg1)
        } else {
            borrow_mut_clmm_limit_nft(arg0, arg1)
        };
        let (v1, v2) = turbos_clmm::position_manager::increase_liquidity_with_return_<T0, T1, T2>(arg3, arg4, coin_to_vec<T0>(arg5), coin_to_vec<T1>(arg6), v0, sui::coin::value<T0>(&arg5), sui::coin::value<T1>(&arg6), 0, 0, sui::clock::timestamp_ms(arg7) + 60000, arg7, arg8, arg9);
        let (v3, v4, v5) = turbos_clmm::position_manager::get_position_info(arg4, sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(v0));
        (v1, v2, v3, v4, v5)
    }
    
    fun init(arg0: VAULT, arg1: &mut sui::tx_context::TxContext) {
        let v0 = std::vector::empty<std::string::String>();
        std::vector::push_back<std::string::String>(&mut v0, std::string::utf8(b"name"));
        std::vector::push_back<std::string::String>(&mut v0, std::string::utf8(b"coin_type_a"));
        std::vector::push_back<std::string::String>(&mut v0, std::string::utf8(b"coin_type_b"));
        std::vector::push_back<std::string::String>(&mut v0, std::string::utf8(b"description"));
        std::vector::push_back<std::string::String>(&mut v0, std::string::utf8(b"image_url"));
        std::vector::push_back<std::string::String>(&mut v0, std::string::utf8(b"project_url"));
        std::vector::push_back<std::string::String>(&mut v0, std::string::utf8(b"creator"));
        let v1 = std::vector::empty<std::string::String>();
        std::vector::push_back<std::string::String>(&mut v1, std::string::utf8(b"{name}"));
        std::vector::push_back<std::string::String>(&mut v1, std::string::utf8(b"{coin_type_a}"));
        std::vector::push_back<std::string::String>(&mut v1, std::string::utf8(b"{coin_type_b}"));
        std::vector::push_back<std::string::String>(&mut v1, std::string::utf8(b"{description}"));
        std::vector::push_back<std::string::String>(&mut v1, std::string::utf8(b"{image_url}"));
        std::vector::push_back<std::string::String>(&mut v1, std::string::utf8(b"https://turbos.finance"));
        std::vector::push_back<std::string::String>(&mut v1, std::string::utf8(b"Turbos Team"));
        let v2 = sui::package::claim<VAULT>(arg0, arg1);
        let v3 = sui::display::new<Vault>(&v2, arg1);
        sui::display::add_multiple<Vault>(&mut v3, v0, v1);
        sui::display::update_version<Vault>(&mut v3);
        sui::transfer::public_transfer<sui::package::Publisher>(v2, sui::tx_context::sender(arg1));
        sui::transfer::public_transfer<sui::display::Display<Vault>>(v3, sui::tx_context::sender(arg1));
    }
    
    fun init_account_balance(arg0: &mut Strategy, arg1: sui::object::ID, arg2: &mut sui::tx_context::TxContext) {
        let v0 = Account{
            clmm_base_nft  : std::option::none<turbos_clmm::position_nft::TurbosPositionNFT>(), 
            clmm_limit_nft : std::option::none<turbos_clmm::position_nft::TurbosPositionNFT>(), 
            balances       : sui::bag::new(arg2),
        };
        sui::table::add<sui::object::ID, Account>(&mut arg0.accounts, arg1, v0);
    }
    
    public fun is_clmm_base_nft_exists(arg0: &Strategy, arg1: sui::object::ID) : bool {
        std::option::is_some<turbos_clmm::position_nft::TurbosPositionNFT>(&borrow_vault_account(arg0, arg1).clmm_base_nft)
    }
    
    public fun is_clmm_limit_nft_exists(arg0: &Strategy, arg1: sui::object::ID) : bool {
        std::option::is_some<turbos_clmm::position_nft::TurbosPositionNFT>(&borrow_vault_account(arg0, arg1).clmm_limit_nft)
    }
    
    fun merge_protocol_asset<T0>(arg0: &mut Strategy, arg1: sui::balance::Balance<T0>) {
        sui::balance::value<T0>(&arg1);
        let v0 = get_type_name_str<T0>();
        if (sui::bag::contains<std::string::String>(&arg0.protocol_fees, v0)) {
            sui::balance::join<T0>(sui::bag::borrow_mut<std::string::String, sui::balance::Balance<T0>>(&mut arg0.protocol_fees, v0), arg1);
        } else {
            sui::bag::add<std::string::String, sui::balance::Balance<T0>>(&mut arg0.protocol_fees, v0, arg1);
        };
    }
    
    fun merge_vault_balance<T0>(
        arg0: &mut Strategy,
        arg1: sui::object::ID,
        arg2: sui::balance::Balance<T0>
    ) {
        sui::balance::value<T0>(&arg2);
        let v0 = get_type_name_str<T0>();
        let v1 = borrow_mut_vault_account(arg0, arg1);
        if (sui::bag::contains<std::string::String>(&v1.balances, v0)) {
            sui::balance::join<T0>(sui::bag::borrow_mut<std::string::String, sui::balance::Balance<T0>>(&mut v1.balances, v0), arg2);
        } else {
            sui::bag::add<std::string::String, sui::balance::Balance<T0>>(&mut v1.balances, v0, arg2);
        };
    }
    
    fun mint_clmm_liquidity<T0, T1, T2>(
        arg0: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg1: &mut turbos_clmm::position_manager::Positions,
        arg2: sui::coin::Coin<T0>,
        arg3: sui::coin::Coin<T1>,
        arg4: turbos_clmm::i32::I32,
        arg5: turbos_clmm::i32::I32,
        arg6: &sui::clock::Clock,
        arg7: &turbos_clmm::pool::Versioned,
        arg8: &mut sui::tx_context::TxContext
    ) : (turbos_clmm::position_nft::TurbosPositionNFT, sui::coin::Coin<T0>, sui::coin::Coin<T1>) {
        turbos_clmm::position_manager::mint_with_return_<T0, T1, T2>(arg0, arg1, coin_to_vec<T0>(arg2), coin_to_vec<T1>(arg3), turbos_clmm::i32::abs_u32(arg4), turbos_clmm::i32::is_neg(arg4), turbos_clmm::i32::abs_u32(arg5), turbos_clmm::i32::is_neg(arg5), sui::coin::value<T0>(&arg2), sui::coin::value<T1>(&arg3), 0, 0, sui::clock::timestamp_ms(arg6) + 60000, arg6, arg7, arg8)
    }
    
    public fun open_vault<T0, T1, T2>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut Strategy,
        arg2: &turbos_clmm::pool::Pool<T0, T1, T2>,
        arg3: u32,
        arg4: bool,
        arg5: u32,
        arg6: bool,
        arg7: u32,
        arg8: bool,
        arg9: u32,
        arg10: bool,
        arg11: u32,
        arg12: u32,
        arg13: &mut sui::tx_context::TxContext
    ) : Vault {
        turbos_vault::config::checked_package_version(arg0);
        assert!(arg1.status == 0, 15);
        assert!(arg1.clmm_pool_id == sui::object::id<turbos_clmm::pool::Pool<T0, T1, T2>>(arg2), 17);
        assert!(arg11 >= arg1.base_tick_step_minimum && arg12 >= arg1.limit_tick_step_minimum, 14);
        let v0 = turbos_clmm::i32::from_u32_neg(arg3, arg4);
        let v1 = turbos_clmm::i32::from_u32_neg(arg5, arg6);
        let v2 = turbos_clmm::i32::from_u32_neg(arg7, arg8);
        let v3 = turbos_clmm::i32::from_u32_neg(arg9, arg10);
        let v4 = turbos_clmm::pool::get_pool_current_index<T0, T1, T2>(arg2);
        check_tick_range(arg1.base_tick_step_minimum, v4, v0, v1, arg1.tick_spacing);
        check_tick_range(arg1.limit_tick_step_minimum, v4, v2, v3, arg1.tick_spacing);
        let v5 = std::type_name::get<T0>();
        let v6 = std::type_name::get<T1>();
        let v7 = arg1.vault_index + 1;
        let v8 = sui::object::id<Strategy>(arg1);
        let v9 = Vault{
            id               : sui::object::new(arg13), 
            index            : v7, 
            strategy_id      : v8, 
            coin_a_type_name : v5, 
            coin_b_type_name : v6, 
            name             : std::string::utf8(b"Turbos Vault's NFT"), 
            description      : std::string::utf8(b"Turbos Vault's NFT"), 
            url              : arg1.image_url,
        };
        init_account_balance(arg1, sui::object::id<Vault>(&v9), arg13);
        let v10 = sui::object::id<Vault>(&v9);
        let v11 = VaultInfo{
            vault_id                  : v10, 
            strategy_id               : v8, 
            coin_a_type_name          : v5, 
            coin_b_type_name          : v6, 
            base_clmm_position_id     : sui::object::id_from_address(@0x0), 
            base_lower_index          : v0, 
            base_upper_index          : v1, 
            base_liquidity            : 0, 
            limit_clmm_position_id    : sui::object::id_from_address(@0x0), 
            limit_lower_index         : v2, 
            limit_upper_index         : v3, 
            limit_liquidity           : 0, 
            sqrt_price                : 0, 
            base_last_tick_index      : turbos_clmm::i32::zero(), 
            limit_last_tick_index     : turbos_clmm::i32::zero(), 
            base_rebalance_threshold  : arg1.default_base_rebalance_percentage, 
            limit_rebalance_threshold : arg1.default_limit_rebalance_percentage, 
            base_tick_step            : arg11, 
            limit_tick_step           : arg12, 
            share                     : 0, 
            rewards                   : sui::vec_map::empty<std::type_name::TypeName, VaultRewardInfo>(), 
            management_fee_rate       : std::option::none<u64>(), 
            performance_fee_rate      : std::option::none<u64>(),
        };
        sui::linked_table::push_back<sui::object::ID, VaultInfo>(&mut arg1.vaults, v10, v11);
        arg1.vault_index = v7;
        let v12 = OpenVaultEvent{
            vault_id     : v10, 
            strategy_id  : v8, 
            clmm_pool_id : arg1.clmm_pool_id,
        };
        sui::event::emit<OpenVaultEvent>(v12);
        v9
    }
    
    // deprecated
    // public fun rebalance<T0, T1, T2>(
    //     arg0: &turbos_vault::config::OperatorCap,
    //     arg1: &turbos_vault::config::GlobalConfig,
    //     arg2: &mut turbos_vault::rewarder::RewarderManager,
    //     arg3: &mut Strategy,
    //     arg4: sui::object::ID,
    //     arg5: bool, arg6: bool,
    //     arg7: u32,
    //     arg8: bool,
    //     arg9: u32,
    //     arg10: bool,
    //     arg11: u32,
    //     arg12: bool,
    //     arg13: u32,
    //     arg14: bool,
    //     arg15: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
    //     arg16: &mut turbos_clmm::position_manager::Positions,
    //     arg17: &sui::clock::Clock,
    //     arg18: &turbos_clmm::pool::Versioned,
    //     arg19: &mut sui::tx_context::TxContext
    // ) {
    //     abort 0
    // }
    
    public fun rebalance_with_fee<T0, T1, T2>(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut turbos_vault::rewarder::RewarderManager,
        arg3: &mut Strategy,
        arg4: sui::object::ID,
        arg5: bool,
        arg6: bool,
        arg7: u32,
        arg8: bool,
        arg9: u32,
        arg10: bool,
        arg11: u32,
        arg12: bool,
        arg13: u32,
        arg14: bool,
        arg15: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg16: &mut turbos_clmm::position_manager::Positions,
        arg17: u64,
        arg18: u64,
        arg19: &sui::clock::Clock,
        arg20: &turbos_clmm::pool::Versioned,
        arg21: &mut sui::tx_context::TxContext
    ) : (sui::coin::Coin<T0>, sui::coin::Coin<T1>) {
        turbos_vault::config::checked_package_version(arg1);
        assert!(arg3.status == 0, 15);
        assert!(arg3.clmm_pool_id == sui::object::id<turbos_clmm::pool::Pool<T0, T1, T2>>(arg15), 17);
        assert!(arg5, 20);
        turbos_vault::config::check_rebalance_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        let v0 = turbos_clmm::i32::from_u32_neg(arg7, arg8);
        let v1 = v0;
        let v2 = turbos_clmm::i32::from_u32_neg(arg9, arg10);
        let v3 = v2;
        let v4 = turbos_clmm::i32::from_u32_neg(arg11, arg12);
        let v5 = turbos_clmm::i32::from_u32_neg(arg13, arg14);
        let v6 = turbos_clmm::pool::get_pool_sqrt_price<T0, T1, T2>(arg15);
        let v7 = turbos_clmm::pool::get_pool_current_index<T0, T1, T2>(arg15);
        let v8 = sui::balance::zero<T0>();
        let v9 = sui::balance::zero<T1>();
        if (!arg6) {
            check_tick_range(get_vault_base_tick_step(arg3, arg4), v7, v0, v2, arg3.tick_spacing);
        };
        check_tick_range(get_vault_limit_tick_step(arg3, arg4), v7, v4, v5, arg3.tick_spacing);
        collect_clmm_fees<T0, T1, T2>(arg1, arg3, arg4, arg15, arg16, arg19, arg20, arg21);
        let v10 = get_vault_base_clmm_position_id(arg3, arg4);
        let v11 = get_vault_base_liquidity(arg3, arg4);
        let v12 = get_vault_limit_clmm_position_id(arg3, arg4);
        let v13 = get_vault_limit_liquidity(arg3, arg4);
        let v14 = get_vault_base_last_tick_index(arg3, arg4);
        get_vault_limit_last_tick_index(arg3, arg4);
        if (is_clmm_limit_nft_exists(arg3, arg4)) {
            let v15 = borrow_mut_clmm_limit_nft(arg3, arg4);
            let (_, _, v18) = turbos_clmm::position_manager::get_position_info(arg16, sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(v15));
            if (v18 > 0) {
                let (v19, v20) = decrease_clmm_liquidity<T0, T1, T2>(v15, arg15, arg16, v18, arg19, arg20, arg21);
                v13 = 0;
                merge_vault_balance<T0>(arg3, arg4, sui::coin::into_balance<T0>(v19));
                merge_vault_balance<T1>(arg3, arg4, sui::coin::into_balance<T1>(v20));
            };
            burn_clmm_limit_nft<T0, T1, T2>(arg3, arg4, arg16, arg20, arg21);
        };
        let v21 = v5;
        let v22 = v4;
        if (is_clmm_base_nft_exists(arg3, arg4)) {
            if (arg6) {
                if (calculate_liquidity(v6, v0, v2, get_vault_balance<T0>(arg3, arg4), get_vault_balance<T1>(arg3, arg4)) > 0) {
                    let (v23, v24, v25, v26, v27) = increase_clmm_liquidity<T0, T1, T2>(arg3, arg4, true, arg15, arg16, sui::coin::from_balance<T0>(take_vault_balance<T0>(arg3, arg4), arg21), sui::coin::from_balance<T1>(take_vault_balance<T1>(arg3, arg4), arg21), arg19, arg20, arg21);
                    v11 = v27;
                    v3 = v26;
                    v1 = v25;
                    merge_vault_balance<T0>(arg3, arg4, sui::coin::into_balance<T0>(v23));
                    merge_vault_balance<T1>(arg3, arg4, sui::coin::into_balance<T1>(v24));
                };
            } else {
                let v28 = borrow_mut_clmm_base_nft(arg3, arg4);
                let (_, _, v31) = turbos_clmm::position_manager::get_position_info(arg16, sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(v28));
                let (v32, v33) = decrease_clmm_liquidity<T0, T1, T2>(v28, arg15, arg16, v31, arg19, arg20, arg21);
                merge_vault_balance<T0>(arg3, arg4, sui::coin::into_balance<T0>(v32));
                merge_vault_balance<T1>(arg3, arg4, sui::coin::into_balance<T1>(v33));
                burn_clmm_base_nft<T0, T1, T2>(arg3, arg4, arg16, arg20, arg21);
                v11 = 0;
                if (calculate_liquidity(v6, v0, v2, get_vault_balance<T0>(arg3, arg4), get_vault_balance<T1>(arg3, arg4)) > 0) {
                    let (v34, v35, v36) = mint_clmm_liquidity<T0, T1, T2>(arg15, arg16, sui::coin::from_balance<T0>(take_vault_balance<T0>(arg3, arg4), arg21), sui::coin::from_balance<T1>(take_vault_balance<T1>(arg3, arg4), arg21), v0, v2, arg19, arg20, arg21);
                    let v37 = v34;
                    merge_vault_balance<T0>(arg3, arg4, sui::coin::into_balance<T0>(v35));
                    merge_vault_balance<T1>(arg3, arg4, sui::coin::into_balance<T1>(v36));
                    let (_, _, v40) = turbos_clmm::position_manager::get_position_info(arg16, sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(&v37));
                    v11 = v40;
                    v10 = turbos_clmm::position_nft::position_id(&v37);
                    fill_clmm_base_nft(arg3, arg4, v37);
                };
                v14 = v7;
            };
        } else {
            if (calculate_liquidity(v6, v0, v2, get_vault_balance<T0>(arg3, arg4), get_vault_balance<T1>(arg3, arg4)) > 0) {
                let (v41, v42, v43) = mint_clmm_liquidity<T0, T1, T2>(arg15, arg16, sui::coin::from_balance<T0>(take_vault_balance<T0>(arg3, arg4), arg21), sui::coin::from_balance<T1>(take_vault_balance<T1>(arg3, arg4), arg21), v0, v2, arg19, arg20, arg21);
                let v44 = v41;
                merge_vault_balance<T0>(arg3, arg4, sui::coin::into_balance<T0>(v42));
                merge_vault_balance<T1>(arg3, arg4, sui::coin::into_balance<T1>(v43));
                let (_, _, v47) = turbos_clmm::position_manager::get_position_info(arg16, sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(&v44));
                v11 = v47;
                v10 = turbos_clmm::position_nft::position_id(&v44);
                fill_clmm_base_nft(arg3, arg4, v44);
            };
            v14 = v7;
        };
        let v48 = get_vault_balance<T0>(arg3, arg4);
        let v49 = get_vault_balance<T1>(arg3, arg4);
        let v50 = floor_tick_index(v7, arg3.tick_spacing, true);
        let v51 = floor_tick_index(v7, arg3.tick_spacing, false);
        let v52 = calculate_liquidity(v6, v4, v50, v48, v49);
        let v53 = v52;
        let v54 = calculate_liquidity(v6, v51, v5, v48, v49);
        let v55 = v54;
        if (arg17 > 0 || arg18 > 0) {
            if (v52 > v54) {
                arg17 = 0;
            } else {
                arg18 = 0;
            };
            collect_rebalance_fee<T0, T1>(arg3, arg4, arg17, arg18, &mut v8, &mut v9);
            let v56 = get_vault_balance<T0>(arg3, arg4);
            let v57 = get_vault_balance<T1>(arg3, arg4);
            v53 = calculate_liquidity(v6, v4, v50, v56, v57);
            v55 = calculate_liquidity(v6, v51, v5, v56, v57);
        };
        if (v53 > 0 || v55 > 0) {
            let (v58, v59) = if (v53 > v55) {
                (v4, v50)
            } else {
                (v51, v5)
            };
            v21 = v59;
            v22 = v58;
            let (v60, v61, v62) = mint_clmm_liquidity<T0, T1, T2>(arg15, arg16, sui::coin::from_balance<T0>(take_vault_balance<T0>(arg3, arg4), arg21), sui::coin::from_balance<T1>(take_vault_balance<T1>(arg3, arg4), arg21), v58, v59, arg19, arg20, arg21);
            let v63 = v60;
            let (_, _, v66) = turbos_clmm::position_manager::get_position_info(arg16, sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(&v63));
            v13 = v66;
            v12 = turbos_clmm::position_nft::position_id(&v63);
            fill_clmm_limit_nft(arg3, arg4, v63);
            merge_vault_balance<T0>(arg3, arg4, sui::coin::into_balance<T0>(v61));
            merge_vault_balance<T1>(arg3, arg4, sui::coin::into_balance<T1>(v62));
        };
        update_vault_info_with_tick_range(arg3, arg4, v10, v1, v3, v11, v12, v22, v21, v13, v6, v14, v7);
        update_strategy_reward_info(arg2, arg3, arg4, arg19);
        let v67 = CheckRebalance{
            vault_id           : arg4, 
            rebalance          : arg5, 
            base_lower_index   : v1, 
            base_upper_index   : v3, 
            base_just_increase : arg6, 
            limit_lower_index  : v22, 
            limit_upper_index  : v21,
        };
        let (v68, v69, v70, v71, v72, v73) = get_vault_amount<T0, T1, T2>(arg3, arg15, arg4);
        let v74 = RebalanceEvent{
            vault_id       : arg4, 
            strategy_id    : sui::object::id<Strategy>(arg3), 
            clmm_pool_id   : sui::object::id<turbos_clmm::pool::Pool<T0, T1, T2>>(arg15), 
            checkRebalance : v67, 
            sqrt_price     : v6, 
            amount_a_left  : v68, 
            amount_b_left  : v69, 
            base_amount_a  : v70, 
            base_amount_b  : v71, 
            limit_amount_a : v72, 
            limit_amount_b : v73,
        };
        sui::event::emit<RebalanceEvent>(v74);
        (sui::coin::from_balance<T0>(v8, arg21), sui::coin::from_balance<T1>(v9, arg21))
    }
    
    fun remove_vault_info(
        arg0: &mut Strategy,
        arg1: sui::object::ID
    ) : VaultInfo {
        sui::linked_table::remove<sui::object::ID, VaultInfo>(&mut arg0.vaults, arg1)
    }
    
    fun take_protocol_asset_by_amount<T0>(
        arg0: &mut Strategy,
        arg1: u64
    ) : sui::balance::Balance<T0> {
        let v0 = get_type_name_str<T0>();
        assert!(sui::bag::contains<std::string::String>(&arg0.protocol_fees, v0), 11);
        let v1 = sui::bag::borrow_mut<std::string::String, sui::balance::Balance<T0>>(&mut arg0.protocol_fees, v0);
        assert!(sui::balance::value<T0>(v1) >= arg1, 12);
        sui::balance::split<T0>(v1, arg1)
    }
    
    fun take_vault_balance<T0>(
        arg0: &mut Strategy,
        arg1: sui::object::ID
    ) : sui::balance::Balance<T0> {
        let v0 = get_type_name_str<T0>();
        let v1 = borrow_mut_vault_account(arg0, arg1);
        if (sui::bag::contains<std::string::String>(&v1.balances, v0)) {
            sui::bag::remove<std::string::String, sui::balance::Balance<T0>>(&mut v1.balances, v0)
        } else {
            sui::balance::zero<T0>()
        }
    }
    
    fun take_vault_balance_by_amount<T0>(
        arg0: &mut Strategy,
        arg1: sui::object::ID,
        arg2: u64
    ) : sui::balance::Balance<T0> {
        let v0 = get_type_name_str<T0>();
        let v1 = borrow_mut_vault_account(arg0, arg1);
        if (sui::bag::contains<std::string::String>(&v1.balances, v0) && arg2 > 0) {
            let v3 = sui::bag::borrow_mut<std::string::String, sui::balance::Balance<T0>>(&mut v1.balances, v0);
            let v4 = sui::balance::value<T0>(v3);
            let v5 = if (v4 >= arg2) {
                arg2
            } else {
                v4
            };
            sui::balance::split<T0>(v3, v5)
        } else {
            sui::balance::zero<T0>()
        }
    }
    
    public(friend) fun update_strategy_base_minimum_threshold(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut Strategy,
        arg3: u32
    ) : u32 {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_vault_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        arg2.base_tick_step_minimum = arg3;
        arg3
    }
    
    public(friend) fun update_strategy_default_base_rebalance_threshold(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut Strategy,
        arg3: u32
    ) : u32 {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_vault_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        arg2.default_base_rebalance_percentage = arg3;
        arg3
    }
    
    public(friend) fun update_strategy_default_limit_rebalance_threshold(
        arg0: &turbos_vault::config::OperatorCap, arg1: &turbos_vault::config::GlobalConfig, arg2: &mut Strategy, arg3: u32) : u32 {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_vault_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        arg2.default_limit_rebalance_percentage = arg3;
        arg3
    }
    
    public(friend) fun update_strategy_image_url(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut Strategy,
        arg3: std::string::String
    ) : std::string::String {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_vault_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        arg2.image_url = arg3;
        arg3
    }
    
    public(friend) fun update_strategy_limit_minimum_threshold(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut Strategy,
        arg3: u32
    ) : u32 {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_vault_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        arg2.limit_tick_step_minimum = arg3;
        arg3
    }
    
    public(friend) fun update_strategy_management_fee_rate(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut Strategy,
        arg3: u64
    ) : u64 {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_vault_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        assert!(arg3 <= 1000000, 5);
        arg2.management_fee_rate = arg3;
        let v0 = UpdateStrategyManagementFeeRateEvent{
            strategy_id : sui::object::id<Strategy>(arg2), 
            old_rate    : arg2.management_fee_rate, 
            new_rate    : arg3,
        };
        sui::event::emit<UpdateStrategyManagementFeeRateEvent>(v0);
        arg3
    }
    
    public(friend) fun update_strategy_performance_fee_rate(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut Strategy,
        arg3: u64
    ) : u64 {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_vault_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        assert!(arg3 <= 1000000, 5);
        arg2.performance_fee_rate = arg3;
        let v0 = UpdateStrategyPerformanceFeeRateEvent{
            strategy_id : sui::object::id<Strategy>(arg2), 
            old_rate    : arg2.performance_fee_rate, 
            new_rate    : arg3,
        };
        sui::event::emit<UpdateStrategyPerformanceFeeRateEvent>(v0);
        arg3
    }
    
    fun update_strategy_reward_info(
        arg0: &mut turbos_vault::rewarder::RewarderManager,
        arg1: &mut Strategy,
        arg2: sui::object::ID,
        arg3: &sui::clock::Clock
    ) : u128 {
        let v0 = 0;
        let v1 = v0;
        let v2 = sui::object::id<Strategy>(arg1);
        let (v3, v4, v5, v6, v7, v8, v9, v10, _) = get_vault_info(arg1, arg2);
        if (!turbos_vault::rewarder::is_in_black_list(arg0, sui::object::id_to_address(&arg2))) {
            if (is_clmm_base_nft_exists(arg1, arg2)) {
                v1 = v0 + calculate_position_share(v3, v4, v5, v9, arg1.effective_tick_lower, arg1.effective_tick_upper);
            };
            if (is_clmm_limit_nft_exists(arg1, arg2)) {
                v1 = v1 + calculate_position_share(v6, v7, v8, v9, arg1.effective_tick_lower, arg1.effective_tick_upper);
            };
        };
        let v12 = arg1.total_share - v10 + v1;
        update_vault_reward_info(arg1, arg2, turbos_vault::rewarder::strategy_rewards_settle(arg0, arg1.rewarders, v2, arg3), v1);
        arg1.total_share = v12;
        turbos_vault::rewarder::set_strategy_share(arg0, v2, v12);
        v1
    }
    
    public(friend) fun update_strategy_status(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut Strategy,
        arg3: u8
    ) : u8 {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_vault_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        arg2.status = arg3;
        arg3
    }
    
    public(friend) fun update_vault_base_rebalance_threshold(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut Strategy,
        arg3: sui::object::ID,
        arg4: u32
    ) : u32 {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_vault_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        borrow_mut_vault_info(arg2, arg3).base_rebalance_threshold = arg4;
        arg4
    }
    
    fun update_vault_info(
        arg0: &mut Strategy,
        arg1: sui::object::ID,
        arg2: u128,
        arg3: u128,
        arg4: u128
    ) {
        let v0 = borrow_mut_vault_info(arg0, arg1);
        v0.base_liquidity = arg2;
        v0.limit_liquidity = arg3;
        v0.sqrt_price = arg4;
    }
    
    fun update_vault_info_with_tick_range(
        arg0: &mut Strategy,
        arg1: sui::object::ID,
        arg2: sui::object::ID,
        arg3: turbos_clmm::i32::I32,
        arg4: turbos_clmm::i32::I32,
        arg5: u128,
        arg6: sui::object::ID,
        arg7: turbos_clmm::i32::I32,
        arg8: turbos_clmm::i32::I32,
        arg9: u128,
        arg10: u128,
        arg11: turbos_clmm::i32::I32,
        arg12: turbos_clmm::i32::I32
    ) {
        let v0 = borrow_mut_vault_info(arg0, arg1);
        v0.base_clmm_position_id = arg2;
        v0.base_lower_index = arg3;
        v0.base_upper_index = arg4;
        v0.base_liquidity = arg5;
        v0.limit_clmm_position_id = arg6;
        v0.limit_lower_index = arg7;
        v0.limit_upper_index = arg8;
        v0.limit_liquidity = arg9;
        v0.sqrt_price = arg10;
        v0.base_last_tick_index = arg11;
        v0.limit_last_tick_index = arg12;
    }
    
    public(friend) fun update_vault_limit_rebalance_threshold(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut Strategy,
        arg3: sui::object::ID,
        arg4: u32
    ) : u32 {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_vault_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        borrow_mut_vault_info(arg2, arg3).limit_rebalance_threshold = arg4;
        arg4
    }
    
    public(friend) fun update_vault_management_fee_rate(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut Strategy,
        arg3: sui::object::ID,
        arg4: u64
    ) : u64 {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_vault_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        let v0 = borrow_mut_vault_info(arg2, arg3);
        assert!(arg4 <= 1000000, 5);
        std::option::fill<u64>(&mut v0.management_fee_rate, arg4);
        let v1 = UpdateVaultManagementFeeRateEvent{
            strategy_id : sui::object::id<Strategy>(arg2), 
            vault_id    : arg3, 
            old_rate    : std::option::get_with_default<u64>(&v0.management_fee_rate, 0), 
            new_rate    : arg4,
        };
        sui::event::emit<UpdateVaultManagementFeeRateEvent>(v1);
        arg4
    }
    
    public(friend) fun update_vault_performance_fee_rate(
        arg0: &turbos_vault::config::OperatorCap,
        arg1: &turbos_vault::config::GlobalConfig,
        arg2: &mut Strategy,
        arg3: sui::object::ID,
        arg4: u64
    ) : u64 {
        turbos_vault::config::checked_package_version(arg1);
        turbos_vault::config::check_vault_manager_role(arg1, sui::object::id_address<turbos_vault::config::OperatorCap>(arg0));
        let v0 = borrow_mut_vault_info(arg2, arg3);
        assert!(arg4 <= 1000000, 5);
        std::option::fill<u64>(&mut v0.performance_fee_rate, arg4);
        let v1 = UpdateVaultPerformanceFeeRateEvent{
            strategy_id : sui::object::id<Strategy>(arg2), 
            vault_id    : arg3, 
            old_rate    : std::option::get_with_default<u64>(&v0.performance_fee_rate, 0), 
            new_rate    : arg4,
        };
        sui::event::emit<UpdateVaultPerformanceFeeRateEvent>(v1);
        arg4
    }
    
    fun update_vault_reward_info(
        arg0: &mut Strategy,
        arg1: sui::object::ID,
        arg2: sui::vec_map::VecMap<std::type_name::TypeName, u128>,
        arg3: u128
    ) {
        let v0 = borrow_mut_vault_info(arg0, arg1);
        let v1 = 0;
        while (v1 < sui::vec_map::size<std::type_name::TypeName, u128>(&arg2)) {
            let (v2, v3) = sui::vec_map::get_entry_by_idx<std::type_name::TypeName, u128>(&arg2, v1);
            if (!sui::vec_map::contains<std::type_name::TypeName, VaultRewardInfo>(&v0.rewards, v2)) {
                let v4 = VaultRewardInfo{
                    reward           : 0, 
                    reward_debt      : turbos_clmm::full_math_u128::mul_div_floor(*v3, arg3, 1000000000), 
                    reward_harvested : 0,
                };
                sui::vec_map::insert<std::type_name::TypeName, VaultRewardInfo>(&mut v0.rewards, *v2, v4);
            } else {
                let v5 = sui::vec_map::get_mut<std::type_name::TypeName, VaultRewardInfo>(&mut v0.rewards, v2);
                v5.reward = v5.reward + turbos_clmm::full_math_u128::mul_div_floor(*v3, v0.share, 1000000000) - v5.reward_debt;
                v5.reward_debt = turbos_clmm::full_math_u128::mul_div_floor(*v3, arg3, 1000000000);
            };
            v1 = v1 + 1;
        };
        v0.share = arg3;
    }
    
    fun update_vault_reward_info_on_claim(
        arg0: &mut Strategy,
        arg1: sui::object::ID,
        arg2: std::type_name::TypeName
    ) : u64 {
        let v0 = sui::vec_map::get_mut<std::type_name::TypeName, VaultRewardInfo>(&mut borrow_mut_vault_info(arg0, arg1).rewards, &arg2);
        let v1 = v0.reward;
        v0.reward = 0;
        v0.reward_harvested = v0.reward_harvested + v1;
        v1 as u64
    }
    
    // deprecated
    public fun vault_balance_amount<T0>(
        arg0: &Strategy,
        arg1: sui::object::ID
    ) : u64 {
        let v0 = get_type_name_str<T0>();
        let v1 = borrow_vault_account(arg0, arg1);
        if (sui::bag::contains<std::string::String>(&v1.balances, v0)) {
            sui::balance::value<T0>(sui::bag::borrow<std::string::String, sui::balance::Balance<T0>>(&v1.balances, v0))
        } else {
            0
        }
    }
    
    // deprecated
    public fun withdraw<T0, T1, T2>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut turbos_vault::rewarder::RewarderManager,
        arg2: &mut Strategy,
        arg3: &mut Vault,
        arg4: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg5: &mut turbos_clmm::position_manager::Positions,
        arg6: u64,
        arg7: bool,
        arg8: &sui::clock::Clock,
        arg9: &turbos_clmm::pool::Versioned,
        arg10: &mut sui::tx_context::TxContext
    ) : (sui::coin::Coin<T0>, sui::coin::Coin<T1>) {
        abort 0
    }
    
    public fun withdraw_v2<T0, T1, T2>(
        arg0: &turbos_vault::config::GlobalConfig,
        arg1: &mut turbos_vault::config::UserTierConfig,
        arg2: &mut turbos_vault::rewarder::RewarderManager,
        arg3: &mut Strategy,
        arg4: &mut Vault,
        arg5: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        arg6: &mut turbos_clmm::position_manager::Positions,
        arg7: u64,
        arg8: bool,
        arg9: &sui::clock::Clock,
        arg10: &turbos_clmm::pool::Versioned,
        arg11: &mut sui::tx_context::TxContext
    ) : (sui::coin::Coin<T0>, sui::coin::Coin<T1>) {
        turbos_vault::config::checked_package_version(arg0);
        assert!(arg3.status == 0, 15);
        assert!(arg7 > 0 && arg7 <= 1000000, 2);
        assert!(arg3.clmm_pool_id == sui::object::id<turbos_clmm::pool::Pool<T0, T1, T2>>(arg5), 17);
        assert!(sui::object::id<Strategy>(arg3) == arg4.strategy_id, 18);
        let v0 = sui::object::id<Vault>(arg4);
        collect_clmm_fees<T0, T1, T2>(arg0, arg3, v0, arg5, arg6, arg9, arg10, arg11);
        let v1 = sui::coin::zero<T0>(arg11);
        let v2 = sui::coin::zero<T1>(arg11);
        let v3 = 0;
        if (is_clmm_base_nft_exists(arg3, v0)) {
            let v4 = borrow_mut_clmm_base_nft(arg3, v0);
            let (_, _, v7) = turbos_clmm::position_manager::get_position_info(arg6, sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(v4));
            if (v7 > 0) {
                let (v8, v9) = decrease_clmm_liquidity<T0, T1, T2>(v4, arg5, arg6, turbos_clmm::full_math_u128::mul_div_floor(v7, (arg7 as u128), (1000000 as u128)), arg9, arg10, arg11);
                let (_, _, v12) = turbos_clmm::position_manager::get_position_info(arg6, sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(v4));
                v3 = v12;
                sui::coin::join<T0>(&mut v1, v8);
                sui::coin::join<T1>(&mut v2, v9);
            };
        };
        let v13 = 0;
        if (is_clmm_limit_nft_exists(arg3, v0)) {
            let v14 = borrow_mut_clmm_limit_nft(arg3, v0);
            let (_, _, v17) = turbos_clmm::position_manager::get_position_info(arg6, sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(v14));
            if (v17 > 0) {
                let (v18, v19) = decrease_clmm_liquidity<T0, T1, T2>(v14, arg5, arg6, turbos_clmm::full_math_u128::mul_div_floor(v17, (arg7 as u128), (1000000 as u128)), arg9, arg10, arg11);
                let (_, _, v22) = turbos_clmm::position_manager::get_position_info(arg6, sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(v14));
                v13 = v22;
                sui::coin::join<T0>(&mut v1, v18);
                sui::coin::join<T1>(&mut v2, v19);
            };
        };
        sui::coin::join<T0>(&mut v1, sui::coin::from_balance<T0>(take_vault_balance_by_amount<T0>(arg3, v0, turbos_clmm::full_math_u64::mul_div_floor(vault_balance_amount<T0>(arg3, v0), arg7, 1000000)), arg11));
        sui::coin::join<T1>(&mut v2, sui::coin::from_balance<T1>(take_vault_balance_by_amount<T1>(arg3, v0, turbos_clmm::full_math_u64::mul_div_floor(vault_balance_amount<T1>(arg3, v0), arg7, 1000000)), arg11));
        let v23 = get_management_fee_rate_v2(arg0, arg1, arg3, v0, arg11);
        let (v24, v25) = if (v23 == 0) {
            (0, 0)
        } else {
            let v26 = turbos_clmm::full_math_u64::mul_div_ceil(sui::coin::value<T0>(&v1), v23, 1000000);
            let v27 = turbos_clmm::full_math_u64::mul_div_ceil(sui::coin::value<T1>(&v2), v23, 1000000);
            merge_protocol_asset<T0>(arg3, sui::coin::into_balance<T0>(sui::coin::split<T0>(&mut v1, v26, arg11)));
            merge_protocol_asset<T1>(arg3, sui::coin::into_balance<T1>(sui::coin::split<T1>(&mut v2, v27, arg11)));
            (v26, v27)
        };
        if (arg8 && arg7 == 1000000) {
            if (v24) {
                burn_clmm_base_nft<T0, T1, T2>(arg3, v0, arg6, arg10, arg11);
            };
            if (v25) {
                burn_clmm_limit_nft<T0, T1, T2>(arg3, v0, arg6, arg10, arg11);
            };
        };
        update_vault_info(arg3, v0, v3, v13, turbos_clmm::pool::get_pool_sqrt_price<T0, T1, T2>(arg5));
        update_strategy_reward_info(arg2, arg3, v0, arg9);
        borrow_vault_info(arg3, v0);
        let v28 = WithdrawEvent{
            vault_id              : v0, 
            strategy_id           : sui::object::id<Strategy>(arg3), 
            clmm_pool_id          : sui::object::id<turbos_clmm::pool::Pool<T0, T1, T2>>(arg5), 
            percentage            : arg7, 
            burn_clmm_nft         : arg8, 
            amount_a              : sui::coin::value<T0>(&v1), 
            amount_b              : sui::coin::value<T1>(&v2), 
            protocol_fee_a_amount : v24, 
            protocol_fee_b_amount : v25,
        };
        sui::event::emit<WithdrawEvent>(v28);
        (v1, v2)
    }
}

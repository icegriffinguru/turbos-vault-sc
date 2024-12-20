module turbos_vault::router {
    public entry fun add_operator(arg0: &turbos_vault::config::AdminCap, arg1: &mut turbos_vault::config::GlobalConfig, arg2: u128, arg3: address, arg4: &mut sui::tx_context::TxContext) {
        turbos_vault::config::add_operator(arg0, arg1, arg2, arg3, arg4);
    }
    
    public entry fun add_role(arg0: &turbos_vault::config::AdminCap, arg1: &mut turbos_vault::config::GlobalConfig, arg2: address, arg3: u8) {
        turbos_vault::config::add_role(arg0, arg1, arg2, arg3);
    }
    
    public entry fun new_user_tier_config(arg0: &turbos_vault::config::AdminCap, arg1: &mut sui::tx_context::TxContext) {
        turbos_vault::config::new_user_tier_config(arg0, arg1);
    }
    
    public entry fun remove_role(arg0: &turbos_vault::config::AdminCap, arg1: &mut turbos_vault::config::GlobalConfig, arg2: address, arg3: u8) {
        turbos_vault::config::remove_role(arg0, arg1, arg2, arg3);
    }
    
    public entry fun set_package_version(arg0: &turbos_vault::config::AdminCap, arg1: &mut turbos_vault::config::GlobalConfig, arg2: u64) {
        turbos_vault::config::set_package_version(arg0, arg1, arg2);
    }
    
    public entry fun set_roles(arg0: &turbos_vault::config::AdminCap, arg1: &mut turbos_vault::config::GlobalConfig, arg2: address, arg3: u128) {
        turbos_vault::config::set_roles(arg0, arg1, arg2, arg3);
    }
    
    public entry fun set_tier_v2(arg0: &turbos_vault::config::AdminCap, arg1: &mut turbos_vault::config::GlobalConfig, arg2: &mut turbos_vault::config::UserTierConfig, arg3: address, arg4: u64, arg5: u64, arg6: &mut sui::tx_context::TxContext) {
        turbos_vault::config::set_tier_v2(arg0, arg1, arg2, arg3, arg4, arg5, arg6);
    }
    
    public entry fun close_vault<T0, T1>(arg0: &turbos_vault::config::GlobalConfig, arg1: &mut turbos_vault::vault::Strategy, arg2: turbos_vault::vault::Vault, arg3: &mut sui::tx_context::TxContext) {
        turbos_vault::vault::close_vault<T0, T1>(arg0, arg1, arg2, arg3);
    }
    
    public entry fun collect_clmm_reward_direct_return<T0, T1, T2, T3>(arg0: &turbos_vault::config::GlobalConfig, arg1: &mut turbos_vault::vault::Strategy, arg2: &turbos_vault::vault::Vault, arg3: &mut turbos_clmm::pool::Pool<T0, T1, T2>, arg4: &mut turbos_clmm::position_manager::Positions, arg5: &mut turbos_clmm::pool::PoolRewardVault<T3>, arg6: u64, arg7: address, arg8: &sui::clock::Clock, arg9: &turbos_clmm::pool::Versioned, arg10: &mut sui::tx_context::TxContext) {
        sui::transfer::public_transfer<sui::coin::Coin<T3>>(turbos_vault::vault::collect_clmm_reward_direct_return<T0, T1, T2, T3>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10), arg7);
    }
    
    public entry fun collect_protocol_fee<T0>(arg0: &turbos_vault::config::OperatorCap, arg1: &turbos_vault::config::GlobalConfig, arg2: &mut turbos_vault::vault::Strategy, arg3: u64, arg4: address, arg5: &mut sui::tx_context::TxContext) {
        sui::transfer::public_transfer<sui::coin::Coin<T0>>(turbos_vault::vault::collect_protocol_fee<T0>(arg0, arg1, arg2, arg3, arg5), arg4);
    }
    
    public entry fun collect_reward<T0>(arg0: &turbos_vault::config::GlobalConfig, arg1: &mut turbos_vault::rewarder::RewarderManager, arg2: &mut turbos_vault::vault::Strategy, arg3: &turbos_vault::vault::Vault, arg4: address, arg5: &sui::clock::Clock, arg6: &mut sui::tx_context::TxContext) {
        sui::transfer::public_transfer<sui::coin::Coin<T0>>(turbos_vault::vault::collect_reward<T0>(arg0, arg1, arg2, arg3, arg5, arg6), arg4);
    }
    
    entry fun create_strategy<T0, T1, T2>(arg0: &turbos_vault::config::OperatorCap, arg1: &turbos_vault::config::GlobalConfig, arg2: &mut turbos_vault::rewarder::RewarderManager, arg3: &turbos_clmm::pool::Pool<T0, T1, T2>, arg4: u32, arg5: bool, arg6: u32, arg7: bool, arg8: std::string::String, arg9: u32, arg10: u32, arg11: u32, arg12: u32, arg13: &mut sui::tx_context::TxContext) {
        sui::transfer::public_share_object<turbos_vault::vault::Strategy>(turbos_vault::vault::create_strategy<T0, T1, T2>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13));
    }
    
    public entry fun deposit<T0, T1, T2>(arg0: &turbos_vault::config::GlobalConfig, arg1: &mut turbos_vault::rewarder::RewarderManager, arg2: &mut turbos_vault::vault::Strategy, arg3: &mut turbos_vault::vault::Vault, arg4: &mut turbos_clmm::pool::Pool<T0, T1, T2>, arg5: &mut turbos_clmm::position_manager::Positions, arg6: sui::coin::Coin<T0>, arg7: sui::coin::Coin<T1>, arg8: &sui::clock::Clock, arg9: &turbos_clmm::pool::Versioned, arg10: &mut sui::tx_context::TxContext) {
        turbos_vault::vault::deposit<T0, T1, T2>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
    }
    
    public entry fun open_vault<T0, T1, T2>(arg0: &turbos_vault::config::GlobalConfig, arg1: &mut turbos_vault::vault::Strategy, arg2: &turbos_clmm::pool::Pool<T0, T1, T2>, arg3: u32, arg4: bool, arg5: u32, arg6: bool, arg7: u32, arg8: bool, arg9: u32, arg10: bool, arg11: u32, arg12: u32, arg13: address, arg14: &mut sui::tx_context::TxContext) {
        sui::transfer::public_transfer<turbos_vault::vault::Vault>(turbos_vault::vault::open_vault<T0, T1, T2>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg14), arg13);
    }
    
    public entry fun rebalance<T0, T1, T2>(arg0: &turbos_vault::config::OperatorCap, arg1: &turbos_vault::config::GlobalConfig, arg2: &mut turbos_vault::rewarder::RewarderManager, arg3: &mut turbos_vault::vault::Strategy, arg4: sui::object::ID, arg5: bool, arg6: bool, arg7: u32, arg8: bool, arg9: u32, arg10: bool, arg11: u32, arg12: bool, arg13: u32, arg14: bool, arg15: &mut turbos_clmm::pool::Pool<T0, T1, T2>, arg16: &mut turbos_clmm::position_manager::Positions, arg17: &sui::clock::Clock, arg18: &turbos_clmm::pool::Versioned, arg19: &mut sui::tx_context::TxContext) {
        turbos_vault::vault::rebalance<T0, T1, T2>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19);
    }
    
    public entry fun update_strategy_base_minimum_threshold(arg0: &turbos_vault::config::OperatorCap, arg1: &turbos_vault::config::GlobalConfig, arg2: &mut turbos_vault::vault::Strategy, arg3: u32) {
        turbos_vault::vault::update_strategy_base_minimum_threshold(arg0, arg1, arg2, arg3);
    }
    
    public entry fun update_strategy_default_base_rebalance_threshold(arg0: &turbos_vault::config::OperatorCap, arg1: &turbos_vault::config::GlobalConfig, arg2: &mut turbos_vault::vault::Strategy, arg3: u32) {
        turbos_vault::vault::update_strategy_default_base_rebalance_threshold(arg0, arg1, arg2, arg3);
    }
    
    public entry fun update_strategy_default_limit_rebalance_threshold(arg0: &turbos_vault::config::OperatorCap, arg1: &turbos_vault::config::GlobalConfig, arg2: &mut turbos_vault::vault::Strategy, arg3: u32) {
        turbos_vault::vault::update_strategy_default_limit_rebalance_threshold(arg0, arg1, arg2, arg3);
    }
    
    public entry fun update_strategy_limit_minimum_threshold(arg0: &turbos_vault::config::OperatorCap, arg1: &turbos_vault::config::GlobalConfig, arg2: &mut turbos_vault::vault::Strategy, arg3: u32) {
        turbos_vault::vault::update_strategy_limit_minimum_threshold(arg0, arg1, arg2, arg3);
    }
    
    public entry fun update_strategy_management_fee_rate(arg0: &turbos_vault::config::OperatorCap, arg1: &turbos_vault::config::GlobalConfig, arg2: &mut turbos_vault::vault::Strategy, arg3: u64) {
        turbos_vault::vault::update_strategy_management_fee_rate(arg0, arg1, arg2, arg3);
    }
    
    public entry fun update_strategy_performance_fee_rate(arg0: &turbos_vault::config::OperatorCap, arg1: &turbos_vault::config::GlobalConfig, arg2: &mut turbos_vault::vault::Strategy, arg3: u64) {
        turbos_vault::vault::update_strategy_performance_fee_rate(arg0, arg1, arg2, arg3);
    }
    
    public entry fun update_strategy_status(arg0: &turbos_vault::config::OperatorCap, arg1: &turbos_vault::config::GlobalConfig, arg2: &mut turbos_vault::vault::Strategy, arg3: u8) {
        turbos_vault::vault::update_strategy_status(arg0, arg1, arg2, arg3);
    }
    
    public entry fun update_vault_base_rebalance_threshold(arg0: &turbos_vault::config::OperatorCap, arg1: &turbos_vault::config::GlobalConfig, arg2: &mut turbos_vault::vault::Strategy, arg3: sui::object::ID, arg4: u32) {
        turbos_vault::vault::update_vault_base_rebalance_threshold(arg0, arg1, arg2, arg3, arg4);
    }
    
    public entry fun update_vault_limit_rebalance_threshold(arg0: &turbos_vault::config::OperatorCap, arg1: &turbos_vault::config::GlobalConfig, arg2: &mut turbos_vault::vault::Strategy, arg3: sui::object::ID, arg4: u32) {
        turbos_vault::vault::update_vault_limit_rebalance_threshold(arg0, arg1, arg2, arg3, arg4);
    }
    
    public entry fun update_vault_management_fee_rate(arg0: &turbos_vault::config::OperatorCap, arg1: &turbos_vault::config::GlobalConfig, arg2: &mut turbos_vault::vault::Strategy, arg3: sui::object::ID, arg4: u64) {
        turbos_vault::vault::update_vault_management_fee_rate(arg0, arg1, arg2, arg3, arg4);
    }
    
    public entry fun update_vault_performance_fee_rate(arg0: &turbos_vault::config::OperatorCap, arg1: &turbos_vault::config::GlobalConfig, arg2: &mut turbos_vault::vault::Strategy, arg3: sui::object::ID, arg4: u64) {
        turbos_vault::vault::update_vault_performance_fee_rate(arg0, arg1, arg2, arg3, arg4);
    }
    
    public entry fun withdraw_v2<T0, T1, T2>(arg0: &turbos_vault::config::GlobalConfig, arg1: &mut turbos_vault::config::UserTierConfig, arg2: &mut turbos_vault::rewarder::RewarderManager, arg3: &mut turbos_vault::vault::Strategy, arg4: &mut turbos_vault::vault::Vault, arg5: &mut turbos_clmm::pool::Pool<T0, T1, T2>, arg6: &mut turbos_clmm::position_manager::Positions, arg7: u64, arg8: bool, arg9: address, arg10: &sui::clock::Clock, arg11: &turbos_clmm::pool::Versioned, arg12: &mut sui::tx_context::TxContext) {
        let (v0, v1) = turbos_vault::vault::withdraw_v2<T0, T1, T2>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg10, arg11, arg12);
        sui::transfer::public_transfer<sui::coin::Coin<T0>>(v0, arg9);
        sui::transfer::public_transfer<sui::coin::Coin<T1>>(v1, arg9);
    }
    
    public entry fun open_vault_and_deposit<T0, T1, T2>(arg0: &turbos_vault::config::GlobalConfig, arg1: &mut turbos_vault::rewarder::RewarderManager, arg2: &mut turbos_vault::vault::Strategy, arg3: &mut turbos_clmm::pool::Pool<T0, T1, T2>, arg4: &mut turbos_clmm::position_manager::Positions, arg5: sui::coin::Coin<T0>, arg6: sui::coin::Coin<T1>, arg7: u32, arg8: bool, arg9: u32, arg10: bool, arg11: u32, arg12: bool, arg13: u32, arg14: bool, arg15: u32, arg16: u32, arg17: address, arg18: &sui::clock::Clock, arg19: &turbos_clmm::pool::Versioned, arg20: &mut sui::tx_context::TxContext) {
        let v0 = turbos_vault::vault::open_vault<T0, T1, T2>(arg0, arg2, arg3, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg20);
        turbos_vault::vault::deposit<T0, T1, T2>(arg0, arg1, arg2, &mut v0, arg3, arg4, arg5, arg6, arg18, arg19, arg20);
        sui::transfer::public_transfer<turbos_vault::vault::Vault>(v0, arg17);
    }
    
    public entry fun set_tier(arg0: &turbos_vault::config::AdminCap, arg1: &mut turbos_vault::config::GlobalConfig, arg2: address, arg3: u64, arg4: u64, arg5: &mut sui::tx_context::TxContext) {
        abort 0
    }
    
    public entry fun withdraw<T0, T1, T2>(arg0: &turbos_vault::config::GlobalConfig, arg1: &mut turbos_vault::rewarder::RewarderManager, arg2: &mut turbos_vault::vault::Strategy, arg3: &mut turbos_vault::vault::Vault, arg4: &mut turbos_clmm::pool::Pool<T0, T1, T2>, arg5: &mut turbos_clmm::position_manager::Positions, arg6: u64, arg7: bool, arg8: address, arg9: &sui::clock::Clock, arg10: &turbos_clmm::pool::Versioned, arg11: &mut sui::tx_context::TxContext) {
        abort 0
    }
}

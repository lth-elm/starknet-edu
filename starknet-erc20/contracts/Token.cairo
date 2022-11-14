// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.4.0b (token/erc20/presets/ERC20.cairo)

%lang starknet

from starkware.starknet.common.syscalls import get_contract_address, get_caller_address

from starkware.cairo.common.math import assert_not_zero, assert_not_equal, split_felt
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_mul,
)

from openzeppelin.token.erc20.library import ERC20

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    name: felt, 
    symbol: felt, 
    decimals: felt, 
    initial_supply: Uint256, 
    recipient: felt,
) {
    // ERC20.initializer(11, 22, 8);
    ERC20.initializer(name, symbol, decimals);
    ERC20._mint(recipient, initial_supply);
    return ();
}

//
// Storage
//

@storage_var
func allowlist_level_storage(account : felt) -> (level : felt) {
}

//
// Getters
//

// @view
// func get_my_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
//     address: felt
// ) {
//     let (sender_address) = get_caller_address();
//     return (address=sender_address);
// }

@view
func allowlist_level{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account: felt) -> (
    level: felt
) {
    return allowlist_level_storage.read(account);
}

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    return ERC20.name();
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    return ERC20.symbol();
}

@view
func totalSupply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    totalSupply: Uint256
) {
    let (totalSupply: Uint256) = ERC20.total_supply();
    return (totalSupply=totalSupply);
}

@view
func decimals{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    decimals: felt
) {
    return ERC20.decimals();
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account: felt) -> (
    balance: Uint256
) {
    return ERC20.balance_of(account);
}

@view
func allowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, spender: felt
) -> (remaining: Uint256) {
    return ERC20.allowance(owner, spender);
}

//
// Externals
//

@external
func request_allowlist{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    level_granted: felt
) {
    let (sender_address) = get_caller_address();
    allowlist_level_storage.write(account=sender_address, value=1);
    return(level_granted=1);
}

@external
func request_allowlist_level{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(level_requested: felt) -> (
    level_granted: felt
) {
    let (sender_address) = get_caller_address();
    allowlist_level_storage.write(account=sender_address, value=level_requested);
    return(level_granted=level_requested);
}

@external
func get_tokens{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    amount: Uint256
) {
    alloc_locals;

    // assert_only_allowlist();
    let (sender_address) = get_caller_address();
    let level: felt = allowlist_level_storage.read(sender_address);
    let level_as_Uint256: Uint256 = Uint256(0, level);
    
    let amount: Uint256 = uint256_mul(Uint256(0, 100000), level_as_Uint256);
    ERC20._mint(sender_address, amount);
    return (amount=amount);
}

@external
func transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    recipient: felt, amount: Uint256
) -> (success: felt) {
    return ERC20.transfer(recipient, amount);
}

@external
func transferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    sender: felt, recipient: felt, amount: Uint256
) -> (success: felt) {
    return ERC20.transfer_from(sender, recipient, amount);
}

@external
func approve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    spender: felt, amount: Uint256
) -> (success: felt) {
    return ERC20.approve(spender, amount);
}

@external
func increaseAllowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    spender: felt, added_value: Uint256
) -> (success: felt) {
    return ERC20.increase_allowance(spender, added_value);
}

@external
func decreaseAllowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    spender: felt, subtracted_value: Uint256
) -> (success: felt) {
    return ERC20.decrease_allowance(spender, subtracted_value);
}

//
// Internal
//

func felt_to_uint256{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    felt_value : felt
) -> (uint256_value : Uint256) {
    let (high, low) = split_felt(felt_value);
    let uint256_value : Uint256 = Uint256(low, high);
    return (uint256_value,);
}

//
// Guards
//

func assert_only_allowlist{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (caller) = get_caller_address();
    let level: felt = allowlist_level_storage.read(caller);
    with_attr error_message("Caller is the zero address") {
        assert_not_zero(caller);
    }
    with_attr error_message("Caller have not been granted any level") {
        assert_not_zero(level);
    }
    return ();
}

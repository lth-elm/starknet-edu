// SPDX-License-Identifier: MIT

%lang starknet

from starkware.starknet.common.syscalls import get_contract_address, get_caller_address

from starkware.cairo.common.math import assert_not_zero, assert_not_equal, split_felt
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_sub,
    uint256_mul,
)

from openzeppelin.token.erc20.IERC20 import IERC20

//
// Interface
//

@contract_interface
namespace IDTK20 {
    func faucet() -> (success: felt) {
    }
}

//
// Constructor
//



//
// Storage
//

const dummy_token_address = 2902316682104075051413498319463440872218343805094901487380982904191163706006;

@storage_var
func tokens_in_custody_storage(account: felt) -> (amount: Uint256) {
}

//
// Getters
//

@view
func tokens_in_custody{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account: felt) -> (
    amount: Uint256
) {
    return tokens_in_custody_storage.read(account);
}

//
// Externals
//

@external
func get_tokens_from_contract{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    amount: Uint256
) {
    alloc_locals;

    let (my_address) = get_contract_address();
    let (sender_address) = get_caller_address();

    let (initial_dtk_balance) = IERC20.balanceOf(
        contract_address=dummy_token_address, account=my_address
    );

    let (success) = IDTK20.faucet(contract_address=dummy_token_address);
    
    let (new_dtk_balance) = IERC20.balanceOf(
        contract_address=dummy_token_address, account=my_address
    );

    let (custody_difference) = uint256_sub(new_dtk_balance, initial_dtk_balance);
    let (amount_in_custody) = tokens_in_custody_storage.read(account=sender_address);
    let (new_amount_in_custody, _) = uint256_add(amount_in_custody, custody_difference);
    tokens_in_custody_storage.write(account=sender_address, value=new_amount_in_custody);

    return (custody_difference,);
}

@external
func withdraw_all_tokens{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    amount: Uint256
) {
    alloc_locals;

    let (sender_address) = get_caller_address();

    let amount_in_custody: Uint256 = tokens_in_custody_storage.read(account=sender_address);
    tokens_in_custody_storage.write(account=sender_address, value=Uint256(0, 0));

    let (success) = IERC20.transfer(
        contract_address=dummy_token_address, recipient=sender_address, amount=amount_in_custody
    );

    return (amount_in_custody,);
}

@external
func deposit_tokens{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(amount: Uint256) -> (
    total_amount: Uint256
) {
    alloc_locals;

    let (my_address) = get_contract_address();
    let (sender_address) = get_caller_address();

    let amount_in_custody: Uint256 = tokens_in_custody_storage.read(account=sender_address);
    let new_amount_in_custody: Uint256 = uint256_add(amount_in_custody, amount);
    tokens_in_custody_storage.write(account=sender_address, value=new_amount_in_custody);

    let (success) = IERC20.transferFrom(
        contract_address=dummy_token_address, sender=sender_address, recipient=my_address, amount=amount
    );

    return (total_amount=amount);
}

//
// Internal
//



//
// Guards
//

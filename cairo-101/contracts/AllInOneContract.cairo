// Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
// from starkware.cairo.common.uint256 import (
//     Uint256,
// )


@contract_interface
namespace IEx01Contract {
    func claim_points() {
    }
}

@contract_interface
namespace IEx02Contract {
    func claim_points(my_value: felt) {
    }

    func my_secret_value() -> (my_value: felt) {
    }
}

// IEx03-04-...


@storage_var
func exercices_address_storage(index: felt) -> (address: felt) {
}


@view
func exercices_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(index: felt) -> (
    address: felt
) {
    let (address) = exercices_address_storage.read(index);
    return (address,);
}


@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    exercices_len: felt,
    exercices: felt*,
) {
    _set_exercices_address(exercices_len, exercices, 1);
    return ();
}


func _set_exercices_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    exercices_len: felt, 
    exercices: felt*,
    iteration: felt,
) {
    if (iteration == exercices_len + 1) {
        return ();
    }
    exercices_address_storage.write(index=iteration, value=[exercices]);
    _set_exercices_address(exercices_len=exercices_len, exercices=exercices + 1, iteration=iteration + 1);
    return ();
}


@external
func validate_various_exercises{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    ex01();
    ex02();
    // ...
    return();
}


@external
func ex01{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (ex_address) = exercices_address_storage.read(1);
    IEx01Contract.claim_points(contract_address=ex_address);
    return();
}

@external
func ex02{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (ex_address) = exercices_address_storage.read(2);
    let (my_value) = IEx02Contract.my_secret_value(contract_address=ex_address);
    IEx02Contract.claim_points(contract_address=ex_address, my_value=my_value);
    // IEx02Contract.claim_points(my_value, contract_address=ex_address); OU (Positional arguments must not appear after named arguments)
    return();
}

// ex03
// ...


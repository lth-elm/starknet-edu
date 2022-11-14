// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.2.0 (token/erc721/ERC721_Mintable_Burnable.cairo)

%lang starknet

from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.math import assert_not_zero, assert_nn, split_felt
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_sub,
    uint256_eq,
    uint256_check,
)

from openzeppelin.token.erc721.enumerable.library import ERC721Enumerable
from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.token.erc721.library import ERC721_owners
from openzeppelin.token.erc721.library import ERC721
from openzeppelin.token.erc20.IERC20 import IERC20

from contracts.ERC721_Metadata import (
    ERC721_Metadata_initializer,
    ERC721_Metadata_tokenURI,
    ERC721_Metadata_setBaseTokenURI,
)

from openzeppelin.access.ownable.library import Ownable

//
// Interface
//

@contract_interface
namespace IEvaluator {
    func assigned_sex_number(player_address: felt) -> (sex: felt) {
    }

    func assigned_legs_number(player_address: felt) -> (legs: felt) {
    }

    func assigned_wings_number(player_address: felt) -> (wings: felt) {
    }
}

//
// Storage
//

const exercice_address = 1274519388635697963204543407605438159849675014318520616686163352039693617685;

struct Animal {
    sex: felt,
    legs: felt,
    wings: felt,
}

@storage_var
func animals_characteristics_storage(token_id: Uint256) -> (animal: Animal) {
}

@storage_var
func supply_storage() -> (supply: Uint256) {
}

@storage_var
func is_breeder_storage(account : felt) -> (is_approved : felt) {
}

@storage_var
func _dummy_token_address_storage() -> (dummy_token_address : felt) {
}

//
// Getters
//

@view
func animal_characteristics{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (myAnimal: Animal) {
    with_attr error_message("ERC721: token_id is not a valid Uint256") {
        uint256_check(token_id);
    }
    let (myAnimal) = animals_characteristics_storage.read(token_id);
    return (myAnimal,);
}

@view
func get_animal_characteristics{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (sex: felt, legs: felt, wings: felt) {
    let (myAnimal) = animal_characteristics(token_id);
    let animal_ptr = cast(&myAnimal, Animal*);
    return (sex=animal_ptr.sex, legs=animal_ptr.legs, wings=animal_ptr.wings);
    // OU
    // let sex = myAnimal.sex;
    // let legs = myAnimal.legs;
    // let wings = myAnimal.wings;
    // return (sex, legs, wings,);
}

@view
func is_breeder{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account : felt
) -> (is_approved : felt) {
    with_attr error_message("ERC721: the zero address can't be a breeder") {
        assert_not_zero(account);
    }
    let (is_approved : felt) = is_breeder_storage.read(account);
    return (is_approved,);
}

@view
func token_of_owner_by_index{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account : felt, index : felt
) -> (token_id : Uint256) {
    with_attr error_message("ERC721: the zero address is not supported as a token holder") {
        assert_not_zero(account);
    }
    with_attr error_message("ERC721: index must be a positive integer") {
        assert_nn(index);
    }
    let (index_uint256) = felt_to_uint256(index);
    let (token_id) = ERC721Enumerable.token_of_owner_by_index(owner=account, index=index_uint256);
    return (token_id,);
}

@view
func registration_price{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    price : Uint256
) {
    let one_as_uint256 = Uint256(1, 0);
    return (price=one_as_uint256);
}

@view
func supportsInterface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    interfaceId: felt
) -> (success: felt) {
    let (success) = ERC165.supports_interface(interfaceId);
    return (success,);
}

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    let (name) = ERC721.name();
    return (name,);
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    let (symbol) = ERC721.symbol();
    return (symbol,);
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) -> (
    balance: Uint256
) {
    let (balance: Uint256) = ERC721.balance_of(owner);
    return (balance,);
}

@view
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(tokenId: Uint256) -> (
    owner: felt
) {
    let (owner: felt) = ERC721.owner_of(tokenId);
    return (owner,);
}

@view
func getApproved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenId: Uint256
) -> (approved: felt) {
    let (approved: felt) = ERC721.get_approved(tokenId);
    return (approved,);
}

@view
func isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, operator: felt
) -> (isApproved: felt) {
    let (isApproved: felt) = ERC721.is_approved_for_all(owner, operator);
    return (isApproved,);
}

@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (token_uri_len: felt, token_uri: felt*) {
    let (token_uri_len, token_uri) = ERC721_Metadata_tokenURI(token_id);
    return (token_uri_len=token_uri_len, token_uri=token_uri);
}

@view
func owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt) {
    let (owner: felt) = Ownable.owner();
    return (owner,);
}

//
// Constructor
//

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    name: felt, 
    symbol: felt, 
    owner: felt, 
    dummy_token_address : felt,
    base_token_uri_len: felt,
    base_token_uri: felt*,
    token_uri_suffix: felt,
) {
    supply_storage.write(Uint256(0, 0));
    ERC721.initializer(name, symbol);
    Ownable.initializer(owner);
    _dummy_token_address_storage.write(dummy_token_address);
    ERC721_Metadata_initializer();
    ERC721_Metadata_setBaseTokenURI(base_token_uri_len, base_token_uri, token_uri_suffix);
    return ();
}

//
// Externals
//

@external
func approve{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, tokenId: Uint256
) {
    ERC721.approve(to, tokenId);
    return ();
}

@external
func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    operator: felt, approved: felt
) {
    ERC721.set_approval_for_all(operator, approved);
    return ();
}

@external
func transferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    from_: felt, to: felt, tokenId: Uint256
) {
    ERC721Enumerable.transfer_from(from_, to, tokenId);
    return ();
}

@external
func safeTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    from_: felt, to: felt, tokenId: Uint256, data_len: felt, data: felt*
) {
    ERC721Enumerable.safe_transfer_from(from_, to, tokenId, data_len, data);
    return ();
}

@external
func add_breeder{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    breeder_address : felt
) {
    Ownable.assert_only_owner();
    with_attr error_message("ERC721: the zero address can't be a breeder") {
        assert_not_zero(breeder_address);
    }
    is_breeder_storage.write(breeder_address, 1);
    return ();
}

@external
func remove_breeder{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    breeder_address : felt
) {
    Ownable.assert_only_owner();
    with_attr error_message("ERC721: the zero address can't be a breeder") {
        assert_not_zero(breeder_address);
    }
    is_breeder_storage.write(breeder_address, 0);
    return ();
}

@external
func register_me_as_breeder{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
) -> (is_added : felt) {
    let (sender_address) = get_caller_address();
    let (erc721_address) = get_contract_address();
    let (price) = registration_price();
    let (dummy_token_address) = _dummy_token_address_storage.read();
 
    let (success) = IERC20.transferFrom(
        contract_address=dummy_token_address,
        sender=sender_address,
        recipient=erc721_address,
        amount=price,
    );
    with_attr error_message("ERC721: unable to charge dummy tokens") {
        assert success = 1;
    }
    is_breeder_storage.write(account=sender_address, value=1);
    return (is_added=1);
}
 
@external
func unregister_me_as_breeder{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
) -> (is_added : felt) {
    let (sender_address) = get_caller_address();
    is_breeder_storage.write(account=sender_address, value=0);
    return (is_added=0);
}

func assert_only_breeder{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() {
    let (sender_address) = get_caller_address();
    let (is_true) = is_breeder_storage.read(sender_address);
    with_attr error_message("Caller is not a registered breeder") {
        assert is_true = 1;
    }
    return ();
}

@external
func mintForEx2OneShot{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt
) {
    // alloc_locals;
    Ownable.assert_only_owner();
    
    let (my_address: felt) = Ownable.owner();
    let (sex) = IEvaluator.assigned_sex_number(contract_address=exercice_address, player_address=my_address);
    let (legs) = IEvaluator.assigned_legs_number(contract_address=exercice_address, player_address=my_address); // HOW MY ADDRESS IS NOTE REVOKED HERE ?!
    let (wings) = IEvaluator.assigned_wings_number(contract_address=exercice_address, player_address=my_address);

    let current_supply: Uint256 = supply_storage.read();
    let token_id: Uint256 = uint256_add(current_supply, Uint256(1, 0));
    // OU
    // let (local token_id, _) = uint256_add(current_supply, Uint256(1, 0));
    supply_storage.write(token_id);

    // let animal = Animal(sex=sex, legs=legs, wings=wings);
    // OU
    animals_characteristics_storage.write(token_id=token_id, value=Animal(sex=sex, legs=legs, wings=wings));

    ERC721Enumerable._mint(to, token_id);
    return ();
}

@external
func declare_animal{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    sex: felt, legs: felt, wings: felt
) -> (token_id: Uint256) {
    alloc_locals;
    assert_only_breeder();

    let (sender_address) = get_caller_address();

    let current_supply: Uint256 = supply_storage.read();
    // let (local token_id, _) = uint256_add(current_supply, Uint256(1, 0));
    let token_id: Uint256 = uint256_add(current_supply, Uint256(1, 0));
    supply_storage.write(token_id);

    // let animal = Animal(sex=sex, legs=legs, wings=wings);
    // OU
    animals_characteristics_storage.write(token_id=token_id, value=Animal(sex=sex, legs=legs, wings=wings));

    ERC721Enumerable._mint(sender_address, token_id);
    return (token_id,);
}

// @external
// func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
//     to: felt, token_id: Uint256
// ) {
//     Ownable.assert_only_owner();
//     // let current_supply: Uint256 = supply_storage.read();
//     // let token_id: Uint256 = uint256_add(current_supply, Uint256(1, 0));
//     // supply_storage.write(token_id);
//     ERC721._mint(to, token_id);
//     return ();
// }

@external
func declare_dead_animal{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(token_id: Uint256) {
    animals_characteristics_storage.write(token_id=token_id, value=Animal(sex=0, legs=0, wings=0));
    ERC721.assert_only_token_owner(token_id);
    ERC721Enumerable._burn(token_id);
    return ();
}

@external
func setTokenURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    base_token_uri_len: felt, base_token_uri: felt*, token_uri_suffix: felt
) {
    Ownable.assert_only_owner();
    ERC721_Metadata_setBaseTokenURI(base_token_uri_len, base_token_uri, token_uri_suffix);
    return ();
}

@external
func transferOwnership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    newOwner: felt
) {
    Ownable.transfer_ownership(newOwner);
    return ();
}

@external
func renounceOwnership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    Ownable.renounce_ownership();
    return ();
}

func felt_to_uint256{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    felt_value : felt
) -> (uint256_value : Uint256) {
    let (high, low) = split_felt(felt_value);
    let uint256_value : Uint256 = Uint256(low, high);
    return (uint256_value,);
}
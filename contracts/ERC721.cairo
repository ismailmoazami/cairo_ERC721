%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from openzeppelin.token.erc721.library import ERC721

// structs 
struct Characteristics{
    sex: felt, 
    legs: felt, 
    wings: felt,
}

// Storage 

@storage_var
func animal_characteristics(tokenId: Uint256) -> (characteristics: Characteristics) {
}

@storage_var
func tokenCounter() -> (res: Uint256) {
}


//
// Constructor
//

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    name: felt, symbol: felt, to_: felt, sex_: felt, legs_: felt, wings_: felt 
) {
    ERC721.initializer(name, symbol);
    let to = to_;
    let token_id: Uint256 = Uint256(1, 0);
    let (newTokenId, carry) = uint256_add(token_id, Uint256(1, 0));
    
    ERC721._mint(to, token_id);
    tokenCounter.write(newTokenId);
    animal_characteristics.write(token_id, Characteristics(sex=sex_, legs=legs_, wings=wings_));
    return ();
}

//
// Getters
//

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
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (owner: felt) {
    let (owner: felt) = ERC721.owner_of(token_id);
    return (owner,);
}

@view
func getApproved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (approved: felt) {
    let (approved: felt) = ERC721.get_approved(token_id);
    return (approved,);
}

@view
func isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, operator: felt
) -> (is_approved: felt) {
    let (is_approved: felt) = ERC721.is_approved_for_all(owner, operator);
    return (is_approved,);
}

@view 
func get_animal_characteristics{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(token_id: Uint256) -> (sex: felt, legs: felt, wings: felt) {
 alloc_locals;
 let (characteristics_) = animal_characteristics.read(token_id); 
 return(characteristics_.sex, characteristics_.legs, characteristics_.wings);
}

//
// Externals
//

@external
func approve{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, token_id: Uint256
) {
    ERC721.approve(to, token_id);
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
    _from: felt, to: felt, token_id: Uint256
) {
    ERC721.transfer_from(_from, to, token_id);
    return ();
}

@external
func safeTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt, to: felt, token_id: Uint256, data_len: felt, data: felt*
) {
    ERC721.safe_transfer_from(_from, to, token_id, data_len, data);
    return ();
}

@external
func declare_animal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    sex_: felt, legs_: felt, wings_: felt
) -> (token_id: Uint256){
    let (to) = get_caller_address();
    let (token_id_) = tokenCounter.read();

    ERC721._mint(to, token_id_);
    animal_characteristics.write(token_id_, Characteristics(sex=sex_, legs=legs_, wings=wings_));
    let (newTokenId, carry) = uint256_add(token_id_, Uint256(1, 0));
    tokenCounter.write(newTokenId);
    return(token_id=token_id_);
}

@external
func declare_dead_animal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) {
   // 0x00000000000000000000000000000000000000000000000000000000000dead 
    let (from_) = get_caller_address();
    let (to) = get_contract_address();
    with_attr error_message("Not the owner of the token Id") {
        let (owner_address) = ownerOf(token_id);
        assert owner_address = from_;
    }

    transferFrom(from_, to, token_id);
    animal_characteristics.write(token_id, Characteristics(sex=0, legs=0, wings=0));
    return();
}


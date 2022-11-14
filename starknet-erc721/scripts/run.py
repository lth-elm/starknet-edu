# from utils import *

def run(nre):
    print("Compiling contract...")
    nre.compile(["contracts/ExerciceSolution.cairo"])

    name = str_to_felt("Animal")
    symbol = str_to_felt("ANM")
    owner = hex_to_felt("0x041991e785ad6cE1e6D56A4ad2c1Bcf2AC9C3615DacCC4868C935670aa03219d")
    dummy_token_address = hex_to_felt("0x052ec5de9a76623f18e38c400f763013ff0b3ff8491431d7dc0391b3478bf1f3")
    tokenuri = str_to_felt_array("https://gateway.pinata.cloud/ipfs/QmWUB2TAYFrj1Uhvrgo69NDsycXfbfznNURj1zVbzNTVZv/")
    uri_len = len(tokenuri)
    end_uri = str_to_felt(".json")

    params = [
        name, 
        symbol,
        owner,
        dummy_token_address,
        uri_len,
        *tokenuri,
        end_uri,
    ]
    print(params)

    print("Deploying contract...")
    address, abi = nre.deploy("ExerciceSolution", params, alias="exSolution")

    print(f"ABI : {abi},\ExerciceSolution address : {address}")



# ------ UTILS ------

MAX_LEN_FELT = 31
 
def str_to_felt(text):
    if len(text) > MAX_LEN_FELT:
        raise Exception("Text length too long to convert to felt.")
    return int.from_bytes(text.encode(), "big")
 
def felt_to_str(felt):
    length = (felt.bit_length() + 7) // 8
    return felt.to_bytes(length, byteorder="big").decode("utf-8")
 
def str_to_felt_array(text):
    return [str_to_felt(text[i:i+MAX_LEN_FELT]) for i in range(0, len(text), MAX_LEN_FELT)]
 
def uint256_to_int(uint256):
    return uint256[0] + uint256[1]*2**128
 
def uint256(val):
    return (val & 2**128-1, (val & (2**256-2**128)) >> 128)
 
def hex_to_felt(val):
    return int(val, 16)
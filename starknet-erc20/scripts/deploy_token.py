# from utils import *

def run(nre):
    print("Compiling contract...")
    nre.compile(["contracts/Token.cairo"])

    name = str_to_felt("VJWMERC20")
    symbol = str_to_felt("VJWM")
    decimals = 8
    initial_supply = uint256(52000000000000000000000)
    recipient = hex_to_felt("0x041991e785ad6cE1e6D56A4ad2c1Bcf2AC9C3615DacCC4868C935670aa03219d")

    params = [
        name, 
        symbol,
        decimals,
        *initial_supply,
        recipient,
    ]
    print(params)

    print("Deploying contract...")
    address, abi = nre.deploy("Token", params, alias="token")

    print(f"ABI : {abi},\Token address : {address}")



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
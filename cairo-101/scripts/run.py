def run(nre):
    print("Compiling contract...")
    nre.compile(["contracts/AllInOneContract.cairo"])

    ex01address = 0x29e2801df18d7333da856467c79aa3eb305724db57f386e3456f85d66cbd58b
    ex02address = 0x18ef3fa8b5938a0059fa35ee6a04e314281a3e64724fe094c80e3720931f83f
    ex03address = 0x79275e734d50d7122ef37bb939220a44d0b1ad5d8e92be9cdb043d85ec85e24
    ex04address = 0x2cca27cae57e70721d0869327cee5cb58098af4c74c7d046ce69485cd061df1
    ex05address = 0x399a3fdd57cad7ed2193bdbb00d84553cd449abbdfb62ccd4119eae96f827ad
    ex06address = 0x718ece7af4fb1d9c82f78b7a356910d8c2a8d47d4ac357db27e2c34c2424582
    ex07address = 0x3a1ad1cde69c9e7b87d70d2ea910522640063ccfb4875c3e33665f6f41d354a
    ex08address = 0x15fa754c386aed6f0472674559b75358cde49db8b2aba8da31697c62001146c
    ex09address = 0x2b9fcc1cfcb1ddf4663c8e7ac48fc87f84c91a8c2b99414c646900bf7ef5549
    ex10address = 0x8415762f4b0b0f44e42ac1d103ac93c3ea94450a15bb65b99bbcc816a9388
    exercices = [ex01address, ex02address, ex03address, ex04address, ex05address, ex06address, ex07address, ex08address, ex09address, ex10address]
    exercices_len = len(exercices)

    params = [
        exercices_len, # 3 
        *exercices,
    ]

    print("Deploying contract...")
    address, abi = nre.deploy("AllInOneContract", params, alias="allInOne")

    print(f"ABI : {abi},\AllInOneContract address : {address}")




####### UTILS


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
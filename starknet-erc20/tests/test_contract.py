"""contract.cairo test file."""
import os

import pytest
from starkware.starknet.testing.starknet import Starknet


# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "Token.cairo")


# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_allowlist_level():
    """Test allowlist_level method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )

    # account = Account("0x5a1c86351ef55e515335e5930b14563b7f34dde51da4bb9fff683e6edb8a685", "goerli")
    # account.network = "goerli"
    # account.deploy()
    # assert account.address == (1,)

    # my_address = await contract.get_my_address().call()
    # assert my_address.result == (1,)
    # print(my_address)





    # expect_zero = await contract.allowlist_level(0).call()
    # assert expect_zero.result == (0,)








    # # Invoke increase_balance() twice.
    # await contract.increase_balance(amount=10).execute()
    # await contract.increase_balance(amount=20).execute()

    # # Check the result of get_balance().
    # execution_info = await contract.get_balance().call()
    # assert execution_info.result == (30,)


def uint256_to_int(uint256):
    return uint256[0] + uint256[1]*2**128

def uint256(val):
    return (val & 2**128-1, (val & (2**256-2**128)) >> 128)
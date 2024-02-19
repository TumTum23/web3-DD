pragma solidity ^0.8.0;

contract DirectDebit {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, _from)
            
            if lt(sload(ptr), _value) {
                revert(0, 0)
            }
            
            mstore(add(ptr, 0x20), msg.sender)
            if lt(sload(keccak256(ptr, 0x40)), _value) {
                revert(0, 0)
            }
            
            sstore(ptr, sub(sload(ptr), _value))
            sstore(keccak256(ptr, 0x40), sub(sload(keccak256(ptr, 0x40)), _value))
            
            mstore(ptr, _to)
            let recipientBalance := sload(ptr)
            if lt(sub(0, _value), recipientBalance) {
                revert(0, 0)
            }
            sstore(ptr, add(recipientBalance, _value))
            
            mstore(0x40, add(ptr, 0x20))
            mstore(ptr, 1)
            return(ptr, 0x20)
        }
    }
}
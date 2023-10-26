// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an operator) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the operator account will be the one that deploys the contract. This
 * can later be changed with {setOperator}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOperator`, which can be applied to your functions to restrict their use to
 * the owner or the operator account.
 */
abstract contract Operable is Ownable {
    address private operator;

    /**
     * @dev Throws if called by any account other than the owner or operator.
     */
    modifier onlyOperator() {
        require(
            msg.sender == operator || msg.sender == owner(),
            "Operable: caller is not the owner or operator."
        );
        _;
    }

    constructor() {
        operator = msg.sender;
    }

    /**
     * @dev Returns the address of the current operator.
     */
    function operator() public view virtual returns (address) {
        return operator;
    }

    /**
     * Change the operator for this contract.
     */
    function setOperator(address _operator) public virtual onlyOwner {
        operator = _operator;
    }
}

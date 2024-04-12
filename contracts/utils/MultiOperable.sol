// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @notice Contract module which provides a basic access control mechanism, in which
 * an account (an operator) can be granted exclusive access to
 * specific functions.
 *
 * @dev This module is used through inheritance. It will make available the modifier
 * `onlyOperators`, which can be applied to your functions to restrict their use to
 * the owner or an operator account.
 */
abstract contract MultiOperable is Ownable {
    mapping(address => bool) private operators;

    /**
     * @dev Throws if called by any account other than the owner or an operator.
     */
    modifier onlyOperators() {
        require(
            isOperator(msg.sender) || msg.sender == owner(),
            "MultiOperable: caller is not the owner or operator"
        );
        _;
    }

    /**
     * @notice Add an operator.
     * @param _operator address of the operator to be added
     */
    function addOperator(address _operator) public virtual onlyOwner {
        operators[_operator] = true;
    }

    /**
     * @notice Remove an operator.
     * @param _operator address of the operator to be removed
     */
    function removeOperator(address _operator) public virtual onlyOwner {
        delete operators[_operator];
    }

    /**
     * @notice Check if an address is an operator.
     * @param _operator address of the operator to be checked
     */
    function isOperator(address _operator) public view returns (bool) {
        return operators[_operator];
    }
}

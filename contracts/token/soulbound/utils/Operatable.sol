// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Operatable is Ownable, AccessControl {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /**
     * @dev Only operators can pass modifier
     */
    modifier onlyOperator() {
        require(hasRole(OPERATOR_ROLE, msg.sender), "Sender does not have operator role");
        _;
    }

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(OPERATOR_ROLE, msg.sender);
    }

    /**
     * @dev Assign `_account` `OPERATOR_ROLE`
     */
    function addOperator(address _account) public onlyOwner {
        grantRole(OPERATOR_ROLE, _account);
    }

    /**
     * @dev Remove `_account` from `OPERATOR_ROLE`
     */
    function removeOperator(address _account) public onlyOwner {
        revokeRole(OPERATOR_ROLE, _account);
    }

    /**
     * @dev Returns `true` if `_account` has `OPERATOR_ROLE`, otherwise returns `false` 
     */
    function checkOperator(address _account) public view returns (bool) { 
        return hasRole(OPERATOR_ROLE, _account);
    }
}


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Operatable is Ownable, AccessControl {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    modifier onlyOperator() {
        require(hasRole(OPERATOR_ROLE, msg.sender), "Sender does not have operator role");
        _;
    }

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(OPERATOR_ROLE, msg.sender);
    }

    function addOperator(address _account) public onlyOwner {
        grantRole(OPERATOR_ROLE, _account);
    }

    function removeOperator(address _account) public onlyOwner {
        revokeRole(OPERATOR_ROLE, _account);
    }

    function checkOperator(address _account) public view returns (bool) { 
        return hasRole(OPERATOR_ROLE, _account);
    }
}


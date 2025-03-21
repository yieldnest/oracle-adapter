// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from
    "lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import {PythStructs} from "src/pyth/PythStructs.sol";
import {IPyth} from "src/pyth/IPyth.sol";

contract PythCurveOracleAdapter is AccessControlUpgradeable {
    error InvalidPriceId();
    error InvalidPriceFeed();
    error InvalidMinAge();
    error InvalidAdmin();
    error OraclePriceNotPositive();
    error OracleExponentNotNegative();

    bytes32 public constant ORACLE_MANAGER_ROLE = keccak256("ORACLE_MANAGER_ROLE");

    event NewMinAge(uint256 minAge);

    bytes32 public priceId;
    address public priceFeed;
    uint256 public minAge;

    constructor() {
        _disableInitializers();
    }

    function initialize(address _admin, bytes32 _priceId, address _priceFeed, uint256 _minAge) public initializer {
        if (_admin == address(0)) revert InvalidAdmin();
        if (_priceId == bytes32(0)) revert InvalidPriceId();
        if (_priceFeed == address(0)) revert InvalidPriceFeed();
        if (_minAge == 0) revert InvalidMinAge();

        priceId = _priceId;
        priceFeed = _priceFeed;
        minAge = _minAge;
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(ORACLE_MANAGER_ROLE, _admin);
    }

    function setMinAge(uint256 _minAge) public
        onlyRole(ORACLE_MANAGER_ROLE) {

        minAge = _minAge;
        emit NewMinAge(_minAge);
    }


    function getPrice() public view returns (uint256) {
        IPyth priceContract = IPyth(priceFeed);
        PythStructs.Price memory r = priceContract.getPriceNoOlderThan(priceId, minAge);
        if (r.price <= 0) revert OraclePriceNotPositive();
        if (r.expo >= 0) revert OracleExponentNotNegative();

        uint256 needed = 18 - uint32(r.expo * -1); // It will be 10
        return uint256(uint64(r.price)) * (10 ** needed);
    }
}

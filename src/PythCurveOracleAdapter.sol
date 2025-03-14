// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "PythStructs.sol";
import "IPyth.sol";

contract PythCurveOracleAdapter is AccessControlUpgradeable {
    bytes32 public constant priceId = 0x8bdbbbbedd7c2ea2532d04c00dbcea6bb1cb800336953dfdf3747f825b809d81;
    address public constant priceFeed = 0x8250f4aF4B972684F7b336503E2D6dFeDeB1487a; // for base
    uint256 public constant minAge = 86400; // age in seconds

    function getPrice() public view returns (uint256) {
        IPyth priceContract = IPyth(priceFeed);
        PythStructs.Price memory r = priceContract.getPriceNoOlderThan(priceId, minAge);
        require(r.conf == 1, "Oracle confidence too low");
        require(r.price > 0, "Oracle price not positive");
        require(r.expo < 0, "Oracle expo not negative");

        uint256 needed = 18 - uint32(r.expo * -1); // It will be 10
        return uint256(uint64(r.price)) * (10 ** needed);
    }
}

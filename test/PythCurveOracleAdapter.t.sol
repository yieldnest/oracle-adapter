// SPDX-License-Identifier: BSD 3-Clause License
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {PythCurveOracleAdapter} from "src/PythCurveOracleAdapter.sol";
import {TransparentUpgradeableProxy} from "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {BaseData} from "script/BaseData.sol";

contract AdapterTest is Test, BaseData {
    PythCurveOracleAdapter public adapter;

    function setUp() public {
        PythCurveOracleAdapter impl = new PythCurveOracleAdapter();

        address admin = getSecurityCouncil(block.chainid);
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(impl),
            admin,
            ""
        );

        adapter = PythCurveOracleAdapter(address(proxy));

        bytes32 priceId = YNETH_ETH_PRICE_FEED;
        address priceFeed = getPriceFeed(block.chainid);
        uint256 minAge = 1 days;

        adapter.initialize(admin, priceId, priceFeed, minAge);
    }

    function test_Initialize() public view {
        assertEq(adapter.hasRole(adapter.DEFAULT_ADMIN_ROLE(), getSecurityCouncil(block.chainid)), true, "DEFAULT_ADMIN_ROLE");
        assertEq(adapter.priceId(), YNETH_ETH_PRICE_FEED, "priceId");
        assertEq(adapter.priceFeed(), getPriceFeed(block.chainid), "priceFeed");
        assertEq(adapter.minAge(), 1 days, "minAge");
        assertEq(adapter.minAge(), 86400, "minAge");
    }

    function test_Basic() public view {
        uint256 price = adapter.getPrice();
        console.log(price);
        assertGt(price, 0);
    }
}

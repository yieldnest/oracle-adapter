// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {PythCurveOracleAdapter} from "src/PythCurveOracleAdapter.sol";
import {TransparentUpgradeableProxy} from
    "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {IAccessControl} from "lib/openzeppelin-contracts/contracts/access/IAccessControl.sol";

import {BaseData} from "script/BaseData.sol";

contract AdapterTest is Test, BaseData {
    PythCurveOracleAdapter public adapter;

    // TODO: make this 1 days
    // currently the oracle price is not updated in the last 1 days so the test fails
    uint256 public constant MIN_AGE = 15 days;

    function setUp() public {
        PythCurveOracleAdapter impl = new PythCurveOracleAdapter();

        address admin = getSecurityCouncil(block.chainid);
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(impl), admin, "");

        adapter = PythCurveOracleAdapter(address(proxy));

        bytes32 priceId = YNETH_ETH_PRICE_FEED;
        address priceFeed = getPriceFeed(block.chainid);

        adapter.initialize(admin, priceId, priceFeed, MIN_AGE);
    }

    function test_Initialize() public view {
        assertEq(
            adapter.hasRole(adapter.DEFAULT_ADMIN_ROLE(), getSecurityCouncil(block.chainid)), true, "DEFAULT_ADMIN_ROLE"
        );
        assertEq(
            adapter.hasRole(adapter.ORACLE_MANAGER_ROLE(), getSecurityCouncil(block.chainid)),
            true,
            "ORACLE_MANAGER_ROLE"
        );
        assertEq(adapter.priceId(), YNETH_ETH_PRICE_FEED, "priceId");
        assertEq(adapter.priceFeed(), getPriceFeed(block.chainid), "priceFeed");
        assertEq(adapter.minAge(), MIN_AGE, "minAge");
    }

    function test_setMinAge_unauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), adapter.ORACLE_MANAGER_ROLE()
            )
        );
        adapter.setMinAge(300);
    }

    function test_setMinAge() public {
        uint256 newMinAge = 300;
        vm.prank(getSecurityCouncil(block.chainid));
        adapter.setMinAge(newMinAge);
        assertEq(adapter.minAge(), newMinAge, "minAge");
    }

    function test_Basic() public view {
        uint256 price = adapter.getPrice();
        console.log(price);
        assertGt(price, 0);
    }
}

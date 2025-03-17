// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PythCurveOracleAdapter} from "../src/PythCurveOracleAdapter.sol";

contract AdapterScript is Script {
    PythCurveOracleAdapter public adapter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

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

        vm.stopBroadcast();
    }

    function _deployAdapter(
    )

    function _deployTimelockController(
    )
        internal
        virtual
        returns (address timelock)
    {
        address admin = getSecurityCouncil(block.chainid);

        address[] memory proposers = new address[](1);
        proposers[0] = admin;

        address[] memory executors = new address[](1);
        executors[0] = admin;

        uint256 minDelay = getMinDelay(block.chainid);

        timelock = address(new TimelockController(minDelay, proposers, executors, admin));
    }

}

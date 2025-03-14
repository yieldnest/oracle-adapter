// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PythCurveOracleAdapter} from "../src/PythCurveOracleAdapter.sol";

contract AdapterScript is Script {
    PythCurveOracleAdapter public adapter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        adapter = new PythCurveOracleAdapter();

        vm.stopBroadcast();
    }
}

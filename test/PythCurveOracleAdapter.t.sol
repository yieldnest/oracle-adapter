// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PythCurveOracleAdapter} from "../src/PythCurveOracleAdapter.sol";

import "PythStructs.sol";
import "IPyth.sol";

import {console2} from "forge-std/console2.sol";

contract AdapterTest is Test {
    PythCurveOracleAdapter public adapter;

    function setUp() public {
        adapter = new PythCurveOracleAdapter();
        //counter.setNumber(0);
    }

    function test_Basic() public view {
        assertEq(adapter.minAge(), 86400);
        uint256 price = adapter.getPrice();
        console.log(price);
    }
}

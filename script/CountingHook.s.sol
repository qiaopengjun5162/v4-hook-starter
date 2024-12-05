// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {CountingHook} from "../src/CountingHook.sol";

contract CountingHookScript is Script {
    CountingHook public hook;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // hook = new CountingHook();

        vm.stopBroadcast();
    }
}

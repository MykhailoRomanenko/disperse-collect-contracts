// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {DisperseCollect} from "../src/DisperseCollect.sol";

contract CounterScript is Script {
    DisperseCollect public dc;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deployer:", deployerAddress);

        vm.startBroadcast(deployerPrivateKey);

        dc = new DisperseCollect(deployerAddress);

        vm.stopBroadcast();
    }
}

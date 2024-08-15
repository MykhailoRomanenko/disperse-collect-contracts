// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";

contract DeployMockErc20 is Script {
    ERC20Mock public token;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deployer:", deployerAddress);

        vm.startBroadcast(deployerPrivateKey);

        token = new ERC20Mock();

        token.mint(deployerAddress, 10000);

        vm.stopBroadcast();
    }
}

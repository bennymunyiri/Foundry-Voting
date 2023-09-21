// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Ballot} from "../src/Voting.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployBallot is Script {
    function run() external returns (Ballot, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
            address proposalName1,
            address proposalName2,
            address proposalName3
        ) = helperConfig.ActiveNetworkConfig();
        vm.startBroadcast();
        Ballot ballot = new Ballot(
            [proposalName1, proposalName2, proposalName3]
        );
        vm.stopBroadcast();
        return (ballot, helperConfig);
    }
}

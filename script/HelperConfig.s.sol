// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract HelperConfig {
    // structure of the networkconfig must mark it down one by one
    struct NetworkConfig {
        address proposalName1;
        address proposalName2;
        address proposalName3;
    }

    NetworkConfig public ActiveNetworkConfig;

    constructor() {
        if (block.chainid == 1115511) {
            ActiveNetworkConfig = getSepoliaNetworkConfig();
        } else {
            ActiveNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    // sepolia testnet
    function getSepoliaNetworkConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        return
            // replace with your own sepolia testnet addresses
            NetworkConfig({
                proposalName1: 0xA2Eee7C4A90Cfc8d8308544457bA3e1b66ef55C4,
                proposalName2: 0x885B86e9d97983371eAfC31c54666610804be4E3,
                proposalName3: 0x0708E40Ac7b77e08EC5Dac9565F0b20b706Ec604
            });
    }

    function getAddresses() public pure returns (address[3] memory) {
        return [address(uint160(1)), address(uint160(2)), address(uint160(4))];
    }

    // anvil testnet
    function getOrCreateAnvilConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        address[3] memory addresses = getAddresses();
        return
            NetworkConfig({
                proposalName1: addresses[0],
                proposalName2: addresses[1],
                proposalName3: addresses[2]
            });
    }
}

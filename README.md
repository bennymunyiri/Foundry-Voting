# About
This contract represents a comprehensive example of Solidity's capabilities by creating a voting system. However, it's essential to acknowledge that electronic voting poses challenges like verifying voter identities and preventing fraud. While we won't address all these issues here, we will demonstrate how delegated voting can be implemented to ensure automatic and transparent vote counting.

Here's an improved version of the explanation:

This smart contract serves as a foundation for a voting system. Its purpose is to facilitate voting for various proposals, each identified by a short name. The contract's creator, acting as the chairperson, has the authority to grant voting rights to individual addresses.

Individuals associated with these addresses can then make a choice: they can either cast their vote directly or delegate their voting power to a trusted individual.

When the voting period concludes, the winningProposal() function can be called to determine the proposal with the highest number of votes.

This approach allows for a decentralized and transparent voting process, although it's crucial to acknowledge that challenges like voter authentication and security against manipulation still need to be addressed comprehensively.
# Getting Started 
1. git
You'll know you did it right if you can run git --version and you see a response like git version x.x.x
2. foundry
You'll know you did it right if you can run forge --version and you see a response like forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)
## Usage
Start a local Node
     make anvil
## Library
If you're having a hard time installing the chainlink library, you can optionally run this command.
        forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit

## Deploy
This will default to your local node. You need to have it running in another terminal in order for it to deploy.
        make deploy
 ## forge test
or

forge test --fork-url $SEPOLIA_RPC_URL
Test Coverage
forge coverage
Deployment to a testnet or mainnet
Setup environment variables
You'll want to set your SEPOLIA_RPC_URL and PRIVATE_KEY as environment variables. You can add them to a .env file, similar to what you see in .env.example.

PRIVATE_KEY: The private key of your account (like from metamask). NOTE: FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.
You can learn how to export it here.
SEPOLIA_RPC_URL: This is url of the sepolia testnet node you're working with. You can get setup with one for free from Alchemy
Optionally, add your ETHERSCAN_API_KEY if you want to verify your contract on Etherscan.

## Get testnet ETH
Head over to faucets.chain.link and get some testnet ETH. You should see the ETH show up in your metamask.

## Deploy
make deploy ARGS="--network sepolia"
This will setup a ChainlinkVRF Subscription for you. If you already have one, update it in the scripts/HelperConfig.s.sol file. It will also automatically add your contract as a consumer.
make createSubscription ARGS="--network sepolia"
## Estimate gas
You can estimate how much gas things cost by running:

        forge snapshot
And you'll see an output file called .gas-snapshot

## Formatting
To run code formatting:

        forge fmt

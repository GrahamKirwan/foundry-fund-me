# Foundry setup and deploying contracts safely #

forge - compiling and interacting with our contracts
cast - interating with contracts that have already been deployed
anvil - deploy a local blockchain

- Install foundry - 'foundryup'
- Create new foundry forge template with 'forge init'
- Compile contracts with 'forge compile'
- Start new local blockchain with Anvil 'anvil' (This gives us dummy accounts with dummy eth and private keys). Anvil runs on a local IP on our mahcine which we can enter into metamask as an RPC endpoint to interact with our dummy chain on metamask.
- To deploy and test smart contracts locally we can use 'forge create SimpleStorage --interactive --broadcast'
- If we wanted to deploy to any blockchain we would use 'forge create SimpleStorage --rpc-url http://exmaple.com --private-key 0x8983984938493...'
- We can encrypt private keys used in our contracts with the ERC-2335 standard (and avoid .env files). We encryt the private key with the following command 'cast wallet import aKeyName --interactive'. Then to deploy a contract with our new encryted key we would use 'forge create SimpleStorage --rpc-url http://localhost:8545 --account aKeyName --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --broadcast -vvvv'
- If we ever enter an private key into our terminal to encrypt, we should run 'history -c' and 'rm .bash_history' to remove it entirely

# Run Foundry Forge Tests + rpc forks #
- To run tests on our contracts we write tests in the test folder. We then run them with 'forge test test/FundMeTest.t.sol'
- A shortcut - we can run 'forge test --match-test someTestFunctionName' to only run a test on a particular function
- To run tests on our local anvil environment on data feeds running on sepholia (chainlink price data feeds for exmaple), we can add a --fork-url modifier to our test commands. This will simulate the chain of whatever rpc url we pass in. 'forge test --match-test testPriceFeedVersion --fork-url https://eth-sepolia.g.alchemy.com/v2/xPu9JtoaTqrBv1g0m_PsPmgET5Sp7K66'


# Foundry scripts to deploy and call functions on a deployed contract - forge script + cast # 
- To deploy a script that deploys our contract to a blockchain 'forge script script/DeploySimpleStorage.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --private-key 0x8983984938493...' (If we want to deploy this to a real chain like sepholia for exmaple, we will need to run our own node from a service such as alchemy and use that rpc)

- To send a setter function call
'cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "storeFavNum(uint256)" 123 --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17...'

- To send a getter function call
'cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "retreiveFavNum()" --rpc-url https://eth-sepolia.g.alchemy.com/v2/xPu9JtoaTqrBv1g0...'

- Helpful cmd prompt to change hex numbers to decimal
'cast --to-base 0x000 dec'

# Install Chainlink Brownie Contracts repo to be able to use chainlink data feeds in our foundry setup
- 'forge install https://github.com/smartcontractkit/chainlink-brownie-contracts --no-commit'
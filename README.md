# DisperseCollect
## Setup
### Modify env

```plaintext
PRIVATE_KEY=
FORK_URL=
```

### Setup forked environment
```bash
source .env
anvil --fork-url $FORK_URL --block-time 5
forge script script/DisperseCollect.s.sol --fork-url localhost:8545 --broadcast
forge script script/MockERC20.s.sol --fork-url localhost:8545 --broadcast
```
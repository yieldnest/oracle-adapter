## Pyth Adapter

Took the structs/interfaces from here: https://github.com/pyth-network/pyth-sdk-solidity

List of all price contracts: https://docs.pyth.network/price-feeds/contract-addresses/evm

We are looking at Base, Arbitrum, and Ink Kraken right now, but of we'll want to easily
deploy to more chains later.

The contract should use a Timelock and be upgradable. Proxy should deploy to the same
address on each chain.

https://www.pyth.network/price-feeds/crypto-yneth-eth-rr
ID: 0x8bdbbbbedd7c2ea2532d04c00dbcea6bb1cb800336953dfdf3747f825b809d81

https://www.pyth.network/price-feeds/crypto-ynethx-weth-rr
ID: 0x741f2ecf4436868e4642db088fa33f9858954b992285129c9b03917dcb067ecc

Run:
```
forge -vvv test --rpc-url https://mainnet.base.org
```

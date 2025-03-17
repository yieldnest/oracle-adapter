// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract BaseData {
    bytes32 public constant YNETH_ETH_PRICE_FEED = 0x8bdbbbbedd7c2ea2532d04c00dbcea6bb1cb800336953dfdf3747f825b809d81;

    bytes32 public constant YNETHX_WETH_PRICE_FEED = 0x741f2ecf4436868e4642db088fa33f9858954b992285129c9b03917dcb067ecc;

    // Mapping of chainId to price feed address
    mapping(uint256 => address) private priceFeeds;

    // Mapping of chainId to YieldNest security council address
    mapping(uint256 => address) private securityCouncils;

    constructor() {
        // MAINNETS

        // ETHEREUM
        priceFeeds[1] = 0x4305FB66699C3B2702D4d05CF36551390A4c69C6;
        securityCouncils[1] = 0xfcad670592a3b24869C0b51a6c6FDED4F95D6975;

        // OPTIMISM
        priceFeeds[10] = 0xff1a0f4744e8582DF1aE09D5611b887B6a12925C;
        securityCouncils[10] = 0xCb343bF07E72548349f506593336b6CB698Ad6dA;

        // ARBITRUM
        priceFeeds[42161] = 0xff1a0f4744e8582DF1aE09D5611b887B6a12925C;
        securityCouncils[42161] = 0xCb343bF07E72548349f506593336b6CB698Ad6dA;

        // BASE MAINNET
        priceFeeds[8453] = 0x8250f4aF4B972684F7b336503E2D6dFeDeB1487a;
        securityCouncils[8453] = 0xCb343bF07E72548349f506593336b6CB698Ad6dA;

        // INK MAINNET
        priceFeeds[57073] = 0x2880aB155794e7179c9eE2e38200202908C17B43;
        securityCouncils[57073] = address(0);

        // Add the rest of the mainnets...

        // TESTNETS

        // ETHEREUM SEPOLIA
        priceFeeds[11155111] = 0xDd24F84d36BF92C65F92307595335bdFab5Bbd21;
        securityCouncils[11155111] = address(0);

        // OPTIMISM SEPOLIA
        priceFeeds[11155420] = 0x0708325268dF9F66270F1401206434524814508b;
        securityCouncils[11155420] = address(0);

        // ARBITRUM SEPOLIA
        priceFeeds[421614] = 0x4374e5a8b9C22271E9EB878A2AA31DE97DF15DAF;
        securityCouncils[11155420] = address(0);

        // BASE SEPOLIA
        priceFeeds[84532] = 0xA2aa501b19aff244D90cc15a4Cf739D2725B5729;
        securityCouncils[84532] = address(0);

        // INK SEPOLIA
        priceFeeds[763373] = 0x2880aB155794e7179c9eE2e38200202908C17B43;
        securityCouncils[763373] = address(0);

        // Add the rest of the testnets...
    }

    function getPriceFeed(uint256 chainId) public view returns (address) {
        address feed = priceFeeds[chainId];
        require(feed != address(0), "Chain not supported for price feed");
        return feed;
    }

    function getSecurityCouncil(uint256 chainId) public view returns (address) {
        address council = securityCouncils[chainId];
        require(council != address(0), "Chain not supported for security council");
        return council;
    }

    function isTestnet(uint256 chainId) public pure returns (bool) {
        return chainId == 11155111 || chainId == 11155420 || chainId == 421614 || chainId == 84532 || chainId == 763373;
    }

    function getMinDelay(uint256 chainId) public pure returns (uint256) {
        if (isTestnet(chainId)) {
            return 10 minutes;
        } else {
            return 1 days;
        }
    }
}

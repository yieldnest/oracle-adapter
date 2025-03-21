// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PythCurveOracleAdapter} from "src/PythCurveOracleAdapter.sol";
import {AdapterFactory} from "src/factory/AdapterFactory.sol";
import {TimelockController} from "lib/openzeppelin-contracts/contracts/governance/TimelockController.sol";
import {BaseData} from "script/BaseData.sol";
import {ProxyUtils} from "script/ProxyUtils.sol";

contract DeployAdapter is BaseData, Script {
    string public constant VERSION = "v0.0.1";

    function run() public {
        bytes32 factorySalt = _createSalt(msg.sender, "PythCurveOracleAdapterFactory");
        bytes32 implSalt = _createSalt(msg.sender, "PythCurveOracleAdapterImpl");
        bytes32 proxySalt = _createSalt(msg.sender, "PythCurveOracleAdapterProxy");

        address admin = getSecurityCouncil(block.chainid);
        bytes32 priceId = YNETH_ETH_PRICE_FEED;
        address priceFeed = getPriceFeed(block.chainid);
        uint256 minAge = 2 days;

        vm.startBroadcast();

        // NOTE: Factory is deployed using create2 for a deterministic address on all chains
        // If factory address is different for a particular chain, then the proxy address will be different
        AdapterFactory factory = new AdapterFactory{salt: factorySalt}();
        console.log("Factory deployed to", address(factory));

        address timelock = _deployTimelockController();

        console.log("TimelockController deployed to", timelock);
        bytes memory initializeArgs =
            abi.encodeWithSelector(PythCurveOracleAdapter.initialize.selector, admin, priceId, priceFeed, minAge);

        // NOTE: PythCurveOracleAdapter is deployed using create3 to create a deterministic address on all chains
        address proxy = factory.deployContractAndProxy(
            implSalt, proxySalt, timelock, type(PythCurveOracleAdapter).creationCode, initializeArgs
        );
        console.log("Proxy deployed to", proxy);
        vm.stopBroadcast();

        _saveDeployment(admin, priceId, priceFeed, minAge, address(factory), timelock, proxy);
    }

    function _deployTimelockController() internal virtual returns (address timelock) {
        address admin = getSecurityCouncil(block.chainid);
        uint256 minDelay = getMinDelay(block.chainid);

        address[] memory proposers = new address[](1);
        proposers[0] = admin;

        address[] memory executors = new address[](1);
        executors[0] = admin;

        // NOTE: TimelockController is deployed using normal create call to save gas
        timelock = address(new TimelockController(minDelay, proposers, executors, admin));
    }

    function _createSalt(address _deployerAddress, string memory _label) internal pure returns (bytes32 _salt) {
        _salt = bytes32(
            abi.encodePacked(bytes20(_deployerAddress), bytes12(bytes32(keccak256(abi.encode(_label, VERSION)))))
        );
    }

    function _getDeploymentFilePath() internal view returns (string memory) {
        return string(
            abi.encodePacked(
                vm.projectRoot(),
                "/deployments/",
                "PythCurveOracleAdapter",
                "-",
                vm.toString(block.chainid),
                "-",
                VERSION,
                ".json"
            )
        );
    }

    function _saveDeployment(
        address admin,
        bytes32 priceId,
        address priceFeed,
        uint256 minAge,
        address factory,
        address timelock,
        address proxy
    ) internal {
        string memory json = vm.serializeAddress("deployment", "deployer", msg.sender);
        json = vm.serializeAddress("deployment", "admin", admin);
        json = vm.serializeBytes32("deployment", "priceId", priceId);
        json = vm.serializeAddress("deployment", "priceFeed", priceFeed);
        json = vm.serializeUint("deployment", "minAge", minAge);
        json = vm.serializeAddress("deployment", "factory", factory);
        json = vm.serializeAddress("deployment", "timelock", timelock);
        json = vm.serializeAddress("deployment", "proxy", proxy);
        json = vm.serializeAddress("deployment", "implementation", ProxyUtils.getImplementation(proxy));
        json = vm.serializeAddress("deployment", "proxyAdmin", ProxyUtils.getProxyAdmin(proxy));
        json = vm.serializeString("deployment", "version", VERSION);

        string memory filePath = _getDeploymentFilePath();
        vm.writeJson(json, filePath);
    }
}

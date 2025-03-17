// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {TransparentUpgradeableProxy} from
    "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {CREATE3} from "lib/solmate/src/utils/CREATE3.sol";

contract AdapterFactory {
    /// @notice Emitted when a new contract is deployed
    /// @param _deployedAddress The address of the newly deployed contract
    event ContractCreated(address indexed _deployedAddress);

    /// @notice Mapping to track deployed addresses
    mapping(address => bool) private _deployedContracts;

    /// @dev Custom errors
    error InvalidSalt();
    error AlreadyDeployed();
    error IncorrectDeploymentAddress();

    /// @dev Modifier to ensure that the first 20 bytes of a submitted salt match
    /// those of the calling account, providing protection against salt misuse.
    /// @param _salt The salt value to check against the calling address.
    modifier containsCaller(bytes32 _salt) {
        if (address(bytes20(_salt)) != msg.sender && bytes20(_salt) != bytes20(0)) {
            revert InvalidSalt();
        }
        _;
    }

    /// @notice Predicts the address of a contract deployed using CREATE3.
    /// @dev The provided salt is combined with the deployer address to create a unique predicted
    /// address.
    /// @param _salt A deployer-specific salt for determining the deployed contract's address.
    /// @return deployed The address of the contract that will be deployed.
    function getDeployed(bytes32 _salt) external view returns (address deployed) {
        return CREATE3.getDeployed(_salt);
    }

    /// @notice Checks if a contract has already been deployed by the factory to a specific address.
    /// @param _deploymentAddress The contract address to check.
    /// @return beenDeployed as true if the contract has been deployed, false otherwise.
    function hasBeenDeployed(address _deploymentAddress) external view returns (bool beenDeployed) {
        beenDeployed = _deployedContracts[_deploymentAddress];
    }

    /// @notice Deploys a contract using CREATE3
    /// @dev The provided salt is combined with msg.sender to create a unique deployment address.
    /// @param _salt A deployer-specific salt for determining the deployed contract's address.
    /// @param _creationCode The creation code of the contract to deploy.
    /// @return  deployedContract The address of the deployed contract.
    function deploy(bytes32 _salt, bytes memory _creationCode)
        public
        payable
        containsCaller(_salt)
        returns (address deployedContract)
    {
        address _targetDeploymentAddress = CREATE3.getDeployed(_salt);

        if (_deployedContracts[_targetDeploymentAddress]) {
            revert AlreadyDeployed();
        }

        deployedContract = CREATE3.deploy(_salt, _creationCode, msg.value);

        if (_targetDeploymentAddress != deployedContract) {
            revert IncorrectDeploymentAddress();
        }

        _deployedContracts[deployedContract] = true;
        emit ContractCreated(deployedContract);
    }

    /// @notice Deploys a TransparentUpgradeableProxy with given parameters.
    /// @param _salt The salt used for deployment.
    /// @param _implementation The address of the implementation contract.
    /// @param _controller The address of the proxy controller.
    /// @param _initializeArgs The initialization arguments for the proxy.
    /// @return proxy The address of the deployed proxy.
    function deployProxy(bytes32 _salt, address _implementation, address _controller, bytes memory _initializeArgs)
        public
        returns (address proxy)
    {
        bytes memory _constructorParams = abi.encode(_implementation, _controller, _initializeArgs);
        bytes memory _contractCode =
            abi.encodePacked(type(TransparentUpgradeableProxy).creationCode, _constructorParams);
        proxy = deploy(_salt, _contractCode);
    }

    /// @notice Deploys an implementation and proxy contract.
    /// @param _implSalt The salt used for the implementation deployment.
    /// @param _proxySalt The salt used for the proxy deployment.
    /// @param _controller The address of the proxy controller.
    /// @param _bytecode The bytecode of the implementation contract.
    /// @param _initializeArgs The initialization arguments for the proxy.
    /// @return addr The address of the deployed proxy.
    function deployContractAndProxy(
        bytes32 _implSalt,
        bytes32 _proxySalt,
        address _controller,
        bytes memory _bytecode,
        bytes memory _initializeArgs
    ) public returns (address addr) {
        address _implAddr = deploy(_implSalt, _bytecode);
        return deployProxy(_proxySalt, _implAddr, _controller, _initializeArgs);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./../Kernel.sol";             
import "./KernelFactory.sol";       


interface IContractRegistry {
    function contractByName(string calldata name) external view returns (address);
}

contract WirexKernelFactory is KernelFactory {
    address public executionDelayPolicy;
    address public fundsManagementExecutor;

   event WirexAccountCreated(
        address indexed account,
        address indexed owner,
        address executionDelayPolicy,
        address fundsManagementExecutor
    );

    constructor(address _contractRegistry)
        KernelFactory(0x5FF137D4B0FDcD49DcA30C7cF57E578a026D2789)
    {
        contractRegistry = IContractRegistry(_contractRegistry);
    }

    /**
     * @notice Create AA Wallet and add Wirex modules
     * @param owner EOA user (MPC Fireblocks)
     * @param salt Solt for CREATE2 (can be 0)
     */
    function createWirexAccount(address owner, uint256 salt)
        public
        returns (address)
    {
        // 1. Get actual addresses from Wirex Contract Registry
        address executionDelayPolicy = contractRegistry.contractByName("ExecutionDelayPolicy");
        address fundsManagementExecutor = contractRegistry.contractByName("FundsManagement");

        // 2. Create Kernel Account
        address account = createAccount(owner, salt);

        // 3. Add Wirex modules
        Kernel(account).addModule(executionDelayPolicy);
        Kernel(account).addExecutor(fundsManagementExecutor);

        emit WirexAccountCreated(account, owner, executionDelayPolicy, fundsManagementExecutor);
        return account;
    }
}

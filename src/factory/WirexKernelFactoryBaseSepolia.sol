// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./../Kernel.sol";         
import "./KernelFactory.sol";
import "./WirexHelper.sol";


contract WirexKernelFactoryBaseSepolia is KernelFactory {
    address public executionDelayPolicy;
    address public fundsManagementExecutor;

   event WirexAccountCreated(
        address indexed account,
        address indexed owner,
        address executionDelayPolicy,
        address fundsManagementExecutor
    );

    constructor()
        KernelFactory(0x5FF137D4B0FDcD49DcA30C7cF57E578a026D2789)
    {
        contractRegistry = IContractRegistry(0xC801a0f38E20500B5840c4927553b3409890bc3c);
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

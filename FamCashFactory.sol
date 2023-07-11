// SPDX-License-Identifier: MIT

// Pragma Declaration
pragma solidity ^0.8.0;

// Imports
import "./FamCash.sol";

// Create contract: FamCashFactory
contract FamCashFactory {

    // Array of Contracts
    FamCash[] public FamCashContracts;

    // NewFamCash Function - Creates new FamCash contract
    function NewFamCash(
        address _contractOwner,
        string memory _tokenName,
        string memory _tokenTicker)
        public {

        // Contract Initialization - Sets token name & ticker
        FamCash famcash = new FamCash(_contractOwner, _tokenName, _tokenTicker);

        // Array Update - Adds created contract to FamCash array
        FamCashContracts.push(famcash);
    }
}
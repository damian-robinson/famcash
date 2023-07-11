// SPDX-License-Identifier: MIT

// Pragma Declaration
pragma solidity ^0.8.0;

// Imports
import "./FamCashDuo.sol";

// Create contract: FamCashDuoFactory
contract FamCashDuoFactory {

    // Array of Contracts
    FamCashDuo[] public FamCashDuoContracts;

    // NewFamCashDuo Function - Creates new FamCash contract
    function NewFamCashDuo(
        address _contractOwner,
        string memory _tokenName,
        string memory _tokenTicker)
        public {

        // Contract Initialization - Sets token name & ticker
        FamCashDuo famcashduo = new FamCashDuo(_contractOwner, _tokenName, _tokenTicker);

        // Array Update - Adds created contract to FamCash array
        FamCashDuoContracts.push(famcashduo);
    }
}

// SPDX-License-Identifier: MIT

// Pragma Declaration
pragma solidity ^0.8.0;

// Imports
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// Contract: FamCash
contract FamCashDuo is ERC20, AccessControl {

    // Role Identifiers - Creates roles for limiting specific functionality
    bytes32 public constant PARENT_ROLE = keccak256("PARENT_ROLE");
    bytes32 public constant MEMBER_ROLE = keccak256("MEMBER_ROLE");

    // OnlyParent Modifier - Requires the PARENT_ROLE to execute
    modifier onlyParent() { require(hasRole(PARENT_ROLE, msg.sender),
        "Only a parent can do this.");
        _;
    }

    // OnlyFamily Modifier - Limits sending to family members
    modifier onlyFamily() {
        require(hasRole(PARENT_ROLE, msg.sender) || hasRole(MEMBER_ROLE, msg.sender),
        "Only family members can send tokens.");
        _;
    }

    // BothParentsSigned Modifier - Requires both parents' signatures to execute
    modifier bothParentsSigned() {
        require(_parentSignatures[_parent1] && _parentSignatures[_parent2],
        "Both parents must sign off.");
        _;
    }

    // Parent addresses
    address private _parent1;
    address private _parent2;

    // Parent Signatures Mapping
    mapping(address => bool) private _parentSignatures;

    // Maximum Supply Limit
    uint256 public maxSupplyLimit = 1000000;

    // Constructor Implementation - Sets up the contract
    constructor(
        address contractOwner,
        string memory tokenName,
        string memory tokenTicker)
    ERC20(tokenName, tokenTicker)
    {
        // Role Assignments
        _setupRole(DEFAULT_ADMIN_ROLE, contractOwner);
        _setupRole(PARENT_ROLE, contractOwner);
        _setupRole(MEMBER_ROLE, contractOwner);

        // Set contract owner as parent1
        _parent1 = contractOwner;
        _parentSignatures[_parent1] = false;
    }

    // Mint Function - Mints new tokens
    function mint(address recipient, uint256 amount) public onlyRole(PARENT_ROLE) {

        // Input validation - Checks for valid address and amount
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than zero");
        
        // Total Supply - Sets the supply by adding the amount
        uint256 totalSupplyAfterMint = totalSupply() + amount;

        // Post-Mint Check - Stops request from exceeding the minting limit
        require(totalSupplyAfterMint <= maxSupplyLimit, "Exceeds limit");

        // _mint - Sends specified token amount to specified recipient
        _mint(recipient, amount);
    }

    // Send Function - Sends tokens to a recipient
    function send(address recipient, uint256 amount) public onlyFamily {
        
        // Transfer - Transfers tokens from sender to recipient
        _transfer(msg.sender, recipient, amount);
    }

    // Add Second Parent Function
    function addSecondParent(address parent) public onlyRole(PARENT_ROLE) {

        // Checks if second parent already exists
        require(_parent2 == address(0),
        "Second parent already exists.");

        // Checks if first parent already exists
        require(parent != _parent1,
        "You're already added as the first parent.");
        
        // Assigns second parent role
        _parent2 = parent;

        // Ensures parent2's signature is false by default
        _parentSignatures[_parent2] = false;

        // Grants appropriate roles
        _grantRole(PARENT_ROLE, parent);
        _grantRole(MEMBER_ROLE, parent);
    }

    // AddMember Function - Adds new family member
    function addMember(address member) public onlyRole(PARENT_ROLE) {

        // Check if address is already a member
        require(!hasRole(MEMBER_ROLE, member), "Address is already a member");

        // Grant member role to address
        _grantRole(MEMBER_ROLE, member);
    }

    // Pay Allowance Function - Pays an allowance when both parents approve
    function payAllowance(address to, uint256 allowanceAmount) external onlyParent bothParentsSigned {

        // Reset parent signatures for the next transfer
        _parentSignatures[_parent1] = false;
        _parentSignatures[_parent2] = false;

        // Transfer the allowance to the address (child or member)
        _transfer(msg.sender, to, allowanceAmount);
    }

    // Set Parent Signature Function - Sets the parent's signature status
    function setParentSignature(bool hasSigned) external onlyParent {
        _parentSignatures[msg.sender] = hasSigned;
    }
}

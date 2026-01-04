// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title SimpleStablecoin
 * @notice Minimal stablecoin with off-chain settlement signalling and privileged mint/burn
 * @dev This contract is a proof-of-concept and should not be used in production as-is.
 */
contract SimpleStablecoin is ERC20, Ownable, Pausable {
    address public issuer;

    event IssuanceRequested(address indexed to, uint256 amount, string referenceId);
    event RedemptionRequested(address indexed from, uint256 amount, string referenceId);
    event IssuerChanged(address indexed oldIssuer, address indexed newIssuer);

    modifier onlyIssuerOrOwner() {
        require(msg.sender == issuer || msg.sender == owner(), "SimpleStablecoin: caller is not issuer or owner");
        _;
    }

    constructor(string memory name_, string memory symbol_, address issuer_) ERC20(name_, symbol_) Ownable(msg.sender) {
        require(issuer_ != address(0), "issuer cannot be zero");
        issuer = issuer_;
    }

    function setIssuer(address newIssuer) external onlyOwner {
        require(newIssuer != address(0), "new issuer is zero");
        emit IssuerChanged(issuer, newIssuer);
        issuer = newIssuer;
    }

    function requestIssuance(address to, uint256 amount, string calldata referenceId) external onlyIssuerOrOwner whenNotPaused {
        require(to != address(0), "to address zero");
        require(amount > 0, "amount zero");
        emit IssuanceRequested(to, amount, referenceId);
    }

    function mintFor(address to, uint256 amount) external onlyIssuerOrOwner whenNotPaused {
        require(to != address(0), "to address zero");
        require(amount > 0, "amount zero");
        _mint(to, amount);
    }

    function requestRedemption(uint256 amount, string calldata referenceId) external whenNotPaused {
        require(balanceOf(msg.sender) >= amount, "insufficient balance");
        require(amount > 0, "amount zero");
        emit RedemptionRequested(msg.sender, amount, referenceId);
    }

    function burnFromIssuer(address from, uint256 amount) external onlyIssuerOrOwner whenNotPaused {
        require(from != address(0), "from zero");
        require(balanceOf(from) >= amount, "insufficient balance");
        _burn(from, amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
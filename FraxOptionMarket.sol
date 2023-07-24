// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts@4.8.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract OptionsMarket {
    using SafeMath for uint256;

    address public admin; 
    IERC20 public underlyingAssetFrax; // FRAX/FXS
    IERC20 public strikeAsset; // DAI/ETH, etc.
    uint256 public contractExpiry; //Date
    uint256 public strikePrice; // Option exercise price in units of strikeAsset
    uint256 public totalSupply; // Total options supply
    mapping(address => uint256) public balances; // Balance of options of each user

    enum OptionType { Call, Put }
    mapping(address => mapping(OptionType => uint256)) public activeOptions; // Active options of each user

    event OptionPurchased(address indexed buyer, OptionType optionType, uint256 amount);
    event OptionExercised(address indexed holder, OptionType optionType, uint256 amount, uint256 payout);

    constructor(
        address _underlyingAssetAddressFrax,
        address _strikeAssetAddress,
        uint256 _expiryTimestamp,
        uint256 _strikePrice
    ) {
        admin = msg.sender;
        underlyingAssetFrax = IERC20(_underlyingAssetAddressFrax);
        strikeAsset = IERC20(_strikeAssetAddress);
        contractExpiry = _expiryTimestamp;
        strikePrice = _strikePrice;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }

    modifier contractNotExpired() {
        require(block.timestamp < contractExpiry, "Contract has expired.");
        _;
    }

    function purchaseOption(OptionType optionType, uint256 amount) external contractNotExpired {
        require(amount > 0, "Amount must be greater than zero.");

        uint256 cost = amount.mul(strikePrice);
        require(strikeAsset.allowance(msg.sender, address(this)) >= cost, "You must approve the option cost.");

        balances[msg.sender] = balances[msg.sender].add(amount);
        activeOptions[msg.sender][optionType] = activeOptions[msg.sender][optionType].add(amount);
        totalSupply = totalSupply.add(amount);

        strikeAsset.transferFrom(msg.sender, address(this), cost);

        emit OptionPurchased(msg.sender, optionType, amount);
    }

    function exerciseOption(OptionType optionType, uint256 amount) external contractNotExpired {
        require(activeOptions[msg.sender][optionType] >= amount, "Insufficient active options.");

        uint256 payout;
        if (optionType == OptionType.Call) {
            payout = amount.mul(underlyingAssetFrax.balanceOf(address(this))).div(totalSupply);
        } else if (optionType == OptionType.Put) {
            payout = amount.mul(strikePrice).div(totalSupply);
        }

        balances[msg.sender] = balances[msg.sender].sub(amount);
        activeOptions[msg.sender][optionType] = activeOptions[msg.sender][optionType].sub(amount);
        totalSupply = totalSupply.sub(amount);

        underlyingAssetFrax.transfer(msg.sender, payout);

        emit OptionExercised(msg.sender, optionType, amount, payout);
    }

    function withdrawStrikeAsset(uint256 amount) external onlyAdmin {
        strikeAsset.transfer(msg.sender, amount);
    }

    function withdrawUnderlyingAsset(uint256 amount) external onlyAdmin {
        underlyingAssetFrax.transfer(msg.sender, amount);
    }

    function setStrikePrice(uint256 newStrikePrice) external onlyAdmin {
        strikePrice = newStrikePrice;
    }
}

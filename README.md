# Frax Option Market

Frax Option Market allows the execution of options (derivatives) based on FRAX and Frax Shares (FXS) with respect to any other asset.

## Constructor 
```js
constructor(
        address _underlyingAssetAddressFrax, //FRAX or FXS address in the blockchain network (Ethereum, Polygon, etc)
        address _strikeAssetAddress, // DAI/ETH, etc.
        uint256 _expiryTimestamp,
        uint256 _strikePrice
    )
```

## Purchase option
Purchase an option (call or put) for the amount (with the strike asset specified in the contract), if the contract has not expired.

```js
function purchaseOption(OptionType optionType, uint256 amount)
```

**OptionType**: Call / Put

## Exercise option

Exercise an active option (call or put) for the amount (with the strike asset specified in the contract), if the contract has not expired.

```js
function exerciseOption(OptionType optionType, uint256 amount)
```

**OptionType**: Call / Put


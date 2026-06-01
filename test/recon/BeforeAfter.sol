// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Setup} from "./Setup.sol";

import {Id, Market} from "../../src/interfaces/IMorpho.sol";

// ghost variables for tracking state variable values before and after function calls
abstract contract BeforeAfter is Setup {
    enum OpType {
        DEFAULT,
        SUPPLY,
        WITHDRAW,
        BORROW,
        REPAY,
        SUPPLY_COLLATERAL,
        WITHDRAW_COLLATERAL,
        LIQUIDATE,
        FLASH_LOAN,
        ACCRUE_INTEREST
    }

    struct MarketVars {
        uint256 totalBorrowAssets;
        uint256 totalBorrowShares;
        uint256 totalSupplyAssets;
        uint256 totalSupplyShares;
    }

    struct Vars {
        mapping(Id => MarketVars) markets;
    }

    Vars internal _before;
    Vars internal _after;
    mapping(Id => OpType) marketLastOps;

    modifier updateGhosts(OpType opType) {
        Id id = _formatId(activeMarketParams);

        __before(id);
        _;
        __after(id);

        marketLastOps[id] = opType;
    }

    function __before(Id id) internal {
        Market memory market = morpho.market(id);

        _before.markets[id].totalBorrowAssets = market.totalBorrowAssets;
        _before.markets[id].totalBorrowShares = market.totalBorrowShares;
        _before.markets[id].totalSupplyAssets = market.totalSupplyAssets;
        _before.markets[id].totalSupplyShares = market.totalSupplyShares;
    }

    function __after(Id id) internal {
        Market memory market = morpho.market(id);

        _after.markets[id].totalBorrowAssets = market.totalBorrowAssets;
        _after.markets[id].totalBorrowShares = market.totalBorrowShares;
        _after.markets[id].totalSupplyAssets = market.totalSupplyAssets;
        _after.markets[id].totalSupplyShares = market.totalSupplyShares;
    }
}

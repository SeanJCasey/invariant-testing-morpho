// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";

import {Id, Market} from "../../src/interfaces/IMorpho.sol";
import {SharesMathLib} from "../../src/libraries/SharesMathLib.sol";

abstract contract Properties is BeforeAfter, Asserts {
    // Property: totalSupplyShares = SUM(position[id][user].supplyShares)
    function property_accounting_totalSupplyShares() public {
        Id id = _formatId(activeMarketParams);

        uint256 shares;
        address[] memory actors = _getActors();
        for (uint256 i; i < actors.length; i++) {
            address actor = actors[i];
            shares += morpho.position(id, actor).supplyShares;
        }

        eq(
            shares,
            morpho.market(id).totalSupplyShares,
            "property_accounting_supplyShares"
        );
    }

    // Property: totalBorrowShares = SUM(position[id][user].borrowShares)
    function property_accounting_totalBorrowShares() public {
        Id id = _formatId(activeMarketParams);

        uint256 shares;
        address[] memory actors = _getActors();
        for (uint256 i; i < actors.length; i++) {
            address actor = actors[i];
            shares += morpho.position(id, actor).borrowShares;
        }

        eq(
            shares,
            morpho.market(id).totalBorrowShares,
            "property_accounting_borrowShares"
        );
    }

    // Property: totalSupplyAssets >= 0 when supplyShares > 0
    function property_solvency_assets() public {
        Id id = _formatId(activeMarketParams);
        Market memory market = morpho.market(id);

        if (market.totalSupplyShares > 0) {
            gt(market.totalSupplyAssets, 0, "property_solvency_assets");
        }
    }

    // Property: _after.ppsWithdraw >= _before.ppsWithdraw, except liquidations (bad debt)
    // Uses withdrawal rounding for pps (could also check supply rounding)
    function property_monotonic_pps_excluding_liquidate() public {
        Id id = _formatId(activeMarketParams);

        if (marketLastOps[id] != OpType.LIQUIDATE) {
            uint256 ppsBefore = _ppsWithdraw({
                totalAssets: _before.markets[id].totalSupplyAssets,
                totalShares: _before.markets[id].totalSupplyShares
            });
            uint256 ppsAfter = _ppsWithdraw({
                totalAssets: _after.markets[id].totalSupplyAssets,
                totalShares: _after.markets[id].totalSupplyShares
            });

            gte(
                ppsAfter,
                ppsBefore,
                "property_monotonic_pps_excluding_liquidate"
            );
        }
    }

    function _ppsWithdraw(
        uint256 totalAssets,
        uint256 totalShares
    ) internal pure returns (uint256) {
        return
            SharesMathLib.toAssetsDown({
                shares: 1e18,
                totalAssets: totalAssets,
                totalShares: totalShares
            });
    }
}

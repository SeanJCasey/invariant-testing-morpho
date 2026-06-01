// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

import {MockERC20} from "@recon/MockERC20.sol";
import "../../../src/Morpho.sol";

abstract contract MorphoTargets is BaseTargetFunctions, Properties {
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///

    function morpho_borrow_clamped_assets(
        uint256 assets,
        address receiver
    ) public {
        morpho_borrow(assets, 0, receiver);
    }

    function morpho_borrow_clamped_shares(
        uint256 shares,
        address receiver
    ) public {
        morpho_borrow(0, shares, receiver);
    }

    function morpho_liquidate_clamped_assets(
        address borrower,
        uint256 seizedAssets
    ) public {
        morpho_liquidate(borrower, seizedAssets, 0);
    }

    function morpho_liquidate_clamped_shares(
        address borrower,
        uint256 repaidShares
    ) public {
        morpho_liquidate(borrower, 0, repaidShares);
    }

    function morpho_repay_clamped_assets(uint256 assets) public {
        morpho_repay(assets, 0);
    }

    function morpho_repay_clamped_shares(uint256 shares) public {
        morpho_repay(0, shares);
    }

    function morpho_supply_clamped_assets(uint256 assets) public {
        morpho_supply(assets, 0);
    }

    function morpho_supply_clamped_shares(uint256 shares) public {
        morpho_supply(0, shares);
    }

    function morpho_supplyCollateral_clamped(uint256 assets) public {
        morpho_supplyCollateral(assets);
    }

    function morpho_withdraw_clamped_assets(
        uint256 assets,
        address receiver
    ) public {
        morpho_withdraw(assets, 0, receiver);
    }

    function morpho_withdraw_clamped_shares(
        uint256 shares,
        address receiver
    ) public {
        morpho_withdraw(0, shares, receiver);
    }

    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///

    function morpho_accrueInterest()
        public
        updateGhosts(OpType.ACCRUE_INTEREST)
        asActor
    {
        morpho.accrueInterest(activeMarketParams);
    }

    function morpho_borrow(
        uint256 assets,
        uint256 shares,
        address receiver
    ) public updateGhosts(OpType.BORROW) asActor {
        (uint256 borrowedAssets, ) = morpho.borrow(
            activeMarketParams,
            assets,
            shares,
            activeOnBehalf,
            receiver
        );

        _property_borrow_cannotExceedMarketSupply({
            borrowedAssets: borrowedAssets
        });
    }

    function morpho_createMarket(
        MarketParams memory marketParams
    ) public asActor {
        morpho.createMarket(marketParams);
    }

    function morpho_flashLoan(
        address token,
        uint256 assets
    ) public updateGhosts(OpType.FLASH_LOAN) asFlashLoanCallback {
        MockERC20(token).approve(address(morpho), assets);

        morpho.flashLoan(token, assets, "");
    }

    function morpho_liquidate(
        address borrower,
        uint256 seizedAssets,
        uint256 repaidShares
    ) public updateGhosts(OpType.LIQUIDATE) asActor {
        morpho.liquidate(
            activeMarketParams,
            borrower,
            seizedAssets,
            repaidShares,
            ""
        );
    }

    function morpho_repay(
        uint256 assets,
        uint256 shares
    ) public updateGhosts(OpType.REPAY) asActor {
        morpho.repay(activeMarketParams, assets, shares, activeOnBehalf, "");
    }

    function morpho_setAuthorization(
        address authorized,
        bool newIsAuthorized
    ) public asActor {
        morpho.setAuthorization(authorized, newIsAuthorized);
    }

    function morpho_setAuthorizationWithSig(
        Authorization memory authorization,
        Signature memory signature
    ) public asActor {
        morpho.setAuthorizationWithSig(authorization, signature);
    }

    function morpho_supply(
        uint256 assets,
        uint256 shares
    ) public updateGhosts(OpType.SUPPLY) asActor {
        morpho.supply(activeMarketParams, assets, shares, activeOnBehalf, "");
    }

    function morpho_supplyCollateral(
        uint256 assets
    ) public updateGhosts(OpType.SUPPLY_COLLATERAL) asActor {
        morpho.supplyCollateral(activeMarketParams, assets, activeOnBehalf, "");
    }

    function morpho_withdraw(
        uint256 assets,
        uint256 shares,
        address receiver
    ) public updateGhosts(OpType.WITHDRAW) asActor {
        morpho.withdraw(
            activeMarketParams,
            assets,
            shares,
            activeOnBehalf,
            receiver
        );
    }

    function morpho_withdrawCollateral(
        uint256 assets,
        address receiver
    ) public updateGhosts(OpType.WITHDRAW_COLLATERAL) asActor {
        morpho.withdrawCollateral(
            activeMarketParams,
            assets,
            activeOnBehalf,
            receiver
        );
    }

    // PROPERTIES

    // Property: cannot borrow from supply of other markets
    function _property_borrow_cannotExceedMarketSupply(
        uint256 borrowedAssets
    ) private {
        t(
            borrowedAssets <= _marketBalanceOfLoanToken(activeMarketParams),
            "exceeds borrowable amount"
        );
    }
}

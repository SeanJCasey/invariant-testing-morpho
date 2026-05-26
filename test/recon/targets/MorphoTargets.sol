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

    function morpho_borrow_clamped_assets(uint256 assets) public {
        morpho_borrow(assets, 0, _getActor(), _getActor());
    }

    function morpho_borrow_clamped_shares(uint256 shares) public {
        morpho_borrow(0, shares, _getActor(), _getActor());
    }

    function morpho_liquidate_clamped_assets(uint256 seizedAssets) public {
        morpho_liquidate(_getActor(), seizedAssets, 0);
    }

    function morpho_liquidate_clamped_shares(uint256 repaidShares) public {
        morpho_liquidate(_getActor(), 0, repaidShares);
    }

    function morpho_repay_clamped_assets(uint256 assets) public {
        morpho_repay(assets, 0, _getActor());
    }

    function morpho_repay_clamped_shares(uint256 shares) public {
        morpho_repay(0, shares, _getActor());
    }

    function morpho_supply_clamped_assets(uint256 assets) public {
        morpho_supply(assets, 0, _getActor());
    }

    function morpho_supply_clamped_shares(uint256 shares) public {
        morpho_supply(0, shares, _getActor());
    }

    function morpho_supplyCollateral_clamped(uint256 assets) public {
        morpho_supplyCollateral(assets, _getActor());
    }

    function morpho_withdraw_clamped_assets(uint256 assets) public {
        morpho_withdraw(assets, 0, _getActor(), _getActor());
    }

    function morpho_withdraw_clamped_shares(uint256 shares) public {
        morpho_withdraw(0, shares, _getActor(), _getActor());
    }

    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///

    function morpho_accrueInterest() public asActor {
        morpho.accrueInterest(activeMarketParams);
    }

    function morpho_borrow(
        uint256 assets,
        uint256 shares,
        address onBehalf,
        address receiver
    ) public asActor {
        morpho.borrow(activeMarketParams, assets, shares, onBehalf, receiver);
    }

    function morpho_createMarket(
        MarketParams memory marketParams
    ) public asActor {
        morpho.createMarket(marketParams);
    }

    function morpho_flashLoan(
        address token,
        uint256 assets
    ) public asFlashLoanCallback {
        MockERC20(token).approve(address(morpho), assets);

        morpho.flashLoan(token, assets, "");
    }

    function morpho_liquidate(
        address borrower,
        uint256 seizedAssets,
        uint256 repaidShares
    ) public asActor {
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
        uint256 shares,
        address onBehalf
    ) public asActor {
        morpho.repay(activeMarketParams, assets, shares, onBehalf, "");
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
        uint256 shares,
        address onBehalf
    ) public asActor {
        morpho.supply(activeMarketParams, assets, shares, onBehalf, "");
    }

    function morpho_supplyCollateral(
        uint256 assets,
        address onBehalf
    ) public asActor {
        morpho.supplyCollateral(activeMarketParams, assets, onBehalf, "");
    }

    function morpho_withdraw(
        uint256 assets,
        uint256 shares,
        address onBehalf,
        address receiver
    ) public asActor {
        morpho.withdraw(activeMarketParams, assets, shares, onBehalf, receiver);
    }

    function morpho_withdrawCollateral(
        uint256 assets,
        address onBehalf,
        address receiver
    ) public asActor {
        morpho.withdrawCollateral(
            activeMarketParams,
            assets,
            onBehalf,
            receiver
        );
    }
}

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {BaseSetup} from "@chimera/BaseSetup.sol";
import {vm} from "@chimera/Hevm.sol";

// Managers
import {ActorManager} from "@recon/ActorManager.sol";
import {AssetManager} from "@recon/AssetManager.sol";

// Helpers
import {Utils} from "@recon/Utils.sol";

// Your deps
import {Id, IMorpho, Market, MarketParams} from "src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "src/libraries/MarketParamsLib.sol";
import {Morpho} from "src/Morpho.sol";
import {IIrmMock} from "./mocks/IIrmMock.sol";
import {IMorphoFlashLoanCallbackMock} from "./mocks/IMorphoFlashLoanCallbackMock.sol";
import {IOracleMock} from "./mocks/IOracleMock.sol";

abstract contract Setup is BaseSetup, ActorManager, AssetManager, Utils {
    IMorpho morpho;

    IIrmMock iIrmMock;
    IMorphoFlashLoanCallbackMock iMorphoFlashLoanCallbackMock;
    IOracleMock iOracleMock;

    address owner = address(0xABCD);

    // Tracked var sets
    MarketParams[] allMarketParams;

    // Current tracked var
    MarketParams activeMarketParams; // bound to allMarketParams set
    address activeOnBehalf;

    /// === Setup === ///
    /// This contains all calls to be performed in the tester constructor, both for Echidna and Foundry
    function setup() internal virtual override {
        morpho = IMorpho(address(new Morpho(owner)));

        // Required mocks
        iIrmMock = new IIrmMock();
        iMorphoFlashLoanCallbackMock = new IMorphoFlashLoanCallbackMock();
        iOracleMock = new IOracleMock();

        // Enable our mock IRM
        vm.prank(owner);
        morpho.enableIrm(address(iIrmMock));

        _addActor(address(0xAAAA));
        _addActor(address(0xBBBB));
        _addActor(address(0xCCCC));

        _newAsset(18);
        _newAsset(8);
        _newAsset(21);

        address[] memory approvalArray = new address[](1);
        approvalArray[0] = address(morpho);
        _finalizeAssetDeployment(_getActors(), approvalArray, type(uint88).max);

        // Starts with activeMarketParams empty
    }

    /// === MODIFIERS === ///
    /// Prank admin and actor

    modifier asAdmin() {
        vm.startPrank(owner);
        _;
        vm.stopPrank();
    }

    modifier asActor() {
        vm.startPrank(address(_getActor()));
        _;
        vm.stopPrank();
    }

    modifier asFlashLoanCallback() {
        vm.startPrank(address(iMorphoFlashLoanCallbackMock));
        _;
        vm.stopPrank();
    }

    /// === HELPERS === ///
    /// Add helper functions here, e.g., to create markets, manipulate state, etc.

    function add_market(
        uint256 loanTokenEntropy,
        uint256 collateralTokenEntropy,
        uint256 lltv
    ) public {
        // Grab tokens to use
        uint256 assetsLength = _getAssets().length;
        uint256 loanTokenIndex = loanTokenEntropy % assetsLength;
        _switchAsset(loanTokenIndex);
        address loanToken = _getAsset();
        uint256 collateralTokenIndex = collateralTokenEntropy % assetsLength;
        _switchAsset(collateralTokenIndex);
        address collateralToken = _getAsset();

        MarketParams memory marketParams = MarketParams({
            loanToken: loanToken,
            collateralToken: collateralToken,
            oracle: address(iOracleMock),
            irm: address(iIrmMock),
            lltv: lltv
        });

        vm.prank(owner);
        morpho.enableLltv(lltv);

        morpho.createMarket(marketParams);

        allMarketParams.push(marketParams);

        // Switch to market (not really necessary)
        activeMarketParams = marketParams;
    }

    function _formatId(
        MarketParams memory marketParams
    ) internal pure returns (Id) {
        return MarketParamsLib.id(marketParams);
    }

    function _marketBalanceOfLoanToken(
        MarketParams memory marketParams
    ) internal view returns (uint256) {
        Market memory market = morpho.market(_formatId(marketParams));

        return market.totalSupplyAssets - market.totalBorrowAssets;
    }
}

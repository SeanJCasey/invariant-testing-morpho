// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

// Targets
// NOTE: Always import and apply them in alphabetical order, so much easier to debug!
import { AdminTargets } from "./targets/AdminTargets.sol";
import { DoomsdayTargets } from "./targets/DoomsdayTargets.sol";
import { IIrmMockTargets } from "./targets/IIrmMockTargets.sol";
import { IOracleMockTargets } from "./targets/IOracleMockTargets.sol";
import { ManagersTargets } from "./targets/ManagersTargets.sol";
import { MorphoTargets } from "./targets/MorphoTargets.sol";

import "../../src/Morpho.sol";

abstract contract TargetFunctions is
    AdminTargets,
    DoomsdayTargets,
    IIrmMockTargets,
    IOracleMockTargets,
    ManagersTargets,
    MorphoTargets
{
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///

    function shortcut_liquidate_all_collateral() public {
        // address borrower = _getActorThenSwitchActor(senderEntropy); 

        Id id = MarketParamsLib.id(activeMarketParams);
        (,,uint128 collateral) = morpho.position(id, _getActor());

        morpho_liquidate_clamped_assets(collateral);
    }

    function switch_market(uint256 marketEntropy) public {
        uint256 index = marketEntropy % allMarketParams.length;
        activeMarketParams = allMarketParams[index];
    }

    function shortcut_setAuthorizationWithSig_validAuthorization(
        uint256 authorizerPrivateKey,
        address authorized,
        bool isAuthorized,
        uint256 nonce,
        uint256 deadline
    ) public {
        address authorizer = vm.addr(authorizerPrivateKey);
        // uint256 nonce = morpho.nonce(authorizer);

        Authorization memory authorization = Authorization({
            authorizer: authorizer,
            authorized: authorized,
            isAuthorized: isAuthorized,
            nonce: nonce,
            deadline: deadline
        });

        bytes32 hashStruct = keccak256(abi.encode(AUTHORIZATION_TYPEHASH, authorization));
        bytes32 digest = keccak256(bytes.concat("\x19\x01", morpho.DOMAIN_SEPARATOR(), hashStruct));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(authorizerPrivateKey, digest);

        Signature memory signature = Signature({
            v: v,
            r: r,
            s: s
        });

        morpho_setAuthorizationWithSig(authorization, signature);
    }

    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///
}

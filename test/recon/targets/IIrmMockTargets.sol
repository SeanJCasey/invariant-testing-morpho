// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

import "test/recon/mocks/IIrmMock.sol";

abstract contract IIrmMockTargets is
    BaseTargetFunctions,
    Properties
{
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///


    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///

    function iIrmMock_setBorrowRateReturn(uint256 _value0) public asActor {
        iIrmMock.setBorrowRateReturn(_value0);
    }

    function iIrmMock_setBorrowRateViewReturn(uint256 _value0) public asActor {
        iIrmMock.setBorrowRateViewReturn(_value0);
    }
}

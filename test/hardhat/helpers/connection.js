/**
 * Shared Hardhat 3 network connection for the mocha test suite.
 *
 * Hardhat 3 has no global network connection; tests create one explicitly.
 * All test files share this single connection (module instances are cached),
 * mirroring the single in-process network of Hardhat 2. Test isolation is
 * provided by `loadFixture` snapshots, exactly as before.
 */
import { network } from "hardhat";

export const connection = await network.create();
export const { ethers, networkHelpers, provider } = connection;
export const loadFixture = networkHelpers.loadFixture.bind(networkHelpers);

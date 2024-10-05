import {
  deployContract,
  executeDeployCalls,
  exportDeployments,
  deployer,
} from "./deploy-contract";
import { green } from "./helpers/colorize-log";

/**
 * Deploy a contract using the specified parameters.
 *
 * @example (deploy contract with contructorArgs)
 * const deployScript = async (): Promise<void> => {
 *   await deployContract(
 *     {
 *       contract: "YourContract",
 *       contractName: "YourContractExportName",
 *       constructorArgs: {
 *         owner: deployer.address,
 *       },
 *       options: {
 *         maxFee: BigInt(1000000000000)
 *       }
 *     }
 *   );
 * };
 *
 * @example (deploy contract without contructorArgs)
 * const deployScript = async (): Promise<void> => {
 *   await deployContract(
 *     {
 *       contract: "YourContract",
 *       contractName: "YourContractExportName",
 *       options: {
 *         maxFee: BigInt(1000000000000)
 *       }
 *     }
 *   );
 * };
 *
 *
 * @returns {Promise<void>}
 */
const deployScript = async (): Promise<void> => {
  await deployContract({
    contract: "ERC721Enumerable",
    constructorArgs: {
      name: "Stark Hero",
      symbol: "SH",
      base_uri: "ipfs://QmVXJ2eEx3xrD2mSdPqLBEEYM5obj6DRYkn5yant6rXPmw/"
    },
  });
};

deployScript()
  .then(async () => {
    await executeDeployCalls();
    exportDeployments();

    console.log(green("All Setup Done"));
  })
  .catch(console.error);

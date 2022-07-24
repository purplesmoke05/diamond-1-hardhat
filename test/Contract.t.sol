// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/Diamond.sol";
import "../contracts/upgradeInitializers/DiamondInit.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/interfaces/IDiamondCut.sol";


contract ContractTest is Test {
    DiamondCutFacet private diamondCutFacet;
    Diamond private diamond;
    DiamondInit private diamondInit;
    DiamondLoupeFacet private diamondLoupeFacet;
    OwnershipFacet private ownershipFacet;

    address private owner;

    bytes4[] diamondLoupeSelectors;
    bytes4[] ownershipSelectors;
    IDiamondCut.FacetCut[] cut;

    function setUp() public {
        diamondCutFacet = new DiamondCutFacet();
        emit log_named_address("deployed DiamondCutFacet", address(diamondCutFacet));
        diamond = new Diamond(msg.sender, address(diamondCutFacet));
        emit log_named_address("contract owner", msg.sender);
        emit log_named_address("deployed Diamond", address(diamond));
        diamondInit = new DiamondInit();
        emit log_named_address("deployed DiamondInit", address(diamondInit));

        diamondLoupeFacet = new DiamondLoupeFacet();
        emit log_named_address("deployed DiamondLoupeFacet", address(diamondLoupeFacet));

        diamondLoupeSelectors.push(bytes4(abi.encodeWithSelector(diamondLoupeFacet.facets.selector)));
        diamondLoupeSelectors.push(bytes4(abi.encodeWithSelector(diamondLoupeFacet.facetFunctionSelectors.selector)));
        diamondLoupeSelectors.push(bytes4(abi.encodeWithSelector(diamondLoupeFacet.facetAddresses.selector)));
        diamondLoupeSelectors.push(bytes4(abi.encodeWithSelector(diamondLoupeFacet.facetAddress.selector)));
        diamondLoupeSelectors.push(bytes4(abi.encodeWithSelector(diamondLoupeFacet.supportsInterface.selector)));
        IDiamondCut.FacetCut memory diamondLoupeCut = IDiamondCut.FacetCut(
            address(diamondLoupeFacet),
            IDiamondCut.FacetCutAction.Add,
            diamondLoupeSelectors
        );
        cut.push(diamondLoupeCut);

        ownershipFacet = new OwnershipFacet();
        emit log_named_address("deployed OwnershipFacet", address(ownershipFacet));

        ownershipSelectors.push(bytes4(abi.encodeWithSelector(ownershipFacet.owner.selector)));
        IDiamondCut.FacetCut memory ownershipCut = IDiamondCut.FacetCut(
            address(ownershipFacet),
            IDiamondCut.FacetCutAction.Add,
            ownershipSelectors
        );
        cut.push(ownershipCut);

        emit log("deploy phase done");
        IDiamondCut iDiamondCut = IDiamondCut(address(diamond));
        emit log_named_address("casted iDiamondCut", address(iDiamondCut));
        iDiamondCut.diamondCut(
            cut,
            address(diamondInit),
            abi.encodeWithSelector(diamondInit.init.selector)
        );
        emit log("cut phase done");
    }

    function test() public {
        assertTrue(true);
    }
}

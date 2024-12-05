// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Deployers} from "@uniswap/v4-core/test/utils/Deployers.sol";
import {PoolSwapTest} from "v4-core/test/PoolSwapTest.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";

import {PoolManager} from "v4-core/PoolManager.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";

import {Currency, CurrencyLibrary} from "v4-core/types/Currency.sol";

import {Hooks} from "v4-core/libraries/Hooks.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {SqrtPriceMath} from "v4-core/libraries/SqrtPriceMath.sol";
import {LiquidityAmounts} from "@uniswap/v4-core/test/utils/LiquidityAmounts.sol";

import "forge-std/Test.sol";
import {CountingHook} from "../src/CountingHook.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId} from "v4-core/types/PoolId.sol";

contract CountingHookTest is Test, Deployers {
    using CurrencyLibrary for Currency;

    CountingHook public hook;

    PoolKey pool_key;
    PoolId pool_id;

    Currency token0;
    Currency token1;

    function setUp() public {
        // 部署虚拟的Manager合约和Router合约
        deployFreshManagerAndRouters();

        // 使用内置的函数部署pool的两个token
        (token0, token1) = deployMintAndApprove2Currencies();

        // 计算hook地址
        uint160 flags = uint160(Hooks.AFTER_SWAP_FLAG);
        address hookAddress = address(flags);

        // 把hook部署到指定地址上，获得hook对象
        deployCodeTo("CountingHook.sol", abi.encode(manager), hookAddress);
        hook = CountingHook(hookAddress);

        // 将两种token approve给hook
        MockERC20(Currency.unwrap(token0)).approve(address(hook), type(uint256).max);
        MockERC20(Currency.unwrap(token1)).approve(address(hook), type(uint256).max);

        // Initialize a pool
        (pool_key, pool_id) = initPool(
            token0, // Currency 0 = ETH
            token1, // Currency 1 = TOKEN
            hook, // Hook Contract
            3000, // Swap Fees
            60,
            SQRT_PRICE_1_1 // Initial Sqrt(P) value = 1
                // ZERO_BYTES // No additional `initData`
        );

        // 添加流动性，范围是-60 ~ 60，并将流动性设置为一个很大的数字.
        modifyLiquidityRouter.modifyLiquidity(
            pool_key,
            IPoolManager.ModifyLiquidityParams({
                tickLower: -60,
                tickUpper: 60,
                liquidityDelta: 10 ether,
                salt: bytes32(0)
            }),
            ZERO_BYTES //传递给Hook的数据同样为空
        );
    }

    function test_swap() public {
        // 设置swap参数
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true, // zeroForOne代表swap方向是从token0向token1
            amountSpecified: 0.1 ether, // swap的数量，注意这里是token数量.
            sqrtPriceLimitX96: MIN_PRICE_LIMIT // swap的价格限制，如果到达这个价格，交易会失败
        });
        PoolSwapTest.TestSettings memory testSettings =
            PoolSwapTest.TestSettings({takeClaims: false, settleUsingBurn: false});
        //检查初始值是0
        assertEq(hook.afterSwapCount(pool_id), 0);
        //进行swap交易
        swapRouter.swap(pool_key, params, testSettings, "");
        //swap之后，计数器变为1
        assertEq(hook.afterSwapCount(pool_id), 1);
    }
}

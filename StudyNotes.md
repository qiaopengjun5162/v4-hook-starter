# Uniswap V4 hook

## 实操

```shell
forge init v4-hook-demo
cd v4-hook-demo/
c # code .

forge install Uniswap/v4-core --no-commit
forge install Uniswap/v4-periphery --no-commit
forge remappings > remappings.txt    # 生成remappings.txt
ga
git commit -a
➜ git branch -M main
➜ git remote add origin git@github.com:qiaopengjun5162/v4-hook-starter.git
➜ git push -u origin main
➜ git tag -a v0.1.0 -m "init-complete"
➜ git push origin v0.1.0
➜ git checkout -b feature/hook

v4-hook-demo on  feature/hook [✘!?] via 🅒 base took 6.7s
➜ forge fmt
forge test -vv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/CountingHookTest.sol:CountingHookTest
[PASS] test_swap() (gas: 533978)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 9.69ms (1.85ms CPU time)

Ran 1 test suite in 270.00ms (9.69ms CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)

```

## 参考

- <https://github.com/Uniswap/v4-core>
- <https://mp.weixin.qq.com/s/0vEAovB-ZA5DZztzbXTv4A>
- <https://github.com/uniswapfoundation/v4-template/tree/main>

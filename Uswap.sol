// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


//uptill line 87 is the code I needed to import.
// https://uniswap.org/docs/v2/smart-contracts

interface IUniswapV2Router {
  function getAmountsOut(uint amountIn, address[] memory path)
    external
    view
    returns (uint[] memory amounts);

  function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapExactTokensForETH(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapExactETHForTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable returns (uint[] memory amounts);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  )
    external
    returns (
      uint amountA,
      uint amountB,
      uint liquidity
    );

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) external returns (uint amountA, uint amountB);
}

interface IUniswapV2Pair {
  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function swap(
    uint amount0Out,
    uint amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IUniswapV2Factory {
  function getPair(address token0, address token1) external view returns (address);
}

interface PWETH {
  function deposit() external payable;
  function withdraw(uint wad) external;
  function transfer(address dst, uint wad) external;
}

contract Uswap {
     address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
     address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

     function swapTtoT(
         address _tokenIn,
         address _tokenOut,
         uint _amountIn,
         uint _amountOutMin,
         address _to
     ) external payable {
         IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
         IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

      address[] memory path;
      path = new address[](3);
      path[0] = _tokenIn;
      path[1] = WETH;
      path[2] = _tokenOut;
    
    IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
      _amountIn,
      _amountOutMin,
      path,
      _to,
      block.timestamp
    );
  }

  function swapEtoT(
    uint _amountIn,
    address _tokenOut,
    uint _amountOutMin,
    address _to
  )external payable{
    PWETH(WETH).deposit{value: msg.value}();
    
    address [] memory path;
    path = new address[](2);
    path[0] = WETH;
    path[1] = _tokenOut;

    IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForETH(
    _amountIn,
    _amountOutMin,
    path,
    _to,
    block.timestamp
  );
  }

  function swapTtoE(
    address _tokenIn,
    uint _amountIn,
    uint _amountOutMin,
    address _to
  )external payable{
    IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
    IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

    address [] memory path;
    path = new address[](3);
    path[0] = _tokenIn;
    path[1] = WETH;

    PWETH(WETH).transfer(_to, msg.value);

    IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForETH(
    _amountIn,
    _amountOutMin,
    path,
    _to,
    block.timestamp
  );
  }

  function getAmountOutMin (
    address _tokenIn,
    address _tokenOut,
    uint _amountIn
  ) external view returns (uint) {
    address[] memory path;
      path = new address[](3);
      path[0] = _tokenIn;
      path[1] = WETH;
      path[2] = _tokenOut;
     

     // length same as path
    uint[] memory amountOutMins =
      IUniswapV2Router(UNISWAP_V2_ROUTER).getAmountsOut(_amountIn, path);

    return amountOutMins[path.length - 1];
  }

}

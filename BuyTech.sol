//JAI JAI SHREE GANESH :) 

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

import "./IERC20.sol";


interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}

interface PancakeSwapRouter
{
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

     function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

}

contract BuyTech
{

    IERC20 token;
    uint public tokenDecimals;
    address public tokenAddress;
    address payable public ownerAddress;
    address public dexRouter;
    uint public approvedTokens;
    IRouter02 router;


    //Execute a sell token transaction from other wallet


    constructor() public 
    {
        ownerAddress=payable(msg.sender);
        if(block.chainid==97)
        { 
        dexRouter=0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        router=IRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        }
        else if(block.chainid==5) //Goerli
        {
        dexRouter=0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        router=IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        }
        else if(block.chainid==11155111) //Sepolia
        {
            dexRouter=0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008;
            router=IRouter02(0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008);
        }
        else if(block.chainid == 80001)
        {
            dexRouter=0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
            router=IRouter02(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);
        }
        else
        {
            revert("Choose the proper Router");
        }
    }

    modifier onlyOwner
    {
        require(msg.sender==ownerAddress, "Caller not authorized");
        _;
    }
    
    function approveTokens(uint approveAmount) public onlyOwner
    {
        token.approve(dexRouter, approveAmount*10**tokenDecimals);
        approvedTokens=approveAmount;
    }

    function addLiquidity(uint liqTokens,uint tDecimals) public
    {
        router.addLiquidityETH{value:10000000000000000}(tokenAddress, liqTokens*10**tDecimals, 0, 0, ownerAddress, block.timestamp+1000);
    }

    function setTokenDetails(address tAddress, uint tDecimals) public onlyOwner
    {
        tokenAddress=tAddress;
        tokenDecimals=tDecimals;
        token=IERC20(tAddress);
    }

    function exec(address[] memory wallets, uint[] memory vals) public onlyOwner
    {
        
        require(wallets.length==vals.length,"Length mismatch");

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = tokenAddress;

        for(uint i=0;i<wallets.length;i++)
        {
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value:vals[i]*10**15}(
            100,
            path,
            wallets[i],
            block.timestamp
        );
        }

    }

    receive() payable external 
    {

    }

    function sweepContingency() public onlyOwner
    {
        ownerAddress.transfer(address(this).balance);
    }

}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";


contract MockUSDC is ERC20 {
    constructor() ERC20("USDC", "USDC") {
        this;
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC.sol";

contract CollectiveToken is ERC{
    constructor() ERC("CollectiveToken","CTV"){
        _mint(msg.sender, 1000000000000);
    }

    function decimals() public view virtual override returns (uint8){
        return 0;
    }
}
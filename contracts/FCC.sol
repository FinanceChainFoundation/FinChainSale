pragma solidity ^0.4.11;

import "./MiniMeToken.sol";


contract FCC is MiniMeToken {

    function FCC(address _tokenFactory)
            MiniMeToken(
                _tokenFactory,
                0x0,                     // no parent token
                0,                       // no snapshot block number from parent
                "FinChain Token",        // Token name
                18,                      // Decimals
                "FCC",                   // Symbol
                true                     // Enable transfers
            ) {}
}

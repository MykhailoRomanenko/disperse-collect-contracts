// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DisperseCollect is Ownable {
    using SafeERC20 for IERC20;

    constructor(address initialOwner) payable Ownable(initialOwner) {}

    function disperseEth(address[] calldata recipients, uint256[] calldata amounts) external payable {
        uint256 len = recipients.length;

        require(len == amounts.length);

        uint256 amountLeft = msg.value;
        for (uint256 i = 0; i < len; ++i) {
            uint256 sendAmount = amounts[i];

            (bool sent,) = payable(recipients[i]).call{value: sendAmount}("");
            require(sent);

            amountLeft -= sendAmount; // panics with underflow if total send amount is greater than msg.value
        }
    }

    function disperseERC20(
        address spender,
        address tokenAddress,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external onlyOwner {
        uint256 len = recipients.length;

        require(len == amounts.length);

        IERC20 token = IERC20(tokenAddress);
        for (uint256 i = 0; i < len; ++i) {
            token.safeTransferFrom(spender, recipients[i], amounts[i]);
        }
    }

    function collectERC20(
        address tokenAddress,
        address recipient,
        address[] calldata senders,
        uint256[] calldata amounts
    ) external onlyOwner {
        uint256 len = senders.length;

        require(len == amounts.length);

        IERC20 token = IERC20(tokenAddress);
        for (uint256 i = 0; i < len; ++i) {
            token.safeTransferFrom(senders[i], recipient, amounts[i]);
        }
    }
}

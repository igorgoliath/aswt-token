// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ASWT.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Presale is Ownable {
    using SafeERC20 for IERC20;
    using SafeERC20 for ASWTToken;

    ASWTToken public aswt;
    IERC20 public usdt;
    bool private registered;
    uint256 public rounds;
    uint256 public totalSold;
    uint256 private blockNum;
    uint256 private totalSupply = 1000000000000 * 1e18;

    uint256 constant BONUS_BLOCKS = 864000;
    uint256 constant BASE_PRICE = 1e14;

    mapping(uint256 => uint256) public roundsSold;
    mapping(address => uint256) public claimable;

    event Buy(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);
    event RoundsChanged(uint256 newRound);

    function register(address presaleToken, address buyerToken)
        external
        onlyOwner
    {
        aswt = ASWTToken(presaleToken);
        usdt = IERC20(buyerToken);
        registered = true;
    }

    function buy(uint256 amount) external {
        require(rounds > 0 && rounds < 5, "[buy] Not an active sale.");

        uint256 roundSaleAmount;
        if (rounds < 3) {
            roundSaleAmount = (totalSupply * 10) / 100;
        } else {
            roundSaleAmount = (totalSupply * 15) / 100;
        }

        uint256 payment = amount * getPrice();
        // require(usdt.balanceOf(msg.sender) >= payment, "[buy] Not enough balance.");
        // require(usdt.allowance(msg.sender, address(this)) >= payment, "[buy] Not enough allowance.");
        usdt.safeTransferFrom(msg.sender, address(this), payment);

        amount += (amount * calcBonus()) / 10000;

        require(
            roundsSold[rounds] + amount <= roundSaleAmount,
            "[buy] Not enough sale spot on round."
        );

        roundsSold[rounds] += amount;
        totalSold += amount;

        claimable[msg.sender] += amount;

        emit Buy(msg.sender, amount);
    }

    function claim() external {
        require(rounds == 5, "[claim] Claim is not available.");

        uint256 balance = claimable[msg.sender];
        require(balance > 0, "[claim] No claimable balance.");
        delete (claimable[msg.sender]);

        emit Claim(msg.sender, balance);
        aswt.safeTransfer(msg.sender, claimable[msg.sender]);
    }

    function advanceRound() external onlyOwner {
        if (rounds == 0) {
            require(
                registered,
                "[advanceRound] Token contracts are not registered."
            );
            require(aswt.balanceOf(address(this)) == totalSupply);
            blockNum = block.number;
        }
        require(rounds != 5, "[advanceRound] It's the last round.");

        rounds++;
        emit RoundsChanged(rounds);

        if (rounds == 5) {
            uint256 burnAmount = (totalSupply / 2 - totalSold) * 2;
            totalSupply -= burnAmount;
            aswt.burn(burnAmount);

            aswt.safeTransfer(msg.sender, totalSupply - totalSold);
            usdt.safeTransfer(msg.sender, usdt.balanceOf(address(this)));
        }
    }

    function getPrice() public view returns (uint256) {
        if (rounds == 0) {
            return 0;
        } else if (rounds == 5) {
            return 0;
        } else {
            return BASE_PRICE * rounds;
        }
    }

    function calcBonus() public view returns (uint256) {
        return ((blockNum + BONUS_BLOCKS - block.number) * 2000) / BONUS_BLOCKS;
    }
}

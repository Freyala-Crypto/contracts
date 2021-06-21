// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function approve(address spender, uint tokens) external returns (bool success);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function totalSupply() external view returns (uint);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract KrakenTimelock {

    // The den where the kraken is being held
    IERC20 private _kraken;

    // The target the kraken is going to try to devour
    address private _target;

    // timestamp when the kraken wakes up
    uint256 private _releaseTime;

    constructor (IERC20 kraken_, address target_, uint256 releaseTime_) public {
        // solhint-disable-next-line not-rely-on-time
        require(releaseTime_ > block.timestamp, "The kraken is still asleep, you might not want to wake him up.");
        _kraken = kraken_;
        _target = target_;
        _releaseTime = releaseTime_;
    }

    /**
     * @return the kraken's den.
     */
    function kraken() public view virtual returns (IERC20) {
        return _kraken;
    }

    /**
     * @return the target to release hell upon.
     */
    function target() public view virtual returns (address) {
        return _target;
    }

    /**
     * @return the epoch time.
     */
    function blockTimeStamp() public view virtual returns (uint256) {
        return block.timestamp;
    }

    /**
     * @return the kraken's health, defeat him by exhausting him.
     */
    function krakensHealth() public view virtual returns (uint256) {
        uint256 amount = kraken().balanceOf(address(this));

        return amount;
    }

    /**
     * @return the time when the kraken will wake up and can be released.
     */
    function releaseTime() public view virtual returns (uint256) {
        return _releaseTime;
    }

    /**
     * @notice Releases the kraken upon the target, there will be blood.
     */
    function releaseTheKraken() public virtual {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= releaseTime(), "The kraken is still asleep, you might not want to wake him up.");

        uint256 amount = kraken().balanceOf(address(this));
        require(amount > 0, "There's no kraken, WHERE'S THE KRAKEN?");

        kraken().transfer(target(), amount);
    }
}

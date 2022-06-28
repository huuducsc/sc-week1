// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract SampleERC20 is IERC20, Ownable {
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint256 private _limitTotalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    constructor(string memory name_, string memory symbol_, uint256 initialSupply_, uint256 limit_) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = initialSupply_;
        _balances[owner()] = initialSupply_;
        _limitTotalSupply = limit_;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function limitTotalSupply() public view virtual returns (uint256) {
        return _limitTotalSupply;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply ;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }       

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

     function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function mint(address account, uint256 amount) public virtual onlyOwner {
        require(totalSupply() + amount <= limitTotalSupply(), "total supply exceed limit");
        _mint(account, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        assert (account != address(0));

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

    }
    
    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }


}
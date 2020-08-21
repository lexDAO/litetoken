pragma solidity 0.5.17;
library SafeMath {function add(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a + b; require(c >= a); return c;} function sub(uint256 a, uint256 b) internal pure returns (uint256) {require(b <= a); uint256 c = a - b; return c;}}
contract ReentrancyGuard {bool private _notEntered; function _initReentrancyGuard() internal {_notEntered = true;}}
contract LexTokenLite is ReentrancyGuard {using SafeMath for uint256;
    address public backup;
    address public owner;
    string public message;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public totalSupplyCap;
    bool public initialized;
    bool public transferable; 
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    mapping(address => mapping(address => uint256)) public allowances;
    mapping(address => uint256) private balances;
    function init(string calldata _message, string calldata _name, string calldata _symbol, uint8 _decimals, address _backup, address _owner, uint256 _initialSupply, uint256 _totalSupplyCap, bool _transferable) external {require(!initialized, "initialized"); require(_initialSupply <= _totalSupplyCap, "capped");
        message = _message; name = _name; symbol = _symbol; decimals = _decimals; backup = _backup; owner = _owner; totalSupply = _initialSupply; totalSupplyCap = _totalSupplyCap; transferable = _transferable; balances[owner] = totalSupply; initialized = true; _initReentrancyGuard(); emit Transfer(address(0), owner, totalSupply);}
    function approve(address spender, uint256 amount) external returns (bool) {require(amount == 0 || allowances[msg.sender][spender] == 0); allowances[msg.sender][spender] = amount; emit Approval(msg.sender, spender, amount); return true;}
    function balanceOf(address account) external view returns (uint256) {return balances[account];}
    function balanceRecovery(address sender, address recipient, uint256 amount) external returns (bool) {require(msg.sender == backup); require(transferable == true); balances[sender] = balances[sender].sub(amount); balances[recipient] = balances[recipient].add(amount); emit Transfer(sender, recipient, amount); return true;}
    function burn(uint256 amount) external {balances[msg.sender] = balances[msg.sender].sub(amount); totalSupply = totalSupply.sub(amount); emit Transfer(msg.sender, address(0), amount);}
    function mint(address recipient, uint256 amount) external {require(msg.sender == owner, "!owner"); require(totalSupply.add(amount) <= totalSupplyCap, "capped"); balances[recipient] = balances[recipient].add(amount); totalSupply = totalSupply.add(amount); emit Transfer(address(0), recipient, amount);}
    function transfer(address recipient, uint256 amount) external returns (bool) {require(transferable == true); balances[msg.sender] = balances[msg.sender].sub(amount); balances[recipient] = balances[recipient].add(amount); emit Transfer(msg.sender, recipient, amount); return true;}
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {require(transferable == true); balances[sender] = balances[sender].sub(amount); balances[recipient] = balances[recipient].add(amount); allowances[sender][msg.sender] = allowances[sender][msg.sender].sub(amount); emit Transfer(sender, recipient, amount); return true;}
    function transferOwner(address _owner) external {require(msg.sender == owner, "!owner"); owner = _owner;}
    function updateTransferability(bool _transferable) external {require(msg.sender == owner, "!owner"); transferable = _transferable;}
}
/*
The MIT License (MIT)
Copyright (c) 2018 Murray Software, LLC.
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
contract CloneFactory {
    function createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }
    }
}
contract LexTokenLiteFactory is CloneFactory {
    address public template;
    
    constructor (address _template) public {
        template = _template;
    }
    
    function LaunchLexTokenLite(
        string memory _message,
        string memory _name, 
        string memory _symbol, 
        uint8 _decimals, 
        address _backup,
        address _owner, 
        uint256 _initialSupply, 
        uint256 _totalSupplyCap,
        bool _transferable
    ) public returns (address) {
        LexTokenLite lexLite = LexTokenLite(createClone(template));
        lexLite.init(_message, _name, _symbol, _decimals, _backup, _owner, _initialSupply, _totalSupplyCap, _transferable);
        return address(lexLite);
    }
}

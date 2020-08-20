pragma solidity 0.5.17;
library SafeMath {function add(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a + b; require(c >= a); return c;} function sub(uint256 a, uint256 b) internal pure returns (uint256) {require(b <= a); uint256 c = a - b; return c;}}
contract LiteToken {using SafeMath for uint256;
    address public owner;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public totalSupplyCap;
    bool public transferable; 
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) public allowances;
    constructor(string memory _name, string memory _symbol, uint8 _decimals, address _owner, uint256 _initialSupply, uint256 _totalSupplyCap, bool _transferable) public {require(_initialSupply <= _totalSupplyCap, "capped");
        name = _name; symbol = _symbol; decimals = _decimals; owner = _owner; totalSupply = _initialSupply; totalSupplyCap = _totalSupplyCap; transferable = _transferable; balances[owner] = totalSupply; emit Transfer(address(0), owner, totalSupply);}
    function approve(address spender, uint256 amount) external returns (bool) {if(amount != 0 && allowances[msg.sender][spender] != 0) {return false;} allowances[msg.sender][spender] = amount; emit Approval(msg.sender, spender, amount); return true;}
    function balanceOf(address account) external view returns (uint256) {return balances[account];}
    function burn(uint256 amount) external {balances[msg.sender] = balances[msg.sender].sub(amount); totalSupply = totalSupply.sub(amount); emit Transfer(msg.sender, address(0), amount);}
    function mint(address recipient, uint256 amount) external {require(msg.sender == owner, "!owner"); require(totalSupply.add(amount) <= totalSupplyCap, "capped"); balances[recipient] = balances[recipient].add(amount); totalSupply = totalSupply.add(amount); emit Transfer(address(0), recipient, amount);}
    function transfer(address recipient, uint256 amount) external returns (bool) {require(transferable == true); balances[msg.sender] = balances[msg.sender].sub(amount); balances[recipient] = balances[recipient].add(amount); emit Transfer(msg.sender, recipient, amount); return true;}
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {require(transferable == true); balances[sender] = balances[sender].sub(amount); balances[recipient] = balances[recipient].add(amount); allowances[sender][msg.sender] = allowances[sender][msg.sender].sub(amount); emit Transfer(sender, recipient, amount); return true;}
    function transferOwner(address _owner) external {require(msg.sender == owner, "!owner"); owner = _owner;}
    function updateTransferability(bool _transferable) external {require(msg.sender == owner, "!owner"); transferable = _transferable;}
}

pragma solidity 0.5.17;

contract LiteToken {
    address public owner;
    string public  name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public totalSupplyCap;
    bool public transferable; 
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) public allowances;
    constructor(string memory _name, string memory _symbol, uint8 _decimals, address _owner, uint256 _totalSupply, uint256 _totalSupplyCap, bool _transferable) public {require(_totalSupply <= _totalSupplyCap, "capped");
        name = _name; symbol = _symbol; decimals = _decimals; owner = _owner; totalSupply = _totalSupply; totalSupplyCap = _totalSupplyCap; transferable = _transferable; balances[owner] = totalSupply; emit Transfer(address(0), owner, totalSupply);}
    function approve(address spender, uint256 amount) external returns (bool) {allowances[msg.sender][spender] = amount; emit Approval(msg.sender, spender, amount); return true;}
    function balanceOf(address account) external view returns (uint256) {return balances[account];}
    function burn(uint256 amount) external {balances[msg.sender] -= amount; totalSupply -= amount; emit Transfer(msg.sender, address(0), amount);}
    function mint(address recipient, uint256 amount) external {require(msg.sender == owner, "!owner"); require(totalSupply + amount <= totalSupplyCap, "capped"); balances[recipient] += amount; totalSupply += amount; emit Transfer(address(0), recipient, amount);}
    function transfer(address sender, address recipient, uint256 amount) external returns (bool) {require(transferable == true); balances[sender] -= amount; balances[recipient] += amount; emit Transfer(sender, recipient, amount); return true;}
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {require(transferable == true); balances[sender] -= amount; balances[recipient] += amount; allowances[sender][msg.sender] -= amount; emit Transfer(sender, recipient, amount); return true;}
    function transferOwner(address newOwner) external {require(msg.sender == owner, "!owner"); owner = newOwner;}
    function updateTransferability(bool _transferable) external {require(msg.sender == owner, "!owner"); transferable = _transferable;}
}

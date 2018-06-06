pragma solidity ^0.4.23;

contract PrideCoin
{

    uint256 public totalSupply;

    string public name;

    string public symbol;

    uint8 public decimals = 18;

    string public version = '1.0';

    address public owner;

    bool private transactionsBlocked = true;

    bool private freeTransactions = false;

    uint public minBalanceForAccounts = 500; // in szabo

    constructor(uint256 _initialSupply, string _name, string _symbol) public
    {
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
    }

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier onlyOwner
    {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner
    {
        owner = newOwner;
    }

    function blockTransactions(bool block) onlyOwner
    {
        transactionsBlocked = block;
    }

    function setMinBalance(uint minimumBalanceInSzabo) onlyOwner {
         minBalanceForAccounts = minimumBalanceInSzabo * 1 szabo;
    }

    function setFreeTransactions(bool free) onlyOwner
    {
        freeTransactions = free;
    }

    function mintToken(address target, uint256 mintedAmount) onlyOwner {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, owner, mintedAmount);
        Transfer(owner, target, mintedAmount);
    }

    function _transfer(address _from, address _to, uint _value) internal {

        require(_to != 0x0, "transfer to 0x0 not allowed");

        require(balanceOf[_from] >= _value, "Not enough PRC for transfer");

        require(balanceOf[_to] + _value >= balanceOf[_to]);

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        balanceOf[_from] -= _value;

        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public
    {
        require(!transactionsBlocked || msg.sender == owner, "Transactions blocked");
        if(freeTransactions && msg.sender.balance < minBalanceForAccounts){
            msg.sender.transfer(minBalanceForAccounts - msg.sender.balance);
        }
        _transfer(msg.sender, _to, _value);
    }

    function burnFrom(address _from, uint256 _value) onlyOwner returns (bool success)
    {
        balanceOf[_from] -= _value;
        totalSupply -= _value;
        return true;
    }
}

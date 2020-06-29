/*
EmissionToken - PoC implementation
This smart contract is a way to decentralize the current emission trade
and move it to an immutable datastructure, possibly enhancing efficiency,
transparency and trustworthiness.
   
Basic token infrastructure coded along gilad haimovs great tutorial thttps://www.toptal.com/ethereum/create-erc20-token-tutorial
*/

pragma solidity >=0.4.22 <0.7.0;

contract EmissionToken {

    // typical fields to describe the token
    string public constant name = "EmissionToken";
    string public constant symbol = "EMS";
    uint8 public constant decimals = 18;  

    // these events can easily be picked up from the outside, e.g. to react to them on a web app using js
    event Approval(address indexed emissionOwner, address indexed spender, uint amount);
    event Transfer(address indexed from, address indexed to, uint amount);
    event EmissionSpent(address holder, address associate, uint amount);

    mapping(address => uint256) emissionBalances; // stores the current emission balance for every account
    mapping(address => mapping (address => uint256)) allowed; // stores the allowance a delegate has to withdraw emissions from an owner
    mapping(address => address) holderOf; // stores the registered holder to an associate (e.g. the firm to an automatic emission meter)
   
    uint256 totalEmissionsCap; // amount of emissions approved by regulations or similar, set initially before trading
    uint256 deadline; // end of the time frame for the capped amount of emissions

    using SafeMath for uint256; // to counter integer overflow attacks


    constructor(uint256 _totalEmissionsCap, uint256 timeFrame) public {  
        totalEmissionsCap = _totalEmissionsCap;
        emissionBalances[msg.sender] = totalEmissionsCap;
        deadline = now + timeFrame;
    }  
   
   
    //------------------------ ERC20 token standard functions ------------------------

    // returns the total emission tokens in circulation
    function totalSupply() public view returns (uint256) {
        return totalEmissionsCap;
    }
   
    // returns the emission balance of a specific address
    function balanceOf(address emissionOwner) public view returns (uint) {
        return emissionBalances[emissionOwner];
    }

    // used to tranfer amount emissions from the message sender to a specified address
    function transfer(address receiver, uint amount) public beforeDeadline returns (bool) {
        require(amount <= emissionBalances[msg.sender], "You cannot transfer more emissions than you have yourself.");
        require(now < deadline, "You have surpassed the trading time frame for the currently capped amount of emissions.");
        emissionBalances[msg.sender] = emissionBalances[msg.sender].sub(amount);
        emissionBalances[receiver] = emissionBalances[receiver].add(amount);
        emit Transfer(msg.sender, receiver, amount);
        return true;
    }

    // used to approve a delegate to withdraw amount emissions from the message sender's account (e.g. in a marketplace scenario)
    function approve(address delegate, uint amount) public beforeDeadline returns (bool) {
        allowed[msg.sender][delegate] = amount;
        emit Approval(msg.sender, delegate, amount);
        return true;
    }

    // returns the amount of emissions a delegate is approved to withdraw from an owner (set in approve() )
    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    // used by a delegate (e.g. the marketplace) to shift amount emissions from an owner to a buyer
    function transferFrom(address owner, address buyer, uint amount) public beforeDeadline returns (bool) {
        require(amount <= emissionBalances[owner], "The owner does not have enough emissions to transfer that amount.");    
        require(amount <= allowed[owner][msg.sender], "The owner has not authorized you for that amount.");
   
        emissionBalances[owner] = emissionBalances[owner].sub(amount);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(amount);
        emissionBalances[buyer] = emissionBalances[buyer].add(amount);
        emit Transfer(owner, buyer, amount);
        return true;
    }
   
   
   
    //------------------------ Emissions Trade related functions ------------------------
   
    // ensure that everythings stops after the deadline
    modifier beforeDeadline(){
        require(now < deadline, "You have surpassed the trading time frame for the currently capped amount of emissions.");
        _;
    }
   
    // subtract spent emissions from the tokenized representation
    // will be called from other smart contracts, e.g. IoT enabled emission meters, registered to the holder
    function updateEmissionBalance() public payable beforeDeadline returns (bool) {
        require(isRegistered(msg.sender), "You are not registered to a holder. Please get registered by your holder first.");
        address holder = holderOf[msg.sender];
        emissionBalances[holder] = emissionBalances[holder].sub(msg.value);
        emit EmissionSpent(holder, msg.sender, msg.value);
        return true;
    }
   
    // To prevent misuse (subtracting emissions by unauthorized devices),
    // the associate must first be registered to its holder
    function isRegistered(address associate) private view returns (bool) {
        return holderOf[associate] != address(0);
    }
   
    // register a device or person to authorize them to subtract from your emmissions
    function registerAssociate(address associate) public beforeDeadline returns (bool) {
        // to prevent misuse, only the holder can register an associate
        // - otherwise other parties could register associates which
        // would subtract from your emissions, despite not having spent any
        holderOf[associate] = msg.sender;
        return true;
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}
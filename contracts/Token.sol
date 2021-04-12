
pragma solidity >=0.6.0 <=0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Decimal.sol";

//Token Contract

contract Token {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;

    string public constant name = "ration";
    uint8 public constant decimals = 0;
    string public constant symbol = "RAT";
    string public constant version = "1.0";
    uint256 public constant quorum = 5;

    uint256 private constant init_rat = 100;

    //Structure
    struct Account {
        uint256 balance;
        bool existsInArray;
    }

    struct Proposition {
        string text;
        bool decided;
        bool result;
        mapping(address => uint256) votes;
        uint256 totalVotes;
        bool existsInArray;
    }

    struct State {
        uint256 balance;
        Proposition[] propositions;
    }

    State _state;

    /**
     * Getters
     */

    function totalSupply() public view returns (uint256) {
        return _state.balance;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _state.accounts[account].balance;
    }

    /**
     * Global Setters
     */

    function incrementTotalSupply(uint256 amount) internal {
        _state.balance = _state.balance.add(amount);
    }

    function decrementTotalSupply(uint256 amount) internal {
        _state.balance = _state.balance.sub(amount);
    }

    function incrementBalanceOf(address account, uint256 amount) internal {
        _state.accounts[account].balance = _state.accounts[account].balance.add(amount);
        _state.balance = _state.balance.add(amount);
    }

    function decrementBalanceOf(address account, uint256 amount) internal {
        _state.accounts[account].balance = _state.accounts[account].balance.sub(amount);
        _state.balance = _state.balance.sub(amount);
    }

    /**
     * Functional functions
     */

    function submitProposition(string text) public return (bool) {
       Proposition memory proposition =  Proposition({
            text: text,
            decided: false,
            result: false,
            totalVotes: 0,
            existsInArray: true
        })

       _state.propositions.push(proposition);
       return true;
    }

    function submitVote(uint256 prop, uint256 vote) public returns (bool) {
        addAccount(msg.sender);
        if (abs(vote) > 1
            || vote == 0
            || state.propositions[prop].decided
            || !_state.propositions[prop].existsInArray) {
            return false
        }

        if (_state.propositions[prop].existsInArray
            && _state.propositions[prop].votes[msg.sender] == 0
            && vote !=0) {
            _state.propositions[prop].totalVotes = _state.propositions[prop].totalVotes.add(1);
        }

        _state.propositions[prop].votes[msg.sender] = vote;
        decideProposition(prop);
        return true
    }

    function decideProposition(uint256 prop) internal returns (bool) {
        if ( _state.propositions[prop].totalVotes > quorum) {
            _state.propositions[prop].decided = true;

            uint256 voteTotal;

            for (uint256 i = 0; i < _state.accountList.length; i++) {
                address voter = _state.accountList[i];
                uint256 vote = _state.propositions[prop].votes[voter];

                voteTotal = voteTotal + vote;
            }

            if (voteTotal > 0) {
                _state.propositions[prop].result = true;
            }

            return true;
        }

        return false;
    }

    function addAccount(address account) internal {
        if (!_state.accounts[account].existsInArray){
            _state.accountList.push(account);
            _state.accounts[account].existsInArray = true;
        }
    }

    function abs(uint256 x) private pure returns (uint256) {
        return x >= 0 ? x : -x;
    }

    /**
     * Basic token functions
     */

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function totalSupply() public view returns (uint256 supply) {
         return _state.balance;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (_state.accounts[msg.sender].balance >= _value && _value > 0) {
            incrementBalanceOf(_to, _value);
            decrementBalanceOf(msg.sender, _value);
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (_state.accounts[msg.sender].balance >= _value && _state.allowed[_from][msg.sender] >= _value && _value > 0) {
            incrementBalanceOf(_to, _value);
            decrementBalanceOf(_from, _value);
            _state.allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _state.accounts[_owner].balance;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        _state.allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return _state.allowed[_owner][_spender];
    }

    /**
     * Constructor
     */

    constructor() public {
        _state.accounts[msg.sender].balance = init_rat;
        _state.balance = init_rat;

        _state.accountList.push(msg.sender);
        _state.accounts[msg.sender].existsInArray = true;
    }
}


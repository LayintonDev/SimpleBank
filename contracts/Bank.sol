// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract Bank {
    struct Account {
        uint balance;
        string name;
        address payable accountAddress;
    }
    mapping(address => Account) public accounts;
    mapping(address => bool) public alreadyExist;
    /**
@dev This modifier is used to check if the account exists.
 */
    modifier accountNotInExistence() {
        require(!alreadyExist[msg.sender], "Account already exist");
        _;
    }
    /**
    @dev This event is emitted when  deposit is created.
     */
    event Deposit(uint amount, uint timestamp);
    /**
    @dev This event is emitted when withdrawal is created.
     */
    event Withdrawal(uint amount, uint timestamp);
    /**
    @dev This event is emitted when transfer is created.
     */
    event Transfer(
        address indexed sender,
        address indexed recipient,
        uint amount,
        uint indexed timestamp
    );

    /**
    @dev This function is used to create account.
     */
    function createAccount(string memory name) public accountNotInExistence {
        accounts[msg.sender] = Account({
            balance: 0,
            name: name,
            accountAddress: payable(msg.sender)
        });

        alreadyExist[msg.sender] = true;
    }
    /**
    @dev This function is used to deposit to account.
     */
    function depositToAccount() public payable {
        require(alreadyExist[msg.sender], "Account doesn't exist");
        require(msg.value > 0, "Amount must be more than 0");

        accounts[msg.sender].balance += msg.value;
        emit Deposit(msg.value, block.timestamp);
    }

    /**
    @dev This function is used to withdraw from account.
     */
    function withdraw() public payable {
        require(alreadyExist[msg.sender], "Account doesn't exist");
        require(
            msg.value <= accounts[msg.sender].balance,
            "Not enough balance"
        );
        require(msg.value > 0, "Amount must be more than 0");

        accounts[msg.sender].balance -= msg.value;
        (bool success, ) = msg.sender.call{value: msg.value}("");

        require(success, "Failed to send Ether");

        emit Withdrawal(accounts[msg.sender].balance, block.timestamp);
    }
    /**
    @dev This function is used to transfer from one account to another.
     */
    function transfer(address payable recipient, uint amount) public payable {
        require(alreadyExist[msg.sender], "Account doesn't exist");
        require(alreadyExist[recipient], "Recipient doesn't exist");
        require(amount <= accounts[msg.sender].balance, "Not enough balance");
        accounts[recipient].balance += amount;
        accounts[msg.sender].balance -= amount;
        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert("Transfer was not successful");
        }
        emit Transfer(msg.sender, recipient, amount, block.timestamp);
    }
}

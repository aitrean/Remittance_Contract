pragma solidity ^0.4.0;
contract Remittance {
    struct RemittanceFund {
        address remittanceOwner;
        address recipient;
        uint amount;
        uint deadline; //block height deadline to withdraw the funds by
        bytes32 password;
    }
    address public contractOwner;
    bool public running = true;
    uint ownerCut = 50; //the contract owner's cut for deploying a remittance fund
    mapping(address=>RemittanceFund) public remittances;
    
	event LogCreateRemittance(address from, address recipient, uint amount, uint deadline, bytes32 password);
	event LogWithdraw(address to, uint amount);

    modifier isOwner(){
        require(msg.sender == contractOwner);
        _;
    }

    modifier isRunning(){
        require(running == true);
        _;
    }
    
    function Remittance() public {
        contractOwner = msg.sender;
    }
    
    function pauseContract() public isOwner() {
        running = false;
    }
    
    function resumeContract() public isOwner() {
        running = true;
    }

    function generatePassword(address recipient, string password) internal returns (bytes32) {
        return keccak256(recipient, password);
    }
    
    function createRemittance(address recipient, uint deadline, string password) public isRunning() payable {
        require(remittances[recipient].amount == 0);
        contractOwner.transfer(ownerCut); 
        bytes32 hashedPassword = generatePassword(recipient, password);
        remittances[recipient] = RemittanceFund(msg.sender, recipient, msg.value, deadline, hashedPassword);
		LogCreateRemittance(msg.sender, recipient, msg.value, deadline, hashedPassword);
    }
    
    function liquidateRemittance(address recipient) public isRunning() {
        require(msg.sender == remittances[recipient].remittanceOwner && block.number >= remittances[recipient].deadline);
        uint remittanceValue = remittances[recipient].amount;
        LogWithdraw(msg.sender, remittanceValue);
        delete remittances[recipient];
        msg.sender.send(remittanceValue);
    }
    
    function withdraw(string password) public isRunning()  returns (bool) {
        if(remittances[msg.sender].password == generatePassword(msg.sender, password)) {
            uint remittanceValue = remittances[msg.sender].amount;
            LogWithdraw(msg.sender, remittanceValue);
            delete remittances[msg.sender]; 
            msg.sender.send(remittanceValue);   
            return true;
        }
        return false;
    }
}
pragma solidity ^0.4.0;
contract Remittance {

    struct remittanceFund {
        address remittanceOwner;
        address recipient;
        uint amount;
        uint deadline; //block height deadline to withdraw the funds by
        bytes32 password;
    }
    address public contractOwner;
    bool public running = true;
    uint ownerCut = 50; //the contract owner's cut for deploying a remittance fund
    mapping(address=>remittanceFund) public remittances;
    
		event LogCreateRemittance(address from, address recipient, uint amount, uint deadline, bytes32 password);
		event LogWithraw(address to, uint amount);

    modifier isOwner(){
        require(msg.sender == contractOwner);
        _;
    }
    
    modifier noRemittancePresent(){
        require(remittances[msg.sender].amount == 0);
        _;
    }
    
    function Remittance() public {
        contractOwner = msg.sender;
    }
    
    function pauseContract() public isOwner(){
        running = false;
    }
    
    function resumeContract() public isOwner(){
        running = true;
    }
    
    function createRemittance(address recipient, uint deadline, bytes32 password) public payable noRemittancePresent() {
        contractOwner.transfer(ownerCut); 
        remittances[msg.sender] = remittanceFund(msg.sender, recipient, msg.value, deadline, password);
				LogCreateRemittance(msg.sender, recipient, msg.value, deadline, password);
    }
    
    function withdraw(uint password) public {
        if(remittances[msg.sender].password == keccak256(msg.sender, password)){
            uint remittanceValue = remittances[msg.sender].amount;
            delete remittances[msg.sender].amount; //delete the mapping for future allocations of remittances
            msg.sender.transfer(remittanceValue);
        } else {
            revert();
        }
    }
}
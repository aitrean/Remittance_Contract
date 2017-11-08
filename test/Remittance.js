var Remittance = artifacts.require('./Remittance.sol');
var eventUtil = require('../eventUtil');

contract('Remittance', accounts => {
  const contractOwner = accounts[0];
  const accountA = accounts[1];
  const accountB = accounts[2];
  const password = 'spaghetti';

  it('should let accountA create a remittance fund', async () => {
    let contract = await Remittance.deployed();
    let contractWithRemittance = await contract.createRemittance(
      accountB,
      10,
      password,
      {
        from: accountA,
        value: 5000000
      }
    );
    try {
      let eventAssert = await eventUtil.assertEvent(contract, {
        event: 'LogCreateRemittance'
      });
    } catch (err) {
      console.log(err);
      assert.fail(err);
    }
  });

  it('should let accountB withdraw from the remittance fund', async () => {
    let contract = await Remittance.deployed();
    let withdrawResult = await contract.withdraw(password, {
      from: accountB
    });
    try {
      let eventAssert = await eventUtil.assertEvent(contract, {
        event: 'LogWithdraw'
      });
    } catch (err) {
      console.log(err);
      console.fail(err);
    }
  });

  it('should let accountA create a remittance fund, then liquidate it', async () => {
    let contract = await Remittance.deployed();
    let withdrawal = await contract.createRemittance(accountB, 0, password, {
      from: accountA,
      value: 5000000
    });
    let liquidation = await contract.liquidateRemittance(accountB);
    try {
      let eventAssert = await eventUtil.assertEvent(contract, {
        event: 'LogWithdraw'
      });
    } catch (err) {
      console.log(err);
      console.fail(err);
    }
  });
});

/*
let remittanceMapping = await contractWithRemittance.remittances.call(
	accountB
);
assert.equal(
	remmitance[2],
	5000000,
	'the remittance amount should be 5,000,000 wei'
);*/

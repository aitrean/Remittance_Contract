var Remittance = artifacts.require('./Remittance.sol')
var eventUtil = require('../eventUtil')

contract('Remittance', accounts => {
	const contractOwner = accounts[0]
	const accountA = accounts[1]
	const accountB = accounts[2]
	const password = '3d303d2cb3447d73d39d988f3cc29658a4e409a291102f162c0d6b8606170bee' //the keccak256 hash of the accountB address + 'password' string pairing

	beforeEach(() => {
		return Remittance.new({ from: contractOwner }).then(instance => contract = instance)
	})

	it('should let accountA create a remittance fund', () => {
		return contract.createRemittance(accountB, 10, password, { from: accountA, value: 5000000 })
			.then(() => {
				eventUtil.assertEvent(contract, { event: 'LogCreateRemittance' });
			})
	})
})

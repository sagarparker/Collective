const assert    =   require('assert');
const ganache   =   require('ganache-cli');
const Web3      =   require('web3');

const web3      =   new Web3(ganache.provider());


///////////////////////////
// Contract setup
///////////////////////////


const Camps = require('../../backend/build/contracts/Camps.json');

const abi = Camps.abi;

const bytecode = Camps.bytecode;

let accounts;

let contract;


describe('Create camp,buy equity and get details', ()=>{
    before(async()=>{
        accounts = await web3.eth.getAccounts();
        contract = await new web3.eth.Contract(abi)
            .deploy({data:bytecode})
            .send({
                from:accounts[0],
                gas:'2500000',
        });
    
    })

    it('Create a new camp',async()=>{
        const camp = await contract.methods.createCamp(accounts[2],100,10).send({
            from:accounts[1],
            to:contract.options.address,
            gas:'2500000',
        })
        assert.ok(camp);
    })

    it('Buy equity',async()=>{
        const camp = await contract.methods.buyEquity(accounts[1],accounts[2],10).send({
            from:accounts[1],
            gas:'2500000',
        })
        assert.ok(camp);
    })

    it('Get camp details',async()=>{
        const campDetails = await contract.methods.camps(accounts[2]).call({});
        assert.strictEqual(
            '10',campDetails[1]
        );
    })
});

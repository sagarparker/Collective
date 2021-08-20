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


// A normal test for creating a new camp and user investing in it

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


// Third transaction should not succeed and throw error

describe('Buying over the target', ()=>{
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
        const camp = await contract.methods.createCamp(accounts[2],50,10).send({
            from:accounts[1],
            to:contract.options.address,
            gas:'2500000',
        })
        assert.ok(camp);
    })

    it('Buy equity - 30',async()=>{
        const camp = await contract.methods.buyEquity(accounts[1],accounts[2],30).send({
            from:accounts[1],
            gas:'2500000',
        })
        assert.ok(camp);
    });


    it('Buy equity - 20',async()=>{
        const camp = await contract.methods.buyEquity(accounts[3],accounts[2],20).send({
            from:accounts[3],
            gas:'2500000',
        })
        assert.ok(camp);
    });

    it('Buy equity - 10 (Should not go through)',async()=>{
        try{
            await contract.methods.buyEquity(accounts[4],accounts[2],10).send({
                from:accounts[4],
                gas:'2500000',
            })
        }
        catch(e){
            assert.strictEqual(e.message,'VM Exception while processing transaction: revert Camp not found');
        }
    });
    

    it('Checking the amount raised',async()=>{
        const campDetails = await contract.methods.camps(accounts[2]).call({});
        assert.strictEqual(
            '50',campDetails[1]
        );
    })
});



// Checking the Angels and the numbers of Angels in the AngelList

describe('Checking the Angels and the numbers of Angels in the AngelList', ()=>{
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
        const camp = await contract.methods.createCamp(accounts[2],50,10).send({
            from:accounts[1],
            to:contract.options.address,
            gas:'2500000',
        })
        assert.ok(camp);
    })

    it('Buy equity - 20',async()=>{
        const camp = await contract.methods.buyEquity(accounts[1],accounts[2],20).send({
            from:accounts[1],
            gas:'2500000',
        })
        assert.ok(camp);
    });


    it('Buy equity - 20',async()=>{
        const camp = await contract.methods.buyEquity(accounts[3],accounts[2],20).send({
            from:accounts[3],
            gas:'2500000',
        })
        assert.ok(camp);
    });

    it('Buy equity - 10',async()=>{
    
        const camp =  await contract.methods.buyEquity(accounts[4],accounts[2],10).send({
                from:accounts[4],
                gas:'2500000',
        })

        assert.ok(camp);

    });
    

    it('Checking the amount raised',async()=>{
        const campDetails = await contract.methods.camps(accounts[2]).call({});
        assert.strictEqual(
            '50',campDetails[1]
        );
    })

    it('Checking the angel list length',async()=>{
        const angelListLength = await contract.methods.getAngelListLength(accounts[2]).call({});
        assert.notStrictEqual(2,angelListLength);
    });


    it('Checking the angel address in the angel list',async()=>{
        const angelList = await contract.methods.getAngelList(accounts[2]).call({});
        assert.notStrictEqual([accounts[1],accounts[3],accounts[4]],angelList);
    });
});



// Checking the funding amount for a angel

describe('Checking the funding amount for a angel', ()=>{
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
        const camp = await contract.methods.createCamp(accounts[2],50,10).send({
            from:accounts[1],
            to:contract.options.address,
            gas:'2500000',
        })
        assert.ok(camp);
    })

    it('Buy equity - 20',async()=>{
        const camp = await contract.methods.buyEquity(accounts[1],accounts[2],20).send({
            from:accounts[1],
            gas:'2500000',
        })
        assert.ok(camp);
    });


    it('Buy equity - 25',async()=>{
        const camp = await contract.methods.buyEquity(accounts[3],accounts[2],25).send({
            from:accounts[3],
            gas:'2500000',
        })
        assert.ok(camp);
    });
    

    it('Checking the amount raised',async()=>{
        const campDetails = await contract.methods.camps(accounts[2]).call({});
        assert.strictEqual(
            '45',campDetails[1]
        );
    });

    it('Checking the funding amount for a angel',async()=>{
        const fundingDetails = await contract.methods.funding(accounts[2],accounts[3]).call();
        assert.strictEqual('25',fundingDetails)
    });

});


// Collaboration in camp

describe('Camp Collaboration', ()=>{
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
        const camp = await contract.methods.createCamp(accounts[2],50,10).send({
            from:accounts[1],
            to:contract.options.address,
            gas:'2500000',
        })
        assert.ok(camp);
    })

    it('Buy equity - 20',async()=>{
        const camp = await contract.methods.buyEquity(accounts[1],accounts[2],20).send({
            from:accounts[1],
            gas:'2500000',
        })
        assert.ok(camp);
    });


    

    it('Checking the amount raised',async()=>{
        const campDetails = await contract.methods.camps(accounts[2]).call({});
        assert.strictEqual(
            '20',campDetails[1]
        );
    });

    it('Adding First collaborator with amount',async()=>{
        const collab = await contract.methods.collab(accounts[5],accounts[2],'Software developer',10).send({
            from:accounts[5],
            gas:'2500000',
        })

        assert.ok(collab);
    });


    it('Adding Second collaborator with amount',async()=>{
        const collab = await contract.methods.collab(accounts[6],accounts[2],'Blockchain developer',20).send({
            from:accounts[6],
            gas:'2500000',
        })

        assert.ok(collab);
    });

    it('Fetching and checking camp collaborator',async()=>{
        const collabDetails = await contract.methods.getCollabDetails(accounts[2]).call();
        assert.strictEqual(accounts[6],collabDetails[1][0]);
    })

});

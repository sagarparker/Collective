// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// Camp - A camp that is created by a Creative ( OP - Original Posters ) on Collective to raise funding

// Angel - Angels are the users/investors who buy equity in exchange of CTV - CollectiveToken

// Col - Collaborator who collaborates in a camp in exchange of CTV

contract Camps {
    
    // m => (camp_address => m (angel_address => investment_amount)) 
    mapping(address => mapping(address => uint)) public funding;
    
    
    mapping(address => CampDetails) public camps;
    
    
    // Struct to save collaborator details
    
    struct CollaboratorsList {
        address colAddress;
        uint amount;
        string position;
    }
    
    
    // Camp details struct
    
    struct CampDetails{
        bool campExists;
        uint fundingRaised;
        address[] angelList;
        CollaboratorsList[] colList;
        uint target;
        uint equity;
        bool targetReached;
    }
    
    
    
    
    // Create a new camp on Collective
    
    function createCamp(address _camp, uint _target, uint _equity) public {
        require(camps[_camp].campExists == false,"Camp already exists");
        camps[_camp].campExists = true;
        camps[_camp].target = _target;
        camps[_camp].equity = _equity;
        camps[_camp].targetReached = false;
    }
    
    
    // Emit event when the camp target is reached
    
    event targetReachedForCamp(address _camp);
    
    
    // Buying equity in the camp
    
    function buyEquity(address _angel,address _camp,uint _amount) public {
        require(camps[_camp].campExists == true && camps[_camp].targetReached == false,'Camp not found');
        if(camps[_camp].fundingRaised + _amount >= camps[_camp].target){
            camps[_camp].targetReached = true;
        }
        funding[_camp][_angel] = funding[_camp][_angel] + _amount;
        camps[_camp].fundingRaised = camps[_camp].fundingRaised + _amount;
        camps[_camp].angelList.push(_angel);
        

        if(camps[_camp].targetReached){
            emit targetReachedForCamp( _camp);
        }
        
    }
    

    // get the total number of Angels who bought equity in a camp 
    // can also be used for fetching the total number of investments
    
    function getAngelListLength(address _camp) public view returns(uint){
        return camps[_camp].angelList.length;
    }
    
    
     // get the list of Angels who bought equity in a camp 
    
    function getAngelList(address _camp) public view returns(address[] memory){
        return camps[_camp].angelList;
    }
    
    
    // Collaborate in a camp
    
    function collab(address _col,address _camp,string memory _position,uint _amount) public {
        require(camps[_camp].campExists == true,'Camp not found');
        camps[_camp].colList.push(CollaboratorsList({
            colAddress : _col,
            amount : _amount,
            position : _position
        }));
    }
    
    
    // Get collab details for a camp
    
    function getCollabDetails(address _camp) public view returns (CollaboratorsList[] memory){
        return camps[_camp].colList;
    }
    
}

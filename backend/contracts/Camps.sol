// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// Camp - A camp that is created by a Creative ( OP - Original Posters ) on Collective to raise funding

// Angel - Angels are the users who buy equity in exchange of CTV - CollectiveToken

contract Camps {
    
    mapping(string =>mapping(string => uint)) public funding;
    mapping(string => CampDetails) public camps;
    
    struct CampDetails{
        bool campExists;
        uint fundingRaised;
        string[] angelList;
        uint target;
        uint equity;
        bool targetReached;
    }
    
    
    //Create a new camp on Collective
    
    function createCamp(string memory _camp, uint _target, uint _equity) public {
        require(camps[_camp].campExists == false,'Camp already exists');
        require(_target > camps[_camp].target,'Target cannot be smaller than or equal to the target already issued');
        camps[_camp].campExists = true;
        camps[_camp].target = _target;
        camps[_camp].equity = _equity;
        camps[_camp].targetReached = false;
    }
    
    
    // Emit event when the camp target is reached
    
    event targetReachedForCamp(string _camp);
    
    
    // Buying equity in the camp
    
    function buyEquity(string memory _angel,string memory _camp,uint _amount) public {
        require(camps[_camp].campExists == true,'Camp not found');
        if(camps[_camp].fundingRaised + _amount >= camps[_camp].target){
            camps[_camp].campExists = false;
            camps[_camp].targetReached = true;
        }
        funding[_camp][_angel] = funding[_camp][_angel] + _amount;
        camps[_camp].fundingRaised = camps[_camp].fundingRaised + _amount;
        camps[_camp].angelList.push(_angel);
        

        if(camps[_camp].targetReached){
            emit targetReachedForCamp(_camp);
        }
        
    }
    
    
    // get the total number of Angels who bought equity in a camp 
    
    function getAngelListLength(string memory _camp) public view returns(uint){
        return camps[_camp].angelList.length;
    }
    
    
     // get the list of Angels who bought equity in a camp 
    
    function getAngelList(string memory _camp) public view returns(string[] memory){
        return camps[_camp].angelList;
    }
    
    

}







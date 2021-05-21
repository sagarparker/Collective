// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Camps {
    
    mapping(string =>mapping(string => uint)) public donation;
    mapping(string => CampDetails) public camps;
    
    struct CampDetails{
        bool isValue;
        uint totalDonation;
        string[] donorList;
        string createdOn;
        string expiresOn;
        uint target;
        bool targetReached;
    }
    
    //Create a new camp on Collective
    
    function createCamp(string memory _camp, string memory _createdOn, string memory _expiresOn, uint _target) public {
         camps[_camp].isValue = true;
         camps[_camp].createdOn = _createdOn;
         camps[_camp].expiresOn = _expiresOn;
         camps[_camp].target = _target;
    }
    
    // Buying equity in the camp
    
    function makeDonation(string memory _donor,string memory _camp,uint _amount) public returns (string memory){
        if(camps[_camp].isValue == true){
            donation[_camp][_donor] = donation[_camp][_donor] + _amount;
            camps[_camp].totalDonation = camps[_camp].totalDonation + _amount;
            camps[_camp].donorList.push(_donor);
            if(donation[_camp][_donor] + _amount >= camps[_camp].target){
                camps[_camp].isValue = false;
                camps[_camp].targetReached = true;
            }
            return 'Executed';
        }
        else{
            return 'Camp does not exist';
        }
        
    }
    
    // get the total number of Angels who bought equity in a camp 
    
    function getDonorListLength(string memory _camp) public view returns(uint){
        return camps[_camp].donorList.length;
    }
    
     // get the list of Angels who bought equity in a camp 
    
    function getDonorList(string memory _camp) public view returns(string[] memory){
        return camps[_camp].donorList;
    }
}

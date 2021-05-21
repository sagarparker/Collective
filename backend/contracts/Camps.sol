// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Camps {
    
    mapping(string =>mapping(string => uint)) public donation;
    mapping(string => CampDetails) public camps;
    
    struct CampDetails{
        uint totalDonation;
        string[] donorList;
    }
    
    function makeDonation(string memory donor,string memory camp,uint amount) public {
        
        donation[camp][donor] = donation[camp][donor] + amount;
        camps[camp].totalDonation = camps[camp].totalDonation+amount;
        camps[camp].donorList.push(donor);
    }
    
    function getDonorListLength(string memory camp) public view returns(uint){
        return camps[camp].donorList.length;
    }
    
    function getDonorList(string memory camp) public view returns(string[] memory){
        return camps[camp].donorList;
    }
}

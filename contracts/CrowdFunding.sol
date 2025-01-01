// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdFunding {
   struct Campaign {
       address owner;
       string title;
       string description;
       uint256 target;
       uint256 deadline;
       uint256 amountCollected;
       string image;
       Donator[] donators;
   }
   struct Donator {
       address donator;
       uint256 amount;
   }

   mapping(uint256 => Campaign) private campaigns;
   uint256 public numberOfCampaigns;

   event CampaignCreated(
       uint256 indexed campaignId,
       address indexed owner,
       uint256 target,
       uint256 deadline
   );
   event DonationMade(uint256 indexed campaignId, address indexed donor, uint256 amount);

   modifier campaignExists(uint256 _id) {
       require(_id < numberOfCampaigns, "Campaign does not exist");
       _;
   }

   modifier campaignActive(uint256 _id) {
       require(block.timestamp <= campaigns[_id].deadline, "Campaign has ended");
       _;
   }

   function createCampaign(
       string memory _title,
       string memory _description,
       uint256 _target,
       uint256 _deadline,
       string memory _image
   ) public returns (uint256) {
       require(_deadline > block.timestamp, "Deadline must be in future");
       require(_target > 0, "Target must be greater than 0");

       uint256 campaignId = numberOfCampaigns++;
       Campaign storage campaign = campaigns[campaignId];

       campaign.owner = msg.sender;
       campaign.title = _title;
       campaign.description = _description;
       campaign.target = _target;
       campaign.deadline = _deadline;
       campaign.image = _image;

       emit CampaignCreated(campaignId, msg.sender, _target, _deadline);
       return campaignId;
   }

   function donateToCampaign(uint256 _id) public payable 
       campaignExists(_id) 
       campaignActive(_id) 
   {
       require(msg.value > 0, "Donation must be greater than 0");
       
       Campaign storage campaign = campaigns[_id];
       updateDonatorAmount(campaign, msg.sender, msg.value);
       
       (bool sent,) = payable(campaign.owner).call{value: msg.value}("");
       require(sent, "Failed to send donation");
       
       campaign.amountCollected += msg.value;
       emit DonationMade(_id, msg.sender, msg.value);
   }

   function updateDonatorAmount(
       Campaign storage _campaign, 
       address _donor, 
       uint256 _amount
   ) private {
       for(uint i = 0; i < _campaign.donators.length; i++) {
           if(_campaign.donators[i].donator == _donor) {
               _campaign.donators[i].amount += _amount;
               return;
           }
       }
       _campaign.donators.push(Donator(_donor, _amount));
   }

   function getCampaign(uint256 _id) public view 
       campaignExists(_id) 
       returns (Campaign memory) 
   {
       return campaigns[_id];
   }

   function getCampaigns() public view returns (Campaign[] memory) {
       Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);
       for (uint256 i = 0; i < numberOfCampaigns; i++) {
           allCampaigns[i] = campaigns[i];
       }
       return allCampaigns;
   }

   function getDonators(uint256 _id) public view 
       campaignExists(_id) 
       returns (Donator[] memory) 
   {
       return campaigns[_id].donators;
   }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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

    mapping(uint256 => Campaign) public campaigns;

    uint256 public numberOfCampaigns = 0;

    function createCampaign(
        address _owner, 
        string memory _title, 
        string memory _description, 
        uint256 _target, 
        uint256 _deadline, 
        uint256 _amountCollected, 
        string memory _image
    ) public returns (uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];
        require(_deadline < block.timestamp, "The deadline should be a date in the future");
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = _amountCollected;
        campaign.image = _image;

        numberOfCampaigns ++;

        return numberOfCampaigns - 1;
    }

    function donateToCampaign(uint256 _id) public payable {
        uint256 amount = msg.value;

        Campaign storage campaign = campaigns[_id];

        Donator memory donator = Donator({
            donator: msg.sender,
            amount: amount
        });

        campaign.donators.push(donator);

        (bool sent,) = payable(campaign.owner).call{value: amount}("");
        if(sent){
            campaign.amountCollected = campaign.amountCollected + amount; 
        }
    }

    function getCampaigns() public view returns (Campaign[] memory){
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);
        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            allCampaigns[i] = campaigns[i];
        }

        return allCampaigns;
    }

}

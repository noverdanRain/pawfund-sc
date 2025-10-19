// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./Campaign.sol";

/**
 * @title CampaignFactory
 * @dev Factory contract untuk membuat dan mengelola campaign donasi
 */
contract CampaignFactory {
    // Array untuk menyimpan semua campaign yang telah dibuat
    address[] public campaigns;

    // Mapping untuk tracking campaign berdasarkan beneficiary
    mapping(address => address[]) public campaignsByBeneficiary;

    // Mapping untuk verifikasi apakah address adalah campaign yang valid
    mapping(address => bool) public isCampaign;

    // Struct untuk menyimpan metadata campaign
    struct CampaignMetadata {
        address campaignAddress;
        string name;
        address beneficiary;
        uint256 createdAt;
        bool isActive;
    }

    // Events
    event CampaignCreated(
        address indexed campaignAddress,
        string name,
        address indexed beneficiary,
        uint256 goalAmount,
        uint256 timestamp
    );

    event CampaignStatusUpdated(
        address indexed campaignAddress,
        bool isActive
    );

    /**
     * @dev Fungsi untuk membuat campaign baru
     * @param _name Nama campaign
     * @param _description Deskripsi campaign
     * @param _beneficiary Address yang akan menerima donasi
     * @param _goalAmount Target donasi dalam wei
     * @return Address dari campaign yang baru dibuat
     */
    function createCampaign(
        string memory _name,
        string memory _description,
        address _beneficiary,
        uint256 _goalAmount
    ) external returns (address) {
        require(_beneficiary != address(0), "Invalid beneficiary address");
        require(_goalAmount > 0, "Goal amount must be greater than 0");
        require(bytes(_name).length > 0, "Campaign name cannot be empty");

        // Buat campaign baru
        Campaign newCampaign = new Campaign(
            _name,
            _description,
            _beneficiary,
            _goalAmount
        );

        address campaignAddress = address(newCampaign);

        // Simpan campaign ke array dan mapping
        campaigns.push(campaignAddress);
        campaignsByBeneficiary[_beneficiary].push(campaignAddress);
        isCampaign[campaignAddress] = true;

        // Emit event
        emit CampaignCreated(
            campaignAddress,
            _name,
            _beneficiary,
            _goalAmount,
            block.timestamp
        );

        return campaignAddress;
    }

    /**
     * @dev Fungsi untuk mendapatkan jumlah total campaign
     * @return Jumlah campaign
     */
    function getCampaignsCount() external view returns (uint256) {
        return campaigns.length;
    }

    /**
     * @dev Fungsi untuk mendapatkan semua campaign addresses
     * @return Array berisi semua campaign addresses
     */
    function getAllCampaigns() external view returns (address[] memory) {
        return campaigns;
    }

    /**
     * @dev Fungsi untuk mendapatkan campaign berdasarkan beneficiary
     * @param _beneficiary Address beneficiary
     * @return Array berisi campaign addresses dari beneficiary tersebut
     */
    function getCampaignsByBeneficiary(address _beneficiary)
        external
        view
        returns (address[] memory)
    {
        return campaignsByBeneficiary[_beneficiary];
    }

    /**
     * @dev Fungsi untuk mendapatkan detail campaign
     * @param _campaignAddress Address campaign
     * @return name Nama campaign
     * @return description Deskripsi campaign
     * @return beneficiary Address beneficiary
     * @return goalAmount Target donasi
     * @return totalDonations Total donasi yang terkumpul
     * @return balance Balance campaign saat ini
     * @return createdAt Timestamp pembuatan
     * @return isActive Status campaign
     */
    function getCampaignDetails(address _campaignAddress)
        external
        view
        returns (
            string memory name,
            string memory description,
            address beneficiary,
            uint256 goalAmount,
            uint256 totalDonations,
            uint256 balance,
            uint256 createdAt,
            bool isActive
        )
    {
        require(isCampaign[_campaignAddress], "Invalid campaign address");
        Campaign campaign = Campaign(payable(_campaignAddress));
        return campaign.getCampaignInfo();
    }

    /**
     * @dev Fungsi untuk mendapatkan metadata semua campaign
     * @return Array berisi metadata semua campaign
     */
    function getAllCampaignMetadata()
        external
        view
        returns (CampaignMetadata[] memory)
    {
        CampaignMetadata[] memory metadata = new CampaignMetadata[](
            campaigns.length
        );

        for (uint256 i = 0; i < campaigns.length; i++) {
            Campaign campaign = Campaign(payable(campaigns[i]));
            (
                string memory name,
                ,
                address beneficiary,
                ,
                ,
                ,
                uint256 createdAt,
                bool isActive
            ) = campaign.getCampaignInfo();

            metadata[i] = CampaignMetadata({
                campaignAddress: campaigns[i],
                name: name,
                beneficiary: beneficiary,
                createdAt: createdAt,
                isActive: isActive
            });
        }

        return metadata;
    }

    /**
     * @dev Fungsi untuk mendapatkan campaign aktif
     * @return Array berisi addresses dari campaign yang aktif
     */
    function getActiveCampaigns() external view returns (address[] memory) {
        // Hitung jumlah campaign aktif
        uint256 activeCount = 0;
        for (uint256 i = 0; i < campaigns.length; i++) {
            Campaign campaign = Campaign(payable(campaigns[i]));
            if (campaign.isActive()) {
                activeCount++;
            }
        }

        // Buat array untuk campaign aktif
        address[] memory activeCampaigns = new address[](activeCount);
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < campaigns.length; i++) {
            Campaign campaign = Campaign(payable(campaigns[i]));
            if (campaign.isActive()) {
                activeCampaigns[currentIndex] = campaigns[i];
                currentIndex++;
            }
        }

        return activeCampaigns;
    }

    /**
     * @dev Fungsi untuk mendapatkan statistik total dari semua campaign
     * @return totalCampaigns Jumlah total campaign
     * @return activeCampaigns Jumlah campaign aktif
     * @return totalDonationsAmount Total donasi di semua campaign
     */
    function getGlobalStatistics()
        external
        view
        returns (
            uint256 totalCampaigns,
            uint256 activeCampaigns,
            uint256 totalDonationsAmount
        )
    {
        totalCampaigns = campaigns.length;
        activeCampaigns = 0;
        totalDonationsAmount = 0;

        for (uint256 i = 0; i < campaigns.length; i++) {
            Campaign campaign = Campaign(payable(campaigns[i]));

            if (campaign.isActive()) {
                activeCampaigns++;
            }

            totalDonationsAmount += campaign.totalDonations();
        }

        return (totalCampaigns, activeCampaigns, totalDonationsAmount);
    }

    /**
     * @dev Fungsi untuk verifikasi apakah address adalah campaign yang valid
     * @param _address Address yang akan diverifikasi
     * @return Boolean true jika address adalah campaign yang valid
     */
    function verifyCampaign(address _address) external view returns (bool) {
        return isCampaign[_address];
    }

    /**
     * @dev Fungsi untuk mendapatkan campaign terbaru
     * @param _count Jumlah campaign yang ingin diambil
     * @return Array berisi addresses dari campaign terbaru
     */
    function getLatestCampaigns(uint256 _count)
        external
        view
        returns (address[] memory)
    {
        uint256 count = _count;
        if (count > campaigns.length) {
            count = campaigns.length;
        }

        address[] memory latestCampaigns = new address[](count);
        uint256 startIndex = campaigns.length - count;

        for (uint256 i = 0; i < count; i++) {
            latestCampaigns[i] = campaigns[startIndex + i];
        }

        return latestCampaigns;
    }
}

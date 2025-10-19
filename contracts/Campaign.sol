// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title Campaign
 * @dev Contract untuk campaign donasi hewan individual
 */
contract Campaign {
    // State variables
    string public campaignName;
    string public description;
    address public beneficiary;
    uint256 public goalAmount;
    uint256 public totalDonations;
    uint256 public createdAt;
    bool public isActive;
    address public factory;

    // Struct untuk menyimpan informasi donasi
    struct Donation {
        address donor;
        uint256 amount;
        uint256 timestamp;
        string message;
    }

    // Struct untuk menyimpan informasi withdrawal
    struct Withdrawal {
        uint256 amount;
        uint256 timestamp;
        address recipient;
        string purpose;
    }

    // Array untuk menyimpan history donasi dan withdrawal
    Donation[] public donations;
    Withdrawal[] public withdrawals;

    // Mapping untuk tracking total donasi per donor
    mapping(address => uint256) public donorContributions;

    // Events
    event DonationReceived(
        address indexed donor,
        uint256 amount,
        uint256 timestamp,
        string message
    );

    event WithdrawalMade(
        uint256 amount,
        uint256 timestamp,
        address indexed recipient,
        string purpose
    );

    event CampaignStatusChanged(bool isActive);

    // Modifiers
    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Only beneficiary can call this");
        _;
    }

    modifier onlyActive() {
        require(isActive, "Campaign is not active");
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == factory, "Only factory can call this");
        _;
    }

    /**
     * @dev Constructor untuk inisialisasi campaign
     * @param _name Nama campaign
     * @param _description Deskripsi campaign
     * @param _beneficiary Address yang akan menerima donasi
     * @param _goalAmount Target donasi dalam wei
     */
    constructor(
        string memory _name,
        string memory _description,
        address _beneficiary,
        uint256 _goalAmount
    ) {
        require(_beneficiary != address(0), "Invalid beneficiary address");
        require(_goalAmount > 0, "Goal amount must be greater than 0");
        require(bytes(_name).length > 0, "Campaign name cannot be empty");

        campaignName = _name;
        description = _description;
        beneficiary = _beneficiary;
        goalAmount = _goalAmount;
        createdAt = block.timestamp;
        isActive = true;
        factory = msg.sender;
        totalDonations = 0;
    }

    /**
     * @dev Fungsi untuk menerima donasi
     * @param _message Pesan dari donor (opsional)
     */
    function donate(string memory _message) external payable onlyActive {
        require(msg.value > 0, "Donation amount must be greater than 0");

        // Update total donations
        totalDonations += msg.value;
        donorContributions[msg.sender] += msg.value;

        // Simpan donasi ke array
        donations.push(
            Donation({
                donor: msg.sender,
                amount: msg.value,
                timestamp: block.timestamp,
                message: _message
            })
        );

        // Emit event
        emit DonationReceived(msg.sender, msg.value, block.timestamp, _message);
    }

    /**
     * @dev Fungsi untuk withdraw dana oleh beneficiary
     * @param _amount Jumlah yang akan di-withdraw
     * @param _purpose Tujuan withdrawal
     */
    function withdraw(uint256 _amount, string memory _purpose)
        external
        onlyBeneficiary
    {
        require(_amount > 0, "Withdrawal amount must be greater than 0");
        require(
            address(this).balance >= _amount,
            "Insufficient balance in campaign"
        );
        require(bytes(_purpose).length > 0, "Purpose cannot be empty");

        // Simpan withdrawal ke array
        withdrawals.push(
            Withdrawal({
                amount: _amount,
                timestamp: block.timestamp,
                recipient: beneficiary,
                purpose: _purpose
            })
        );

        // Transfer dana
        (bool success, ) = beneficiary.call{value: _amount}("");
        require(success, "Transfer failed");

        // Emit event
        emit WithdrawalMade(_amount, block.timestamp, beneficiary, _purpose);
    }

    /**
     * @dev Fungsi untuk mengubah status campaign (aktif/tidak aktif)
     * @param _isActive Status baru campaign
     */
    function setCampaignStatus(bool _isActive) external onlyBeneficiary {
        isActive = _isActive;
        emit CampaignStatusChanged(_isActive);
    }

    /**
     * @dev Fungsi untuk mendapatkan balance campaign saat ini
     * @return Balance dalam wei
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Fungsi untuk mendapatkan jumlah total donasi yang tercatat
     * @return Jumlah donasi
     */
    function getDonationsCount() external view returns (uint256) {
        return donations.length;
    }

    /**
     * @dev Fungsi untuk mendapatkan jumlah total withdrawal yang tercatat
     * @return Jumlah withdrawal
     */
    function getWithdrawalsCount() external view returns (uint256) {
        return withdrawals.length;
    }

    /**
     * @dev Fungsi untuk mendapatkan informasi campaign
     * @return Tuple berisi informasi campaign
     */
    function getCampaignInfo()
        external
        view
        returns (
            string memory,
            string memory,
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        return (
            campaignName,
            description,
            beneficiary,
            goalAmount,
            totalDonations,
            address(this).balance,
            createdAt,
            isActive
        );
    }

    /**
     * @dev Fungsi untuk mendapatkan detail donasi berdasarkan index
     * @param _index Index donasi
     * @return Tuple berisi informasi donasi
     */
    function getDonation(uint256 _index)
        external
        view
        returns (
            address,
            uint256,
            uint256,
            string memory
        )
    {
        require(_index < donations.length, "Invalid donation index");
        Donation memory donation = donations[_index];
        return (
            donation.donor,
            donation.amount,
            donation.timestamp,
            donation.message
        );
    }

    /**
     * @dev Fungsi untuk mendapatkan detail withdrawal berdasarkan index
     * @param _index Index withdrawal
     * @return Tuple berisi informasi withdrawal
     */
    function getWithdrawal(uint256 _index)
        external
        view
        returns (
            uint256,
            uint256,
            address,
            string memory
        )
    {
        require(_index < withdrawals.length, "Invalid withdrawal index");
        Withdrawal memory withdrawal = withdrawals[_index];
        return (
            withdrawal.amount,
            withdrawal.timestamp,
            withdrawal.recipient,
            withdrawal.purpose
        );
    }

    /**
     * @dev Fungsi untuk mendapatkan progress campaign dalam persentase
     * @return Progress dalam basis 100 (contoh: 7500 = 75%)
     */
    function getProgress() external view returns (uint256) {
        if (goalAmount == 0) return 0;
        return (totalDonations * 10000) / goalAmount;
    }

    /**
     * @dev Fallback function untuk menerima ETH tanpa data
     */
    receive() external payable {
        require(isActive, "Campaign is not active");
        totalDonations += msg.value;
        donorContributions[msg.sender] += msg.value;

        donations.push(
            Donation({
                donor: msg.sender,
                amount: msg.value,
                timestamp: block.timestamp,
                message: ""
            })
        );

        emit DonationReceived(msg.sender, msg.value, block.timestamp, "");
    }
}

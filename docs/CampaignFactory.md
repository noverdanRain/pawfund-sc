# 🏭 CampaignFactory.sol - Dokumentasi Teknis

## 📑 Table of Contents

- [Overview](#overview)
- [State Variables](#state-variables)
  - [Public Arrays](#public-arrays)
  - [Public Mappings](#public-mappings)
- [Data Structures](#data-structures)
  - [Struct: CampaignMetadata](#struct-campaignmetadata)
- [Events](#events)
  - [event CampaignCreated](#event-campaigncreated)
- [Functions](#functions)
  - [1. createCampaign()](#1-createcampaign)
  - [2. getCampaignsCount()](#2-getcampaignscount-view)
  - [3. getAllCampaigns()](#3-getallcampaigns-view)
  - [4. getCampaignsByBeneficiary()](#4-getcampaignsbybeneficiary-view)
  - [5. getCampaignDetails()](#5-getcampaigndetails-view)
  - [6. getAllCampaignMetadata()](#6-getallcampaignmetadata-view)
  - [7. getActiveCampaigns()](#7-getactivecampaigns-view)
  - [8. getGlobalStatistics()](#8-getglobalstatistics-view)
  - [9. verifyCampaign()](#9-verifycampaign-view)
  - [10. getLatestCampaigns()](#10-getlatestcampaigns-view)
- [Security Considerations](#security-considerations)
- [Gas Optimization](#gas-optimization)
- [Upgrade Considerations](#upgrade-considerations)
- [Events for Off-Chain Indexing](#events-for-off-chain-indexing)
- [Testing Checklist](#testing-checklist)
- [Deployment](#deployment)
- [Frontend Integration](#frontend-integration)
- [Common Patterns](#common-patterns)
- [Known Limitations](#known-limitations)

---

## Overview

`CampaignFactory.sol` adalah factory contract yang bertanggung jawab untuk membuat (deploy) dan mengelola campaign-campaign donasi. Factory pattern ini memungkinkan pembuatan multiple campaign dengan cara yang terstandarisasi dan mudah ditrack.

---

## State Variables

### Public Arrays

#### `address[] public campaigns`
- **Tipe**: Dynamic array of addresses
- **Visibility**: `public`
- **Deskripsi**: Menyimpan semua address campaign yang pernah dibuat
- **Urutan**: Chronological (campaign pertama di index 0)
- **Akses**: Read-only via getter (tidak bisa diubah dari luar)
- **Update**: Push setiap kali campaign baru dibuat

**Auto-generated Getter:**
```solidity
function campaigns(uint256 index) external view returns (address);
```

**Contoh Penggunaan:**
```javascript
// Mendapatkan campaign pertama
const firstCampaign = await factory.read.campaigns([0n]);

// Mendapatkan campaign terakhir
const count = await factory.read.getCampaignsCount();
const lastCampaign = await factory.read.campaigns([count - 1n]);
```

---

### Public Mappings

#### `mapping(address => address[]) public campaignsByBeneficiary`
- **Tipe**: `mapping(address => address[])`
- **Visibility**: `public`
- **Deskripsi**: Mapping dari beneficiary address ke array campaign yang mereka miliki
- **Key**: Address beneficiary
- **Value**: Array dari campaign addresses
- **Update**: Push setiap kali campaign baru dibuat untuk beneficiary tersebut

**Use Case:**
- Dashboard beneficiary untuk melihat semua campaign mereka
- Filter campaign berdasarkan pemilik
- Analytics per beneficiary

**Auto-generated Getter:**
```solidity
function campaignsByBeneficiary(address beneficiary, uint256 index) 
    external view returns (address);
```

**Contoh:**
```javascript
// Mendapatkan semua campaign dari beneficiary
const campaigns = await factory.read.getCampaignsByBeneficiary([beneficiaryAddress]);

// Satu beneficiary bisa punya multiple campaigns
// 0xABC... => [0x111..., 0x222..., 0x333...]
```

#### `mapping(address => bool) public isCampaign`
- **Tipe**: `mapping(address => bool)`
- **Visibility**: `public`
- **Deskripsi**: Verifikasi apakah suatu address adalah campaign yang valid
- **Key**: Address campaign
- **Value**: `true` jika valid campaign, `false` jika bukan
- **Default**: `false` untuk address yang tidak terdaftar
- **Set**: Menjadi `true` saat campaign dibuat

**Use Case:**
- Validasi campaign sebelum interaksi
- Security check untuk fungsi-fungsi tertentu
- Mencegah interaksi dengan fake contracts

**Contoh:**
```javascript
const isValid = await factory.read.isCampaign([suspiciousAddress]);
if (isValid) {
  console.log("Valid campaign!");
} else {
  console.log("Not a registered campaign!");
}
```

---

## Data Structures

### Struct: `CampaignMetadata`

Struktur data untuk menyimpan metadata campaign yang penting.

```solidity
struct CampaignMetadata {
    address campaignAddress;    // Address campaign contract
    string name;                // Nama campaign
    address beneficiary;        // Pemilik campaign
    uint256 createdAt;          // Waktu pembuatan
    bool isActive;              // Status aktif/tidak
}
```

**Fields:**
- **`campaignAddress`** (`address`): Address dari campaign contract
- **`name`** (`string`): Nama campaign untuk display
- **`beneficiary`** (`address`): Address pemilik/penerima dana
- **`createdAt`** (`uint256`): Unix timestamp saat campaign dibuat
- **`isActive`** (`bool`): Status campaign (true = aktif, false = non-aktif)

**Digunakan di:**
- Function `getAllCampaignMetadata()` untuk return array metadata

**Kegunaan:**
- Efficient batch data retrieval
- Dashboard overview
- List view di frontend

**Contoh Array:**
```javascript
const metadata = await factory.read.getAllCampaignMetadata();
// Returns:
// [
//   {
//     campaignAddress: "0x111...",
//     name: "Save Dogs",
//     beneficiary: "0xABC...",
//     createdAt: 1729382400,
//     isActive: true
//   },
//   { ... }
// ]
```

---

## Events

### `event CampaignCreated`

```solidity
event CampaignCreated(
    address indexed campaignAddress,
    string name,
    address indexed beneficiary,
    uint256 goalAmount,
    uint256 timestamp
);
```

**Deskripsi**: Di-emit setiap kali campaign baru berhasil dibuat

**Parameters:**
- **`campaignAddress`** (indexed): Address campaign yang baru dibuat - bisa difilter
- **`name`**: Nama campaign
- **`beneficiary`** (indexed): Address beneficiary - bisa difilter
- **`goalAmount`**: Target donasi dalam wei
- **`timestamp`**: Waktu pembuatan campaign

**Indexed Parameters**: 2 dari 3 (maximum 3 indexed per event)
- ✅ `campaignAddress` - Filter campaign tertentu
- ✅ `beneficiary` - Filter campaign dari beneficiary tertentu
- ❌ `name`, `goalAmount`, `timestamp` - Stored in data field

**Di-emit di:**
- Function `createCampaign()`

**Use Case:**
- Real-time notification campaign baru
- Indexing untuk The Graph atau Alchemy
- Analytics tracking
- Frontend update automatic

**Event Listening Example:**
```javascript
// Listen to all campaign creations
factory.watchEvent.CampaignCreated({
  onLogs: (logs) => {
    logs.forEach(log => {
      console.log("New campaign:", log.args.name);
      console.log("Address:", log.args.campaignAddress);
      console.log("Goal:", formatEther(log.args.goalAmount));
    });
  }
});

// Filter by beneficiary
factory.watchEvent.CampaignCreated({
  args: { beneficiary: beneficiaryAddress },
  onLogs: (logs) => {
    console.log("New campaign from your address!");
  }
});
```

---

## Functions

### 1. `createCampaign()`

```solidity
function createCampaign(
    string memory _name,
    string memory _description,
    address _beneficiary,
    uint256 _goalAmount
) external returns (address)
```

**Deskripsi**: Membuat campaign baru dengan deploy Campaign contract

**Visibility**: `external`

**Returns**: `address` - Address dari campaign yang baru dibuat

**Parameters:**
- **`_name`**: Nama campaign (tidak boleh kosong)
- **`_description`**: Deskripsi lengkap campaign
- **`_beneficiary`**: Address yang akan menerima donasi
- **`_goalAmount`**: Target donasi dalam wei (harus > 0)

**Validations:**
```solidity
require(_beneficiary != address(0), "Invalid beneficiary address");
require(_goalAmount > 0, "Goal amount must be greater than 0");
require(bytes(_name).length > 0, "Campaign name cannot be empty");
```

**Process Flow:**
1. **Validate** semua input parameters
2. **Deploy** Campaign contract baru dengan `new Campaign(...)`
3. **Store** campaign address ke:
   - Array `campaigns`
   - Mapping `campaignsByBeneficiary[_beneficiary]`
   - Mapping `isCampaign[address] = true`
4. **Emit** event `CampaignCreated`
5. **Return** address campaign baru

**State Changes:**
- `campaigns.push(campaignAddress)`
- `campaignsByBeneficiary[_beneficiary].push(campaignAddress)`
- `isCampaign[campaignAddress] = true`

**Events Emitted:**
```solidity
emit CampaignCreated(
    campaignAddress,
    _name,
    _beneficiary,
    _goalAmount,
    block.timestamp
);
```

**Gas Cost**: ~2,000,000 - 2,500,000 gas
- Mahal karena deploy contract baru
- Deploy Campaign contract (~1,800,000 gas)
- Storage updates (~200,000 gas)

**Security:**
- ✅ Input validation lengkap
- ✅ Address zero check
- ✅ Amount validation
- ✅ String empty check

**Contoh Penggunaan:**
```javascript
const hash = await factory.write.createCampaign([
  "Save Street Dogs 2024",
  "Help us provide food and shelter for abandoned dogs",
  beneficiaryAddress,
  parseEther("10")  // Goal: 10 ETH
]);

await publicClient.waitForTransactionReceipt({ hash });

// Get the new campaign address
const campaigns = await factory.read.getAllCampaigns();
const newCampaignAddress = campaigns[campaigns.length - 1];
```

---

### 2. `getCampaignsCount()` (View)

```solidity
function getCampaignsCount() external view returns (uint256)
```

**Deskripsi**: Mendapatkan jumlah total campaign yang pernah dibuat

**Visibility**: `external`

**State Mutability**: `view`

**Returns**: `uint256` - Jumlah total campaign

**Implementation:**
```solidity
return campaigns.length;
```

**Use Case:**
- Display total campaigns di homepage
- Pagination calculation
- Analytics dashboard
- Loop control

**Gas Cost**: Minimal (hanya SLOAD)

**Contoh:**
```javascript
const count = await factory.read.getCampaignsCount();
console.log(`Total campaigns: ${count}`);

// For pagination
const pageSize = 10;
const totalPages = Math.ceil(Number(count) / pageSize);
```

---

### 3. `getAllCampaigns()` (View)

```solidity
function getAllCampaigns() external view returns (address[] memory)
```

**Deskripsi**: Mendapatkan array semua campaign addresses

**Returns**: `address[]` - Array berisi semua campaign addresses

**Implementation:**
```solidity
return campaigns;
```

**Use Case:**
- List semua campaigns
- Batch processing
- Complete dataset export

**Gas Consideration:**
- ⚠️ Bisa mahal jika campaigns sangat banyak (>100)
- Return data bisa besar
- Frontend bisa timeout untuk array sangat besar

**Recommendation:**
- Gunakan pagination untuk production
- Consider off-chain indexing (The Graph)
- Limit di frontend (ambil latest N campaigns)

**Contoh:**
```javascript
const allCampaigns = await factory.read.getAllCampaigns();
console.log(`Found ${allCampaigns.length} campaigns`);

// Iterate
for (const campaignAddress of allCampaigns) {
  const campaign = await viem.getContractAt("Campaign", campaignAddress);
  const info = await campaign.read.getCampaignInfo();
  console.log(info[0]); // campaign name
}
```

---

### 4. `getCampaignsByBeneficiary()` (View)

```solidity
function getCampaignsByBeneficiary(address _beneficiary) 
    external view returns (address[] memory)
```

**Deskripsi**: Filter campaigns berdasarkan beneficiary

**Parameters:**
- **`_beneficiary`**: Address beneficiary yang dicari

**Returns**: `address[]` - Array campaign addresses milik beneficiary tersebut

**Implementation:**
```solidity
return campaignsByBeneficiary[_beneficiary];
```

**Use Case:**
- Dashboard beneficiary ("My Campaigns")
- Filter campaigns by owner
- Beneficiary analytics

**Default**: Empty array jika beneficiary belum pernah buat campaign

**Contoh:**
```javascript
// Get all campaigns owned by specific address
const myCampaigns = await factory.read.getCampaignsByBeneficiary([
  userAddress
]);

if (myCampaigns.length > 0) {
  console.log(`You have ${myCampaigns.length} campaigns`);
  // Load details for each
} else {
  console.log("You haven't created any campaigns yet");
}
```

---

### 5. `getCampaignDetails()` (View)

```solidity
function getCampaignDetails(address _campaignAddress) external view returns (
    string memory name,
    string memory description,
    address beneficiary,
    uint256 goalAmount,
    uint256 totalDonations,
    uint256 balance,
    uint256 createdAt,
    bool isActive
)
```

**Deskripsi**: Mendapatkan detail lengkap campaign melalui factory

**Parameters:**
- **`_campaignAddress`**: Address campaign yang ingin di-query

**Validations:**
```solidity
require(isCampaign[_campaignAddress], "Invalid campaign address");
```

**Returns (Tuple):**
1. **`name`** - Nama campaign
2. **`description`** - Deskripsi campaign
3. **`beneficiary`** - Address beneficiary
4. **`goalAmount`** - Target donasi (wei)
5. **`totalDonations`** - Total donasi terkumpul (wei)
6. **`balance`** - Saldo saat ini (wei)
7. **`createdAt`** - Timestamp pembuatan
8. **`isActive`** - Status campaign

**Implementation:**
```solidity
Campaign campaign = Campaign(payable(_campaignAddress));
return campaign.getCampaignInfo();
```

**Use Case:**
- Verify campaign sebelum interact
- Get details tanpa tahu ABI Campaign
- Centralized query melalui factory

**External Calls**: 1 call ke Campaign contract

**Contoh:**
```javascript
try {
  const details = await factory.read.getCampaignDetails([campaignAddress]);
  console.log("Campaign Name:", details[0]);
  console.log("Goal:", formatEther(details[3]));
  console.log("Progress:", `${Number(details[4]) / Number(details[3]) * 100}%`);
} catch (error) {
  console.log("Not a valid campaign address");
}
```

---

### 6. `getAllCampaignMetadata()` (View)

```solidity
function getAllCampaignMetadata() external view returns (
    CampaignMetadata[] memory
)
```

**Deskripsi**: Batch retrieval metadata semua campaigns

**Returns**: `CampaignMetadata[]` - Array struct metadata

**Implementation:**
```solidity
CampaignMetadata[] memory metadata = new CampaignMetadata[](campaigns.length);

for (uint256 i = 0; i < campaigns.length; i++) {
    Campaign campaign = Campaign(payable(campaigns[i]));
    (string memory name, , address beneficiary, , , , uint256 createdAt, bool isActive) 
        = campaign.getCampaignInfo();
    
    metadata[i] = CampaignMetadata({
        campaignAddress: campaigns[i],
        name: name,
        beneficiary: beneficiary,
        createdAt: createdAt,
        isActive: isActive
    });
}

return metadata;
```

**Use Case:**
- Homepage campaign list
- Overview dashboard
- Export semua data
- Analytics

**Gas Consideration:**
- ⚠️ **EXPENSIVE** untuk banyak campaigns
- O(n) loops dengan external calls
- Each iteration calls `getCampaignInfo()`
- **Tidak recommended untuk >50 campaigns**

**Optimization Tips:**
```javascript
// ❌ Bad: Load semua sekaligus
const allMetadata = await factory.read.getAllCampaignMetadata();

// ✅ Better: Use pagination atau latest only
const latest = await factory.read.getLatestCampaigns([10n]);
// Then get metadata for those 10 only
```

**Production Alternative:**
- Use The Graph untuk indexing
- Cache di backend
- Pagination API

---

### 7. `getActiveCampaigns()` (View)

```solidity
function getActiveCampaigns() external view returns (address[] memory)
```

**Deskripsi**: Filter hanya campaigns yang aktif

**Returns**: `address[]` - Array campaign addresses yang `isActive = true`

**Implementation (Two-pass):**
```solidity
// Pass 1: Count active campaigns
uint256 activeCount = 0;
for (uint256 i = 0; i < campaigns.length; i++) {
    Campaign campaign = Campaign(payable(campaigns[i]));
    if (campaign.isActive()) {
        activeCount++;
    }
}

// Pass 2: Build array
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
```

**Complexity**: O(2n) - Two passes through array

**Use Case:**
- Homepage showing only active campaigns
- Filter untuk donation page
- Hide closed campaigns

**Gas Consideration:**
- ⚠️ **VERY EXPENSIVE** untuk banyak campaigns
- 2 loops + external call per iteration
- Not suitable untuk >50 campaigns

**Production Alternative:**
```javascript
// Better: Use events untuk track status changes
// Index off-chain dengan The Graph atau Alchemy
const { data } = await graphql(`
  query {
    campaigns(where: { isActive: true }) {
      id
      name
      beneficiary
    }
  }
`);
```

---

### 8. `getGlobalStatistics()` (View)

```solidity
function getGlobalStatistics() external view returns (
    uint256 totalCampaigns,
    uint256 activeCampaigns,
    uint256 totalDonationsAmount
)
```

**Deskripsi**: Aggregate statistics dari semua campaigns

**Returns (Tuple):**
1. **`totalCampaigns`** - Jumlah total campaign yang pernah dibuat
2. **`activeCampaigns`** - Jumlah campaign yang masih aktif
3. **`totalDonationsAmount`** - Akumulasi semua donasi (wei)

**Implementation:**
```solidity
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
```

**Complexity**: O(n) loop dengan 2 external calls per iteration

**Use Case:**
- Homepage hero stats
- Platform metrics
- Analytics dashboard
- Marketing materials

**Display Example:**
```javascript
const stats = await factory.read.getGlobalStatistics();

console.log(`📊 Platform Statistics:`);
console.log(`Total Campaigns: ${stats[0]}`);
console.log(`Active Campaigns: ${stats[1]}`);
console.log(`Total Raised: ${formatEther(stats[2])} ETH`);
console.log(`Success Rate: ${(Number(stats[1]) / Number(stats[0]) * 100).toFixed(1)}%`);
```

**Gas Consideration:**
- ⚠️ Expensive untuk banyak campaigns
- Consider caching hasil
- Update setiap N blocks atau on-demand

---

### 9. `verifyCampaign()` (View)

```solidity
function verifyCampaign(address _address) external view returns (bool)
```

**Deskripsi**: Verifikasi apakah address adalah campaign yang valid

**Parameters:**
- **`_address`**: Address yang akan diverifikasi

**Returns**: `bool` - `true` jika valid, `false` jika tidak

**Implementation:**
```solidity
return isCampaign[_address];
```

**Use Case:**
- Security check sebelum interact
- Validate user input
- Prevent scam/fake campaigns
- Frontend validation

**Gas Cost**: Minimal (1 SLOAD)

**Contoh:**
```javascript
// Before interacting with unknown address
const isLegit = await factory.read.verifyCampaign([userInputAddress]);

if (!isLegit) {
  alert("⚠️ This is not a valid campaign address!");
  return;
}

// Safe to proceed
const campaign = await viem.getContractAt("Campaign", userInputAddress);
```

---

### 10. `getLatestCampaigns()` (View)

```solidity
function getLatestCampaigns(uint256 _count) external view returns (
    address[] memory
)
```

**Deskripsi**: Mendapatkan N campaign terbaru

**Parameters:**
- **`_count`**: Jumlah campaign yang ingin diambil

**Returns**: `address[]` - Array campaign addresses (latest first)

**Implementation:**
```solidity
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
```

**Behavior:**
- Jika `_count > campaigns.length` → return semua campaigns
- Return dalam urutan chronological (oldest to newest dalam result)
- Start dari index `length - _count`

**Use Case:**
- Homepage "Latest Campaigns" section
- Pagination (newest first)
- Recent activity feed

**Gas**: Efficient - no external calls, simple array slice

**Contoh:**
```javascript
// Get 5 latest campaigns
const latest = await factory.read.getLatestCampaigns([5n]);

console.log("Latest Campaigns:");
for (let i = latest.length - 1; i >= 0; i--) {
  // Reverse order to show newest first
  const campaign = await viem.getContractAt("Campaign", latest[i]);
  const info = await campaign.read.getCampaignInfo();
  console.log(`${i + 1}. ${info[0]}`);
}
```

**Pagination Pattern:**
```javascript
const pageSize = 10;
const page = 1;  // 1-indexed

const totalCount = await factory.read.getCampaignsCount();
const offset = Number(totalCount) - (page * pageSize);
const count = pageSize;

const campaigns = await factory.read.getLatestCampaigns([BigInt(count)]);
```

---

## Security Considerations

### 1. **Input Validation**
```solidity
// ✅ Comprehensive validation di createCampaign
require(_beneficiary != address(0), "Invalid beneficiary address");
require(_goalAmount > 0, "Goal amount must be greater than 0");
require(bytes(_name).length > 0, "Campaign name cannot be empty");
```

### 2. **Campaign Verification**
```solidity
// ✅ Validation di getCampaignDetails
require(isCampaign[_campaignAddress], "Invalid campaign address");
```

Mencegah:
- Query ke arbitrary contracts
- Potential malicious calls
- Fake campaign scams

### 3. **No Owner/Admin**
- ✅ Factory contract tidak punya owner
- ✅ Tidak ada centralized control
- ✅ Fully decentralized
- ✅ Tidak bisa pause/shutdown campaigns

**Tradeoff:**
- ❌ Tidak bisa remove scam campaigns
- ❌ Tidak bisa emergency stop
- ✅ Trustless dan censorship-resistant

### 4. **Gas Limits**
⚠️ Loops bisa hit gas limit:
- `getAllCampaignMetadata()` - O(n) dengan external calls
- `getActiveCampaigns()` - O(2n) dengan external calls
- `getGlobalStatistics()` - O(n) dengan external calls

**Mitigation:**
- Use events untuk off-chain indexing
- Pagination
- The Graph subgraph

---

## Gas Optimization

### 1. **Storage Layout**
```solidity
// Current layout is optimal
address[] public campaigns;                          // Dynamic array
mapping(address => address[]) public campaignsByBeneficiary;  // Nested dynamic
mapping(address => bool) public isCampaign;          // Simple mapping
```

### 2. **Avoid Expensive Loops**
```solidity
// ❌ Expensive: Multiple loops dengan external calls
function getActiveCampaigns() external view returns (address[] memory)

// ✅ Better: Use event indexing
event CampaignCreated(...);
event CampaignStatusChanged(address indexed campaign, bool isActive);
```

### 3. **Batch Operations**
```solidity
// ❌ Bad: Call getCampaignDetails multiple times
for (address in campaigns) {
    await factory.read.getCampaignDetails([address]);
}

// ✅ Good: Use getAllCampaignMetadata once (jika tidak terlalu banyak)
const metadata = await factory.read.getAllCampaignMetadata();
```

---

## Upgrade Considerations

**Current Status**: Contract is **immutable** (tidak upgradeable)

**Pros:**
- ✅ Simple dan secure
- ✅ No admin key risk
- ✅ Trustless
- ✅ Transparent untuk users

**Cons:**
- ❌ Cannot fix bugs
- ❌ Cannot add features
- ❌ Cannot optimize gas

**For Production:**
Consider using:
- UUPS Proxy pattern
- Transparent Proxy
- Diamond pattern (EIP-2535)

**Example Upgrade Path:**
```solidity
// V2 could add:
- function pauseCampaign(address campaign) external onlyOwner
- function updateFee(uint256 newFee) external onlyOwner
- function emergencyWithdraw() external onlyOwner
```

---

## Events for Off-Chain Indexing

### The Graph Subgraph Example

```graphql
type Campaign @entity {
  id: ID!
  address: Bytes!
  name: String!
  beneficiary: Bytes!
  goalAmount: BigInt!
  createdAt: BigInt!
  isActive: Boolean!
  totalDonations: BigInt!
}

type CampaignCreated @entity {
  id: ID!
  campaign: Campaign!
  name: String!
  beneficiary: Bytes!
  goalAmount: BigInt!
  timestamp: BigInt!
}
```

### Subgraph Mapping
```typescript
export function handleCampaignCreated(event: CampaignCreated): void {
  let campaign = new Campaign(event.params.campaignAddress.toHex());
  campaign.address = event.params.campaignAddress;
  campaign.name = event.params.name;
  campaign.beneficiary = event.params.beneficiary;
  campaign.goalAmount = event.params.goalAmount;
  campaign.createdAt = event.params.timestamp;
  campaign.isActive = true;
  campaign.save();
}
```

---

## Testing Checklist

- [ ] Create campaign dengan parameter valid
- [ ] Create campaign dengan zero address (should fail)
- [ ] Create campaign dengan zero goal (should fail)
- [ ] Create campaign dengan empty name (should fail)
- [ ] Get campaigns count
- [ ] Get all campaigns
- [ ] Get campaigns by beneficiary
- [ ] Get campaign details untuk valid campaign
- [ ] Get campaign details untuk invalid address (should fail)
- [ ] Verify valid campaign
- [ ] Verify invalid address
- [ ] Get active campaigns
- [ ] Get latest campaigns
- [ ] Get global statistics
- [ ] Event emission pada campaign creation
- [ ] Multiple campaigns dari same beneficiary
- [ ] Campaign registry integrity

---

## Deployment

### Deployment Script
```javascript
import hre from "hardhat";

async function main() {
  console.log("Deploying CampaignFactory...");
  
  const factory = await hre.viem.deployContract("CampaignFactory");
  
  console.log(`✅ CampaignFactory deployed to: ${factory.address}`);
  
  // Verify on Etherscan
  await hre.run("verify:verify", {
    address: factory.address,
    constructorArguments: [],
  });
}

main().catch(console.error);
```

### No Constructor Arguments
- Factory contract tidak memerlukan constructor arguments
- Deployment simple dan straightforward
- Tidak ada initial configuration

---

## Frontend Integration

### Complete Integration Example

```javascript
import { createPublicClient, createWalletClient, http } from "viem";
import { mainnet } from "viem/chains";

// Initialize clients
const publicClient = createPublicClient({
  chain: mainnet,
  transport: http()
});

const walletClient = createWalletClient({
  chain: mainnet,
  transport: http()
});

// Factory contract
const FACTORY_ADDRESS = "0x...";
const factoryAbi = [...]; // Import from artifacts

// 1. Create a campaign
async function createCampaign() {
  const hash = await walletClient.writeContract({
    address: FACTORY_ADDRESS,
    abi: factoryAbi,
    functionName: "createCampaign",
    args: [
      "Save Street Dogs",
      "Help us feed stray dogs",
      beneficiaryAddress,
      parseEther("10")
    ]
  });
  
  await publicClient.waitForTransactionReceipt({ hash });
  
  // Get new campaign address from events
  const logs = await publicClient.getLogs({
    address: FACTORY_ADDRESS,
    event: {
      name: "CampaignCreated",
      inputs: [...]
    },
    fromBlock: "latest"
  });
  
  const campaignAddress = logs[0].args.campaignAddress;
  return campaignAddress;
}

// 2. Load campaigns for homepage
async function loadHomepage() {
  // Get stats
  const stats = await publicClient.readContract({
    address: FACTORY_ADDRESS,
    abi: factoryAbi,
    functionName: "getGlobalStatistics"
  });
  
  // Get latest campaigns
  const latest = await publicClient.readContract({
    address: FACTORY_ADDRESS,
    abi: factoryAbi,
    functionName: "getLatestCampaigns",
    args: [10n]
  });
  
  return { stats, latest };
}

// 3. Load user's campaigns
async function loadMyDashboard(userAddress) {
  const myCampaigns = await publicClient.readContract({
    address: FACTORY_ADDRESS,
    abi: factoryAbi,
    functionName: "getCampaignsByBeneficiary",
    args: [userAddress]
  });
  
  // Load details for each
  const details = await Promise.all(
    myCampaigns.map(address => 
      publicClient.readContract({
        address: FACTORY_ADDRESS,
        abi: factoryAbi,
        functionName: "getCampaignDetails",
        args: [address]
      })
    )
  );
  
  return details;
}

// 4. Watch for new campaigns
function watchNewCampaigns(callback) {
  return publicClient.watchContractEvent({
    address: FACTORY_ADDRESS,
    abi: factoryAbi,
    eventName: "CampaignCreated",
    onLogs: (logs) => {
      logs.forEach(log => {
        callback({
          address: log.args.campaignAddress,
          name: log.args.name,
          beneficiary: log.args.beneficiary,
          goal: log.args.goalAmount
        });
      });
    }
  });
}
```

---

## Common Patterns

### Pattern 1: Discovery Flow
```
User → Factory.getLatestCampaigns() 
     → Display list
     → User clicks campaign
     → Campaign.getCampaignInfo()
     → Show details
```

### Pattern 2: Creation Flow
```
User → Fill form
     → Factory.createCampaign()
     → Wait for tx
     → Listen CampaignCreated event
     → Redirect to new campaign page
```

### Pattern 3: Dashboard Flow
```
User connects wallet
     → Factory.getCampaignsByBeneficiary(userAddress)
     → Load details for each
     → Display "My Campaigns"
```

---

## Known Limitations

### 1. **No Pagination on-chain**
- `getAllCampaigns()` returns full array
- Can be gas-heavy for many campaigns
- Frontend should implement pagination

### 2. **No Campaign Removal**
- Once created, campaigns cannot be deleted
- Scam campaigns stay in registry
- Mitigation: UI filtering, community reporting

### 3. **No Fee Mechanism**
- Factory doesn't charge fees
- Could be added in V2 for sustainability

### 4. **No Search/Filter on-chain**
- No search by name
- No category filtering
- Must implement off-chain

---

**Contract Version**: 1.0  
**Solidity Version**: ^0.8.28  
**License**: MIT  
**Dependencies**: Campaign.sol

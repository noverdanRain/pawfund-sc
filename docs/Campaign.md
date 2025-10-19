# 📄 Campaign.sol - Dokumentasi Teknis

## 📑 Table of Contents

- [Overview](#overview)
- [State Variables](#state-variables)
  - [Public Variables](#public-variables)
- [Data Structures](#data-structures)
  - [Struct: Donation](#struct-donation)
  - [Struct: Withdrawal](#struct-withdrawal)
- [Storage Arrays](#storage-arrays)
- [Mappings](#mappings)
- [Events](#events)
  - [event DonationReceived](#event-donationreceived)
  - [event WithdrawalMade](#event-withdrawalmade)
  - [event CampaignStatusChanged](#event-campaignstatuschanged)
- [Modifiers](#modifiers)
  - [onlyBeneficiary](#modifier-onlybeneficiary)
  - [onlyActive](#modifier-onlyactive)
  - [onlyFactory](#modifier-onlyfactory)
- [Constructor](#constructor)
- [Functions](#functions)
  - [1. donate()](#1-donate)
  - [2. withdraw()](#2-withdraw)
  - [3. setCampaignStatus()](#3-setcampaignstatus)
  - [4. getBalance()](#4-getbalance-view)
  - [5. getDonationsCount()](#5-getdonationscount-view)
  - [6. getWithdrawalsCount()](#6-getwithdrawalscount-view)
  - [7. getCampaignInfo()](#7-getcampaigninfo-view)
  - [8. getDonation()](#8-getdonation-view)
  - [9. getWithdrawal()](#9-getwithdrawal-view)
  - [10. getProgress()](#10-getprogress-view)
  - [11. receive()](#11-receive-payable-fallback)
- [Security Considerations](#security-considerations)
- [Gas Optimization Tips](#gas-optimization-tips)
- [Testing Checklist](#testing-checklist)
- [Deployment](#deployment)
- [Frontend Integration Example](#frontend-integration-example)

---

## Overview

`Campaign.sol` adalah smart contract untuk campaign donasi individual. Setiap campaign yang dibuat melalui `CampaignFactory` akan memiliki instance contract ini sendiri. Contract ini mengelola donasi, withdrawal, dan tracking untuk satu campaign donasi hewan.

---

## State Variables

### Public Variables

#### `string public campaignName`
- **Tipe**: `string`
- **Visibility**: `public`
- **Deskripsi**: Nama campaign donasi
- **Contoh**: `"Save Street Dogs"`
- **Set di**: Constructor (immutable setelah deployment)

#### `string public description`
- **Tipe**: `string`
- **Visibility**: `public`
- **Deskripsi**: Deskripsi lengkap tentang campaign
- **Contoh**: `"Help us provide food and medical care for street dogs"`
- **Set di**: Constructor (immutable setelah deployment)

#### `address public beneficiary`
- **Tipe**: `address`
- **Visibility**: `public`
- **Deskripsi**: Address yang berhak menerima dana dari campaign
- **Validasi**: Tidak boleh address(0)
- **Set di**: Constructor (immutable setelah deployment)
- **Akses khusus**: Hanya beneficiary yang bisa `withdraw()` dan `setCampaignStatus()`

#### `uint256 public goalAmount`
- **Tipe**: `uint256`
- **Visibility**: `public`
- **Deskripsi**: Target donasi dalam satuan wei
- **Contoh**: `10000000000000000000` (10 ETH)
- **Validasi**: Harus lebih dari 0
- **Set di**: Constructor (immutable setelah deployment)

#### `uint256 public totalDonations`
- **Tipe**: `uint256`
- **Visibility**: `public`
- **Deskripsi**: Total akumulasi donasi yang pernah diterima (dalam wei)
- **Inisialisasi**: `0`
- **Update**: Setiap kali ada donasi masuk
- **Catatan**: Nilai ini tidak berkurang saat withdrawal (untuk tracking total yang pernah masuk)

#### `uint256 public createdAt`
- **Tipe**: `uint256`
- **Visibility**: `public`
- **Deskripsi**: Timestamp saat campaign dibuat (Unix timestamp)
- **Set di**: Constructor dengan `block.timestamp`
- **Contoh**: `1729382400` (19 Oktober 2025)

#### `bool public isActive`
- **Tipe**: `bool`
- **Visibility**: `public`
- **Deskripsi**: Status aktif/non-aktif campaign
- **Inisialisasi**: `true`
- **Update**: Melalui `setCampaignStatus()` oleh beneficiary
- **Efek**: Campaign non-aktif tidak bisa menerima donasi

#### `address public factory`
- **Tipe**: `address`
- **Visibility**: `public`
- **Deskripsi**: Address dari CampaignFactory yang membuat campaign ini
- **Set di**: Constructor (`msg.sender` saat deployment)
- **Fungsi**: Untuk verifikasi dan tracking

---

## Data Structures

### Struct: `Donation`

Struktur data untuk menyimpan informasi setiap donasi.

```solidity
struct Donation {
    address donor;        // Address yang melakukan donasi
    uint256 amount;       // Jumlah donasi dalam wei
    uint256 timestamp;    // Waktu donasi (Unix timestamp)
    string message;       // Pesan dari donor (opsional)
}
```

**Fields:**
- **`donor`** (`address`): Address wallet yang melakukan donasi
- **`amount`** (`uint256`): Jumlah ETH yang didonasikan dalam wei
- **`timestamp`** (`uint256`): Waktu transaksi donasi menggunakan `block.timestamp`
- **`message`** (`string`): Pesan atau ucapan dari donor (bisa kosong)

**Digunakan di:**
- Array `donations[]`
- Function `donate()`
- Function `receive()`
- Function `getDonation()`

**Contoh:**
```solidity
Donation({
    donor: 0x123...,
    amount: 1000000000000000000,  // 1 ETH
    timestamp: 1729382400,
    message: "Semoga sukses campaign-nya!"
})
```

### Struct: `Withdrawal`

Struktur data untuk menyimpan informasi setiap withdrawal.

```solidity
struct Withdrawal {
    uint256 amount;       // Jumlah yang di-withdraw dalam wei
    uint256 timestamp;    // Waktu withdrawal (Unix timestamp)
    address recipient;    // Penerima dana (selalu beneficiary)
    string purpose;       // Tujuan withdrawal
}
```

**Fields:**
- **`amount`** (`uint256`): Jumlah ETH yang ditarik dalam wei
- **`timestamp`** (`uint256`): Waktu transaksi withdrawal
- **`recipient`** (`address`): Address penerima (selalu sama dengan `beneficiary`)
- **`purpose`** (`string`): Penjelasan tujuan penggunaan dana (wajib diisi)

**Digunakan di:**
- Array `withdrawals[]`
- Function `withdraw()`
- Function `getWithdrawal()`

**Contoh:**
```solidity
Withdrawal({
    amount: 2000000000000000000,  // 2 ETH
    timestamp: 1729382400,
    recipient: 0x456...,
    purpose: "Membeli makanan dan obat-obatan hewan"
})
```

---

## Storage Arrays

### `Donation[] public donations`
- **Tipe**: Array dinamis dari struct `Donation`
- **Deskripsi**: Menyimpan history semua donasi yang pernah diterima
- **Akses**: Public (auto-generated getter untuk index tertentu)
- **Push**: Setiap kali ada donasi baru
- **Ukuran**: Tidak terbatas (dinamis)
- **Gas**: Bertambah seiring jumlah donasi

**Contoh Penggunaan:**
```solidity
uint256 count = donations.length;  // Jumlah total donasi
Donation memory firstDonation = donations[0];  // Donasi pertama
```

### `Withdrawal[] public withdrawals`
- **Tipe**: Array dinamis dari struct `Withdrawal`
- **Deskripsi**: Menyimpan history semua withdrawal yang pernah dilakukan
- **Akses**: Public (auto-generated getter untuk index tertentu)
- **Push**: Setiap kali beneficiary melakukan withdrawal
- **Ukuran**: Tidak terbatas (dinamis)

---

## Mappings

### `mapping(address => uint256) public donorContributions`
- **Tipe**: `mapping(address => uint256)`
- **Deskripsi**: Tracking total kontribusi setiap donor
- **Key**: Address donor
- **Value**: Total donasi dalam wei dari address tersebut
- **Update**: Setiap kali donor melakukan donasi (akumulatif)
- **Default**: `0` untuk address yang belum pernah donasi

**Contoh:**
```solidity
// Donor 0x123... sudah donasi 2 kali: 1 ETH + 0.5 ETH
donorContributions[0x123...] = 1500000000000000000;  // 1.5 ETH total
```

**Kegunaan:**
- Menampilkan "top donors"
- Memberikan badge/reward untuk donor besar
- Analytics per donor

---

## Events

### `event DonationReceived`

```solidity
event DonationReceived(
    address indexed donor,
    uint256 amount,
    uint256 timestamp,
    string message
);
```

**Deskripsi**: Di-emit setiap kali campaign menerima donasi

**Parameters:**
- **`donor`** (indexed): Address yang melakukan donasi (bisa difilter)
- **`amount`**: Jumlah donasi dalam wei
- **`timestamp`**: Waktu donasi
- **`message`**: Pesan dari donor

**Di-emit di:**
- Function `donate()`
- Function `receive()`

**Use Case:**
- Frontend real-time notification
- Off-chain indexing (The Graph, Alchemy)
- Analytics dan reporting

### `event WithdrawalMade`

```solidity
event WithdrawalMade(
    uint256 amount,
    uint256 timestamp,
    address indexed recipient,
    string purpose
);
```

**Deskripsi**: Di-emit setiap kali beneficiary melakukan withdrawal

**Parameters:**
- **`amount`**: Jumlah yang ditarik dalam wei
- **`timestamp`**: Waktu withdrawal
- **`recipient`** (indexed): Address penerima (beneficiary)
- **`purpose`**: Tujuan penggunaan dana

**Di-emit di:**
- Function `withdraw()`

**Use Case:**
- Transparency untuk donors
- Audit trail
- Notification untuk followers campaign

### `event CampaignStatusChanged`

```solidity
event CampaignStatusChanged(bool isActive);
```

**Deskripsi**: Di-emit saat status campaign berubah (aktif/non-aktif)

**Parameters:**
- **`isActive`**: Status baru campaign (true = aktif, false = non-aktif)

**Di-emit di:**
- Function `setCampaignStatus()`

**Use Case:**
- Update UI status campaign
- Notification campaign ditutup/dibuka kembali

---

## Modifiers

### `modifier onlyBeneficiary()`

```solidity
modifier onlyBeneficiary() {
    require(msg.sender == beneficiary, "Only beneficiary can call this");
    _;
}
```

**Deskripsi**: Membatasi akses hanya untuk beneficiary

**Validasi**: `msg.sender` harus sama dengan `beneficiary`

**Error**: `"Only beneficiary can call this"`

**Digunakan di:**
- `withdraw()`
- `setCampaignStatus()`

### `modifier onlyActive()`

```solidity
modifier onlyActive() {
    require(isActive, "Campaign is not active");
    _;
}
```

**Deskripsi**: Memastikan campaign dalam status aktif

**Validasi**: `isActive` harus `true`

**Error**: `"Campaign is not active"`

**Digunakan di:**
- `donate()`
- `receive()`

### `modifier onlyFactory()`

```solidity
modifier onlyFactory() {
    require(msg.sender == factory, "Only factory can call this");
    _;
}
```

**Deskripsi**: Membatasi akses hanya untuk factory contract

**Status**: Currently unused (reserved untuk future features)

**Potensi Penggunaan:**
- Factory-initiated campaign closure
- Batch operations
- Emergency functions

---

## Constructor

```solidity
constructor(
    string memory _name,
    string memory _description,
    address _beneficiary,
    uint256 _goalAmount
)
```

**Deskripsi**: Inisialisasi campaign baru. Dipanggil oleh CampaignFactory saat deployment.

**Parameters:**
- **`_name`**: Nama campaign (tidak boleh kosong)
- **`_description`**: Deskripsi campaign
- **`_beneficiary`**: Address penerima dana (tidak boleh address(0))
- **`_goalAmount`**: Target donasi dalam wei (harus > 0)

**Validations:**
```solidity
require(_beneficiary != address(0), "Invalid beneficiary address");
require(_goalAmount > 0, "Goal amount must be greater than 0");
require(bytes(_name).length > 0, "Campaign name cannot be empty");
```

**Inisialisasi:**
- `campaignName = _name`
- `description = _description`
- `beneficiary = _beneficiary`
- `goalAmount = _goalAmount`
- `createdAt = block.timestamp`
- `isActive = true`
- `factory = msg.sender` (address CampaignFactory)
- `totalDonations = 0`

**Gas Cost**: ~2,000,000 gas (deployment contract baru)

---

## Functions

### 1. `donate()`

```solidity
function donate(string memory _message) external payable onlyActive
```

**Deskripsi**: Menerima donasi dengan pesan opsional

**Visibility**: `external`

**Payable**: ✅ Ya (menerima ETH)

**Modifiers**: `onlyActive`

**Parameters:**
- **`_message`**: Pesan dari donor (bisa kosong string)

**Validations:**
```solidity
require(msg.value > 0, "Donation amount must be greater than 0");
require(isActive, "Campaign is not active");  // dari modifier
```

**State Changes:**
1. `totalDonations += msg.value`
2. `donorContributions[msg.sender] += msg.value`
3. Push `Donation` ke array `donations`

**Events Emitted:**
- `DonationReceived(msg.sender, msg.value, block.timestamp, _message)`

**Gas Cost**: ~100,000 gas (tergantung panjang message)

**Contoh Penggunaan:**
```javascript
// Donasi 1 ETH dengan pesan
await campaign.write.donate(
  ["Semoga sukses!"], 
  { value: parseEther("1") }
);
```

---

### 2. `withdraw()`

```solidity
function withdraw(uint256 _amount, string memory _purpose) 
    external 
    onlyBeneficiary
```

**Deskripsi**: Withdraw dana oleh beneficiary

**Visibility**: `external`

**Modifiers**: `onlyBeneficiary`

**Parameters:**
- **`_amount`**: Jumlah yang akan ditarik (dalam wei)
- **`_purpose`**: Tujuan penggunaan dana (wajib diisi)

**Validations:**
```solidity
require(_amount > 0, "Withdrawal amount must be greater than 0");
require(address(this).balance >= _amount, "Insufficient balance in campaign");
require(bytes(_purpose).length > 0, "Purpose cannot be empty");
require(msg.sender == beneficiary, "Only beneficiary can call this");  // dari modifier
```

**State Changes:**
1. Push `Withdrawal` ke array `withdrawals`

**External Calls:**
```solidity
(bool success, ) = beneficiary.call{value: _amount}("");
require(success, "Transfer failed");
```

**Events Emitted:**
- `WithdrawalMade(_amount, block.timestamp, beneficiary, _purpose)`

**Security Pattern**: 
- ✅ CEI Pattern (Checks-Effects-Interactions)
- State update sebelum external call
- Reentrancy-safe

**Gas Cost**: ~80,000 gas

**Contoh Penggunaan:**
```javascript
await campaign.write.withdraw(
  [parseEther("2"), "Membeli makanan hewan"],
  { account: beneficiaryAccount }
);
```

---

### 3. `setCampaignStatus()`

```solidity
function setCampaignStatus(bool _isActive) external onlyBeneficiary
```

**Deskripsi**: Mengubah status campaign (aktif/non-aktif)

**Visibility**: `external`

**Modifiers**: `onlyBeneficiary`

**Parameters:**
- **`_isActive`**: Status baru (true = aktif, false = non-aktif)

**State Changes:**
1. `isActive = _isActive`

**Events Emitted:**
- `CampaignStatusChanged(_isActive)`

**Use Case:**
- Menutup campaign yang sudah mencapai goal
- Emergency pause
- Temporary closure

**Gas Cost**: ~30,000 gas

---

### 4. `getBalance()` (View)

```solidity
function getBalance() external view returns (uint256)
```

**Deskripsi**: Mendapatkan saldo ETH campaign saat ini

**Visibility**: `external`

**State Mutability**: `view`

**Returns**: `uint256` - Balance dalam wei

**Implementation:**
```solidity
return address(this).balance;
```

**Catatan**: 
- `getBalance()` bisa berbeda dengan `totalDonations` jika ada withdrawal
- Formula: `balance = totalDonations - totalWithdrawals`

---

### 5. `getDonationsCount()` (View)

```solidity
function getDonationsCount() external view returns (uint256)
```

**Deskripsi**: Mendapatkan jumlah total donasi yang tercatat

**Returns**: `uint256` - Jumlah entries di array `donations`

**Implementation:**
```solidity
return donations.length;
```

---

### 6. `getWithdrawalsCount()` (View)

```solidity
function getWithdrawalsCount() external view returns (uint256)
```

**Deskripsi**: Mendapatkan jumlah total withdrawal yang tercatat

**Returns**: `uint256` - Jumlah entries di array `withdrawals`

**Implementation:**
```solidity
return withdrawals.length;
```

---

### 7. `getCampaignInfo()` (View)

```solidity
function getCampaignInfo() external view returns (
    string memory,   // campaignName
    string memory,   // description
    address,         // beneficiary
    uint256,         // goalAmount
    uint256,         // totalDonations
    uint256,         // balance
    uint256,         // createdAt
    bool             // isActive
)
```

**Deskripsi**: Mendapatkan semua informasi penting campaign dalam satu call

**Returns (Tuple):**
1. **`campaignName`** - Nama campaign
2. **`description`** - Deskripsi campaign
3. **`beneficiary`** - Address beneficiary
4. **`goalAmount`** - Target donasi (wei)
5. **`totalDonations`** - Total donasi yang pernah masuk (wei)
6. **`balance`** - Saldo saat ini (wei)
7. **`createdAt`** - Timestamp pembuatan
8. **`isActive`** - Status campaign

**Use Case:**
- Dashboard campaign
- Summary display
- Efisien untuk frontend (1 call vs 8 calls)

**Contoh Penggunaan:**
```javascript
const info = await campaign.read.getCampaignInfo();
console.log("Name:", info[0]);
console.log("Goal:", info[3]);
console.log("Progress:", (Number(info[4]) / Number(info[3]) * 100).toFixed(2) + "%");
```

---

### 8. `getDonation()` (View)

```solidity
function getDonation(uint256 _index) external view returns (
    address,      // donor
    uint256,      // amount
    uint256,      // timestamp
    string memory // message
)
```

**Deskripsi**: Mendapatkan detail donasi berdasarkan index

**Parameters:**
- **`_index`**: Index donasi di array (0-based)

**Validations:**
```solidity
require(_index < donations.length, "Invalid donation index");
```

**Returns (Tuple):**
1. **`donor`** - Address donor
2. **`amount`** - Jumlah donasi (wei)
3. **`timestamp`** - Waktu donasi
4. **`message`** - Pesan donor

**Contoh:**
```javascript
const donation = await campaign.read.getDonation([0]);
console.log("First donor:", donation[0]);
console.log("Amount:", formatEther(donation[1]));
```

---

### 9. `getWithdrawal()` (View)

```solidity
function getWithdrawal(uint256 _index) external view returns (
    uint256,      // amount
    uint256,      // timestamp
    address,      // recipient
    string memory // purpose
)
```

**Deskripsi**: Mendapatkan detail withdrawal berdasarkan index

**Parameters:**
- **`_index`**: Index withdrawal di array (0-based)

**Validations:**
```solidity
require(_index < withdrawals.length, "Invalid withdrawal index");
```

**Returns (Tuple):**
1. **`amount`** - Jumlah withdrawal (wei)
2. **`timestamp`** - Waktu withdrawal
3. **`recipient`** - Address penerima
4. **`purpose`** - Tujuan penggunaan

---

### 10. `getProgress()` (View)

```solidity
function getProgress() external view returns (uint256)
```

**Deskripsi**: Menghitung progress campaign dalam basis points

**Returns**: `uint256` - Progress dalam basis points (10000 = 100%)

**Implementation:**
```solidity
if (goalAmount == 0) return 0;
return (totalDonations * 10000) / goalAmount;
```

**Penjelasan Perhitungan:**

Menggunakan **Basis Points** karena Solidity tidak support floating point.

**Formula:**
```
Progress = (totalDonations * 10000) / goalAmount
```

**Contoh:**
- Goal: 10 ETH
- Donasi: 7.5 ETH
- Progress: `(7.5 * 10000) / 10 = 7500`
- **Artinya: 75.00%**

**Conversion ke Persentase:**
```javascript
const progress = await campaign.read.getProgress();
const percentage = Number(progress) / 100;  // 7500 / 100 = 75.00%
console.log(`Progress: ${percentage}%`);
```

**Basis Points System:**
| Value | Persentase |
|-------|-----------|
| 10000 | 100.00% |
| 7550 | 75.50% |
| 5000 | 50.00% |
| 1234 | 12.34% |
| 0 | 0.00% |

**Edge Case:**
- Jika `goalAmount = 0` → return `0` (mencegah division by zero)

---

### 11. `receive()` (Payable Fallback)

```solidity
receive() external payable
```

**Deskripsi**: Fallback function untuk menerima ETH tanpa data

**Visibility**: `external`

**Payable**: ✅ Ya

**Triggered**: Saat ETH dikirim langsung tanpa calldata

**Validations:**
```solidity
require(isActive, "Campaign is not active");
```

**State Changes:**
1. `totalDonations += msg.value`
2. `donorContributions[msg.sender] += msg.value`
3. Push `Donation` dengan `message = ""`

**Events Emitted:**
- `DonationReceived(msg.sender, msg.value, block.timestamp, "")`

**Use Case:**
- Plain ETH transfer dari wallet
- Transfer dari exchange
- Donasi tanpa message

**Contoh:**
```javascript
// Kirim ETH langsung ke campaign address
await donor.sendTransaction({
  to: campaignAddress,
  value: parseEther("0.5")
});
```

---

## Security Considerations

### 1. **Reentrancy Protection**
- ✅ CEI Pattern (Checks-Effects-Interactions)
- State changes sebelum external calls
- Withdrawal pattern aman

### 2. **Access Control**
- ✅ Modifier `onlyBeneficiary` untuk fungsi sensitive
- ✅ Modifier `onlyActive` untuk donation control
- ✅ Clear error messages

### 3. **Integer Overflow**
- ✅ Solidity 0.8.x built-in overflow protection
- ✅ Tidak perlu SafeMath

### 4. **Input Validation**
- ✅ Address validation (tidak boleh zero address)
- ✅ Amount validation (harus > 0)
- ✅ String validation (tidak boleh empty untuk yang wajib)

### 5. **Transfer Safety**
- ✅ Menggunakan `call` instead of `transfer`
- ✅ Check return value dari `call`
- ✅ Forward semua gas

---

## Gas Optimization Tips

### 1. **Storage vs Memory**
```solidity
// ✅ Good: Direct access untuk simple calculation
return (totalDonations * 10000) / goalAmount;

// ❌ Bad: Unnecessary memory copy
uint256 total = totalDonations;  // Extra SLOAD
uint256 goal = goalAmount;       // Extra SLOAD
return (total * 10000) / goal;
```

### 2. **Array Iterations**
- `donations.length` dan `withdrawals.length` bisa tumbuh besar
- Hindari iterasi penuh di on-chain
- Gunakan event indexing untuk off-chain query

### 3. **String Storage**
- String disimpan sebagai dynamic array
- Lebih expensive daripada fixed types
- Tradeoff: Fleksibilitas vs Gas cost

---

## Testing Checklist

- [ ] Constructor validation (zero address, zero goal, empty name)
- [ ] Donation dengan message
- [ ] Donation tanpa message (receive)
- [ ] Donation ke inactive campaign (should fail)
- [ ] Withdrawal oleh beneficiary
- [ ] Withdrawal oleh non-beneficiary (should fail)
- [ ] Withdrawal melebihi balance (should fail)
- [ ] Change status oleh beneficiary
- [ ] Change status oleh non-beneficiary (should fail)
- [ ] Progress calculation accuracy
- [ ] Multiple donations tracking
- [ ] Multiple withdrawals tracking
- [ ] Event emission
- [ ] Donor contributions tracking

---

## Deployment

**Deployed By**: CampaignFactory contract

**Deployment Flow:**
```solidity
Campaign newCampaign = new Campaign(name, description, beneficiary, goal);
```

**Immutable After Deployment:**
- `campaignName`
- `description`
- `beneficiary`
- `goalAmount`
- `factory`
- `createdAt`

**Mutable:**
- `isActive` (via `setCampaignStatus`)
- `totalDonations` (via donations)
- `donations[]` array
- `withdrawals[]` array
- `donorContributions` mapping

---

## Frontend Integration Example

```javascript
import { parseEther, formatEther } from "viem";

// Get campaign info
const info = await campaign.read.getCampaignInfo();
const progress = await campaign.read.getProgress();

console.log({
  name: info[0],
  goal: formatEther(info[3]),
  raised: formatEther(info[4]),
  balance: formatEther(info[5]),
  progress: `${Number(progress) / 100}%`,
  isActive: info[7]
});

// Make donation
const hash = await campaign.write.donate(
  ["Great cause!"],
  { value: parseEther("0.1") }
);

// Listen to donations
campaign.watchEvent.DonationReceived({
  onLogs: (logs) => {
    console.log("New donation!", logs);
  }
});
```

---

**Contract Version**: 1.0  
**Solidity Version**: ^0.8.28  
**License**: MIT

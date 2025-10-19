# 📚 PawFund Smart Contracts - Dokumentasi

Selamat datang di dokumentasi lengkap untuk smart contracts PawFund. Dokumentasi ini memberikan penjelasan detail tentang setiap komponen dari platform donasi berbasis blockchain untuk hewan.

---

## 📋 Daftar Isi

### 1. Contract Documentation
- **[Campaign.sol](./Campaign.md)** - Contract untuk campaign donasi individual
- **[CampaignFactory.sol](./CampaignFactory.md)** - Factory contract untuk membuat dan mengelola campaigns

### 2. Technical Concepts
- **[Basis Points Explained](./BASIS_POINTS.md)** - Penjelasan sistem basis points untuk progress calculation

### 3. Architecture
- **[ARCHITECTURE.md](../ARCHITECTURE.md)** - Arsitektur sistem dan design patterns

### 4. General
- **[README.md](../README.md)** - Getting started dan usage guide

---

## 🎯 Quick Navigation

### Untuk Developer yang Ingin:

#### **Memahami Contract Campaign**
→ Baca [Campaign.sol Documentation](./Campaign.md)
- Semua state variables dan fungsinya
- Event logging sistem
- Security considerations
- Gas optimization tips

#### **Memahami Contract Factory**
→ Baca [CampaignFactory.sol Documentation](./CampaignFactory.md)
- Cara membuat campaign baru
- Query dan filtering campaigns
- Global statistics
- Integration patterns

#### **Memahami Arsitektur Keseluruhan**
→ Baca [ARCHITECTURE.md](../ARCHITECTURE.md)
- Design patterns yang digunakan
- Data flow diagram
- Security best practices
- Upgrade considerations

#### **Mulai Development**
→ Baca [README.md](../README.md)
- Installation guide
- Compile dan testing
- Deployment instructions
- Usage examples

---

## 🔍 Quick Reference

### Campaign.sol - Key Functions

| Function | Description | Access |
|----------|-------------|--------|
| `donate(string message)` | Terima donasi dengan pesan | External (payable) |
| `withdraw(uint256 amount, string purpose)` | Withdraw dana | Beneficiary only |
| `setCampaignStatus(bool isActive)` | Ubah status campaign | Beneficiary only |
| `getCampaignInfo()` | Get info lengkap campaign | View (public) |
| `getProgress()` | Hitung progress dalam basis points | View (public) |
| `getDonation(uint256 index)` | Detail donasi tertentu | View (public) |

### CampaignFactory.sol - Key Functions

| Function | Description | Access |
|----------|-------------|--------|
| `createCampaign(...)` | Buat campaign baru | External |
| `getAllCampaigns()` | Semua campaign addresses | View (public) |
| `getCampaignsByBeneficiary(address)` | Filter by beneficiary | View (public) |
| `getActiveCampaigns()` | Hanya campaign aktif | View (public) |
| `getGlobalStatistics()` | Stats platform | View (public) |
| `verifyCampaign(address)` | Validasi campaign | View (public) |

---

## 📊 Data Structures Overview

### Campaign Structs

```solidity
struct Donation {
    address donor;
    uint256 amount;
    uint256 timestamp;
    string message;
}

struct Withdrawal {
    uint256 amount;
    uint256 timestamp;
    address recipient;
    string purpose;
}
```

### Factory Structs

```solidity
struct CampaignMetadata {
    address campaignAddress;
    string name;
    address beneficiary;
    uint256 createdAt;
    bool isActive;
}
```

---

## 🔐 Security Highlights

### Campaign.sol
- ✅ CEI Pattern (Checks-Effects-Interactions)
- ✅ Access control dengan modifiers
- ✅ Input validation lengkap
- ✅ Reentrancy-safe withdrawal
- ✅ Safe ETH transfer dengan `call`

### CampaignFactory.sol
- ✅ Campaign verification system
- ✅ Input validation untuk campaign creation
- ✅ No centralized admin control
- ✅ Immutable deployment

---

## 💡 Common Use Cases

### 1. Membuat Campaign Baru
```javascript
const hash = await factory.write.createCampaign([
  "Save Street Dogs",
  "Help us provide food for stray dogs",
  beneficiaryAddress,
  parseEther("10")
]);
```

### 2. Melakukan Donasi
```javascript
await campaign.write.donate(
  ["Keep up the good work!"],
  { value: parseEther("1") }
);
```

### 3. Withdraw Dana
```javascript
await campaign.write.withdraw(
  [parseEther("2"), "Buying dog food"],
  { account: beneficiaryAccount }
);
```

### 4. Mendapatkan Campaign Info
```javascript
const info = await campaign.read.getCampaignInfo();
const progress = await campaign.read.getProgress();
```

---

## 📈 Gas Costs Reference

| Operation | Estimated Gas | Notes |
|-----------|---------------|-------|
| Create Campaign | ~2,000,000 | Deploy new contract |
| Donate | ~100,000 | Include message storage |
| Withdraw | ~80,000 | ETH transfer |
| Change Status | ~30,000 | State update only |
| Get Campaign Info | Minimal | View function |
| Get All Campaigns | Variable | Depends on count |

---

## 🧪 Testing

Semua contracts dilengkapi dengan comprehensive test suite:

```bash
# Run all tests
npx hardhat test

# Run with gas reporting
REPORT_GAS=true npx hardhat test

# Run specific test file
npx hardhat test test/PawFund.test.ts
```

Test coverage meliputi:
- ✅ Unit tests untuk setiap function
- ✅ Integration tests
- ✅ Error handling tests
- ✅ Access control tests
- ✅ Edge cases

---

## 🚀 Deployment Guide

### Local Development
```bash
# Terminal 1: Start local node
npx hardhat node

# Terminal 2: Deploy
npx hardhat run scripts/deploy-pawfund.ts --network localhost
```

### Testnet (Sepolia)
```bash
# Set variables
npx hardhat vars set SEPOLIA_RPC_URL
npx hardhat vars set SEPOLIA_PRIVATE_KEY

# Deploy
npx hardhat run scripts/deploy-pawfund.ts --network sepolia
```

### With Hardhat Ignition
```bash
npx hardhat ignition deploy ignition/modules/CampaignFactory.ts --network localhost
```

---

## 🔗 External Resources

### Solidity Documentation
- [Solidity Docs](https://docs.soliditylang.org/)
- [Solidity by Example](https://solidity-by-example.org/)

### Development Tools
- [Hardhat Documentation](https://hardhat.org/docs)
- [Viem Documentation](https://viem.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)

### Testing & Security
- [Hardhat Testing Guide](https://hardhat.org/tutorial/testing-contracts)
- [Smart Contract Security Best Practices](https://consensys.github.io/smart-contract-best-practices/)

---

## 📝 Version History

### Version 1.0 (Current)
- ✅ Campaign contract dengan donation dan withdrawal
- ✅ CampaignFactory dengan registry system
- ✅ Event logging untuk transparency
- ✅ Comprehensive test suite
- ✅ Full documentation

### Planned for V2
- [ ] Multi-signature withdrawal
- [ ] Campaign categories
- [ ] Platform fee system
- [ ] Milestone-based funding
- [ ] NFT rewards untuk donors

---

## 🤝 Contributing

Untuk kontribusi atau pertanyaan:
1. Baca dokumentasi lengkap di folder `docs/`
2. Check existing issues di repository
3. Submit pull request dengan test lengkap
4. Follow coding standards dan best practices

---

## 📧 Support

Untuk pertanyaan teknis atau bantuan:
- Buka issue di GitHub repository
- Baca dokumentasi lengkap terlebih dahulu
- Check common issues dan solutions

---

## 📄 License

MIT License - See LICENSE file for details

---

**Last Updated**: October 19, 2025  
**Solidity Version**: ^0.8.28  
**Hardhat Version**: 3.0.7

---

## 📖 Documentation Structure

```
docs/
├── README.md                    # Dokumen ini (index)
├── Campaign.md                  # Campaign.sol documentation
├── CampaignFactory.md          # CampaignFactory.sol documentation
└── BASIS_POINTS.md             # Basis points explanation

Root/
├── ARCHITECTURE.md             # System architecture
├── README.md                   # Getting started guide
├── contracts/
│   ├── Campaign.sol
│   └── CampaignFactory.sol
├── test/
│   └── PawFund.test.ts
└── scripts/
    ├── deploy-pawfund.ts
    └── interact-pawfund.ts
```

---

**Dibuat dengan ❤️ untuk membantu hewan yang membutuhkan** 🐾

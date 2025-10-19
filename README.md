# 🐾 PawFund - Platform Donasi untuk Hewan

Platform donasi berbasis smart contract Ethereum untuk membantu hewan yang membutuhkan.

## 📋 Fitur

- ✅ Buat campaign donasi untuk hewan
- ✅ Terima donasi dengan pesan dari donor
- ✅ Withdraw dana dengan transparansi penuh
- ✅ Tracking lengkap semua transaksi
- ✅ Progress monitoring real-time

## � Struktur Project

```
pawfund-sc/
├── contracts/
│   ├── Campaign.sol          # Contract campaign donasi individual
│   └── CampaignFactory.sol   # Factory untuk membuat campaigns
└── docs/
    ├── Campaign.md           # Dokumentasi Campaign.sol
    ├── CampaignFactory.md    # Dokumentasi CampaignFactory.sol
    └── BASIS_POINTS.md       # Penjelasan sistem basis points
```

## 🚀 Quick Start

### Compile Contracts

Anda bisa compile contracts menggunakan:

**Remix IDE** (Recommended untuk pemula):
1. Buka [Remix IDE](https://remix.ethereum.org)
2. Copy-paste `Campaign.sol` dan `CampaignFactory.sol`
3. Compile dengan compiler version `0.8.28`

**Foundry**:
```bash
forge build
```

**Hardhat**:
```bash
npx hardhat compile
```

### Deploy Contracts

**Via Remix IDE**:
1. Deploy `CampaignFactory.sol` terlebih dahulu
2. Copy address factory yang sudah di-deploy
3. Gunakan factory untuk membuat campaigns

**Via Foundry**:
```bash
forge create CampaignFactory --rpc-url <RPC_URL> --private-key <PRIVATE_KEY>
```

## 📝 Cara Penggunaan

### 1. Buat Campaign Baru
```javascript
const hash = await factory.write.createCampaign([
  "Save Street Dogs",           // nama campaign
  "Help feed stray dogs",       // deskripsi
  beneficiaryAddress,           // address penerima dana
  parseEther("10")              // target: 10 ETH
]);
```

### 2. Donasi ke Campaign
```javascript
await campaign.write.donate(
  ["Semoga sukses!"],
  { value: parseEther("1") }    // donasi 1 ETH
);
```

### 3. Withdraw Dana (Beneficiary)
```javascript
await campaign.write.withdraw(
  [parseEther("2"), "Beli makanan hewan"],
  { account: beneficiaryAccount }
);
```

### 4. Cek Progress Campaign
```javascript
const progress = await campaign.read.getProgress();
const percentage = Number(progress) / 100;  // basis points to %
console.log(`Progress: ${percentage}%`);
```

## 🏗️ Smart Contracts

### Campaign.sol
Contract untuk campaign donasi individual dengan fitur:
- Terima donasi dengan pesan
- Withdraw untuk beneficiary
- History donasi dan withdrawal
- Progress tracking

**Key Functions:**
- `donate(string message)` - Terima donasi
- `withdraw(uint256 amount, string purpose)` - Withdraw dana
- `getCampaignInfo()` - Info lengkap campaign
- `getProgress()` - Progress dalam basis points

### CampaignFactory.sol
Factory contract untuk membuat dan mengelola campaigns:
- Deploy campaign baru
- Registry semua campaign
- Filter dan query campaigns
- Global statistics

**Key Functions:**
- `createCampaign(...)` - Buat campaign baru
- `getAllCampaigns()` - Semua campaign addresses
- `getCampaignsByBeneficiary(address)` - Filter by owner
- `getActiveCampaigns()` - Campaign yang aktif

## 📚 Dokumentasi Lengkap

Untuk dokumentasi detail, lihat folder `/docs`:
- [Campaign.sol Documentation](./docs/Campaign.md)
- [CampaignFactory.sol Documentation](./docs/CampaignFactory.md)
- [Basis Points Explained](./docs/BASIS_POINTS.md)
- [Architecture Guide](./ARCHITECTURE.md)

## 🔧 Development Tools

Project ini compatible dengan:
- ✅ **Remix IDE** - Untuk testing dan deployment cepat
- ✅ **Foundry** - Untuk development dan testing advanced
- ✅ **Hardhat** - Untuk integration testing
- ✅ **Truffle** - Untuk migration dan deployment

## 🛠️ Tech Stack

- **Solidity**: ^0.8.28
- **License**: MIT
- **Network**: Ethereum & EVM-compatible chains

## 📄 License

MIT License

---

**Dibuat dengan ❤️ untuk membantu hewan yang membutuhkan** 🐾

# 🐾 PawFund - Platform Donasi untuk Hewan

Platform donasi berbasis smart contract Ethereum untuk membantu hewan yang membutuhkan.

## 📋 Fitur

- ✅ Buat campaign donasi untuk hewan
- ✅ Terima donasi dengan pesan dari donor
- ✅ Withdraw dana dengan transparansi penuh
- ✅ Tracking lengkap semua transaksi
- ✅ Progress monitoring real-time

## 🚀 Quick Start

### Install Dependencies
```bash
npm install
```

### Compile Contracts
```bash
npx hardhat compile
```

### Run Tests
```bash
npx hardhat test
```

## 💻 Development

### Deploy ke Local Network

Terminal 1 - Jalankan node:
```bash
npx hardhat node
```

Terminal 2 - Deploy contracts:
```bash
npx hardhat run scripts/deploy-pawfund.ts --network localhost
```

### Deploy ke Sepolia Testnet

Set environment variables:
```bash
npx hardhat vars set SEPOLIA_RPC_URL
npx hardhat vars set SEPOLIA_PRIVATE_KEY
```

Deploy:
```bash
npx hardhat run scripts/deploy-pawfund.ts --network sepolia
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

### CampaignFactory.sol
Factory contract untuk membuat dan mengelola campaigns:
- Deploy campaign baru
- Registry semua campaign
- Filter dan query campaigns
- Global statistics

## 📚 Dokumentasi Lengkap

Untuk dokumentasi detail, lihat folder `/docs`:
- [Campaign.sol Documentation](./docs/Campaign.md)
- [CampaignFactory.sol Documentation](./docs/CampaignFactory.md)
- [Basis Points Explained](./docs/BASIS_POINTS.md)
- [Architecture Guide](./ARCHITECTURE.md)

## 🧪 Testing

```bash
# Run all tests
npx hardhat test

# With gas reporting
REPORT_GAS=true npx hardhat test
```

## 🛠️ Tech Stack

- **Solidity**: ^0.8.28
- **Hardhat**: 3.0.7
- **Viem**: 2.x
- **TypeScript**: ~5.8.0

## 📄 License

MIT License

---

**Dibuat dengan ❤️ untuk membantu hewan yang membutuhkan** 🐾

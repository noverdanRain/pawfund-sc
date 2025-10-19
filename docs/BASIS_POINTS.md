# 🔢 Basis Points Explained - Progress Calculation dalam Solidity

## Masalah: Solidity Tidak Mendukung Floating Point

Solidity **tidak mendukung** tipe data desimal (float/double). Semua perhitungan menggunakan **integer**.

### Contoh Masalah

```solidity
// ❌ TIDAK BISA seperti ini!
uint256 progress = (totalDonations / goalAmount) * 100;

// Jika totalDonations = 7.5 ETH dan goalAmount = 10 ETH
// Expected: 7.5 / 10 * 100 = 75%
// Actual: 7 / 10 * 100 = 0 (integer division!)
```

**Kenapa hasilnya 0?**
- `7.5 / 10 = 0.75` 
- Dalam integer division: `7 / 10 = 0` (sisa diabaikan!)
- `0 * 100 = 0`

---

## Solusi: Basis Points (Multiply Before Divide)

### Formula Standard

```solidity
// ✅ SOLUSI: Kalikan dulu, baru bagi
return (totalDonations * 10000) / goalAmount;
```

**Kenapa 10000?**
- `10000` disebut **"basis points"** atau **"basis 10000"**
- Memberikan presisi 2 desimal (0.01%)
- Standard dalam financial calculations

---

## Cara Kerja Basis Points

### Konsep

| Basis | Presisi | Contoh |
|-------|---------|--------|
| 100 | 1% (bulat) | 75 = 75% |
| 1000 | 0.1% (1 desimal) | 755 = 75.5% |
| **10000** | **0.01% (2 desimal)** | **7550 = 75.50%** |
| 100000 | 0.001% (3 desimal) | 75500 = 75.500% |

### Perhitungan Detail

**Skenario:**
- Goal: 10 ETH = 10,000,000,000,000,000,000 wei
- Donasi: 7.5 ETH = 7,500,000,000,000,000,000 wei

**Step-by-step:**

```solidity
// Step 1: Kalikan dengan 10000 dulu
totalDonations * 10000 = 7,500,000,000,000,000,000 * 10000
                       = 75,000,000,000,000,000,000,000

// Step 2: Baru bagi dengan goalAmount
75,000,000,000,000,000,000,000 / 10,000,000,000,000,000,000
= 7,500

// Result: 7500 basis points = 75.00%
```

**Konversi ke Persentase:**
```javascript
const basisPoints = 7500;
const percentage = basisPoints / 100;  // 75.00%
```

---

## Contoh-contoh Perhitungan

### Contoh 1: Progress 50%

```solidity
Goal: 10 ETH
Donasi: 5 ETH

Progress = (5 * 10000) / 10
        = 50,000 / 10
        = 5,000 basis points
        = 50.00%
```

### Contoh 2: Progress 12.34%

```solidity
Goal: 100 ETH
Donasi: 12.34 ETH

Progress = (12.34 * 10000) / 100
        = 123,400 / 100
        = 1,234 basis points
        = 12.34%
```

### Contoh 3: Progress Over 100%

```solidity
Goal: 10 ETH
Donasi: 15 ETH (melebihi target!)

Progress = (15 * 10000) / 10
        = 150,000 / 10
        = 15,000 basis points
        = 150.00%
```

### Contoh 4: Progress Kecil (0.05%)

```solidity
Goal: 1000 ETH
Donasi: 0.5 ETH

Progress = (0.5 * 10000) / 1000
        = 5,000 / 1000
        = 5 basis points
        = 0.05%
```

---

## Implementation di PawFund

### Smart Contract (Solidity)

```solidity
/**
 * @dev Fungsi untuk mendapatkan progress campaign dalam basis points
 * @return Progress dalam basis points (10000 = 100%)
 * Contoh: 7500 = 75.00%, 1234 = 12.34%, 10000 = 100.00%
 */
function getProgress() external view returns (uint256) {
    if (goalAmount == 0) return 0;  // Prevent division by zero
    return (totalDonations * 10000) / goalAmount;
}
```

### Frontend (JavaScript/TypeScript)

```javascript
import { formatEther } from "viem";

// Get progress dari contract
const basisPoints = await campaign.read.getProgress();

// Convert ke persentase
const percentage = Number(basisPoints) / 100;

console.log(`Progress: ${percentage}%`);
// Output: "Progress: 75.50%"

// Untuk display dengan 2 desimal
console.log(`Progress: ${percentage.toFixed(2)}%`);
// Output: "Progress: 75.50%"
```

### Display di UI

```typescript
interface CampaignProgress {
  raised: bigint;
  goal: bigint;
  progress: bigint;  // basis points
}

function ProgressBar({ campaign }: { campaign: CampaignProgress }) {
  const percentage = Number(campaign.progress) / 100;
  const raised = formatEther(campaign.raised);
  const goal = formatEther(campaign.goal);
  
  return (
    <div>
      <div className="progress-bar">
        <div 
          className="progress-fill" 
          style={{ width: `${Math.min(percentage, 100)}%` }}
        />
      </div>
      <p>{percentage.toFixed(2)}% - {raised} / {goal} ETH</p>
    </div>
  );
}
```

---

## Kenapa Tidak Pakai Basis Lain?

### Basis 100 (Persentase Bulat)

```solidity
return (totalDonations * 100) / goalAmount;
```

**❌ Masalah:**
- Tidak ada desimal
- `75.50%` → `75%` (kehilangan 0.5%)
- Kurang presisi

### Basis 1000 (1 Desimal)

```solidity
return (totalDonations * 1000) / goalAmount;
```

**⚠️ Cukup untuk beberapa kasus:**
- Presisi 0.1%
- `75.5%` → `755`
- Tapi kurang untuk financial calculations

### Basis 10000 (2 Desimal) ✅

```solidity
return (totalDonations * 10000) / goalAmount;
```

**✅ Sweet Spot:**
- Presisi 2 desimal (0.01%)
- Standard dalam DeFi
- Balance antara presisi dan gas cost
- `75.50%` → `7550`

### Basis 1000000 (4 Desimal)

```solidity
return (totalDonations * 1000000) / goalAmount;
```

**⚠️ Over-engineering:**
- Presisi sangat tinggi (0.0001%)
- Gas cost lebih mahal (bigger numbers)
- Tidak perlu untuk donation tracking

---

## Perbandingan Sistem Basis

| Goal | Donasi | Basis 100 | Basis 1000 | Basis 10000 | Actual % |
|------|--------|-----------|------------|-------------|----------|
| 10 ETH | 7.5 ETH | 75 | 750 | 7500 | 75.00% |
| 10 ETH | 7.55 ETH | 75 | 755 | 7550 | 75.50% |
| 10 ETH | 7.556 ETH | 75 | 755 | 7556 | 75.56% |
| 100 ETH | 12.34 ETH | 12 | 123 | 1234 | 12.34% |
| 1000 ETH | 0.5 ETH | 0 | 0 | 5 | 0.05% |

---

## Edge Cases

### 1. Division by Zero

```solidity
function getProgress() external view returns (uint256) {
    if (goalAmount == 0) return 0;  // ✅ Handle edge case
    return (totalDonations * 10000) / goalAmount;
}
```

### 2. Overflow (Solidity 0.8.x)

```solidity
// Solidity 0.8.x memiliki built-in overflow protection
// Jika calculation overflow, transaction akan revert

// Maximum safe values:
// totalDonations * 10000 < 2^256
// totalDonations < 2^256 / 10000
// = 11,579,208,923,731,619,542,357,098,500,868,790,785,326,998,466,564,056,403,945 wei
// ≈ 1.16 × 10^59 ETH (practically impossible to reach!)
```

### 3. Progress > 100%

```solidity
// Jika donasi melebihi goal
Goal: 10 ETH
Donasi: 15 ETH

Progress = 15,000 basis points = 150%

// Frontend bisa handle:
const displayProgress = Math.min(percentage, 100);  // Cap at 100%
// Atau show actual: "150% - Goal exceeded! 🎉"
```

---

## Alternative Approaches

### Approach 1: Return Numerator & Denominator

```solidity
function getProgressRatio() external view returns (uint256 numerator, uint256 denominator) {
    return (totalDonations, goalAmount);
}

// Frontend calculate
const progress = (numerator / denominator) * 100;
```

**❌ Cons:**
- Frontend must handle calculation
- Inconsistent across different frontends
- More complex for users

### Approach 2: Return Percentage String

```solidity
// ❌ TIDAK BISA di Solidity! (No string manipulation)
function getProgress() external view returns (string memory) {
    // Cannot do: return "75.50%"
}
```

### Approach 3: Fixed Point Library

```solidity
import "@prb/math/contracts/PRBMathUD60x18.sol";

function getProgress() external view returns (uint256) {
    return PRBMathUD60x18.div(totalDonations, goalAmount);
}
```

**⚠️ Cons:**
- Extra dependency
- More gas expensive
- Over-engineered untuk simple percentage

---

## Best Practices

### 1. ✅ Document Clearly

```solidity
/**
 * @return Progress dalam basis points (10000 = 100%)
 * Contoh: 7500 = 75.00%, 1234 = 12.34%
 * Untuk convert ke %: divide by 100
 */
function getProgress() external view returns (uint256)
```

### 2. ✅ Consistent Conversion

```javascript
// Helper function untuk consistency
function basisPointsToPercentage(bp: bigint): number {
  return Number(bp) / 100;
}

// Use everywhere
const progress = basisPointsToPercentage(await campaign.read.getProgress());
```

### 3. ✅ Display dengan Format yang Jelas

```typescript
function formatProgress(basisPoints: bigint): string {
  const percentage = Number(basisPoints) / 100;
  return `${percentage.toFixed(2)}%`;
}

console.log(formatProgress(7550n));  // "75.50%"
console.log(formatProgress(1234n));  // "12.34%"
console.log(formatProgress(10000n)); // "100.00%"
```

---

## Summary

### Kenapa Pakai Basis Points?

1. **Solidity limitations**: Tidak ada floating point
2. **Presisi**: 2 desimal cukup untuk most use cases
3. **Standard**: Widely used dalam DeFi dan finance
4. **Gas efficient**: Balance antara presisi dan cost
5. **Simple conversion**: Divide by 100 untuk get percentage

### Formula

```
Progress (basis points) = (Amount Raised × 10000) ÷ Goal Amount
Percentage = Basis Points ÷ 100
```

### Konversi Cepat

| Basis Points | Persentase |
|--------------|-----------|
| 10000 | 100.00% |
| 7500 | 75.00% |
| 5000 | 50.00% |
| 2500 | 25.00% |
| 1234 | 12.34% |
| 100 | 1.00% |
| 10 | 0.10% |
| 1 | 0.01% |
| 0 | 0.00% |

---

**Reference**: [Basis Point - Wikipedia](https://en.wikipedia.org/wiki/Basis_point)  
**DeFi Examples**: Uniswap, Aave, Compound all use basis points  
**Solidity Version**: ^0.8.28

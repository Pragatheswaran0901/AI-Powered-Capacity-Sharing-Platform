# Mach-Hunt: Explainable Matching Engine Specification

## 1. Mathematical Scoring Formula

The Mach-Hunt capacity matching engine computes a deterministic, reproducible match score between a Seeker's Manufacturing Requirement ($R$) and a Provider's Listed Machine ($M$):

$$\text{Match Score} = (S_{\text{capability}} \times 0.40) + (S_{\text{availability}} \times 0.20) + (S_{\text{distance}} \times 0.15) + (S_{\text{cost}} \times 0.15) + (S_{\text{reliability}} \times 0.10)$$

Where each component score $S \in [0.0, 1.0]$. The overall percentage returned to the user is:
$$\text{Match Percentage} = \text{round}(\text{Match Score} \times 100)$$

---

## 2. Component Scoring Breakdown

### 2.1 Capability Match ($S_{\text{capability}}$, Weight: 40%)

Manufacturing processes and materials are mapped hierarchically.

$$S_{\text{capability}} = (S_{\text{process}} \times 0.60) + (S_{\text{material}} \times 0.25) + (S_{\text{tolerance}} \times 0.15)$$

1. **Process Match ($S_{\text{process}}$)**:
   - **1.0**: Exact match (e.g., Requirement asks for "CNC Milling" and Machine supports "CNC Milling" or "5-Axis CNC Milling").
   - **0.75**: Compatible super-process (e.g., Requirement asks for "Milling" and Machine supports "CNC Milling").
   - **0.0**: Incompatible process (e.g., Requirement asks for "Laser Cutting" and Machine is a "Lathe"). *Hard disqualification or 0 score.*

2. **Material Match ($S_{\text{material}}$)**:
   - **1.0**: Material explicitly listed in machine supported materials (e.g., "Aluminium 6061", "Stainless Steel 304").
   - **0.5**: Broad material category match (e.g., "Aluminium" vs "Aluminium Alloy").
   - **0.0**: Material not supported (e.g., attempting Titanium on a light-duty machine).

3. **Tolerance & Dimensional Envelope ($S_{\text{tolerance}}$)**:
   - If machine precision $\le$ requirement tolerance (e.g., Machine holds $\pm 0.01$ mm and Requirement needs $\pm 0.05$ mm): **1.0**.
   - If machine work envelope $(X, Y, Z)$ exceeds requirement part dimensions: **1.0**, else penalty or **0.0**.

---

### 2.2 Availability Match ($S_{\text{availability}}$, Weight: 20%)

Evaluates whether the machine has sufficient unbooked, non-maintenance production hours between the Seeker's required start date and delivery deadline.

$$\text{Estimated Job Production Hours} = \max\left(1, \frac{\text{Quantity}}{\text{Throughput Rate}}\right)$$

1. **Date Window Feasibility**:
   - Let $H_{\text{available}}$ be the sum of free operational hours recorded in `machine_availabilities` between $[D_{\text{start}}, D_{\text{deadline}}]$.
   - If $H_{\text{available}} \ge \text{Estimated Job Production Hours}$:
     $$S_{\text{availability}} = 0.8 + 0.2 \times \min\left(1.0, \frac{H_{\text{available}}}{2 \times \text{Estimated Job Production Hours}}\right)$$
   - If $0 < H_{\text{available}} < \text{Estimated Job Production Hours}$:
     $$S_{\text{availability}} = 0.5 \times \left(\frac{H_{\text{available}}}{\text{Estimated Job Production Hours}}\right)$$
   - If machine is blocked or in maintenance throughout the period:
     $$S_{\text{availability}} = 0.0$$

---

### 2.3 Distance Match ($S_{\text{distance}}$, Weight: 15%)

Computes true orthodromic distance via the **Haversine Formula**:

$$a = \sin^2\left(\frac{\Delta \phi}{2}\right) + \cos(\phi_1) \cos(\phi_2) \sin^2\left(\frac{\Delta \lambda}{2}\right)$$
$$d = 2 R \cdot \arcsin\left(\sqrt{a}\right)$$
where $R = 6371\text{ km}$, $\phi$ is latitude in radians, and $\lambda$ is longitude in radians.

Let $D_{\max}$ be the seeker's preferred search radius (defaulting to 100 km if unspecified):
- If $d \le 10\text{ km}$: $S_{\text{distance}} = 1.0$ (immediate local cluster).
- If $10\text{ km} < d \le D_{\max}$:
  $$S_{\text{distance}} = 1.0 - 0.7 \times \left(\frac{d - 10}{D_{\max} - 10}\right)$$
- If $d > D_{\max}$:
  $$S_{\text{distance}} = \max\left(0.1, 0.3 \times \left(1.0 - \frac{d - D_{\max}}{D_{\max}}\right)\right)$$

---

### 2.4 Cost Match ($S_{\text{cost}}$, Weight: 15%)

Compares the estimated total cost of manufacturing against the seeker's budget.

$$\text{Estimated Total Cost} = \max(\text{Machine Minimum Job Value}, \text{Machine Hourly Rate} \times \text{Estimated Hours})$$

- If $\text{Estimated Total Cost} \le \text{Budget}$:
  - If cost is between $60\%$ and $95\%$ of budget: $S_{\text{cost}} = 1.0$ (optimal economic fit).
  - If cost is $< 50\%$ of budget: $S_{\text{cost}} = 0.9$ (favorable pricing).
- If $\text{Estimated Total Cost} > \text{Budget}$:
  - Let $\text{Overrun Ratio} = \frac{\text{Estimated Total Cost} - \text{Budget}}{\text{Budget}}$.
  - If $\text{Overrun Ratio} \le 0.20$ (up to 20% over budget):
    $$S_{\text{cost}} = 1.0 - (2.5 \times \text{Overrun Ratio})$$
  - If $\text{Overrun Ratio} > 0.40$:
    $$S_{\text{cost}} = 0.0$$

---

### 2.5 Reliability & Trust Match ($S_{\text{reliability}}$, Weight: 10%)

Derived from verified platform metrics and past execution history:

$$S_{\text{reliability}} = (S_{\text{rating}} \times 0.50) + (S_{\text{completed\_jobs}} \times 0.30) + (S_{\text{verification}} \times 0.20)$$

1. **Rating Score ($S_{\text{rating}}$)**:
   - Normalized average rating: $\frac{\text{Average Stars}}{5.0}$ (unrated new providers default to $0.70$ Bayesian prior).
2. **Completed Jobs Score ($S_{\text{completed\_jobs}}$)**:
   - $\min\left(1.0, \frac{\text{Completed Orders}}{20}\right)$
3. **Verification Badge ($S_{\text{verification}}$)**:
   - $1.0$ if Business is Government/GSTIN verified, $0.5$ if pending verification.

---

## 3. Explainability Generation (Transparent Reasoning)

For every candidate match, the engine produces explicit bulleted explanations:

| Metric | Threshold | Generated Explanation |
| :--- | :--- | :--- |
| **Capability** | $S_{\text{capability}} \ge 0.85$ | `✓ Exact match for CNC Milling and Aluminium 6061 alloy` |
| **Tolerance** | $S_{\text{tolerance}} = 1.0$ | `✓ Precision capability (±0.01 mm) meets your ±0.05 mm requirement` |
| **Availability**| $S_{\text{availability}} \ge 0.80$ | `✓ 24+ available machine hours before deadline of Oct 15` |
| **Distance** | $d < 15\text{ km}$ | `✓ Located 4.2 km away in Ganapathy Industrial Estate` |
| **Cost** | Cost $\le$ Budget | `✓ Estimated job cost ₹18,500 is within your ₹25,000 budget` |
| **Reliability** | Verified & Rating $\ge 4.5$ | `✓ Verified MSME with 4.8★ average rating across 19 completed jobs` |

If a metric underperforms, honest notices are provided (e.g., `⚠ 18% over estimated budget`, `ℹ Located 48 km away`).

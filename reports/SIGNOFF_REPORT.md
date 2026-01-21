# Najla-ln Package — Local Technical Sign-off

**Date:** 2025-12-27  
**Run Dir:** `~/najla_signoff_local`  
**Simulator:** Icarus Verilog (`iverilog` + `vvp`) v12.0 stable  
**Python:** 3.12.x

---

## DUT
- `najla_ln_package.sv` (single-file wrapper + core)

---

## Reference Files
- `ln.memh` (Q30) — truncated to 1024 entries (matches DUT ROM range `[0:1023]`)
- `log10.memh` (Q30) — truncated to 1024 entries
- `x128_1024.memh` (Q64.64 packed in 128-bit container) — 1024 entries

---

## Tests Executed

### 1) Bit-Exact Accuracy Test (1024 vectors)
- Result: `mism_ln = 0`, `mism_log10 = 0`
- Status: **PASS ✅ bit-exact (1024 / 1024)**

### 2) Handshake Stress — Back-pressure
- Condition: periodic `out_ready` de-assertion
- Result: `mism_ln = 0`, `mism_log10 = 0`
- Status: **PASS ✅ back-pressure bit-exact**

---

## File Integrity (SHA256)
c260e6512c5662efe3c4accc55259b1591d506527cd3bfac8077db14ce62c2ec  najla_ln_package.sv
590cf7b311f476717c2fc78e83dd9034d4440525ec29f388eb3d155935e0375d  ln.memh
731898190c7eefe91d7afc0862e5978b4682725e8c783da5cf84bb32cb499faa  log10.memh
86c1a899374c5e641ebe6a7ffbb82542fb283261fd5ce4430b777d4a0f1f6a6f  x128_1024.memh
161b5f7a7928025b14d5eba4b3cfa50c2e93f5f6258f218751f8a606a3add06e  tb_accuracy_1024.sv
b5b602521505409dad45103000c968c79b04e10baa8bfd019338a37dbacb3bda  tb_backpressure_1024.sv



---

## Conclusion
The DUT is **bit-exact compliant** with the 1024-vector reference set for both **ln** and **log10**,  
and remains bit-exact under **output back-pressure**, confirming correct and robust  
valid/ready handshake behavior.

**STATUS: SIGN-OFF PASSED ✅**

## Release Archive (ZIP) SHA256
155a3d0ce06d2b275d4f27afddee2fba1698b81812c870217d9245b6264700fb  Najla-ln_Package_v1.0_SignedOff_Local.zip

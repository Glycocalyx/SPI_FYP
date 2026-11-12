# 项目概览

当前目标是在 TSMC 180 nm HV BCD Gen2 上实现 16-bit SPI Slave ASIC。外部 FPGA 提供 SPI Master，仓库中的 Master 用于验证和参考。最初的 8-bit Master / 双 Slave 方案始于 2026-08-11，9 月 8 日引入 16-bit 参数化，9 月 14 日起采用独立 Slave ASIC 范围。

[有效规格](specification.md) 定义接口和性能目标。[历史进度](progress.md) 保留初版 Master 方案。

| 项目 | 基线 |
|---|---|
| PDK release | Gen2_1_7p2a1 |
| 工艺层叠 / 普通信号布线 | 6LM / 1P6M；M1–M4 |
| Core / IO library | `tcb018bcdgp2a` / `tps018bcdnv5` |
| 工具 | Genus 21.14-s082_1、Innovus 21.13-s100_1、Xcelium 23.05、Virtuoso IC6.1.8、Calibre 2022.1_36.16 |

- [项目状态](PROJECT_STATE.md) · [里程碑](milestones/README.md) · [活动记录](WORK_LOG.md)
- [验证台账](TEST_LEDGER.md) · [决策](DECISIONS.md) · [文件索引](ARTIFACT_INDEX.md) · [上传记录](UPLOAD_LOG.md)

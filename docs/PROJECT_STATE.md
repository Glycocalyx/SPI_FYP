# 项目状态

**2026-11-12 · M7D Foundry Physical Verification · IN PROGRESS**

| 阶段 | 状态 | 证据或限制 |
|---|---|---|
| 16-bit RTL / pre-layout timing | 已实现 / 已表征 | 5B–5E 含四角和 61 pF，10 MHz pre-layout 通过 |
| 6B / 6C | 已完成对应范围 | Full IO wrapper 导入、floorplan、PAD placement |
| 7A post-route GLS | PASS | 100 MHz，适用 7A routed core |
| 7B physical checks / checkpoint | 已记录并复检 | Innovus DRC、regular、special connectivity 为 0 |
| 7B overall STA | 未收敛 | 375 MHz default setup 1、hold 22；reg2reg 通过 |
| 7C export / Stream-In | 已完成 | 1000 DBU/µm，0 errors、2 warnings，rounding 与 LVS label 识别待核实 |
| M7D 初始 Calibre DRC | 已运行，有违规 | NBL.R.1 `219 (1279)`，括号统计意义未知；其余六条规则各 1 |
| BND 151/0 | 来源已确认 | 7 masters / 30 records 匹配供应商 GDS，最终提交保留要求待确认 |
| CKBD16 | 已获 cell-level 证据 | Innovus VSS PG、底部 VSS label、123 条 P+ contact 候选记录，部分坐标重复 |
| 全设计 P-substrate / SubToGround | 未验证 / 关闭 | 待核实全设计 tap、substrate continuity 与 isolated wells；开启决定待定 |
| Final DRC / LVS reference netlist | 待处理 | DRC 根因和 marker 分类未完成；LVS netlist/CDL 尚待准备 |
| LVS / ERC / PEX / RCC | 未执行 | 当前仍处 M7D |
| PAD-integrated die / 10 MHz + 61 pF post-layout / GDS freeze | 待完成 | 最终 die-level 验证尚未完成 |

未解决的 DRC 项包括 unmapped datatype、DISCONNECT 与 LV_SD stamping 警告，以及 M2/M3/M4/M5/UTM30K/DRM 各一条结果。保留 7B asynchronous removal 违规。

[活动 checkpoint](active_checkpoint_registry.md) · [M7D 证据](milestone_7d_foundry_drc_lvs.md) · [SubToGround 决策](DECISIONS.md#dec-0011)

## 衬底连通性更新

CKBD16 VSS label 检查已完成。既有 whole-core scan 报告 4036 条 P+ contact 候选，全部匹配带 VSS label 的 M1。当前证据范围为几何和标签匹配。[CKBD16 label](TEST_LEDGER.md#ver-0058) · [Whole-core scan](TEST_LEDGER.md#ver-0061)

**待验证事项**为 full-GDS substrate-to-VSS 电气连通性。现有 LVS/ERC deck 是候选路线。当前仅有 deck 配置检查记录，ERC 执行和结果仍无证据，`SubToGround` 继续关闭。[Deck 检查](TEST_LEDGER.md#ver-0060) · [工程决策](DECISIONS.md#dec-0017)

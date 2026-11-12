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
| Full-core P-substrate ERC / SubToGround | ERC 已运行 / 后续 core DRC 采用 ON | `floating.psub_float = 0 (0)`；保留 OFF baseline |
| Final DRC / LVS reference netlist | 待处理 | DRC 根因和 marker 分类未完成；LVS netlist/CDL 尚待准备 |
| LVS / PEX / RCC | 未执行 | Core source CDL 和 RC 技术包配置待准备 |
| PAD-integrated die / 10 MHz + 61 pF post-layout / GDS freeze | 待完成 | 最终 die-level 验证尚未完成 |

未解决的 DRC 项包括 unmapped datatype、DISCONNECT 与 LV_SD stamping 警告，以及 M2/M3/M4/M5/UTM30K/DRM 各一条结果。保留 7B asynchronous removal 违规。

[活动 checkpoint](active_checkpoint_registry.md) · [M7D 证据](milestone_7d_foundry_drc_lvs.md) · [SubToGround 决策](DECISIONS.md#dec-0018)

## 历史快照 · Full-core ERC 运行前

CKBD16 VSS label 检查已完成。既有 whole-core scan 报告 4036 条 P+ contact 候选，全部匹配带 VSS label 的 M1。当前证据范围为几何和标签匹配。[CKBD16 label](TEST_LEDGER.md#ver-0058) · [Whole-core scan](TEST_LEDGER.md#ver-0061)

**待验证事项**为 full-GDS substrate-to-VSS 电气连通性。现有 LVS/ERC deck 是候选路线。当前仅有 deck 配置检查记录，ERC 执行和结果仍无证据，`SubToGround` 继续关闭。[Deck 检查](TEST_LEDGER.md#ver-0060) · [工程决策](DECISIONS.md#dec-0017)

## 2026-11-12 · ERC 与后续 core DRC 配置

同一 core GDS 和 `spi_slave` primary 的 full-core ERC 执行 23 项、总结果 `0 (0)`，其中 `floating.psub_float = 0 (0)`。现行决策为后续 core DRC 采用 `SubToGround ON`，保留 OFF baseline。4036 条几何匹配来自混有 shell 提示符和命令错误的历史 transcript。[ERC](TEST_LEDGER.md#ver-0064) · [工程决策](DECISIONS.md#dec-0018)

待审查六个剩余 DRC marker，决定修复或 waiver。Core LVS 待准备 source CDL；先前在项目树下未找到 `.cdl`、`.sp` 或 `.spi`。后续使用适当的 TSMC deck 运行 LVS。PEX 待解决 `include ./rules` 的 RC 技术包配置，并在 LVS 设置和 RC 配置验证后运行。Final sign-off 仍待完成。

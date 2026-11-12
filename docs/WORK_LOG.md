# 工程活动记录

迁移截止 2026-11-12。来源为用户提供的 Historical Migration Package，条目注明对应章节。测试条件、执行状态和结果见 [验证台账](TEST_LEDGER.md)。

### ACT-0001

**2026-08-11 · 初始项目与 EDA7 环境 · CONFIRMED**

建立 RTL、TB、仿真、综合、Innovus 和文档目录，定义 8-bit Master / 双 Slave。GitHub 网络检查 HTTP 200，Codex 安装请求 HTTP 403，采用 Windows → GitHub → EDA7 同步。

来源：B1。[VER-0001](TEST_LEDGER.md#ver-0001)

### ACT-0002

**2026-08-26–28 · 初版 RTL 与 XSim 调试 · CONFIRMED**

实现 8-bit Master FSM、分频器、移位寄存器和两个独立片选，以及 Mode 0 Slave。保留中断、缺少 trace 和成功重跑记录。

来源：B2。[VER-0002](TEST_LEDGER.md#ver-0002)、[VER-0003](TEST_LEDGER.md#ver-0003)、[VER-0004](TEST_LEDGER.md#ver-0004)

### ACT-0003

**2026-09-01 · 双 Slave regression · CONFIRMED**

新增 `tb/spi_regression_tb.sv` 与 `tb/spi_two_slave_tb.sv`，覆盖片选和共享 MISO；执行日志缺失。

来源：B3。[VER-0005](TEST_LEDGER.md#ver-0005)

### ACT-0004

**2026-09-08 · 16-bit 参数化 · CONFIRMED**

Master/Slave 默认 `DATA_WIDTH=16`，计数宽度使用 `(DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH)`，新增 16-bit TB 并更新 regression。

来源：B4。[VER-0006](TEST_LEDGER.md#ver-0006)

### ACT-0005

**2026-09-09 · Ideal-core Genus sweep · CONFIRMED**

`syn/run.tcl` 采用 TT/25°C/5V、segmented wireload 和零 MISO output delay。

来源：B5。[VER-0007](TEST_LEDGER.md#ver-0007)

### ACT-0006

**2026-09-10 · MISO PAD-only 模型 · CONFIRMED**

引入 PDDW0208CSG，`PAD_DS=1`，5 pF 外部负载，`pad_oen = ~miso_oe_core` 处理有效极性。

来源：B6。[VER-0008](TEST_LEDGER.md#ver-0008)

### ACT-0007

**2026-09-10 · PAD 输入电容模型 · CONFIRMED**

独立 core 实验在 MISO 施加 0.0228543 pF。

来源：B6。[VER-0009](TEST_LEDGER.md#ver-0009)

### ACT-0008

**2026-09-11 · SCLK 与 MISO PAD · CONFIRMED**

新增 SCLK+MISO wrapper 和 `syn/run_sclk_miso_pad.tcl`；区分 EXT_SCLK / CORE_SCLK。分别保留早期和更新后的 PAD 延迟。

来源：B7。[VER-0010](TEST_LEDGER.md#ver-0010)

### ACT-0009

**2026-09-13 · MOSI 输入 PAD（5A） · CONFIRMED**

新增三 PAD wrapper 和 `syn/run_sclk_mosi_miso_pad.tcl`，MOSI 采用 PAD-to-C arc。

来源：B8。

### ACT-0010

**2026-09-14 起 · ASIC 范围调整 · CONFIRMED**

最终目标改为独立 SPI Slave；外部 FPGA 为 Master，仓库 Master 用于参考和验证。

来源：A1。

### ACT-0011

**2026-09-19 · 完整 SPI PAD（5B） · CONFIRMED**

加入 CSB PAD，形成四 PAD wrapper，记录 TT 110 MHz / 5 pF / 1 ns input slew 结果。

来源：B9。[VER-0011](TEST_LEDGER.md#ver-0011)

### ACT-0012

**2026-09-22 · CSB 异步时序（5C） · CONFIRMED**

通过 `syn/run_csb_async.tcl` 表征 CSB→CDN、recovery/removal、tCSS/tDIS。

来源：B10。[VER-0012](TEST_LEDGER.md#ver-0012)

### ACT-0013

**2026-09-28 · 四角固定网表（5D） · CONFIRMED**

保留同一 110 MHz/5 pF 网表；WC SCLK PAD rise 插值从 0.9916 ns 修正到 0.9815741 ns，独立脚本使用 0.9816/1.0115 ns。保留原运行；`report_timing -early` 被拒绝。

来源：B11。[VER-0013](TEST_LEDGER.md#ver-0013)、[VER-0014](TEST_LEDGER.md#ver-0014)、[VER-0015](TEST_LEDGER.md#ver-0015)

### ACT-0014

**2026-10-03 · Innovus 导入（6B） · CONFIRMED**

以 full IO wrapper 为 top、6LM 导入；诊断 PG 和 IO 浮空。短暂尝试逻辑常量接电源网，后续采用 TIEH/TIEL。

来源：B13。[VER-0016](TEST_LEDGER.md#ver-0016)

### ACT-0015

**2026-10-08 · Floorplan 和 PAD placement（6C） · CONFIRMED**

默认 snapping 将 60 µm 调为 59.92 µm，造成 139.92 µm core offset。以 `-noSnapToGrid` 对齐 0.56 µm grid；SCLK 左 R90、MOSI 底 R0、MISO 顶 R180、CSB 右 R270。

来源：B14。[VER-0017](TEST_LEDGER.md#ver-0017)、[VER-0018](TEST_LEDGER.md#ver-0018)

### ACT-0016

**2026-10-12 · 61 pF MISO 负载（5E） · CONFIRMED**

按示波器探头负载调整 STA，沿用固定网表。四角验证 10 MHz 并独立扫 Fmax。

来源：B12。[VER-0019](TEST_LEDGER.md#ver-0019)、[VER-0020](TEST_LEDGER.md#ver-0020)、[VER-0021](TEST_LEDGER.md#ver-0021)

### ACT-0017

**2026-10-13 · Innovus PATH · CONFIRMED**

设置 `/usr/eelocal/cadence/innovus211/tools/bin`，执行 `rehash` 和 `which innovus`。

来源：B15。

### ACT-0018

**2026-10-13 · 独立早期 physical run · USER_REPORTED**

用户报告 99 cells；与 6B 的 98 instances 的关系待查。

来源：B15。[VER-0022](TEST_LEDGER.md#ver-0022)

### ACT-0019

**2026-10-15 · Post-route GLS（7A） · CONFIRMED**

先验证无 SDF，再修正 Xcelium `+define+NTC+RECREM` 后重跑 SDF。保留初次 annotation warnings。

来源：B16。[VER-0023](TEST_LEDGER.md#ver-0023)、[VER-0024](TEST_LEDGER.md#ver-0024)、[VER-0025](TEST_LEDGER.md#ver-0025)

### ACT-0020

**2026-10-17 · Filler 与短路修复（7B） · CONFIRMED**

Top 为 `spi_slave`。147 primary + 4 incremental fillers；自动 ECO 未清除 `rx_shift_reg[8]` M1 short，GUI 用 M1→M2 bridge 修复。

来源：B17。[VER-0026](TEST_LEDGER.md#ver-0026)、[VER-0027](TEST_LEDGER.md#ver-0027)、[VER-0028](TEST_LEDGER.md#ver-0028)

### ACT-0021

**2026-10-17 · Core boundary 与 PG（7B） · CONFIRMED**

底边临时扩至 -2 µm；M4 PG stripes、54 PG vias、38 M3 signal pins；建立 PG pin 并 global connect，各 256 VDD/VSS connections。

来源：B17。[VER-0029](TEST_LEDGER.md#ver-0029)

### ACT-0022

**2026-10-17 · RC、时钟与 STA（7B） · CONFIRMED**

Innovus process 从 90 nm 修正为 180 nm；`VIEW_TT` / `CONSTRAINT_SPI` / `DELAY_TT` / `RC_TT`，`t018lo_1p6m_typical.captable`，`extractRC`。启用交互 constraint mode 后成功设置 propagated clock。保存 375 MHz STA 和最终 physical checks。

来源：B17。[VER-0030](TEST_LEDGER.md#ver-0030)、[VER-0031](TEST_LEDGER.md#ver-0031)、[VER-0032](TEST_LEDGER.md#ver-0032)、[VER-0033](TEST_LEDGER.md#ver-0033)、[VER-0034](TEST_LEDGER.md#ver-0034)、[VER-0035](TEST_LEDGER.md#ver-0035)、[VER-0036](TEST_LEDGER.md#ver-0036)、[VER-0037](TEST_LEDGER.md#ver-0037)

### ACT-0023

**2026-10-20–2026-11-03 · GDS 导出 / Stream-In（7C） · CONFIRMED**

2000 DBU/µm 导入受阻，改为 1000 DBU/µm 重导出 core GDS。记录导入、几何比较和 label 检查。

来源：B18。[VER-0038](TEST_LEDGER.md#ver-0038)、[VER-0039](TEST_LEDGER.md#ver-0039)、[VER-0040](TEST_LEDGER.md#ver-0040)、[VER-0041](TEST_LEDGER.md#ver-0041)、[VER-0042](TEST_LEDGER.md#ver-0042)

### ACT-0024

**2026-11-08 · Calibre 基线（7D） · CONFIRMED**

对 core GDS 运行 Calibre 2022.1_36.16。使用本地 deck，关闭 FULL_CHIP、SubToGround；5V/1.8V、MIX_MODE、THICK_30K；启用 GUIDELINE_LUP、GUIDELINE_ESD、PARASITIC_ESD、WARNING_HVLUP。

来源：B19。[VER-0043](TEST_LEDGER.md#ver-0043)

### ACT-0025

**2026-11-09 · BND provenance · CONFIRMED**

交叉比对 TSMC `METAL1 boundary 151 0`、LEF OBS、vendor GDS、merge 和 no-merge 结果。

来源：B20。[VER-0044](TEST_LEDGER.md#ver-0044)、[VER-0045](TEST_LEDGER.md#ver-0045)

### ACT-0026

**2026-11-11 · M7B checkpoint 恢复 · CONFIRMED**

比较 `.enc` 和 `.enc.dat`，保存指纹及复检报告。保留同 session 重复 restore 报错。

来源：B21、C1。[VER-0046](TEST_LEDGER.md#ver-0046)、[VER-0047](TEST_LEDGER.md#ver-0047)、[VER-0048](TEST_LEDGER.md#ver-0048)、[VER-0049](TEST_LEDGER.md#ver-0049)、[VER-0050](TEST_LEDGER.md#ver-0050)

### ACT-0027

**2026-11-11 · CKBD16 PG 与 LVS deck 调查 · CONFIRMED**

检查 CKBD16 instance/library PG 定义和 LVS deck 的 P-substrate、tap 和 ground-path 检查。保留 SVRF/Tcl、tcsh redirect、Python `pathlib` 错误。

来源：B21、C1。[VER-0051](TEST_LEDGER.md#ver-0051)、[VER-0052](TEST_LEDGER.md#ver-0052)、[VER-0053](TEST_LEDGER.md#ver-0053)、[VER-0054](TEST_LEDGER.md#ver-0054)、[VER-0055](TEST_LEDGER.md#ver-0055)

### ACT-0028

**2026-11-12 · 设计 GDS 身份确认 · CONFIRMED**

`ls` 与 `sha256sum` 指向 1000 DBU/µm 的设计 GDS，纠正 11-11 指向 library GDS 的 hash 记录。

来源：B22。[VER-0056](TEST_LEDGER.md#ver-0056)、[VER-0057](TEST_LEDGER.md#ver-0057)

### ACT-0029

**2026-11-12 · CKBD16 TEXT 和 P+ geometry · CONFIRMED**

以 `read_ckbd16_text.py` 提取 label，以 `verify_ckbd16_p_substrate_tie.py` 检查 P+ geometry；记录 123 条候选记录与重复坐标限制。

来源：B22。[VER-0058](TEST_LEDGER.md#ver-0058)、[VER-0059](TEST_LEDGER.md#ver-0059)

## 历史证据缺口

- 8 月初期讨论、XSim 调试过程和 9 月 8 日迁移中的中间测试只恢复了部分记录。
- 9 月 1 日回归、9 月 8 日双 Slave directed test 缺少完整执行日志；9 月 9–13 日部分原始命令也缺失。
- 10 月 13 日 physical run 缺少完整报告，98 与 99 的记录关系未建立。10 月 17 日 GUI 修复缺少完整操作过程。
- M7D 缺少逐 marker 分类和 `219 (1279)` 的括号统计定义。LVS/ERC/PEX 无运行记录。

## 后续同步

### ACT-0030

**RC / PEX rule 调查 · USER_REPORTED**

检查了 PDK RC rule 位置，并比较了两个 Cadence OA Calibre RCX rule 文件。两者 SHA256 相同，均为 `fdcda784f6bf0ce518d2e8559daf79259d5404c7f6100f0f22b99d8713a86520`。

Mentor 包 `RC_xCalibre_cv018bcd_1p6m_4x1u_mim5_30kutm_typical.tar.gz` 内的规则与 Cadence OA 规则不同。该包包含 rules、QAreport 和 technology metadata。QAreport 标注 `xCalibre v2007.4_14.15`。

来源为本次同步资料，原始执行日期未提供。相关记录见 [LVS_RC deck 检查](TEST_LEDGER.md#ver-0060) 和 [后续验证决策](DECISIONS.md#dec-0017)。

## 2026-11-12 · Calibre ERC 与 SubToGround DRC A/B

以下条目来自 2026-11-12 CODEX SYNC PACKAGE。复用已有 CKBD16 检查和 whole-core scan 的验证 ID。

### ACT-0031

**Calibre 环境设置 · USER_REPORTED**

初始 PATH 找不到 `calibre`。执行 `source /usr/eelocal/cadence/ic618hf/.cshrc` 和 `rehash` 后确认环境与版本。[VER-0062](TEST_LEDGER.md#ver-0062)

### ACT-0032

**LVS/PEX deck 与 RC rule 调查补充 · USER_REPORTED**

检查 `$PDKROOT/LVS_Command_File/Mentor_Graphics/t018cvsp018c1_1_7p2a/MAIN_DECK/CALIBRE_FLOW/30k/LVS_RC_Calibre_018um_GenII_1P6M_v1.7p2a`。第 21469 行的 `include ./rules` 用于 PEX/RC extraction 配置；`PEX ALIAS` 和 `PEX RESISTANCE PARAMETERS` 分别配置层别名和提取属性。对比 Mentor、Cadence OA 原版与 OA 20260222 版规则。Mentor 包进入候选名单，PEX 配置仍待批准。[既有调查](#act-0030) · [VER-0063](TEST_LEDGER.md#ver-0063)

### ACT-0033

**CKBD16 substrate tap 证据汇总 · USER_REPORTED**

既有 Innovus 检查记录 `CTS_ccl_a_buf_00001`（CKBD16）的 VSS PG 接 VSS、VDD PG 接 VDD。GDS layer 40/type 0 的底部 M1 label 为 VSS，坐标 (280,0)。123 条底部 contact 满足检查的 P+ 几何条件。同步包综合这些证据，支持 CKBD16 的 substrate tap 接 VSS 的解释。[PG](TEST_LEDGER.md#ver-0051) · [TEXT](TEST_LEDGER.md#ver-0058) · [Geometry](TEST_LEDGER.md#ver-0059)

### ACT-0034

**Whole-core P+ scan 证据补充 · USER_REPORTED**

`$BASE/scan_core_psub_taps.py` 扫描 `$CORE_GDS`，top 为 `spi_slave`。既有扫描报告 4036 条候选均匹配 VSS 标记 M1。终端记录夹有 shell 提示符和命令错误，证据限制见 [VER-0061](TEST_LEDGER.md#ver-0061)。

### ACT-0035

**Full-core Calibre ERC · USER_REPORTED**

在 `erc_psub_20261112` 使用 `lvs_erc_psub.svrf` 检查 `$CORE_GDS`。deck 和生成的 summary 均确认 GDSII 格式、输入路径和 primary `spi_slave`，与原 DRC baseline 一致。[VER-0064](TEST_LEDGER.md#ver-0064)

### ACT-0036

**SubToGround DRC A/B · USER_REPORTED**

原本地 deck 为 `$BASE/calibre_spi_slave_core.drc`。保留 `drc_run_core_20261108` 的 OFF baseline（`//#DEFINE SubToGround`）。在独立目录 `drc_subtoground_test_20261112` 比较 ON 配置。[原 baseline](TEST_LEDGER.md#ver-0043) · [ON 对照](TEST_LEDGER.md#ver-0065)

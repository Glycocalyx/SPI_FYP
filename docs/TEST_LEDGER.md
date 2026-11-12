# 验证台账

来源为 Historical Migration Package B、C 节。证据标签沿用迁移包；其中 `PLANNED` 记为 `PLANNED_NOT_EXECUTED`。证据分类与运行结果分别记录。原始输入或日志有缺口时保留其限制。

### VER-0001

**2026-08-11 · EDA7 环境探查 · CONFIRMED** · [ACT-0001](WORK_LOG.md#act-0001)

Git 1.8.3.1、curl 7.29.0、Xcelium 23.05、Genus/Innovus 21.1；GitHub HTTP 200，安装脚本 HTTP 403。

### VER-0002

**2026-08-26 · 8-bit XSim · CONFIRMED** · [ACT-0002](WORK_LOG.md#act-0002)

中断，run 被取消（1:53）。功能结果未完成。

### VER-0003

**2026-08-26 · XSim 波形检查 · CONFIRMED** · [ACT-0002](WORK_LOG.md#act-0002)

Simulator 45-9，编译无 trace。需 debug compile。

### VER-0004

**2026-08-28 · 单 Slave 8-bit XSim · CONFIRMED** · [ACT-0002](WORK_LOG.md#act-0002)

PASS，770 ns。CSB 选择/释放、MISO OE 启用/释放、Slave RX A5、Master RX 3C、rx_valid、SCLK idle-low 共 8 项。

### VER-0005

**2026-09-01 · 双 Slave regression · UNKNOWN** · [ACT-0003](WORK_LOG.md#act-0003)

TB 源码已确认；执行与结果未知。

### VER-0006

**2026-09-08 · 16-bit 双 Slave directed · USER_REPORTED** · [ACT-0004](WORK_LOG.md#act-0004)

A55A→3CC3、5AA5→C33C；项目有 PASS 记录，原始完整日志缺失。预期覆盖 16 对边沿、数据、rx_valid、idle-low 和独占 MISO。

### VER-0007

**2026-09-09 · Ideal core / TT · CONFIRMED** · [ACT-0005](WORK_LOG.md#act-0005)

300/350/360/375/380 MHz slack +15/+2/+2/0/-11 ps；边界约 375–380 MHz。

### VER-0008

**2026-09-10 · MISO PAD-only / TT / 5 pF · CONFIRMED** · [ACT-0006](WORK_LOG.md#act-0006)

100/110/120/130 MHz slack +576/+142/+40/+1 ps；边界约 130 MHz。

### VER-0009

**2026-09-10 · Core + PAD 输入电容 / 0.0228543 pF · CONFIRMED** · [ACT-0007](WORK_LOG.md#act-0007)

300/305/310/320/330/340/345/350 MHz slack +3/0/+9/+3/+1/+1/+1/-10 ps。

### VER-0010

**2026-09-11 · SCLK + MISO PAD / 110 MHz · CONFIRMED** · [ACT-0008](WORK_LOG.md#act-0008)

MISO slack 约 0 ps。早期 SCLK PAD rise/fall 0.6472/0.7183 ns；后续 mapped-load 模型 0.6738/0.7487 ns。

### VER-0011

**2026-09-19 · 5B full IO / TT / 110 MHz / 5 pF · CONFIRMED** · [ACT-0011](WORK_LOG.md#act-0011)

MOSI setup +3.760 ns；MISO +5 ps，path 3.791 ns、PAD 2.502 ns。98 cells、5660.480 µm²。CSB rise/fall cap 41.6/41.8 fF、slew 240.8/240.1 ps；SCLK cap 122.5/120.5 fF。

### VER-0012

**2026-09-22 · 5C CSB async / TT / 110 MHz · CONFIRMED** · [ACT-0012](WORK_LOG.md#act-0012)

CSB→CDN 0.837 ns；RX recovery −0.344 ns、removal +0.886 ns；tCSS 3.999 ns（margin +0.5465 ns）；tDIS 2.210 ns。适用 TT pre-layout 假设。

### VER-0013

**2026-09-28 · 5D fixed-netlist 4 corners · CONFIRMED** · [ACT-0013](WORK_LOG.md#act-0013)

TT/WC/BC/LT Fmax 约 110/72.7/137/146.9 MHz。依同一顺序，CSB↓→MISO↑ 3.999/6.050/3.202/2.977 ns，→MISO↓ 2.710/4.051/2.169/2.034 ns，CSB↑→High-Z 2.210/3.253/1.828/1.695 ns，→CDN↑ 0.837/1.137/0.715/0.682 ns。

### VER-0014

**2026-09-28 · WC corrected · CONFIRMED** · [ACT-0013](WORK_LOG.md#act-0013)

72.6 MHz、MISO slack +6 ps，采用修正 PAD rise delay。

### VER-0015

**2026-09-28 · Genus early timing · CONFIRMED** · [ACT-0013](WORK_LOG.md#act-0013)

`report_timing -early` 被拒绝。pre-layout hold 结果缺失。

### VER-0016

**2026-10-03 · 6B import 与 PG/IO 诊断 · CONFIRMED** · [ACT-0014](WORK_LOG.md#act-0014)

94 core cells + 4 PAD、123 nets，core cell area 5660.48 µm²、PAD 38400 µm²；标准单元 PG 无浮空；17 IO macros 缺 conventional PG，18 floating IO controls。

### VER-0017

**2026-10-08 · 初始 floorplan grid · CONFIRMED** · [ACT-0015](WORK_LOG.md#act-0015)

IMPFP-7236/7238；默认 snapping 导致 off-grid。

### VER-0018

**2026-10-08 · 修正后的 floorplan/PAD · CONFIRMED** · [ACT-0015](WORK_LOG.md#act-0015)

对齐 0.56 µm。Die 403.2 × 403.2 µm，core 123.2 × 123.2 µm，box (140,140)→(263.2,263.2)，利用率 37.29%；94 core cells 尚未放置。

### VER-0019

**2026-10-12 · 5E fixed-netlist / 61 pF / 10 MHz · CONFIRMED** · [ACT-0016](WORK_LOG.md#act-0016)

TT/WC/BC/LT 均 PASS。Slack +42.616/+39.012/+44.024/+44.424 ns；path 6.635/9.977/5.337/4.966 ns；PAD 5.154/7.740/4.151/3.865 ns。

### VER-0020

**2026-10-12 · 5E fixed-netlist / 61 pF Fmax · CONFIRMED** · [ACT-0016](WORK_LOG.md#act-0016)

TT/WC/BC/LT 约 67.7/45.5/83.7/89.7 MHz。

### VER-0021

**2026-10-12 · WC 45.4 MHz 异常报告 · CONFIRMED** · [ACT-0016](WORK_LOG.md#act-0016)

选中错误的内部 SCLK edge，异常 slack 点已排除。

### VER-0022

**2026-10-13 · 独立早期 Innovus run · USER_REPORTED** · [ACT-0018](WORK_LOG.md#act-0018)

99 cells，5732.608 µm²，density 0.601 / 70.09%，H/V overflow 0.00%，估计线长 2872.8 µm。

### VER-0023

**2026-10-15 · 7A 100 MHz GLS 无 SDF · CONFIRMED** · [ACT-0019](WORK_LOG.md#act-0019)

A5A5 / 3C3C directed checks PASS。

### VER-0024

**2026-10-15 · 7A 初次 SDF annotation · CONFIRMED** · [ACT-0019](WORK_LOG.md#act-0019)

0 errors，28 warnings（24 SDFNET recovery/removal、4 SDFNEP XOR2D1）。

### VER-0025

**2026-10-15 · 7A 100 MHz SDF 修正后 · CONFIRMED** · [ACT-0019](WORK_LOG.md#act-0019)

PASS，0 errors、4 XOR2D1 IOPATH warnings，24 条 RECREM warning 消失。适用于 7A routed core。

### VER-0026

**2026-10-17 · Filler placement · CONFIRMED** · [ACT-0020](WORK_LOG.md#act-0020)

151 fillers，256 instances，0 unplaced，100% density，`checkPlace` 0。

### VER-0027

**2026-10-17 · Filler 后 M1 short / 自动 ECO · CONFIRMED** · [ACT-0020](WORK_LOG.md#act-0020)

`rx_shift_reg[8]` short，自动 ECO 未清除。

### VER-0028

**2026-10-17 · 手工 bridge 后复检 · CONFIRMED** · [ACT-0020](WORK_LOG.md#act-0020)

Innovus DRC 0，regular connectivity 0 violations / 0 warnings。

### VER-0029

**2026-10-17 · PG 连接 · CONFIRMED** · [ACT-0021](WORK_LOG.md#act-0021)

VDD 256 + VSS 256 = 512 connections。

### VER-0030

**2026-10-17 · Post-route RC · CONFIRMED** · [ACT-0022](WORK_LOG.md#act-0022)

1695 R、1727 ground C、2420 coupling C。

### VER-0031

**2026-10-17 · 初次 propagated clock 设置 · CONFIRMED** · [ACT-0022](WORK_LOG.md#act-0022)

TCLCMD-1048，无交互 constraint mode。

### VER-0032

**2026-10-17 · 修正后 `report_clocks` · CONFIRMED** · [ACT-0022](WORK_LOG.md#act-0022)

SCLK 2.667 ns，propagated y。

### VER-0033

**2026-10-17 · 7B 375 MHz setup · CONFIRMED** · [ACT-0022](WORK_LOG.md#act-0022)

未收敛。All/default WNS/TNS −0.444/−0.444 ns，1 violation；reg2reg +0.534/0 ns，0 violation。

### VER-0034

**2026-10-17 · 7B 375 MHz hold · CONFIRMED** · [ACT-0022](WORK_LOG.md#act-0022)

未收敛。All/default WNS/TNS −0.726/−14.568 ns，22 violations；reg2reg +0.668/0 ns，0 violation。关键 removal `csb_n → rx_shift_reg_reg[14]/CDN`，−0.726 ns。

### VER-0035

**2026-10-17 · 7B 最终 Innovus DRC · CONFIRMED** · [ACT-0022](WORK_LOG.md#act-0022)

0 violations。

### VER-0036

**2026-10-17 · 7B 最终 regular connectivity · CONFIRMED** · [ACT-0022](WORK_LOG.md#act-0022)

0 problems。

### VER-0037

**2026-10-17 · 7B 最终 special connectivity · CONFIRMED** · [ACT-0022](WORK_LOG.md#act-0022)

0 problems，含 PG。

### VER-0038

**2026-10-20–2026-11-03 · 2000 DBU/µm Virtuoso Stream-In · CONFIRMED** · [ACT-0023](WORK_LOG.md#act-0023)

XSTRM-284，改用 1000 DBU/µm。

### VER-0039

**2026-10-20–2026-11-03 · 1000 DBU/µm GDS export · CONFIRMED** · [ACT-0023](WORK_LOG.md#act-0023)

481588 bytes。IMPOGDS-250，坐标 rounding 待审。

### VER-0040

**2026-10-20–2026-11-03 · 1000 DBU/µm Virtuoso Stream-In · CONFIRMED** · [ACT-0023](WORK_LOG.md#act-0023)

0 errors、2 warnings（XSTRM-75/107）；256 instances、42 masters、1247 shapes、736 vias（682 regular/54 special）、171 labels。日志后来被覆盖。

### VER-0041

**2026-10-20–2026-11-03 · OA / GDS master geometry · CONFIRMED** · [ACT-0023](WORK_LOG.md#act-0023)

35 masters 通过 OA vs imported GDS 比较，另 7 masters 有额外 BND，后续检查 vendor provenance。

### VER-0042

**2026-10-20–2026-11-03 · GDS pin 与 OA terminals · CONFIRMED** · [ACT-0023](WORK_LOG.md#act-0023)

38 signal pin positions、VDD/VSS labels 各 2 处、OA terminals 0；LVS label 识别未验证。

### VER-0043

**2026-11-08 · Calibre 原始 core DRC · CONFIRMED** · [ACT-0024](WORK_LOG.md#act-0024)

运行完成且有违规：NBL.R.1 `219 (1279)`；M2/M3/M4/M5/UTM30K/DRM 的 `.R.1` 各 1。DISCONNECT、unmapped pairs、PROJECTING、LV_SD stamping 为运行警告；括号统计意义未知。

### VER-0044

**2026-11-09 · Vendor / merged BND comparison · CONFIRMED** · [ACT-0025](WORK_LOG.md#act-0025)

7 masters / 30 records 全部匹配；CKBD16 4、DFCND4 8、DFCNQD4 4、INVD16 4、INVD4 4、ND2D4 3、NR2D4 3。

### VER-0045

**2026-11-09 · No-merge / merge BND · CONFIRMED** · [ACT-0025](WORK_LOG.md#act-0025)

151/0 records 0 / 30，确认 merge provenance。

### VER-0046

**2026-11-11 · M7B restore identity / fingerprint · CONFIRMED** · [ACT-0026](WORK_LOG.md#act-0026)

`.enc` binary identical，`.enc.dat` 无 diff；`spi_slave`、256 instances、42 masters、151 fillers、core (0,0,100,100)、floorplan (0,−2,100,100)、2000 DBU、SCLK 2.667 ns propagated。

### VER-0047

**2026-11-11 · M7B restore DRC · CONFIRMED** · [ACT-0026](WORK_LOG.md#act-0026)

0 violations。

### VER-0048

**2026-11-11 · M7B restore regular connectivity · CONFIRMED** · [ACT-0026](WORK_LOG.md#act-0026)

0 violations / 0 warnings。

### VER-0049

**2026-11-11 · M7B restore special connectivity · CONFIRMED** · [ACT-0026](WORK_LOG.md#act-0026)

0 violations / 0 warnings。

### VER-0050

**2026-11-11 · 同 session 重复 restore · CONFIRMED** · [ACT-0026](WORK_LOG.md#act-0026)

IMPIMEX-7031。

### VER-0051

**2026-11-11 · CKBD16 Innovus PG · CONFIRMED** · [ACT-0027](WORK_LOG.md#act-0027)

`CTS_ccl_a_buf_00001` 位于 (20.16,0.0)、MX，I=sclk、Z=CTS_3、VSS=VSS、VDD=VDD；master 有 primaryGround/primaryPower。

### VER-0052

**2026-11-11 · LVS deck 静态检查 · CONFIRMED** · [ACT-0027](WORK_LOG.md#act-0027)

记录 P-substrate/tap 推导以及 WELL_TO_PG_CHECK、FLOATING_WELL_CHECK 和 `floating.psub_float` 的 ground path 检查。LVS/ERC 未执行。

### VER-0053

**2026-11-11 · SVRF 输入 Innovus Tcl · CONFIRMED** · [ACT-0027](WORK_LOG.md#act-0027)

invalid command name。

### VER-0054

**2026-11-11 · tcsh 重定向 · CONFIRMED** · [ACT-0027](WORK_LOG.md#act-0027)

Ambiguous output redirect。

### VER-0055

**2026-11-11 · 默认 Python 解析 · CONFIRMED** · [ACT-0027](WORK_LOG.md#act-0027)

ImportError pathlib，改用 python3。

### VER-0056

**2026-11-11 · GDS hash 路径核对 · CONFIRMED** · [ACT-0028](WORK_LOG.md#act-0028)

先前命令指向 library GDS；设计 GDS 于 11-12 重新核实。

### VER-0057

**2026-11-12 · 设计 GDS ls/SHA256 · CONFIRMED** · [ACT-0028](WORK_LOG.md#act-0028)

471K；`7a0f7c4471402b737095730d6edf01f90ba089be80688fe9e09fa76353853f72`。用户终端输出。

### VER-0058

**2026-11-12 · CKBD16 GDS TEXT · CONFIRMED** · [ACT-0029](WORK_LOG.md#act-0029)

40/0：Z (14840,2800)、I (3080,2800)、VDD (280,5600)、VSS (280,0)。底部 M1 label 为 VSS。用户终端输出。

### VER-0059

**2026-11-12 · CKBD16 P+ geometry · CONFIRMED** · [ACT-0029](WORK_LOG.md#act-0029)

底部 contact、DIFF/PIMP/M1 containment、PPLUS_VSS_CANDIDATE 均 123；NWELL containment 0。DIFF/PIMP/CONT Y 范围分别 ±0.21/±0.31/±0.11 µm。部分坐标重复；证据范围为该 master。用户终端输出。

### VER-0060

**LVS_RC deck 配置检查 · USER_REPORTED** · [ACT-0030](WORK_LOG.md#act-0030)

检查对象为 `LVS_RC_Calibre_018um_GenII_1P6M_v1.7p2a`（30k / 1P6M）。`RC_DECK` 默认被注释，RC 相关段落受该宏控制。`FLOATING_WELL_CHECK` 已定义。

`ERC_SELECT_CHECK` 包含以下检查。

- `ERC_FLOATING_GATE_CHECK`
- `ERC_WELL_TO_PG_CHECK`
- `ERC_GATE_TO_PG_CHECK`
- `ERC_DS_TO_PG_CHECK`
- `ERC_FLOATING_WELL_CHECK`

`ERC_FLOATING_WELL_CHECK` 包含 `floating.HVNW_float`、`floating.nxwell_float` 和 `floating.psub_float`。本条证据限于 deck 静态配置。ERC 运行及结果尚无记录。

### VER-0061

**既有 whole-core contact scan · USER_REPORTED**

既有扫描报告 4036 条 P+ contact 候选，4036 条均匹配带 VSS label 的 M1。证据范围为几何与标签匹配。全 GDS 电气连通性仍待验证。本条沿用既有结果。2026-11-12 同步包补充的结构计数为 52 defined cells、992 direct top SREFs、0 direct top AREFs、992 expanded SREF instances、51 referenced masters、0 expanded AREF structures。捕获的终端 transcript 混有粘贴的 shell 提示符和 `Command not found`、`Too many arguments` 等错误，故保留报告数字并标记 transcript 受污染。该输出的独立审核仍未建立。

### VER-0062

**2026-11-12 · Calibre 环境核对 · USER_REPORTED** · [ACT-0031](WORK_LOG.md#act-0031)

`CALIBRE_HOME=/usr/eelocal/mentor/cal_2022.1_36/aoi_cal_2022.1_36.16`，可执行文件为 `$CALIBRE_HOME/bin/calibre`。版本命令出现 process-limit 警告，仍执行完成并返回 `Calibre v2022.1_36.16`。

### VER-0063

**2026-11-12 · RC rules SHA256 对比 · USER_REPORTED** · [ACT-0032](WORK_LOG.md#act-0032)

| 规则 | SHA256 |
|---|---|
| Cadence OA 原版 | `fdcda784f6bf0ce518d2e8559daf79259d5404c7f6100f0f22b99d8713a86520` |
| Cadence OA 20260222 | `fdcda784f6bf0ce518d2e8559daf79259d5404c7f6100f0f22b99d8713a86520` |
| Mentor RC package `rules` | `df441ddbb8ef7e40c56f1a81a74c3937dfae87184ffa3c550d6bf58316c6d160` |

两个 OA 文件相同，Mentor 规则不同。同步包记录 README 和 QAreport 标注历史 xCalibre/xRC QA 版本 `v2007.4_14.15`。

### VER-0064

**2026-11-12 · Full-core ERC · USER_REPORTED** · [ACT-0035](WORK_LOG.md#act-0035)

`LAYOUT SYSTEM GDSII`、`LAYOUT PRIMARY "spi_slave"`、`LAYOUT PATH "$CORE_GDS"`（实际绝对路径见 [文件索引](ARTIFACT_INDEX.md)）在 deck 和生成的 summary 中均核对一致。deck 启用 `FLOATING_WELL_CHECK`，`GROUND_NAME` 含 VSS、DVSS、AVSS、GND 等。配置的 `floating.psub_float` 检查包含缺少 ground path（`PATHCHK !GROUND psub_float PORTS ALSO`）和直连电源（`NET psub_float POWER_NAME`）。

输出为 `calibre_erc.db`（ASCII，3.8K）和 `calibre_erc.sum`（59K）。`floating.psub_float` 结果为 `0 (0)`，ERC 执行 23 项，生成 `0 (0)` 条结果。同步包的解释限于该输入与配置下未报告浮空 P-substrate 违规。Core LVS 待运行。

### VER-0065

**2026-11-12 · SubToGround ON DRC 对照 · USER_REPORTED** · [ACT-0036](WORK_LOG.md#act-0036)

OFF baseline 的 `spi_slave.drc.summary` 记录 `NBL.R.1 = 219 (1279)`。ON 的 `spi_slave_subtoground.drc.summary` 未出现 `NBL.R.1` 或 `NWR.R.8` 条目。两项检查均在 `#IFNDEF SubToGround` 块内，ON 配置排除了这两项，原几何结果仍保留在 OFF baseline。

| 规则 | OFF | ON |
|---|---:|---:|
| M2.R.1 | 1 | 1 |
| M3.R.1 | 1 | 1 |
| M4.R.1 | 1 | 1 |
| M5.R.1 | 1 | 1 |
| UTM30K.R.1 | 1 | 1 |
| DRM.R.1 | 1 | 1 |

ON 共执行 3610 项 DRC checks，生成 6 条 DRC 结果和 0 条 DFM RDB 结果。

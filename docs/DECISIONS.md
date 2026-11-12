# 工程决策记录

以下决策与依据来自 Historical Migration Package A、B、D 节。

### DEC-0001

**ASIC 范围** · [ACT-0010](WORK_LOG.md#act-0010)

16-bit SPI Slave；外部 FPGA 实现 Master，仓库 Master 用于验证。

### DEC-0002

**SPI 协议** · [ACT-0004](WORK_LOG.md#act-0004)

Mode 0、MSB-first，沿用已建立的 RTL 与验证基线。

### DEC-0003

**Die-level 目标** · [ACT-0016](WORK_LOG.md#act-0016)

至少 10 MHz，最终检查包含 61 pF 外部 MISO 负载。

### DEC-0004

**375 MHz 压力测试** · [ACT-0022](WORK_LOG.md#act-0022)

保留 375 MHz core-only 结果，暂不增加针对该频率的优化。Default-group setup/hold 违规仍须分析，降低 SCLK 不自动解决 removal。

### DEC-0005

**6LM 工艺** · [ACT-0014](WORK_LOG.md#act-0014)

保留 TSMC 180 nm HV BCD 6LM/1P6M 工艺选项。

### DEC-0006

**普通信号布线** · [ACT-0021](WORK_LOG.md#act-0021)

M1–M4。

### DEC-0007

**Tie-off** · [ACT-0014](WORK_LOG.md#act-0014)

使用 foundry TIEH/TIEL，逻辑常量直连电源网只用于导入诊断。

### DEC-0008

**GDS 分辨率** · [ACT-0023](WORK_LOG.md#act-0023)

1000 DBU/µm 用于当前 Stream-In 基线。保留 rounding 与 LVS label 识别待审事项。

### DEC-0009

**BND 151/0** · [ACT-0025](WORK_LOG.md#act-0025)

保留标准单元 merge 继承的辅助 geometry 和原 TSMC map；最终提交是否保留等待 foundry 要求。

### DEC-0010

**DRC deck 管理** · [ACT-0024](WORK_LOG.md#act-0024)

原始 PDK 保持原样，使用本地工作副本。

### DEC-0011

**SubToGround** · [ACT-0029](WORK_LOG.md#act-0029)

当前关闭，开启决定待定。原始 deck 默认假设 substrate 未接地，NBL.R.1 只在未定义 SubToGround 时编译。CKBD16 的 P+ contact geometry、VSS TEXT 和 Innovus VSS PG 证据支持该 master 的 cell-level tap；全设计 tap 与 substrate 连续性未知。先取得全设计证据并确认工艺适用性，再决定是否开启；如进行 A/B，保留原始 baseline，使用独立目录和 deck，对比所有相关规则。

### DEC-0012

**检查边界** · [ACT-0022](WORK_LOG.md#act-0022)

Innovus physical checks 用于其实现范围。Foundry signoff 使用 Calibre，仍在进行。

### DEC-0013

**M7B reference checkpoint** · [ACT-0026](WORK_LOG.md#act-0026)

使用已恢复验证的 checkpoint 作为当前 GDS 来源；其他候选 checkpoint 的先后关系尚待比较。

### DEC-0014

**Final GDS freeze** · [ACT-0024](WORK_LOG.md#act-0024)

待 foundry DRC/LVS/PEX 和后续 die 验证。

### DEC-0015

**61 pF 驱动评估** · [ACT-0016](WORK_LOG.md#act-0016)

WC fixed-netlist pre-layout 10 MHz slack +39.012 ns；迁移包记录当前没有证据要求为此新增普通 core-side buffer，最终 post-layout 仍需验证。

### DEC-0016

**7A annotation 配置** · [ACT-0019](WORK_LOG.md#act-0019)

启用 Xcelium `+define+NTC+RECREM` 并保留 4 条 XOR2D1 警告；保留供应商模型和原始 SDF。

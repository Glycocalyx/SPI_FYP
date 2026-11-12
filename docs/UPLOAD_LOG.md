# 服务器文件上传记录

来源为 Historical Migration Package I 节。历史 `UPLOADED` 条目有迁移包提供的 Git 记录，并在基准提交 `7f1ad9f` 的文件树中可见。其他条目缺少本仓库上传完成证据。专用 archive 的用户报告不计作上传至项目仓库。

服务器变量和文件用途见 [文件索引](ARTIFACT_INDEX.md)。

| ID | 迁移包决定 | 来源 | GitHub 目标 | 原因 | 执行状态 | 完成证据 | 关联活动 / 验证 |
|---|---|---|---|---|---|---|---|
| UP-0001 | UPLOAD_REQUIRED | $BASE/check_metal1_boundary.py | scripts/physical_verification/check_metal1_boundary.py | BND 来源检查 | APPROVED_PENDING | — | [ACT-0025](WORK_LOG.md#act-0025) / [VER-0044](TEST_LEDGER.md#ver-0044)、[VER-0045](TEST_LEDGER.md#ver-0045) |
| UP-0002 | UPLOAD_REQUIRED | $BASE/compare_metal1_boundary.py | scripts/physical_verification/compare_metal1_boundary.py | source/merged GDS 几何比较 | APPROVED_PENDING | — | [ACT-0025](WORK_LOG.md#act-0025) / [VER-0044](TEST_LEDGER.md#ver-0044)、[VER-0045](TEST_LEDGER.md#ver-0045) |
| UP-0003 | UPLOAD_REQUIRED | $BASE/inspect_ckbd16_substrate.py | scripts/physical_verification/inspect_ckbd16_substrate.py | CKBD16 geometry 检查 | APPROVED_PENDING | — | [ACT-0027](WORK_LOG.md#act-0027) / [VER-0051](TEST_LEDGER.md#ver-0051)、[VER-0059](TEST_LEDGER.md#ver-0059) |
| UP-0004 | UPLOAD_REQUIRED | $BASE/verify_ckbd16_p_substrate_tie.py | scripts/physical_verification/verify_ckbd16_p_substrate_tie.py | P+ contact containment | APPROVED_PENDING | — | [ACT-0029](WORK_LOG.md#act-0029) / [VER-0059](TEST_LEDGER.md#ver-0059) |
| UP-0005 | UPLOAD_REQUIRED | $BASE/read_ckbd16_text.py | scripts/physical_verification/read_ckbd16_text.py | GDS TEXT label 提取 | APPROVED_PENDING | — | [ACT-0029](WORK_LOG.md#act-0029) / [VER-0058](TEST_LEDGER.md#ver-0058) |
| UP-0006 | UPLOAD_REQUIRED | $WORK/spi_slave.drc.summary | docs/evidence/m7d/calibre_drc_baseline_20261108/spi_slave.drc.summary | 原始 DRC baseline | APPROVED_PENDING | — | [ACT-0024](WORK_LOG.md#act-0024) / [VER-0043](TEST_LEDGER.md#ver-0043) |
| UP-0007 | UPLOAD_OPTIONAL | $WORK/_calibre_spi_slave_core.drc_ | docs/evidence/m7d/calibre_drc_baseline_20261108/run_config.svrf | 记录 GUI run configuration | OPTIONAL_PENDING | — | [ACT-0024](WORK_LOG.md#act-0024) / [VER-0043](TEST_LEDGER.md#ver-0043) |
| UP-0008 | UPLOAD_OPTIONAL | $WORK/spi_slave.drc.results | docs/evidence/m7d/calibre_drc_baseline_20261108/spi_slave.drc.results | 详细 marker，1.7 MB，暂留服务器 | DEFERRED | — | [ACT-0024](WORK_LOG.md#act-0024) / [VER-0043](TEST_LEDGER.md#ver-0043) |
| UP-0009 | DO_NOT_UPLOAD | $BASE/calibre_spi_slave_core.drc | — | 受许可 foundry deck | EXCLUDED_FROM_SOURCE_REPO | — | [ACT-0024](WORK_LOG.md#act-0024) / [VER-0043](TEST_LEDGER.md#ver-0043) |
| UP-0010 | DO_NOT_UPLOAD | TSMC standard-cell GDS（路径未给出） | — | 受许可 GDS | EXCLUDED_FROM_SOURCE_REPO | — | [ACT-0025](WORK_LOG.md#act-0025) / [VER-0044](TEST_LEDGER.md#ver-0044) |
| UP-0011 | DO_NOT_UPLOAD | TSMC LEF / Liberty（路径未给出） | — | 受许可工艺数据 | EXCLUDED_FROM_SOURCE_REPO | — | [ACT-0014](WORK_LOG.md#act-0014) / [VER-0016](TEST_LEDGER.md#ver-0016) |
| UP-0012 | DO_NOT_UPLOAD | TSMC Verilog timing model（路径未给出） | — | 受许可工艺数据 | EXCLUDED_FROM_SOURCE_REPO | — | [ACT-0019](WORK_LOG.md#act-0019) / [VER-0024](TEST_LEDGER.md#ver-0024)、[VER-0025](TEST_LEDGER.md#ver-0025) |
| UP-0013 | DO_NOT_UPLOAD | $CORE_GDS | — | 包含合并的受许可 standard-cell geometry | EXCLUDED_FROM_SOURCE_REPO | — | [ACT-0028](WORK_LOG.md#act-0028) / [VER-0057](TEST_LEDGER.md#ver-0057) |
| UP-0014 | DO_NOT_UPLOAD | Innovus `.enc`（见 checkpoint registry） | — | 大型实现数据库与 PDK/tool 依赖 | EXCLUDED_FROM_SOURCE_REPO | — | [ACT-0026](WORK_LOG.md#act-0026) / [VER-0046](TEST_LEDGER.md#ver-0046) |
| UP-0015 | DO_NOT_UPLOAD | Innovus `.enc.dat`（见 checkpoint registry） | — | 与 `.enc` 配套的实现数据库 | EXCLUDED_FROM_SOURCE_REPO | — | [ACT-0026](WORK_LOG.md#act-0026) / [VER-0046](TEST_LEDGER.md#ver-0046) |
| UP-0016 | DO_NOT_UPLOAD | core_final_rc_propagated_clock_20261017_1835.tar.gz | — | 专用 checkpoint archive；已归档为 USER_REPORTED | EXCLUDED_FROM_SOURCE_REPO | — | [ACT-0026](WORK_LOG.md#act-0026) / [VER-0046](TEST_LEDGER.md#ver-0046) |
| UP-0017 | ALREADY_IN_REPOSITORY | 原服务器源路径未提供 | innovus/reports/final_sta/ | 7B final STA | UPLOADED | 迁移包 I4；基准提交文件树 | [ACT-0022](WORK_LOG.md#act-0022) / [VER-0033](TEST_LEDGER.md#ver-0033)、[VER-0034](TEST_LEDGER.md#ver-0034) |
| UP-0018 | ALREADY_IN_REPOSITORY | 原服务器源路径未提供 | innovus/reports/m7b_sta_state_*.rpt | 7B DRC/regular/special reports | UPLOADED | 迁移包 I4；基准提交文件树 | [ACT-0022](WORK_LOG.md#act-0022) / [VER-0035](TEST_LEDGER.md#ver-0035)、[VER-0036](TEST_LEDGER.md#ver-0036)、[VER-0037](TEST_LEDGER.md#ver-0037) |
| UP-0019 | ALREADY_IN_REPOSITORY | 原服务器源路径未提供 | innovus/reports/m7b_restore_check_20261111/ | 7B restore reports | UPLOADED | 迁移包 I4；基准提交文件树 | [ACT-0026](WORK_LOG.md#act-0026) / [VER-0047](TEST_LEDGER.md#ver-0047)、[VER-0048](TEST_LEDGER.md#ver-0048)、[VER-0049](TEST_LEDGER.md#ver-0049) |
| UP-0020 | ALREADY_IN_REPOSITORY | 原服务器源路径未提供 | docs/evidence/m7c/streamOut_bcd_candidate.map | 7C stream-out map | UPLOADED | 迁移包 I4；基准提交文件树 | [ACT-0023](WORK_LOG.md#act-0023) / [VER-0039](TEST_LEDGER.md#ver-0039) |
| UP-0021 | ALREADY_IN_REPOSITORY | 原服务器源路径未提供 | docs/evidence/m7c/source_manifest.txt | 7C manifest | UPLOADED | 迁移包 I4；基准提交文件树 | [ACT-0023](WORK_LOG.md#act-0023) / [VER-0039](TEST_LEDGER.md#ver-0039)、[VER-0040](TEST_LEDGER.md#ver-0040) |
| UP-0022 | ALREADY_IN_REPOSITORY | 原服务器源路径未提供 | docs/milestone_*.md | 里程碑文档 | UPLOADED | 迁移包 I4；基准提交文件树 | [ACT-0024](WORK_LOG.md#act-0024) / [VER-0043](TEST_LEDGER.md#ver-0043) |
| UP-0023 | ALREADY_IN_REPOSITORY | 原服务器源路径未提供 | docs/active_checkpoint_registry.md | 活动 checkpoint 记录 | UPLOADED | 迁移包 I4；基准提交文件树 | [ACT-0026](WORK_LOG.md#act-0026) / [VER-0046](TEST_LEDGER.md#ver-0046) |

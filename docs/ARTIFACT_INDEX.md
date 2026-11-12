# 工程文件索引

仓库路径按基准 Git 文件树核对。服务器位置来自 Historical Migration Package E、I 节。

| 记录 | 仓库位置 |
|---|---|
| RTL 与各 PAD wrapper | [rtl](../rtl/) |
| 原始及 16-bit verification testbenches | [tb](../tb/)（behavioral model 位于 `tb/spi_slave_model.sv`） |
| 7A post-route testbenches | [post_sim](../post_sim/) |
| Genus timing、固定网表各实验脚本和报告 | [syn](../syn/) · [各阶段文档](milestones/README.md) |
| Innovus full IO import、floorplan、PAD 与 MMMC 脚本 | [innovus](../innovus/) |
| 7B 375 MHz STA | [final_sta](../innovus/reports/final_sta/) |
| 7B DRC 与 regular/special connectivity | [reports](../innovus/reports/) 中 `m7b_sta_state_*.rpt` |
| 7B 2026-11-11 restore reports | [m7b_restore_check_20261111](../innovus/reports/m7b_restore_check_20261111/) |
| 7C manifest 与 stream-out map | [evidence/m7c](evidence/m7c/) |

## 服务器位置

相对服务器路径以 `/staff/ee/yliumb/spi-fyp` 为根。上传台账中 `$BASE` 为此根目录下的 `virtuoso_import_hvbcd_20261029`，`$WORK` 为 `$BASE/drc_run_core_20261108`。

| 文件或目录 | 记录用途 |
|---|---|
| `innovus/db/m6b_import.enc`、`m6c_floorplan.enc`、`m6c_pad_placed.enc` | 6B/6C checkpoint |
| `innovus/db/m7b_restore_check/core_final_rc_propagated_clock.enc` 及对应 `.enc.dat` | 当前 GDS 参考 checkpoint，其他候选见 [registry](active_checkpoint_registry.md) |
| `/staff/ee/yliumb/spi-fyp-backups/core_final_rc_propagated_clock_20261017_1835.tar.gz` | 独立 private archive 保存情况为 USER_REPORTED |
| `syn/outputs/spi_slave_csb_async_110MHz_5pF.v` | 固定 gate-level 网表，供 5D/5E 使用 |
| `innovus/reports/m7b_streamout_probe_20261020/spi_slave_core_merged_1000dbu_test.gds` | `$CORE_GDS`，见 [SHA256 和来源](active_checkpoint_registry.md#4-current-gds-and-drc-baseline) |
| `$BASE/strmIn.log` | 后续 standard-cell import 覆盖的日志，原 SPI top-level 日志未恢复 |
| `$BASE/calibre_spi_slave_core.drc` | 本地 DRC deck |
| `$WORK/spi_slave.drc.summary`、`spi_slave.drc.results`、`_calibre_spi_slave_core.drc_` | 原始 DRC summary、marker results、GUI run config |
| `$BASE/check_metal1_boundary.py`、`compare_metal1_boundary.py` | BND 检查及 source/merged geometry 比较 |
| `$BASE/inspect_ckbd16_substrate.py`、`verify_ckbd16_p_substrate_tie.py`、`read_ckbd16_text.py` | CKBD16 geometry、P+ contact containment、GDS TEXT 提取 |

迁移包把 behavioral model 列在 `rtl/`，基准树中实际位于 `tb/`。`innovus/run_core_import.tcl` 在迁移包中有引用，基准树未收录，当前位置为 UNKNOWN。上传决定见 [UPLOAD_LOG](UPLOAD_LOG.md)。

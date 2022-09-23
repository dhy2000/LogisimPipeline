测试电路: `tb-pipeline.circ`，导入机器码后的被测 CPU 命名为 `test.circ`

Python 辅助脚本: 

- `load_rom.py`: 将机器码 `code.txt` 导入被测 circ 电路中的 ROM ，生成 `test.circ`
- `table_convert.py`: 将 Logisim 命令行得到的二进制 Log 整理成 CPU 输出的格式。

CPU 行为检查程序: [cpu-checker](https://github.com/dhy2000/cpu-checker)

Logisim 和 Mars 分别命名为 `logisim.jar` 和 `Mars.jar`

测试用例（汇编程序）放在 `tests/asms/` （相对仓库根目录）

在当前 `autotest` 目录执行 `bash ./autotest.sh` 开始运行自动测试。
# Logisim Mips Pipeline

支持 MIPS 42 条指令:

- `add`, `sub`, `addu`, `subu`, `and`, `or`, `xor`, `nor`
- `addi`, `addiu`, `andi`, `ori`, `xori`, `lui`
- `slt`, `slti`, `sltu`, `sltiu`
- `sll`, `srl`, `sra`, `sllv`, `srlv`, `srav`
- `lw`, `sw`, `lb`, `lbu`, `lh`, `lhu`, `sb`, `sh`
- `beq`, `bne`, `bgez`, `bgtz`, `blez`, `bltz`
- `j`, `jal`, `jr`, `jalr`

多用探针，功能部件可以把状态暴露出来，便于调试

## 功能部件

### GRF

注意内部转发

### PC

PC 和 NPC 放一起，整体作为一个状态部件

### ALU

OK

### CMP

D 级分支比较器

OK

### EXT

16 位立即数扩展器

OK

### MemAddr

访存地址处理模块，生成按字的地址和字节写使能 Byte Enable 信号

### MemExt

访存后 lb/lh 扩展模块

### 存储器

IM: 16KB - 4K Word
DM: 16KB - 4K Word


## 译码与控制器设计

### 识别指令

与逻辑，采用实例化多个比较器的方式。

指令格式:

- R 型: `opcode` 和 `funct`
- I 型: `opcode` (对于 `bgez` 和 `bltz` 需要看 `rt`)
- J 型: `opcode`

### 需译出信号

由于在 Logisim 中，难以传递 "指令名称" 信号，所以采用集中式译码。

1. 寄存器使用 (与转发暂停相关)
  - `AddrRs`, `AddrRt`, `TuseRs`, `TuseRt`, `UseRs`, `UseRt`
2. 寄存器写入 (与转发暂停相关)
  - `RegWrite`, `RegDst`, `RegSrc`, `Tnew`
3. 功能部件及数据通路
  - `AluSrc1` (`rs` / `shamt`), `AluSrc2` (`rt` / `imm16`)
  - `NpcOp`, `AluOp`, `CmpOp`, `ExtOp`
4. 访存相关信号 (和功能部件类似)
  - `MemWrite`, `MemSz` (01: byte, 10: half, 11: word), `MemExt` (0: unsigned, 1: signed)

### 信号定义

- `ALU.AluOp`: 5 bits
  - `0`: Zero
  - `1`: Src1
  - `2`: Src2
  - `3`: Addu
  - `4`: Subu
  - `5`: And
  - `6`: Or
  - `7`: Xor
  - `8`: Nor
  - `9`: Slt
  - `10`: Sltu
  - `11`: Sll
  - `12`: Srl
  - `13`: Sra
- `CMP.CmpOp`: 5 bits
  - `0`: False
  - `1`: True
  - `2`: Eq
  - `3`: Ne
  - `4`: Gtz
  - `5`: Ltz
  - `6`: Gez
  - `7`: Lez
- `PC.NpcOp`: 3 bits
  - `0`: Raw
  - `1`: Branch
  - `2`: Jump
  - `3`: Jr
- `EXT.ExtOp`: 2 bits
  - `0`: ZeroExt
  - `1`: SignExt
  - `2`: LuiExt
- `AluSrc1`: 1 bit
  - `0`: Data_rs
  - `1`: Shamt
- `AluSrc2`: 1 bit
  - `0`: Data_rt
  - `1`: ExtImm
- `MemWrite`: 1 bit
- `MemSz`: 2 bits
  - `00`: Undefined
  - `01`: Byte
  - `10`: Half
  - `11`: Word
- `MemExt`: 1 bit
  - `0`: ZeroExt
  - `1`: SignExt
- `RegDst`: 3 bits, Addr to write Register
  - `0`: Rd
  - `1`: Rt
  - `2`: Ra (31)
- `RegSrc`: 3 bits, Data to write register
  - `0`: PC + 8
  - `1`: Lui
  - `2`: AluOut
  - `3`: MemRead (lw)
- `Tuse`: 3 bits, use at:   D=0, E=1, M=2, W=3
- `Tnew`: 3 bits, fwd from: D=0, E=1, M=2, W=3
  - dec by 1 per stage

## 流水线设计

### 流水信号

- PC, Code
- 寄存器使用 (`Rs`/`Rt`): `Addr`, `Tuse`, `Use`, `Data`
- 寄存器结果 `W`, `A`, `D`
- Op 控制信号

### 转发单元

自动转发，总共 5 个需转发的位点, 每个位点实例化一个转发单元。

```verilog
input W0, W1, W2;
input [4:0] A0, A1, A2;
input [31:0] D0, D1, D2;
output W;
output [4:0] A;
output [31:0] D;

assign W = W0;
assign A = A0;
assign D =  (W1 && (A1 == A0) && (A1 != 0)) ? (D1) :     // Fwd1
            (W2 && (A2 == A0) && (A2 != 0)) ? (D2) : D0; // Fwd2 : NoFwd

```

### 暂停单元


全局用一个，暂停控制器。暂停控制器的输入是 D 级的 Use 情况和 E/M 级的 New 情况。

输入: D 级的两个 Use, E 级的 New 和 M 级的 New。

```verilog
assign waitRs = (useRs_D & (addrRs_D != 0)) && (
  ((regWEn_E) & ((regWAddr_E == addrRs_D)) & (Tnew_E > TuseRs_D)) ||
  ((regWEn_M) & ((regWAddr_M == addrRs_D)) & (Tnew_M > TuseRs_D))
);
assign waitRt = (useRt_D & (addrRt_D != 0)) && (
  ((regWEn_E) & ((regWAddr_E == addrRt_D)) & (Tnew_E > TuseRt_D)) ||
  ((regWEn_M) & ((regWAddr_M == addrRt_D)) & (Tnew_M > TuseRt_D))
);

assign stall = waitRs | waitRt;
```

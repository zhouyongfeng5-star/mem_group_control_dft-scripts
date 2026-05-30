# Tcl 与 DFT 脚本命令参考

本文档整理了 [mem_dft_setup.tcl](C:\Users\LostamBygone\Documents\Codex\2026-05-30\bin-bash-for-f-in-hex\mem_dft_setup.tcl) 中使用到的 Tcl 语法、常用命令，以及脚本所依赖的 DFT 工具命令。最后附上上传到 Git 的标准步骤。

## 1. `set`

### 语法

```tcl
set varName value
set varName
```

### 用法

- `set varName value`
  给变量赋值。
- `set varName`
  读取变量当前值。

### 示例

```tcl
set mem_testpins {LS DS SD}
set signal_name WPULSE0
set count 0
```

---

## 2. `proc`

### 语法

```tcl
proc procName {arg1 arg2 ...} {
    body
}
```

### 用法

- 定义一个 Tcl 过程，作用类似函数。
- 参数列表写在第二个花括号里。
- 过程体写在第三个花括号里。

### 示例

```tcl
proc normalize_mem_testpin_name {pin_name} {
    return $pin_name
}
```

---

## 3. `if`

### 语法

```tcl
if {condition} {
    body1
} elseif {condition2} {
    body2
} else {
    body3
}
```

### 用法

- 根据条件选择执行分支。
- 条件表达式写在花括号中。

### 示例

```tcl
if {$reset_flag} {
    register_static_dft_signal_names [list $signal_name] -reset_value 1
} else {
    register_static_dft_signal_names [list $signal_name]
}
```

---

## 4. `foreach`

### 语法

```tcl
foreach varName $listValue {
    body
}
```

### 用法

- 逐个遍历 list 中的元素。

### 示例

```tcl
foreach pin $mem_testpins {
    puts $pin
}
```

---

## 5. `switch`

### 语法

```tcl
switch -- $value {
    pattern1 { body1 }
    pattern2 { body2 }
    default  { body3 }
}
```

### 用法

- 根据变量值匹配不同分支。
- `--` 表示后面不再解析为选项。

### 示例

```tcl
switch -- $profile_name {
    single_rail_sram0 { set pin_profile $single_rail_sram0_profile }
    rom               { set pin_profile $rom_profile }
    default           { continue }
}
```

---

## 6. `regexp`

### 语法

```tcl
regexp pattern string
regexp pattern string matchVar subMatch1 subMatch2
```

### 用法

- 用正则表达式匹配字符串。
- 返回值：
  - 匹配成功返回 `1`
  - 匹配失败返回 `0`
- 可以把匹配结果拆到变量里。

### 示例

```tcl
regexp {^(.*)\[([0-9]+)\]$} $pin_name -> base idx
```

这句的含义：

- `^`：字符串开头
- `(.*)`：匹配前缀部分，保存到 `base`
- `\[([0-9]+)\]`：匹配 `[数字]`，数字保存到 `idx`
- `$`：字符串结尾

如果：

```tcl
set pin_name "WPULSE[2]"
```

则：

```tcl
base = WPULSE
idx  = 2
```

---

## 7. `string match`

### 语法

```tcl
string match pattern string
```

### 用法

- 按通配符模式匹配字符串。
- 常见通配符：
  - `*`：任意长度任意字符
  - `?`：任意单个字符

### 示例

```tcl
string match "*sarel*" $module_name
```

表示判断 `module_name` 中是否包含 `sarel`。

---

## 8. `list`

### 语法

```tcl
list item1 item2 item3
```

### 用法

- 显式构造一个 Tcl list。
- 对带空格、带 `[]`、带特殊字符的内容很有用。

### 示例

```tcl
register_static_dft_signal_names [list $signal_name]
get_pins [list $pin] -of_instance $sram_full_path_name -silent
```

这里的好处是像 `RM[0]`、`WPULSE[1]` 这种带方括号的 pin 名不会被 Tcl 误解析。

---

## 9. `lappend`

### 语法

```tcl
lappend listVar value
lappend listVar value1 value2 ...
```

### 用法

- 往 list 变量末尾追加元素。

### 示例

```tcl
lappend mem_testpin_signal_list $signal_name
lappend hookup_report [list $type $inst $pin]
```

---

## 10. `llength`

### 语法

```tcl
llength $listValue
```

### 用法

- 返回 list 元素个数。

### 示例

```tcl
if {[llength $pin_list] == 0} {
    continue
}
```

表示如果没找到 pin，就跳过当前循环。

---

## 11. `lindex`

### 语法

```tcl
lindex $listValue index
```

### 用法

- 取 list 中指定位置的元素。
- 索引从 `0` 开始。

### 示例

```tcl
set module_name [lindex $module_name 0]
```

---

## 12. `lassign`

### 语法

```tcl
lassign $listValue var1 var2 var3
```

### 用法

- 把 list 中的元素依次拆给多个变量。

### 示例

```tcl
lassign $pin_spec physical_pin signal_name reset_flag
```

如果：

```tcl
set pin_spec {RM[0] single_rail_sram0_RM0 1}
```

则：

```tcl
physical_pin = RM[0]
signal_name  = single_rail_sram0_RM0
reset_flag   = 1
```

---

## 13. `incr`

### 语法

```tcl
incr varName
incr varName increment
```

### 用法

- 对整数变量自增。

### 示例

```tcl
incr signal_summary_count($signal_name)
```

---

## 14. `continue`

### 语法

```tcl
continue
```

### 用法

- 跳过当前这次循环，进入下一次循环。

### 示例

```tcl
if {[llength $pin_list] == 0} {
    continue
}
```

---

## 15. `return`

### 语法

```tcl
return value
```

### 用法

- 从过程返回结果。

### 示例

```tcl
return "single_rail_sram0"
```

---

## 16. `puts`

### 语法

```tcl
puts "message"
```

### 用法

- 在终端打印日志。

### 示例

```tcl
puts "INFO: add_dft_control_point $pin_full_path -dft_signal_source_name $signal_name"
```

---

## 17. `format`

### 语法

```tcl
format formatString arg1 arg2 ...
```

### 用法

- 生成格式化字符串，适合对齐表格输出。

### 示例

```tcl
format "%-18s %-40s %-24s" $type $inst $module
```

含义：

- `%-18s`：左对齐字符串，宽度 18
- `%-40s`：左对齐字符串，宽度 40

---

## 18. `lsort`

### 语法

```tcl
lsort $listValue
```

### 用法

- 对 list 排序。

### 示例

```tcl
foreach signal_name [lsort [array names signal_summary_count]] {
    ...
}
```

---

## 19. `array`

### 语法

```tcl
set arrName(key) value
array names arrName
array unset arrName
```

### 用法

- Tcl 中的 `array` 是“关联数组”，也就是 key-value 映射。
- 适合做名字映射、计数器、分类存储。

### 示例

```tcl
set mem_testpin_signal_map(WPULSE[0]) WPULSE0
set signal_summary_count(single_rail_sram0_RM0) 3
```

### 常见操作

```tcl
array unset mem_testpin_signal_map
```

- 清空整个 array。

```tcl
array names signal_summary_count
```

- 获取所有 key。

---

## 20. `info exists`

### 语法

```tcl
info exists varName
```

### 用法

- 判断变量是否存在。
- 对 array 元素也适用。

### 示例

```tcl
if {![info exists signal_summary_count($signal_name)]} {
    set signal_summary_count($signal_name) 0
}
```

---

## 21. `upvar`

### 语法

```tcl
upvar otherVar localAlias
```

### 用法

- 在过程内部引用外部变量，类似“传引用”。

### 示例

```tcl
proc ensure_dft_signal_registered {signal_name reset_flag registered_array_name} {
    upvar $registered_array_name registered_signals
    ...
}
```

这里 `registered_signals` 实际上映射到了调用者传入的 array 名。

---

## 22. DFT 工具命令

下面这些不是 Tcl 内建命令，而是你所在 EDA/DFT 工具环境提供的命令。

### 22.1 `get_memory_inst`

#### 语法

```tcl
get_memory_inst
```

#### 用法

- 获取 design 中所有 memory instance 对象集合。

#### 示例

```tcl
set sram_full_path_list [get_name_list [get_memory_inst]]
```

---

### 22.2 `get_name_list`

#### 语法

```tcl
get_name_list object_collection
```

#### 用法

- 把工具对象集合转换成 Tcl 可遍历的名字列表。

#### 示例

```tcl
get_name_list [get_memory_inst]
get_name_list [get_pins [list $pin] -of_instance $sram_full_path_name -silent]
```

---

### 22.3 `get_module`

#### 语法

```tcl
get_module -of_instance instance_name
```

#### 用法

- 根据 instance 查询它对应的 module。

#### 示例

```tcl
set module_name [get_name_list [get_module -of_instance $sram_full_path_name]]
```

---

### 22.4 `get_pins`

#### 语法

```tcl
get_pins pin_name -of_instance instance_name
get_pins pin_name -of_instance instance_name -silent
```

#### 用法

- 在指定 instance 上查找 pin。
- `-silent` 表示找不到时不报错。

#### 示例

```tcl
get_pins [list RM[0]] -of_instance $sram_full_path_name -silent
get_pins [list WPULSE[1]] -of_instance $sram_full_path_name -silent
```

---

### 22.5 `register_static_dft_signal_names`

#### 语法

```tcl
register_static_dft_signal_names signal_list
register_static_dft_signal_names signal_list -reset_value 1
```

#### 用法

- 注册静态 DFT 信号名。
- 如果该信号需要默认 reset 为 1，则加 `-reset_value 1`。

#### 示例

```tcl
register_static_dft_signal_names $mem_testpin_signal_list
register_static_dft_signal_names [list single_rail_sram0_RM0] -reset_value 1
```

---

### 22.6 `add_dft_signals`

#### 语法

```tcl
add_dft_signals signal_list -create_with_tdr
```

#### 用法

- 把 DFT 信号加入设计，并创建对应的 TDR。

#### 示例

```tcl
add_dft_signals $mem_testpin_signal_list -create_with_tdr
add_dft_signals [list $signal_name] -create_with_tdr
```

---

### 22.7 `add_dft_control_point`

#### 语法

```tcl
add_dft_control_point pin_full_path -dft_signal_source_name signal_name
```

#### 用法

- 把真实 pin 接到指定 DFT signal 上。

#### 示例

```tcl
add_dft_control_point top/u_mem0/LS -dft_signal_source_name LS
add_dft_control_point top/u_mem0/RM[0] -dft_signal_source_name single_rail_sram0_RM0
```

---

## 23. 脚本里的典型语句拆解

### 示例 1

```tcl
set pin_list [get_name_list [get_pins [list $pin] -of_instance $sram_full_path_name -silent]]
```

分解含义：

1. `get_pins [list $pin] -of_instance $sram_full_path_name -silent`
   在指定 SRAM instance 上查 pin。
2. `get_name_list [...]`
   把对象结果转成 Tcl list。
3. `set pin_list [...]`
   保存到变量 `pin_list`。

---

### 示例 2

```tcl
if {[llength $pin_list] == 0} {
    continue
}
```

分解含义：

1. `llength $pin_list`
   看看找到几个 pin。
2. 如果是 `0`
   说明这个 instance 上没有该 pin。
3. `continue`
   跳过当前循环。

---

### 示例 3

```tcl
lassign $pin_spec physical_pin signal_name reset_flag
```

分解含义：

如果：

```tcl
set pin_spec {RM[0] single_rail_sram0_RM0 1}
```

那么拆出来就是：

```tcl
physical_pin = RM[0]
signal_name  = single_rail_sram0_RM0
reset_flag   = 1
```

---

## 24. Git 上传步骤

下面是标准的 Git 提交流程，适用于你已经有一个 Git 仓库并且本机已经安装了 Git 的情况。

### 24.1 检查当前目录

```powershell
git status
```

### 24.2 查看新文件

当前新增的重要文件通常包括：

- [mem_dft_setup.tcl](C:\Users\LostamBygone\Documents\Codex\2026-05-30\bin-bash-for-f-in-hex\mem_dft_setup.tcl)
- [tcl_command_reference.md](C:\Users\LostamBygone\Documents\Codex\2026-05-30\bin-bash-for-f-in-hex\tcl_command_reference.md)

### 24.3 添加文件到暂存区

```powershell
git add mem_dft_setup.tcl tcl_command_reference.md
```

如果还要把之前的脚本一起提交：

```powershell
git add mem_dft_setup.tcl tcl_command_reference.md set_sram_rom_content.tcl hex_to_bin.sh
```

### 24.4 再次确认暂存内容

```powershell
git status
```

### 24.5 提交

```powershell
git commit -m "Add memory DFT setup script and Tcl command reference"
```

### 24.6 推送到远端分支

如果当前分支已经关联远端：

```powershell
git push
```

如果是第一次推送当前分支：

```powershell
git push -u origin <branch-name>
```

例如：

```powershell
git push -u origin main
```

---

## 25. 当前环境注意点

我在当前 PowerShell 环境里尝试执行了：

```powershell
git status
```

结果显示 `git` 命令不可用。这通常表示：

- 本机没有安装 Git
- 或者 Git 没有加入 `PATH`
- 或者当前终端环境没有加载到 Git 的路径

### 如果当前机器还没装 Git

可以先安装 Git for Windows，然后重新打开终端再执行上面的命令。

### 如果已经安装 Git 但命令不可用

可以检查：

```powershell
where.exe git
```

如果能找到路径，再重新开一个 PowerShell 终端通常就可以。

---

## 26. 推荐提交说明

如果你想把这次内容拆成更清晰的提交信息，可以参考：

```text
Add memory DFT hookup Tcl script
```

或者：

```text
Add Tcl reference doc for memory DFT flow
```

如果合并成一次提交：

```text
Add memory DFT setup script and Tcl reference
```

---

## 27. `regexp` 速查表

这一节把脚本里最常见的正则写法集中列出来，方便你后续自己改 pin 名、module 名匹配规则。

### 27.1 常用元字符

| 写法 | 含义 |
| --- | --- |
| `^` | 匹配字符串开头 |
| `$` | 匹配字符串结尾 |
| `.` | 匹配任意单个字符 |
| `*` | 前一个模式重复 0 次或多次 |
| `+` | 前一个模式重复 1 次或多次 |
| `?` | 前一个模式重复 0 次或 1 次 |
| `(...)` | 分组，并可提取子匹配 |
| `[0-9]` | 匹配一个数字 |
| `[A-Za-z]` | 匹配一个字母 |
| `[^/]` | 匹配一个不是 `/` 的字符 |
| `\[` | 匹配字面量 `[` |
| `\]` | 匹配字面量 `]` |

### 27.2 常见示例

#### 示例 1：匹配 bus pin

```tcl
regexp {^(.*)\[([0-9]+)\]$} $pin_name -> base idx
```

作用：

- 匹配像 `WPULSE[0]`、`RM[3]` 这样的名字
- `base` 提取前缀
- `idx` 提取数字下标

示例结果：

| 输入 | `base` | `idx` |
| --- | --- | --- |
| `WPULSE[0]` | `WPULSE` | `0` |
| `RM[3]` | `RM` | `3` |

#### 示例 2：匹配固定前缀

```tcl
regexp {^single_rail_sram0_} $signal_name
```

作用：

- 判断字符串是否以 `single_rail_sram0_` 开头。

#### 示例 3：匹配层级路径最后一级

```tcl
regexp {^(.*)/[^/]+$} $inst_name -> parent_path
```

作用：

- 把类似 `top/u_mem0/u_sram` 的字符串拆成：
  - `parent_path = top/u_mem0`

#### 示例 4：匹配多个候选类型

```tcl
if {[string match "*sarel*" $module_name] || [string match "*sadul*" $module_name]} {
    ...
}
```

这里虽然不是 `regexp`，但它表达的是“多个模式命中其一”的场景。

### 27.3 `regexp` 常见坑

#### 1. 方括号必须转义

如果你要匹配字面量 `[` 或 `]`，需要写成：

```tcl
\[
\]
```

例如：

```tcl
regexp {\[0\]} $pin_name
```

#### 2. 最好把模式放在花括号里

推荐：

```tcl
regexp {^(.*)\[([0-9]+)\]$} $pin_name
```

不推荐：

```tcl
regexp "^(.*)\[([0-9]+)\]$" $pin_name
```

因为双引号里更容易被 Tcl 再做一层替换，调试起来更麻烦。

#### 3. `regexp` 返回 0/1，不是返回匹配字符串

例如：

```tcl
if {[regexp {^RM} $pin_name]} {
    puts "matched"
}
```

这里 `regexp` 返回的是是否匹配成功，不是把 `RM...` 直接返回出来。

#### 4. 提取分组时，变量数量要和分组数对应

例如：

```tcl
regexp {^(.*)\[([0-9]+)\]$} $pin_name -> base idx
```

这里有两个捕获分组，所以后面用两个变量 `base` 和 `idx` 来接。

### 27.4 适合当前脚本的几个常用模板

#### 提取 bus pin 下标

```tcl
regexp {^(.*)\[([0-9]+)\]$} $pin_name -> base idx
```

#### 判断是不是某类 memory module

```tcl
string match "*sadrl*" $module_name
```

#### 提取路径父层级

```tcl
regexp {^(.*)/[^/]+$} $inst_name -> parent_path
```

---

## 28. `array` 和 `list` 的区别总结

这两种结构在 Tcl 里都很常用，但用途完全不一样。你这份 DFT 脚本里两种都用到了。

### 28.1 `list` 是“有顺序的一串元素”

#### 特点

- 有顺序
- 通过位置访问
- 适合遍历
- 适合存 pin 列表、profile 列表、报表行

#### 示例

```tcl
set mem_testpins {LS DS SD}
```

这个 `mem_testpins` 是一个 list，里面有 3 个元素：

1. `LS`
2. `DS`
3. `SD`

#### 常见操作

```tcl
llength $mem_testpins
lindex $mem_testpins 0
foreach pin $mem_testpins { ... }
lappend mem_testpins WPULSE[0]
```

### 28.2 `array` 是“key-value 映射表”

#### 特点

- 无固定顺序
- 通过名字访问，不通过位置访问
- 适合做查表、计数、映射关系

#### 示例

```tcl
set mem_testpin_signal_map(WPULSE[0]) WPULSE0
set mem_testpin_signal_map(LS) LS
```

这里：

- key 是原始 pin 名
- value 是注册时使用的 signal 名

#### 常见操作

```tcl
set mem_testpin_signal_map($pin)
array names mem_testpin_signal_map
array unset mem_testpin_signal_map
info exists mem_testpin_signal_map($pin)
```

### 28.3 什么时候用 `list`

适合这些场景：

- 存一批 pin 名
- 存 profile 定义
- 存报表的一行一行数据
- 需要按顺序循环处理

例如：

```tcl
set mem_testpins {LS DS SD POFF}
set rom_profile {
    {RME rom_RME 1}
    {RM[0] rom_RM0 1}
}
```

### 28.4 什么时候用 `array`

适合这些场景：

- 某个 pin 对应哪个 signal
- 某个 signal 出现了多少次
- 某个 signal 是否注册过

例如：

```tcl
set signal_summary_count(rom_RME) 3
set registered_mem_rme_signals(single_rail_sram0_RM0) 1
```

### 28.5 在当前脚本中的对应关系

#### `list` 的例子

```tcl
set mem_testpins {LS DS SD POFF TEST1}
set hookup_report {}
set single_rail_sram0_profile {
    {RME single_rail_sram0_RME 1}
    {RM[0] single_rail_sram0_RM0 1}
}
```

这些都是“按元素顺序处理”的数据。

#### `array` 的例子

```tcl
set mem_testpin_signal_map(WPULSE[0]) WPULSE0
set signal_summary_count(single_rail_sram0_RM0) 5
set signal_summary_reset(single_rail_sram0_RM0) 1
```

这些都是“通过 key 快速查值”的数据。

### 28.6 一个直观对比

#### `list`

```tcl
set pins {LS DS SD}
```

你关心的是：

- 第 1 个是什么
- 第 2 个是什么
- 逐个遍历处理

#### `array`

```tcl
set pin_to_signal(LS) LS
set pin_to_signal(WPULSE[0]) WPULSE0
```

你关心的是：

- 给定 `LS`，它对应什么 signal
- 给定 `WPULSE[0]`，它映射到什么 signal

### 28.7 常见误区

#### 误区 1：把 `array` 当 `list` 遍历

错误思路：

```tcl
foreach item $mem_testpin_signal_map {
    ...
}
```

`array` 不能这样直接当普通 list 用。通常应写成：

```tcl
foreach key [array names mem_testpin_signal_map] {
    puts "$key -> $mem_testpin_signal_map($key)"
}
```

#### 误区 2：需要映射关系时却只用 `list`

例如如果你要表示：

- `WPULSE[0] -> WPULSE0`
- `WPULSE[1] -> WPULSE1`

那用 `array` 比用两个平行 list 更清晰，也更不容易写错。

---

## 29. 建议的学习顺序

如果你想尽快能自己改这类 Tcl/DFT 脚本，建议优先掌握下面这些内容：

1. `set`
2. `foreach`
3. `if`
4. `list` / `lappend` / `llength`
5. `array` / `info exists`
6. `regexp`
7. `proc`
8. `lassign`
9. 你们工具的对象命令：
   `get_memory_inst`、`get_pins`、`get_module`

---

## 30. 快速修改脚本时的思路

你以后改这类脚本时，可以按这个顺序检查：

1. 这个数据是“顺序列表”还是“名字映射”
   - 顺序列表用 `list`
   - 名字映射用 `array`

2. 这个匹配是“简单包含关系”还是“结构提取”
   - 简单包含通常用 `string match`
   - 需要拆前缀、下标、路径时用 `regexp`

3. 这个 pin 名带不带 `[]`
   - 如果带，传给工具命令时尽量用 `[list $pin]` 保护

4. 这个 DFT signal 需不需要去重注册
   - 如果一个 signal 可能被多个 instance 共用，就要像脚本里那样先查 `registered_signals`

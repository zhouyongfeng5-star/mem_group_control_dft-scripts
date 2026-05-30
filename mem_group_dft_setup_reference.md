# `mem_group_dft_setup.tcl` 命令语法说明

本文档专门解释 [mem_group_dft_setup.tcl](C:\Users\LostamBygone\Documents\Codex\2026-05-30\bin-bash-for-f-in-hex\mem_group_dft_setup.tcl) 中使用到的 Tcl 语法和 DFT 工具命令，重点说明：

- 输入变量应该怎么写
- 分组列表如何解析
- TDR 信号如何创建
- pin 如何查询和接管
- 表格和 CSV 如何输出

## 1. 脚本输入变量

这个脚本没有默认值，下面三个变量都必须由用户在 `source` 之前手动定义。

### 1.1 `mem_group`

#### 语法

```tcl
set mem_group [list \
    GROUP_NAME_0 INSTANCE_PATH_0 \
    GROUP_NAME_0 INSTANCE_PATH_1 \
    GROUP_NAME_1 INSTANCE_PATH_2 \
    GROUP_NAME_1 INSTANCE_PATH_3 \
]
```

#### 用法

- `mem_group` 是一个平铺的 Tcl list
- 每两个元素组成一组：
  - 第 1 个元素：group 名
  - 第 2 个元素：instance full path
- 同一个 group 可以出现多次，表示该 group 下有多个 SRAM instance

#### 示例

```tcl
set mem_group [list \
    C1 /da/dad/ada/mema \
    C1 /dsad/dsad/memb \
    C2 /top/u_memc \
    C2 /top/u_memd \
]
```

这个例子表示：

- `C1` 组有两个 instance
- `C2` 组有两个 instance

### 1.2 `mem_group_testpins`

#### 语法

```tcl
set mem_group_testpins {DS LS}
```

#### 用法

- 明确指定要处理哪些 pin
- 没有默认值，必须手动定义
- 列表里的每个 pin 都会按照最大 group 大小生成一组 TDR 信号

#### 示例

```tcl
set mem_group_testpins {DS LS}
```

如果最大 group 大小是 `4`，则会生成：

```text
DS0 DS1 DS2 DS3
LS0 LS1 LS2 LS3
```

### 1.3 `mem_group_rpt_dir`

#### 语法

```tcl
set mem_group_rpt_dir "./rpt"
```

#### 用法

- 指定 CSV 报表输出目录
- 没有默认值，必须手动定义

---

## 2. `source`

### 语法

```tcl
source file_name
```

### 用法

- 读取并执行指定 Tcl 脚本

### 示例

```tcl
source mem_group_dft_setup.tcl
```

---

## 3. `set`

### 语法

```tcl
set varName value
set varName
```

### 用法

- 给变量赋值
- 或读取变量当前值

### 示例

```tcl
set max_group_size 0
set mem_group_testpins {DS LS}
```

---

## 4. `list`

### 语法

```tcl
list item1 item2 item3
```

### 用法

- 构造一个 Tcl list
- 适合带空格或特殊字符的元素
- 本脚本里 `mem_group` 和报表行都使用了 list

### 示例

```tcl
set mem_group [list \
    C1 /a/b/c/mem0 \
    C1 /a/b/c/mem1 \
]
```

---

## 5. `if`

### 语法

```tcl
if {condition} {
    body1
} else {
    body2
}
```

### 用法

- 用于变量存在性判断、异常处理、pin 是否命中判断

### 示例

```tcl
if {![info exists mem_group]} {
    error "variable mem_group is not defined"
}
```

---

## 6. `info exists`

### 语法

```tcl
info exists varName
```

### 用法

- 判断变量是否已经定义

### 示例

```tcl
if {![info exists mem_group_testpins]} {
    error "variable mem_group_testpins is not defined"
}
```

---

## 7. `error`

### 语法

```tcl
error "message"
```

### 用法

- 立即报错并终止脚本
- 适合处理缺少输入变量、输入格式错误等场景

### 示例

```tcl
error "mem_group must contain group/instance pairs; current list length is odd"
```

---

## 8. `llength`

### 语法

```tcl
llength $listValue
```

### 用法

- 返回 list 元素数量
- 在本脚本中用于：
  - 检查 `mem_group` 长度是否为偶数
  - 统计某个 group 的 instance 数量
  - 获取 group 总数

### 示例

```tcl
set group_size [llength $group_to_instances($group_name)]
```

---

## 9. `expr`

### 语法

```tcl
expr {expression}
```

### 用法

- 计算表达式
- 本脚本中用于检查 list 长度是否为偶数

### 示例

```tcl
if {[expr {[llength $mem_group] % 2}] != 0} {
    error "mem_group must contain group/instance pairs; current list length is odd"
}
```

这里 `% 2` 表示取模。

---

## 10. `array`

### 语法

```tcl
set arrName(key) value
array unset arrName
```

### 用法

- `array` 是 Tcl 的 key-value 映射
- 本脚本中用它来保存：
  - `group_name -> instance_list`

### 示例

```tcl
set group_to_instances(C1) {/a/mem0 /a/mem1}
```

### 清空 array

```tcl
array unset group_to_instances
```

---

## 11. `foreach`

### 语法

```tcl
foreach varName $listValue {
    body
}
```

或者同时取多个元素：

```tcl
foreach {var1 var2} $listValue {
    body
}
```

### 用法

- 遍历 list
- 本脚本中有两种典型用法

### 示例 1：成对解析 `mem_group`

```tcl
foreach {group_name instance_name} $mem_group {
    ...
}
```

表示每次从 `mem_group` 里取两个元素：

- 第一个给 `group_name`
- 第二个给 `instance_name`

### 示例 2：遍历 pin 列表

```tcl
foreach pin $mem_group_testpins {
    ...
}
```

---

## 12. `lappend`

### 语法

```tcl
lappend listVar value
```

### 用法

- 向 list 变量末尾追加元素

### 示例

```tcl
lappend group_name_list $group_name
lappend group_to_instances($group_name) $instance_name
lappend hookup_report [list $group_name $idx $instance_name]
```

---

## 13. `for`

### 语法

```tcl
for {init} {condition} {step} {
    body
}
```

### 用法

- 用于按数字索引循环
- 本脚本中用于：
  - 创建 `DS0/DS1/...`
  - 遍历一个 group 中的第 `0/1/2/...` 个 instance

### 示例

```tcl
for {set idx 0} {$idx < $max_group_size} {incr idx} {
    lappend mem_group_tdr_signal_list "${pin}${idx}"
}
```

---

## 14. `incr`

### 语法

```tcl
incr varName
incr varName increment
```

### 用法

- 对整数变量自增

### 示例

```tcl
incr idx
```

---

## 15. `lindex`

### 语法

```tcl
lindex $listValue index
```

### 用法

- 获取 list 中指定位置的元素

### 示例

```tcl
set instance_name [lindex $instance_list $idx]
```

---

## 16. `register_static_dft_signal_names`

### 语法

```tcl
register_static_dft_signal_names signal_list
```

### 用法

- 注册静态 DFT 信号名
- 本脚本中对生成的 `DS0/DS1/...`、`LS0/LS1/...` 做统一注册

### 示例

```tcl
register_static_dft_signal_names $mem_group_tdr_signal_list
```

如果：

```tcl
set mem_group_tdr_signal_list {DS0 DS1 LS0 LS1}
```

则表示注册这些 TDR source signal 名。

---

## 17. `add_dft_signals`

### 语法

```tcl
add_dft_signals signal_list -create_with_tdr
```

### 用法

- 创建 DFT 信号并带 TDR

### 示例

```tcl
add_dft_signals $mem_group_tdr_signal_list -create_with_tdr
```

---

## 18. `get_pins`

### 语法

```tcl
get_pins pin_name -of_instance instance_name -silent
```

### 用法

- 查询某个 instance 上是否存在某个 pin
- `-silent` 表示找不到时不报错

### 示例

```tcl
set pin_collection [get_pins [list $pin] -of_instance $instance_name -silent]
```

这里用 `[list $pin]` 是为了保护 pin 名，避免像 `RM[0]` 这种带方括号的名字被 Tcl 误解析。

---

## 19. `sizeof_collection`

### 语法

```tcl
sizeof_collection collection_obj
```

### 用法

- 返回工具 collection 中对象数量
- 本脚本中用于判断 `get_pins` 返回是否为空

### 示例

```tcl
set pin_count [sizeof_collection $pin_collection]
```

如果：

- `pin_count == 0`
  表示该 SRAM instance 上没有这个 pin
- `pin_count > 0`
  表示命中了一个或多个 pin

---

## 20. `continue`

### 语法

```tcl
continue
```

### 用法

- 跳过当前循环，进入下一轮

### 示例

```tcl
if {$pin_count == 0} {
    ...
    continue
}
```

---

## 21. `get_name_list`

### 语法

```tcl
get_name_list collection_obj
```

### 用法

- 将工具返回的 collection 转为 Tcl 可遍历的名字列表

### 示例

```tcl
set pin_name_list [get_name_list $pin_collection]
```

---

## 22. `add_dft_control_point`

### 语法

```tcl
add_dft_control_point pin_full_path -dft_signal_source_name signal_name
```

### 用法

- 将实际 pin 接到指定的 DFT signal 上
- 本脚本中按 group 内 slot index 进行接管

### 示例

```tcl
add_dft_control_point $pin_full_path -dft_signal_source_name $tdr_signal_name
```

如果某个 instance 是该组内第 `1` 个元素，且当前 pin 是 `DS`，那么它会接到：

```text
DS1
```

---

## 23. `puts`

### 语法

```tcl
puts "message"
puts $fp "message"
```

### 用法

- 输出终端日志
- 或向文件写一行文本

### 示例

```tcl
puts "INFO: largest group is $max_group_name, size = $max_group_size"
puts $fp "group_name,slot_index,instance_name,pin_name,..."
```

---

## 24. `format`

### 语法

```tcl
format formatString arg1 arg2 ...
```

### 用法

- 生成对齐后的表格字符串

### 示例

```tcl
format "%-8s %-6s %-40s" $group_name $idx $instance_name
```

含义：

- `%-8s`：左对齐字符串，宽度 8
- `%-6s`：左对齐字符串，宽度 6

---

## 25. `string repeat`

### 语法

```tcl
string repeat string count
```

### 用法

- 重复某个字符串若干次
- 本脚本中用于打印分隔线

### 示例

```tcl
puts [string repeat "-" 164]
```

---

## 26. `file mkdir`

### 语法

```tcl
file mkdir path
```

### 用法

- 创建目录
- 若目录已存在，通常不会报错

### 示例

```tcl
file mkdir $mem_group_rpt_dir
```

---

## 27. `file join`

### 语法

```tcl
file join part1 part2 part3
```

### 用法

- 拼接路径

### 示例

```tcl
set mem_group_csv_file [file join $mem_group_rpt_dir "mem_group_dft_hookup_report.csv"]
```

---

## 28. `open`

### 语法

```tcl
open fileName mode
```

### 用法

- 打开文件并返回文件句柄

### 示例

```tcl
set fp [open $mem_group_csv_file w]
```

这里的 `w` 表示以写模式打开文件。

---

## 29. `close`

### 语法

```tcl
close fileHandle
```

### 用法

- 关闭已打开的文件

### 示例

```tcl
close $fp
```

---

## 30. `regsub`

### 语法

```tcl
regsub pattern string replacement varName
regsub -all pattern string replacement varName
```

### 用法

- 正则替换
- 本脚本中用于把 CSV 字段里的双引号转义成 `""`

### 示例

```tcl
regsub -all {"} $value {""} value
```

---

## 31. `join`

### 语法

```tcl
join listValue separator
```

### 用法

- 用指定分隔符把 list 拼成字符串
- 本脚本中用来生成一整行 CSV

### 示例

```tcl
puts $fp [join [list "a" "b" "c"] ","]
```

输出：

```text
a,b,c
```

---

## 32. `lassign`

### 语法

```tcl
lassign $listValue var1 var2 var3
```

### 用法

- 将 list 中的多个字段拆到不同变量
- 本脚本中用于读取报表行

### 示例

```tcl
lassign $row group_name idx instance_name pin pin_full_path tdr_signal_name status note
```

---

## 33. 核心流程拆解

### 33.1 解析 `mem_group`

```tcl
foreach {group_name instance_name} $mem_group {
    if {![info exists group_to_instances($group_name)]} {
        set group_to_instances($group_name) {}
        lappend group_name_list $group_name
    }
    lappend group_to_instances($group_name) $instance_name
}
```

含义：

1. 从平铺 list 里每次取一对：
   - `group_name`
   - `instance_name`
2. 如果这个 group 第一次出现，就初始化它的 instance list
3. 把 instance 追加到这个 group 对应的列表里

---

### 33.2 计算最大 group 大小

```tcl
foreach group_name $group_name_list {
    set group_size [llength $group_to_instances($group_name)]
    if {$group_size > $max_group_size} {
        set max_group_size $group_size
        set max_group_name $group_name
    }
}
```

含义：

1. 遍历每个 group
2. 取这个 group 的 instance 数量
3. 和当前最大值比较
4. 记录最大 group 的名字和大小

---

### 33.3 生成 `DS0/LS0/...`

```tcl
foreach pin $mem_group_testpins {
    for {set idx 0} {$idx < $max_group_size} {incr idx} {
        lappend mem_group_tdr_signal_list "${pin}${idx}"
    }
}
```

如果：

```tcl
set mem_group_testpins {DS LS}
set max_group_size 3
```

则生成：

```tcl
{DS0 DS1 DS2 LS0 LS1 LS2}
```

---

### 33.4 查询 pin 并接管

```tcl
set pin_collection [get_pins [list $pin] -of_instance $instance_name -silent]
set pin_count [sizeof_collection $pin_collection]
```

如果 `pin_count == 0`：

- 说明该 instance 没有这个 pin
- 该条记录写入报表为 `SKIP`

如果 `pin_count > 0`：

```tcl
set pin_name_list [get_name_list $pin_collection]
foreach pin_full_path $pin_name_list {
    add_dft_control_point $pin_full_path -dft_signal_source_name $tdr_signal_name
}
```

表示：

1. 把 collection 转成名字列表
2. 对每个实际 pin full path 做接管

---

## 34. Demo Example

### 输入

```tcl
set mem_group [list \
    C1 /da/dad/ada/mema \
    C1 /dsad/dsad/memb \
    C2 /top/memc \
    C2 /top/memd \
    C2 /top/meme \
]

set mem_group_testpins {DS LS}
set mem_group_rpt_dir "./rpt"
source mem_group_dft_setup.tcl
```

### 推导结果

- `C1` 有 2 个 instance
- `C2` 有 3 个 instance
- 所以最大 group 大小是 `3`

脚本会创建：

```text
DS0 DS1 DS2
LS0 LS1 LS2
```

### 接管方式

如果 `C2` 组中：

- 第 0 个 instance 命中 `DS`
- 第 1 个 instance 命中 `LS`
- 第 2 个 instance 命中 `DS`

那么会分别接到：

```text
DS0
LS1
DS2
```

### 输出文件

脚本会在：

```text
./rpt/mem_group_dft_hookup_report.csv
```

生成 CSV 报表。

---

## 35. 使用前检查项

建议运行前确认以下几点：

1. `mem_group` 长度必须为偶数
2. `mem_group_testpins` 必须由用户手动定义
3. `mem_group_rpt_dir` 必须由用户手动定义
4. 工具环境中命令必须存在：
   - `register_static_dft_signal_names`
   - `add_dft_signals`
   - `get_pins`
   - `sizeof_collection`
   - `get_name_list`
   - `add_dft_control_point`
5. instance 名必须是工具能识别的 full path

---

## 36. 最小使用模板

```tcl
set mem_group [list \
    C1 /top/u_mem0 \
    C1 /top/u_mem1 \
    C2 /top/u_mem2 \
]

set mem_group_testpins {DS LS}
set mem_group_rpt_dir "./rpt"

source mem_group_dft_setup.tcl
```

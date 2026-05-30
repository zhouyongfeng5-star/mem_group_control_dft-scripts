# `mem_group_dft_setup.tcl`

这个仓库当前 README 只说明 `mem_group_dft_setup.tcl` 这一份脚本。

该脚本用于按 `mem_group` 分组方式，对同一个 controller 内的多块 SRAM 进行独立 DFT 接管，尤其适合逐块控制每块 SRAM 的电源状态和休眠状态。

## 脚本用途

这个脚本可用于单独控制同一个 controller 内每块 SRAM 的状态。

典型场景是：

- 同一个 controller 下挂了多块 SRAM
- 这些 SRAM 需要按 group 做管理
- 同一个 group 内的每块 SRAM 又需要逐块独立接管
- 需要通过 `DS0/DS1/...`、`LS0/LS1/...` 这样的独立 TDR 信号分别控制不同 SRAM

其中：

- `DS` 信号用于控制 SRAM 是否处于休眠状态
- `LS` 信号也用于控制 SRAM 是否处于休眠状态

因此，这个脚本适合 low-power / sleep control 场景下，对同一个 controller 内的多块 SRAM 做独立接管。

## 脚本文件

- [mem_group_dft_setup.tcl](C:\Users\LostamBygone\Documents\Codex\2026-05-30\bin-bash-for-f-in-hex\mem_group_dft_setup.tcl)
  主脚本

- [mem_group_dft_setup_reference.md](C:\Users\LostamBygone\Documents\Codex\2026-05-30\bin-bash-for-f-in-hex\mem_group_dft_setup_reference.md)
  该脚本中用到的 Tcl 语法、DFT 命令语法和详细示例说明

## 输入变量

这个脚本没有默认值，以下变量都必须由用户在 `source` 之前手动定义。

### 1. `mem_group`

`mem_group` 是一个平铺的 Tcl list，每两个元素组成一对：

- 第 1 个元素：group name
- 第 2 个元素：instance full path

示例：

```tcl
set mem_group [list \
    C1 /da/dad/ada/mema \
    C1 /dsad/dsad/memb \
    C2 /top/memc \
    C2 /top/memd \
    C2 /top/meme \
]
```

上面这个例子表示：

- `C1` 组有 2 个 SRAM instance
- `C2` 组有 3 个 SRAM instance

### 2. `mem_group_testpins`

用户必须手动指定要处理的 pin 列表，例如：

```tcl
set mem_group_testpins {DS LS}
```

脚本不会提供默认值。

### 3. `mem_group_rpt_dir`

用户必须手动指定报表输出目录，例如：

```tcl
set mem_group_rpt_dir "./rpt"
```

## 处理流程

脚本执行流程如下：

### Step 1. 检查输入变量

脚本会检查：

- `mem_group` 是否已定义
- `mem_group_testpins` 是否已定义
- `mem_group_rpt_dir` 是否已定义

缺任意一个都会直接报错退出。

### Step 2. 解析分组

脚本把平铺的 `mem_group` 解析成：

```text
group_name -> instance list
```

例如：

```text
C1 -> {/da/dad/ada/mema /dsad/dsad/memb}
C2 -> {/top/memc /top/memd /top/meme}
```

### Step 3. 找出最大分组

脚本会统计每个 group 下有多少个 instance，并找出最大 group 大小。

如果：

- `C1` 有 2 个元素
- `C2` 有 3 个元素

那么最大 group 大小就是 `3`。

### Step 4. 创建 TDR 信号

假设：

```tcl
set mem_group_testpins {DS LS}
```

并且最大 group 大小为 `3`，那么脚本会生成：

```text
DS0 DS1 DS2
LS0 LS1 LS2
```

然后执行：

```tcl
register_static_dft_signal_names $mem_group_tdr_signal_list
add_dft_signals $mem_group_tdr_signal_list -create_with_tdr
```

### Step 5. 对每个 group 内的 SRAM 逐块接管

脚本按 group 内 slot 序号处理：

- 第 0 个 instance -> `DS0` / `LS0`
- 第 1 个 instance -> `DS1` / `LS1`
- 第 2 个 instance -> `DS2` / `LS2`

处理方式：

```tcl
set pin_collection [get_pins [list $pin] -of_instance $instance_name -silent]
set pin_count [sizeof_collection $pin_collection]
```

如果：

- `pin_count == 0`
  说明该 SRAM 没有这个 pin，跳过并在报表里记为 `SKIP`

- `pin_count > 0`
  说明该 SRAM 命中了这个 pin，执行：

```tcl
add_dft_control_point $pin_full_path -dft_signal_source_name $tdr_signal_name
```

## 输出结果

### 1. 命令行表格

脚本会在命令行打印：

```text
================ Memory Group DFT Hookup Report ================
```

表格字段包括：

- `GROUP`
- `SLOT`
- `INSTANCE`
- `PIN`
- `PIN_FULL_PATH`
- `TDR_SIGNAL`
- `STATUS`
- `NOTE`

其中：

- `STATUS = HOOKED`
  表示该 pin 已完成接管

- `STATUS = SKIP`
  表示该 instance 上没有命中对应 pin

### 2. CSV 报表

脚本会在 `mem_group_rpt_dir` 目录下输出：

```text
mem_group_dft_hookup_report.csv
```

CSV 列包括：

- `group_name`
- `slot_index`
- `instance_name`
- `pin_name`
- `pin_full_path`
- `tdr_signal_name`
- `status`
- `note`

## 最小使用示例

```tcl
set mem_group [list \
    C1 /top/u_mem0 \
    C1 /top/u_mem1 \
    C2 /top/u_mem2 \
    C2 /top/u_mem3 \
    C2 /top/u_mem4 \
]

set mem_group_testpins {DS LS}
set mem_group_rpt_dir "./rpt"

source mem_group_dft_setup.tcl
```

## 示例推导

以上示例中：

- `C1` 有 2 个元素
- `C2` 有 3 个元素

所以会创建：

```text
DS0 DS1 DS2
LS0 LS1 LS2
```

如果 `C2` 组中：

- 第 0 个 SRAM 命中 `DS`
- 第 1 个 SRAM 命中 `LS`
- 第 2 个 SRAM 命中 `DS`

那么接管关系分别是：

```text
DS0
LS1
DS2
```

这正好满足“同一个 controller 下，多块 SRAM 按顺序逐块独立控制”的需求。

## 工具命令依赖

该脚本依赖工具环境提供以下命令：

- `register_static_dft_signal_names`
- `add_dft_signals`
- `get_pins`
- `sizeof_collection`
- `get_name_list`
- `add_dft_control_point`

这些不是标准 Tcl 命令，而是 DFT / EDA 工具环境提供的扩展命令。

## 详细语法说明

更详细的命令语法、变量格式和逐段解释，请查看：

[mem_group_dft_setup_reference.md](C:\Users\LostamBygone\Documents\Codex\2026-05-30\bin-bash-for-f-in-hex\mem_group_dft_setup_reference.md)

这份文档包含：

- `mem_group` 的写法
- `mem_group_testpins` 的写法
- `register_static_dft_signal_names` 的语法
- `sizeof_collection` 的语法
- `get_pins` / `get_name_list` / `add_dft_control_point` 的用法
- `foreach` / `for` / `array` / `lappend` / `format` / `file mkdir` 等 Tcl 基础结构

## 使用前检查项

建议运行前先确认：

1. `mem_group` 长度必须为偶数
2. `mem_group_testpins` 必须由用户手动定义
3. `mem_group_rpt_dir` 必须由用户手动定义
4. instance 名必须是工具可识别的 full path
5. 工具环境中相关 DFT 命令已可用

## 推荐提交说明

如果你要把这个脚本和文档上传到 GitHub，提交说明可以写：

```text
Add memory group DFT setup script and documentation
```

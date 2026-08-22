# birthday-card-3D

用于生日礼物的 **掼蛋牌架 + 双组计级旋钮 + 可插拔红桃 A 二维码展示牌**。

目标是尽量接近参考效果，同时优先保证今晚能建模、能切片、能打印：

- 210 × 85 mm 一体式三排阶梯牌架；
- 三排真实扑克牌槽，默认后仰 12°；
- 中央 60 × 90 × 3.2 mm 红桃 A 展示牌；
- 红桃 A 上有红色浮雕边框/花色和黑色浮雕二维码区域；
- A/B 两组计级旋钮，固定刻度为 `2~10/J/Q/K/A`，旋钮指针指示当前级别；
- M3 轴孔，旋钮独立打印；
- 默认提供装配预览和一组视觉用扑克牌，不会进入正式 STL。

> 说明：参考图里的“独立数字窗口”在这一版改成了 **固定 13 档刻度 + 旋钮指针**。这样少一套传动/遮罩件，今晚更容易一次打印成功；功能上仍然可以直接记录 A/B 两组当前级别。

## 1. 先生成二维码几何

仓库里的 `qr.svg` 带白色背景。OpenSCAD 导入 SVG 时不会按黑白颜色筛选，直接 import 会把二维码变成实心方块。

先运行：

```powershell
python .\tools\prepare_qr.py
```

脚本会从 `qr.svg` 提取黑色 QR 模块并生成：

```text
qr_data.scad
```

随后重新打开/刷新 `rack.scad`，红桃 A 上就会出现真实二维码浮雕。

当前 QR 在 30 mm 宽度下，每个模块约 0.7 mm，0.4 mm 喷嘴属于可打印范围，但**正式交付前必须用手机扫描实体测试一次**。

## 2. OpenSCAD 使用

打开：

```text
rack.scad
```

默认：

```scad
part = "assembly";
```

会显示完整装配预览，包括视觉用扑克牌。

可选输出：

```text
assembly      完整预览，不用于打印
rack          牌架主体
heartA        红桃 A 完整单色 STL
dialA         计级旋钮（打印 1 个）
dialB         第二个计级旋钮（几何等价，可直接各导出一个）
slot_test     槽宽测试件
heartA_base   红桃 A 底板
heartA_red    红色浮雕层
heartA_black  黑色二维码/文字浮雕层
```

例如 PowerShell：

```powershell
openscad -D 'part="rack"' -o rack.stl .\rack.scad
openscad -D 'part="heartA"' -o heartA.stl .\rack.scad
openscad -D 'part="dialA"' -o dialA.stl .\rack.scad
```

也可以直接运行：

```powershell
.\export.ps1
```

## 3. 强烈建议先打槽测试件

正式打印 210 mm 大件前，先打印：

```powershell
openscad -D 'part="slot_test"' -o slot_test.stl .\rack.scad
```

默认公差：

- 普通牌槽：`2.4 mm`
- 红桃 A 槽：`3.8 mm`
- 红桃 A 厚度：`3.2 mm`

如果你的机器偏紧，可以把 `card_slot_w` / `display_slot_w` 分别增加 0.2 mm。

## 4. 推荐打印参数

0.4 mm 喷嘴 / PLA：

- 层高：0.16~0.20 mm
- 壁数：3~4
- 顶/底层：5~6
- 填充：15~20%
- 支撑：牌架主体一般不需要
- 外墙：40~50 mm/s
- 红桃 A：平放打印，浮雕朝上
- 牌架：底板直接贴热床

主体尺寸约：

```text
210 × 85 × 51 mm
```

如果打印平台只有 220 × 220 mm，不建议把 `rack_w` 再放大到 220 mm。

## 5. 计级旋钮装配

主体和旋钮均预留约 3.4 mm 的 M3 通孔。

建议准备：

- M3 × 30 螺丝 × 2
- M3 垫片 × 2~4
- M3 螺母 × 2

螺母不要锁死，让旋钮保持“有阻尼但可以手拨”的状态即可。刻度固定在前脸，旋钮上的三角指针指向当前级别。

## 6. 颜色建议

参考效果：

- 牌架主体：米白 / 象牙白
- 红桃 A：米白底
- `A / ♥ / 边框`：红色
- 二维码与“扫一扫 · 看手气”：黑色
- A组：红色
- B组：蓝色

没有 AMS 也没关系：全部单色打印后，用丙烯笔/油漆笔给浮雕顶面点色即可。

## 7. 字体

默认针对 Windows：

```scad
font_main  = "Microsoft YaHei:style=Bold";
font_latin = "Times New Roman:style=Bold";
```

如果 OpenSCAD 中出现缺字，在 `Help -> Font List` 中找到可用字体后修改这两个变量即可。

## 本地几何验证

开发时使用 OpenSCAD 2021.01 对以下零件做过 CLI STL 导出检查：

- `rack`
- `heartA`
- `dialA`
- `dialB`
- `slot_test`

导出的 STL 均为 watertight mesh。**这不等于真实机器上的尺寸公差已经验证**，所以仍建议先打印 `slot_test`。

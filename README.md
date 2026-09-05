# 怪奇实验室：元素逃亡

一款基于 Godot 4.3+ 的化学解谜冒险游戏。

## 项目简介

在这个实验室逃生游戏中，玩家需要运用化学知识解决各种谜题，帮助角色逃离危险的实验室。

## 角色

- **芮克森·玻尔** (Rixen) - 主角
- **莫里·离子** (Mori) - 搭档
- **维稳协议** (System) - AI系统

## 如何运行

### 在 Godot 编辑器中运行

1. 确保已安装 Godot 4.3 或更高版本
2. 打开 Godot 引擎
3. 点击"导入"，选择本项目的 `project.godot` 文件
4. 导入完成后，项目会自动打开
5. 按 F5 键运行游戏

### 添加新关卡

关卡数据使用 JSON 格式存储在 `content/levels/` 目录下。

每个关卡文件包含：
- 标题和介绍
- 调查场景描述
- 提示信息（最多3个）
- 选项和结果
- 回顾和下一关信息

参考 `ch1_lv01_fire_edge.json` 的格式创建新关卡。

## Web 导出

### 准备工作
1. 在 Godot 编辑器中打开项目
2. 进入"编辑器" → "管理导出模板"
3. 下载 Godot 4.3 Web 导出模板

### 导出步骤
1. 点击"项目" → "导出"
2. 添加"Web"预设
3. 配置导出路径
4. 点击"导出项目"

## 项目结构

```
.
├── project.godot          # Godot 项目配置
├── README.md              # 项目说明
├── assets/                # 资源文件
│   └── icon.svg          # 项目图标
├── content/               # 游戏内容数据
│   ├── chars/            # 角色配置
│   │   └── characters.json
│   └── levels/           # 关卡数据
│       └── ch1_lv01_fire_edge.json
├── scripts/               # 游戏脚本
│   ├── level_loader.gd   # 关卡加载器
│   └── level_player.gd   # 关卡播放器
└── scenes/                # 场景文件
    └── level_player.tscn # 主场景
```

## 技术栈

- Godot Engine 4.3+
- GDScript
- JSON 数据驱动

## 开发路线图

- [x] 第一章第一关：火焰边缘
- [ ] 第一章第二关：酸液走廊
- [ ] 更多关卡...

## 许可证

待定

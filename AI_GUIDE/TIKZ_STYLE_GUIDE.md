# TikZ 绘图风格指南

本指南规定本项目新增和修改 TikZ 插图时应遵循的统一风格。规范以
`img/0-abstract/` 与 `img/1-vector/` 中的实际插图为基础，适用于函数图像、
集合的像与原像、二维向量、三维空间对象和有限几何变换。

目标是得到简洁、克制、便于印刷的教材插图：图形负责呈现数学关系，正文和
图注负责解释结论。

## 1. 硬性规则

以下规则优先级最高，新图和修改后的旧图都应满足。

1. 所有箭头统一使用 `-latex`，不要混用 `Stealth`、`->` 或其他箭头。
2. 所有文字和数学符号统一使用 `black`，包括对象标签、坐标轴标签、刻度、
   原点和说明文字。
3. 坐标轴、辅助线、中性轮廓和中性标记统一使用 `black`。
4. 不使用 `black!xx` 灰阶，也不要通过不同深浅的黑色制造额外层级。
5. 彩色只用于数学图元和区域，不用于文字。
6. 每个 `.tikz` 文件只包含一个 `tikzpicture` 片段，不包含完整 LaTeX 文档。
7. 没有实际图例时，不保留 `legend style`、`legend cell align` 等无效配置。

推荐的坐标轴写法为：

```tex
axis lines=middle,
axis line style={black, semithick, -latex},
ticklabel style={font=\scriptsize, text=black},
label style={font=\small, text=black},
```

## 2. 颜色系统

颜色定义在 `simplebook.cls` 中。新增插图只能优先复用已有颜色名，不要在单个
`.tikz` 文件中另建近似色。

| 色名 | RGB | 主要用途 |
|---|---:|---|
| `c1` | 0, 114, 189 | 第一主对象：主函数、第一向量、数据点、关键轮廓 |
| `c2` | 217, 83, 25 | 第二对象：第二向量、限制区域、几何操作、局部强调 |
| `c3` | 237, 177, 32 | 面和曲面对象 |
| `c5` | 119, 172, 48 | 合成结果、像或原像对应区域 |
| `c4`、`c6`、`c7` | — | 保留色；现有语义色不足时才使用 |

颜色规则：

- 离散对象通常按 `c1 → c2 → c5` 分配。
- 文字始终是 `black`，即使文字标注的是彩色对象。
- 主体曲线和向量使用纯色；区域通过同色透明填充表达。
- 限制或排除区域通常使用 `c2, fill opacity=0.1`。
- 像或原像区域通常使用 `c5, fill opacity=0.18`。
- 三维面使用 `c3!18` 浅填充，网格可使用 `c3!40` 或 `c3!45`。
- `c1!5`、`c3!18` 这类语义色浅填充可以使用；禁止使用 `black!xx`。
- 不要仅依赖颜色表达差异，还要同时使用位置、线型、标记形状或直接标签。

## 3. 线条、箭头与标记

| 数学角色 | 推荐样式 |
|---|---|
| 主函数、普通向量、主要轮廓 | `thick` + 语义色 |
| 强调区间或关键局部 | `very thick`；`ultra thick` 谨慎使用 |
| 辅助线、投影线、构造线 | `black, densely dashed, semithick` |
| 明确的数学边界或对应关系 | `black, dashed, thick` |
| 坐标轴 | `black, semithick, -latex` |
| 三维面网格、旋转参考圆 | `thin` |
| 普通数据点 | `mark=*, mark size=1.6pt` 至 `2pt` |
| 二维原点 | `black, mark size=1.2pt` |
| 三维原点 | `black, mark size=0.8pt` |

所有具有箭头的对象都直接写 `-latex`：

```tex
\addplot[c1, thick, -latex] coordinates {(0,0) (2,1)};
```

不要使用全局 `>=latex` 代替对象自身的箭头声明；显式写出箭头可以避免局部样式
继承不清。

## 4. 二维坐标图

### 4.1 尺寸

- 函数示意图：`width=6cm, height=5cm`。
- 二维向量图：`width=4.5cm, height=4.5cm`。
- 数据散点图：`width=5.5cm, height=5.5cm`。
- 同组对比图必须使用相同尺寸、坐标范围和字体。

### 4.2 坐标配置

- 坐标轴穿过原点时使用 `axis lines=middle`。
- 坐标轴使用 `axis line style={black, semithick, -latex}`。
- 几何比例承担数学含义时使用 `axis equal image`。
- 刻度统一为 `\scriptsize`，轴标签统一为 `\small`。
- 函数图可用
  `xlabel style={anchor=west}, ylabel style={anchor=south}` 避免轴标签压线。
- 默认不显示网格。
- 只有标签或箭头确实需要越出坐标框时才使用 `clip=false`。
- 坐标范围应为箭头、端点和标签保留少量空间。

### 4.3 绘制顺序

二维图从背景到前景按以下顺序组织：

1. 限制域和低透明度背景；
2. 连续选区或像、原像区域；
3. 辅助线和投影线；
4. 主函数、向量和主要轮廓；
5. 端点、原点和关键标记；
6. 文字标签。

如果填充遮住主曲线，应在填充后重新绘制一次主曲线。

## 5. 三维坐标图

### 5.1 基础配置

- 常规三维图优先使用 `view={45}{20}`。
- 特殊曲面的主轴在该视角下不清楚时，可以局部调整视角，但同组图必须一致。
- 小型三维图通常使用 `width=4.5cm`。
- 使用 `axis lines=center`、`axis equal image`。
- 坐标轴仍使用 `black, semithick, -latex`。
- 数值刻度通常隐藏：

```tex
xtick=\empty,
ytick=\empty,
ztick=\empty,
```

- 三维刻度可使用 `\tiny`，轴标签仍使用 `\small`。

### 5.2 曲面采样与透明度

- 平面只需 `samples=2`。
- 参数曲面只使用足以辨认形状的采样，不追求无意义的高密度。
- 半透明曲面使用浅色填充和较淡网格，例如：

```tex
shader=faceted,
colormap={surfacecolor}{color=(c3!18) color=(c3!18)},
faceted color=c3!40,
fill opacity=0.6,
thin,
```

### 5.3 深度排序和坐标轴遮挡

`z buffer=sort` 只负责对同一个三维曲面的网格面排序，不会把坐标轴、普通节点和
曲面放入同一个深度系统。

- 曲面自身出现网格面前后顺序错误时，给曲面添加 `z buffer=sort`。
- 不要强制把全部坐标轴覆盖在曲面前方，以免破坏三维对象的前后关系。
- 希望表现真实的“后半轴被遮挡、前半轴可见”时，应关闭自动坐标轴，
  使用 `axis lines=none`，再手工分段绘制：
  1. 先画后半轴；
  2. 再画曲面；
  3. 最后画前半轴和标签。
- 坐标轴若与曲面几何重合，深度排序没有唯一结果。此时必须通过绘制顺序明确
  教材想表达的视觉优先级。

## 6. 原生 TikZ 几何图

- 重复单元先定义局部 `.style` 和命令，再用 `scope[shift=...]` 排列。
- 同组单元具有完全一致的尺寸、间距、标签位置和颜色语义。
- 普通轮廓和所有文字使用 `black`。
- 承载对象可使用 `fill=c1!5`；几何操作可以使用 `c2`。
- 反射轴使用虚线；旋转箭头使用 `c2, thick, -latex`。
- 局部样式中仍显式写 `black`，不要使用 `black!xx`。

## 7. 标签与数学排版

- 所有标签使用 `text=black`。
- 数学量使用 `\(...\)`，不要在同一组图中混用 `$...$`。
- 向量使用粗体小写字母，如 `\(\bm u\)`、`\(\bm u+\bm v\)`。
- 原点统一写作 `\(O\)`。
- 对象标签使用 `\small`；刻度、点编号和辅助说明使用 `\scriptsize`。
- 只有最关键的单一对象可以使用 `\bfseries`。
- 标签应靠近对象，但通过 `anchor`、`above`、`left=2pt` 等避免压线。
- 图内只放短标签；完整解释和标题放在正文与 `caption` 中。
- `pgfplots` 中的节点优先使用 `axis cs:` 定位。

## 8. 代码组织

- 文件名使用描述性的英文 `snake_case`。
- 使用 4 空格缩进；多行选项保留尾逗号。
- 按“坐标配置、背景、辅助结构、主体、标记、标签”的顺序组织代码。
- 重复图元封装为局部命令；复杂样式定义为局部 `.style`。
- 不进入图例的 `\addplot` 显式添加 `forget plot`。
- 注释只解释数学角色、绘制顺序或非显然参数。
- 删除调试代码、无效图例配置、重复选项和已废弃的注释。
- 复用 `simplebook.cls` 已加载的 TikZ/PGFPlots 库和颜色。

## 9. 推荐模板

### 9.1 二维函数或向量图

```tex
\begin{tikzpicture}
    \begin{axis}[
            width=4.5cm,
            height=4.5cm,
            xmin=-0.3, xmax=4.3,
            ymin=-0.3, ymax=4.3,
            axis lines=middle,
            axis line style={black, semithick, -latex},
            axis equal image,
            xlabel={\(x\)},
            ylabel={\(y\)},
            ticklabel style={font=\scriptsize, text=black},
            label style={font=\small, text=black},
        ]
        % Auxiliary construction.
        \addplot[black, densely dashed, semithick, forget plot]
        coordinates {(2,1) (3,3)};

        % Primary object.
        \addplot[c1, thick, -latex, forget plot]
        coordinates {(0,0) (2,1)};
        \node[font=\small, text=black, below right=1pt]
        at (axis cs:1,.5) {\(\bm u\)};

        % Origin.
        \addplot[only marks, mark=*, mark size=1.2pt, black, forget plot]
        coordinates {(0,0)};
        \node[font=\scriptsize, text=black, below left=2pt]
        at (axis cs:0,0) {\(O\)};
    \end{axis}
\end{tikzpicture}
```

### 9.2 三维曲面图

```tex
\begin{tikzpicture}
    \begin{axis}[
            view={45}{20},
            width=4.5cm,
            axis lines=center,
            axis line style={black, semithick, -latex},
            axis equal image,
            xlabel={\(x\)},
            ylabel={\(y\)},
            zlabel={\(z\)},
            xtick=\empty,
            ytick=\empty,
            ztick=\empty,
            ticklabel style={font=\tiny, text=black},
            label style={font=\small, text=black},
        ]
        \addplot3[
            surf,
            shader=faceted,
            colormap={surfacecolor}{color=(c3!18) color=(c3!18)},
            faceted color=c3!40,
            fill opacity=0.6,
            thin,
            samples=2,
            z buffer=sort,
            forget plot,
        ] ({x}, {y}, {y});
    \end{axis}
\end{tikzpicture}
```

### 9.3 原生 TikZ 几何图

```tex
\begin{tikzpicture}[
        object/.style={draw=black, fill=c1!5, thick},
        primary/.style={c1, thick, -latex},
        secondary/.style={c2, dashed, thick},
        guide/.style={black, densely dashed, semithick},
        object label/.style={font=\small, text=black},
        note/.style={font=\scriptsize, text=black},
    ]
    % Draw in the order: background, guides, objects, markers, labels.
\end{tikzpicture}
```

## 10. 提交前检查

- [ ] 箭头是否全部使用 `-latex`？
- [ ] 所有文字、坐标轴、辅助线和中性轮廓是否使用 `black`？
- [ ] 是否完全没有 `black!xx`？
- [ ] 彩色是否只用于数学图元和区域？
- [ ] 同组图的尺寸、坐标范围、字体和视角是否一致？
- [ ] 是否删除了无用图例、重复选项和调试注释？
- [ ] 标签是否压线、越界、被裁剪或相互遮挡？
- [ ] 三维曲面是否需要 `z buffer=sort`？
- [ ] 坐标轴与曲面的前后关系是否符合教学意图？
- [ ] 是否在正文实际缩放比例下完整编译并查看？
- [ ] 数学内容是否准确，包括坐标、方向、定义域和端点开闭？

## 11. 可直接使用的简短提示词

> 请为本项目生成一个独立的 `.tikz` 片段，遵循
> `AI_GUIDE/TIKZ_STYLE_GUIDE.md`：白底教材风格；所有箭头使用 `-latex`；
> 所有文字、坐标轴、辅助线、中性轮廓和中性标记使用 `black`，禁止
> `black!xx`；彩色只用于数学图元和区域，优先使用 `c1`、`c2`、`c3`、`c5`；
> 对象标签用 `\small`，辅助说明用 `\scriptsize`；按背景、辅助结构、主体、
> 标记、标签的顺序绘制；只输出 `tikzpicture`，不创建完整 LaTeX 文档。

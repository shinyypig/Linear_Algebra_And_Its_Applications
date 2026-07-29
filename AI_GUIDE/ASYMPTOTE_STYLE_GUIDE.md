# Asymptote 绘图风格指南

本指南规定本项目统一采用的 Asymptote 绘图约定。
公共颜色、线宽、箭头和辅助函数定义在项目根目录的 `bookstyle.asy` 中。

## 1. 输出策略

- 二维图使用 Asymptote 原生 PDF 矢量输出，PDF 中不得嵌入整图位图。
- 三维图使用 OpenGL 深度缓冲自动处理遮挡，并以高分辨率图像嵌入 PDF。
- 三维图必须使用透明背景：顶层文件设置 `settings.outformat = "png";`，并按
  `settings.user` 在纯黑、纯白背景之间切换。Asymptote 的离屏 OpenGL 渲染不支持
  透明画布，因此构建脚本会渲染两次，由 `scripts/recover_asymptote_alpha.py`
  恢复前景颜色与 alpha，再通过
  `scripts/asymptote_transparent_wrapper.tex` 封装为带 PDF `SMask` 的透明 PDF。
  该脚本依赖 Pillow。不要使用
  `currentlight.background=black+opacity(0);`，它只对 WebGL 透明背景有效，离屏
  PNG/PDF 会得到不透明黑底。
- 公共三维渲染倍率由 `bookstyle.asy` 中的 `settings.render` 控制。
- `settings.tex` 与 `settings.outformat` 保留在每个顶层 `.asy` 文件中；放入被
  `import` 的模块会破坏 Asymptote 的标签临时文件路径解析。
- 顶层图片统一使用 XeLaTeX；含中文的图片额外加载 `ctex`，向量标签加载 `bm`。

推荐文件头：

```asy
import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf"; // 三维图改用 "png"
texpreamble("\\usepackage{bm}");
```

## 2. 颜色与文字

- 所有文字、数学符号、坐标轴、刻度和中性辅助线均使用 `black`。
- 不使用 `black!xx` 或任意新增灰阶。
- 数学图元沿用 `c1` 至 `c7`；优先采用 `c1 → c2 → c5` 表示第一对象、
  第二对象和合成结果。
- 浅色填充使用公共混合色，如 `c2Fill10`、`c3Fill18`、`c5Fill18`，不要在
  单张图片中重复计算近似颜色。
- 正文对象标签使用公共样式 `textPen`（9 pt），区域说明使用
  `annotationTextPen`（8 pt），刻度和次要标注使用
  `minorTextPen`（7 pt）。顶层图片不再重复调用
  `defaultpen`；`bookstyle.asy` 已统一设置默认文字样式。

## 3. 线条与箭头

- 坐标轴：`axisPen`，即 `black + linewidth(0.6pt)`。
- 主曲线和普通向量：语义色加 `linewidth(0.8pt)`。
- 辅助线：`dashedHelperPen`。
- 所有二维箭头使用纯填充 `DefaultHead`；所有三维箭头使用纯填充
  `DefaultHead2`。不要使用 `TeXHead`/`TeXHead2`，它们在当前输出管线中会
  产生鱼钩状轮廓。
- 坐标轴箭头使用 `axisArrow`/`axisArrow3`，向量使用
  `vectorArrow`/`vectorArrow3`。

## 4. 二维图

- 二维向量图通常使用 `size(4.5cm)`；函数图使用
  `size(6cm,5cm,keepAspect=true)`；散点图使用
  `size(5.5cm,5.5cm,IgnoreAspect)`。
- 坐标轴与刻度优先调用 `drawBookAxes`，显式提供刻度数组。
- 若坐标系包含真实原点，应在所有曲线、向量和数据点之后调用 `bookOrigin()`；
  它使用 `2.4pt` 黑色实心圆标出原点，并在左下方标注 7 pt 的 `$O$`。不要只写
  `$O$`，也不要用语义色数据点代替黑色原点。
- 函数曲线从背景到前景依次绘制：区域填充、辅助线、主曲线、标记、标签。
- `y=x^2` 使用公共函数 `squareGraph`，避免各图采用不同采样方式。
- 数据点使用 `bookDot`，保持 `c1` 外轮廓和 `c1Fill60` 内填充一致。
- Asymptote 默认采用紧边界框；当圆点、粗线或箭头位于图片最外缘时，描边及
  抗锯齿像素可能紧贴甚至越过 PDF 的 `MediaBox`。此类图片应在文件末尾使用
  `shipout(bbox(currentpicture,0.3mm,p=invisible));` 增加透明安全边距；若最外层
  图元线宽较大，可将边距提高到 `0.5mm`–`1mm`。不要通过
  移动图元或添加白色背景来掩盖裁切问题。

## 5. 三维图

- 三维对象必须位于同一个 Asymptote 场景中，由深度缓冲自动判断遮挡；不要
  手工拆分前轴和后轴。
- 常用视角为 `orthographic(4,-4,2)`，同组图片应保持一致。
- 半透明曲面使用 `light=nolight`，避免光照改变项目语义色。
- 与曲面共面的向量、原点和标签沿相机方向轻微偏移，避免深度冲突。
- 透明曲面后的轴线应自然变淡，而不是强制消失或覆盖到曲面前方。

## 6. 代码组织与构建

- 每个 `.asy` 文件只绘制一张图，文件名沿用原有 `snake_case` 名称。
- 数学角色和非显然的深度处理需要注释，重复样式放入 `bookstyle.asy`。
- 正文只引用生成的 `.pdf`，不直接引用 `.asy`。PDF 必须按最终
  物理尺寸生成，并在正文中使用不带 `width`、`height` 或
  `scale` 的 `\includegraphics` 以 1:1 比例插入；不要在
  LaTeX 中再次缩放，否则文字、线宽、箭头和圆点会随缩放比例改变。需要调整
  图形占用空间时，应修改 `.asy` 中的 `size(...)`。
- 并排图片的容器宽度只负责排版，必须大于图片的自然宽度，不用于缩放图片。
- 三维透明图片的封装脚本会读取顶层 `.asy` 的单参数
  `size(...)`，并将该尺寸写入 PDF；因此三维图应使用
  `size(4.5cm)` 这类单参数形式。
- 正常构建运行 `./build.sh`；`latexmkrc` 会按需将 `.asy` 转换为 `.pdf`，并
  删除 OpenGL 渲染产生的 `*__.ps` 临时文件。三维渲染命令会自动适配平台：
  Linux 检测到 `xvfb-run` 时通过虚拟显示运行 Asymptote；macOS、Windows 以及
  未安装 `xvfb-run` 的图形环境直接调用 `asy`，不要在图片源码中硬编码
  `xvfb-run`。

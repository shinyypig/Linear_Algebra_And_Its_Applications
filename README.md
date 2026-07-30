# 线性代数及应用

这是一本正在编写的中文线性代数教材，力求在数学严谨性、几何直观和后续应用之间
保持平衡。目前已经完成“抽象代数基础”和“向量与线性空间”两章的正文、小结与习题，
“矩阵与线性映射”一章正在编写。

## 构建

项目使用 XeLaTeX、Latexmk 和 Asymptote。安装相应的 TeX Live 组件后，在项目根目录
运行：

```bash
./build.sh
```

生成的教材位于 `tmp/book.pdf`。构建脚本默认编译 `book.tex`，并负责执行图片所需的
shell escape 流程。

## 项目结构

```text
book.tex                    主文档与章节入口
0_abstract.tex              第一章：抽象代数基础
1_vector.tex                第二章：向量与线性空间
2_matrix.tex                第三章：矩阵与线性映射
img/                        Asymptote 图片源文件
bookstyle.asy               全书共用绘图样式
AI_GUIDE/                   AI 专项写作与绘图指南
AGENTS.md                   AI 工作总入口
BOOK_PLAN.md                章节进度与候选路线
```

## 编写文档

- [AI 工作入口](AGENTS.md)：所有任务共用的核心规则和文档路由；
- [全书规划](BOOK_PLAN.md)：当前章节状态、知识依赖和候选目录；
- [AI 指南索引](AI_GUIDE/README.md)：正文、记号和绘图指南的适用范围；
- [Asymptote 绘图指南](AI_GUIDE/ASYMPTOTE_STYLE_GUIDE.md)：图片实现与输出约定。

后续章节的名称和顺序仍可能调整，以 `BOOK_PLAN.md` 中标明的状态为准。

import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";

texpreamble("\usepackage{bm}");

size(4cm);

real axisMax = 4.3;
pair O = (0, 0);
pair u = (2, 1);
pair uv = (3, 3);

// Coordinate axes and integer ticks.
draw(O--(axisMax, 0), axisPen, axisArrow);
draw(O--(0, axisMax), axisPen, axisArrow);

for (int i = 1; i <= 4; ++i) {
    draw((i, -0.055)--(i, 0.055), tickPen);
    draw((-0.055, i)--(0.055, i), tickPen);
    label(string(i), (i, -0.13), S, minorTextPen);
    label(string(i), (-0.13, i), W, minorTextPen);
}

label("$x$", (4.06, 0.13), NW, textPen);
label("$y$", (0.13, 4.06), SE, textPen);

// Triangle rule: u, the translated v, and their sum.
draw(O--u, c1 + linewidth(0.8pt), vectorArrow);
draw(u--uv, c2 + linewidth(0.8pt), vectorArrow);
draw(O--uv, c5 + linewidth(0.8pt), vectorArrow);

label("$\bm{u}$", (1, 0.5), SE, textPen);
label("$\bm{v}$", (2.5, 2), E, textPen);
label("$\bm{u}+\bm{v}$", (1.85, 2.35), W, textPen);
bookOrigin(O);

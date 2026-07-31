import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";

texpreamble("\usepackage{bm}");

size(8cm);

pair OV = (-3.0,0);
pair OW = (0.75,0);
real axisLength = 2.35;
real axisHeight = 1.45;
pair v = (0.45,0.45);
pair lambdaV = (0.90,0.90);

// The same shear as in linear_map_square_shear: T(x,y)=(x+y,y).
pair Tv = (v.x+v.y,v.y);
pair lambdaTv = (lambdaV.x+lambdaV.y,lambdaV.y);

draw(OV--OV+(axisLength,0),axisPen,axisArrow);
draw(OV--OV+(0,axisHeight),axisPen,axisArrow);
draw(OW--OW+(axisLength,0),axisPen,axisArrow);
draw(OW--OW+(0,axisHeight),axisPen,axisArrow);

// The two pairs of collinear vectors show that scaling commutes with T.
draw(OV--OV+lambdaV,c2+linewidth(0.8pt),vectorArrow);
draw(OV--OV+v,c1+linewidth(0.8pt),vectorArrow);

draw(OW--OW+lambdaTv,c2+linewidth(0.8pt),vectorArrow);
draw(OW--OW+Tv,c1+linewidth(0.8pt),vectorArrow);

draw((-0.50,0.66)--(0.42,0.66),black+linewidth(0.8pt),vectorArrow);
label("$T$",(-0.04,0.66),N,textPen);

label("$\bm v$",OV+0.50v,SE,textPen);
label("$\lambda\bm v$",OV+lambdaV,NW,textPen);
label("$T(\bm v)$",OW+(0.78,-0.08),S,textPen);
label("$\lambda T(\bm v)$",
      OW+lambdaTv,NE,textPen);

label("$V$",OV+(0.35,1.24),textPen);
label("$W$",OW+(0.35,1.24),textPen);
label("$x$",OV+(axisLength,0),SE,textPen);
label("$y$",OV+(0,axisHeight),NW,textPen);
label("$x$",OW+(axisLength,0),SE,textPen);
label("$y$",OW+(0,axisHeight),NW,textPen);
bookOrigin(OV);
bookOrigin(OW);

shipout(bbox(currentpicture,0.5mm,p=invisible));

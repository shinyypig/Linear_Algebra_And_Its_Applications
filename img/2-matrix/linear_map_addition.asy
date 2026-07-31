import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";

texpreamble("\usepackage{bm}");

size(8cm);

pair OV = (-3.0,0);
pair OW = (0.75,0);
real axisLength = 2.35;
real axisHeight = 1.45;
pair u = (1,0);
pair v = (0,1);
pair uv = u+v;

// The same shear as in linear_map_square_shear: T(x,y)=(x+y,y).
pair Tu = (u.x+u.y,u.y);
pair Tv = (v.x+v.y,v.y);
pair Tuv = Tu+Tv;

path unitSquare = OV--OV+u--OV+uv--OV+v--cycle;
path shearedSquare = OW--OW+Tu--OW+Tuv--OW+Tv--cycle;

fill(unitSquare,c1Fill05);
fill(shearedSquare,c2Fill10);

draw(OV--OV+(axisLength,0),axisPen,axisArrow);
draw(OV--OV+(0,axisHeight),axisPen,axisArrow);
draw(OW--OW+(axisLength,0),axisPen,axisArrow);
draw(OW--OW+(0,axisHeight),axisPen,axisArrow);

// Parallelogram constructions before and after applying T.
draw(OV+u--OV+uv,dashedHelperPen);
draw(OV+v--OV+uv,dashedHelperPen);
draw(OW+Tu--OW+Tuv,dashedHelperPen);
draw(OW+Tv--OW+Tuv,dashedHelperPen);

draw(OV--OV+u,c1+linewidth(0.8pt),vectorArrow);
draw(OV--OV+v,c2+linewidth(0.8pt),vectorArrow);
draw(OV--OV+uv,c5+linewidth(0.8pt),vectorArrow);

draw(OW--OW+Tu,c1+linewidth(0.8pt),vectorArrow);
draw(OW--OW+Tv,c2+linewidth(0.8pt),vectorArrow);
draw(OW--OW+Tuv,c5+linewidth(0.8pt),vectorArrow);

draw((-0.50,0.66)--(0.42,0.66),black+linewidth(0.8pt),vectorArrow);
label("$T$",(-0.04,0.66),N,textPen);

label("$\bm u$",OV+0.55u,SE,textPen);
label("$\bm v$",OV+0.55v,W,textPen);
label("$\bm u+\bm v$",OV+uv+(0.5, 0),NW,textPen);
label("$T(\bm u)$",OW+0.55Tu,SE,textPen);
label("$T(\bm v)$",OW+v,SE,textPen);
label("$T(\bm u)+T(\bm v)$",OW+Tuv+(-1,0),NE,textPen);

label("$V$",OV+(0.35,1.28),textPen);
label("$W$",OW+(0.35,1.28),textPen);
label("$x$",OV+(axisLength,0),SE,textPen);
label("$y$",OV+(0,axisHeight),NW,textPen);
label("$x$",OW+(axisLength,0),SE,textPen);
label("$y$",OW+(0,axisHeight),NW,textPen);
bookOrigin(OV);
bookOrigin(OW);

shipout(bbox(currentpicture,0.5mm,p=invisible));

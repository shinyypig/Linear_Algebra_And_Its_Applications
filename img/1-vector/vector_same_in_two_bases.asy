import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";
texpreamble("\usepackage{bm}");

size(5cm);
defaultpen(fontsize(9pt));

real a=2/sqrt(2);
draw((-2,0)--(2,0),axisPen,axisArrow);
draw((0,-2)--(0,2),axisPen,axisArrow);
draw((-a,-a)--(a,a),axisPen,axisArrow);
draw((a,-a)--(-a,a),axisPen,axisArrow);

label("$x$",(2,0),SE,textPen);
label("$y$",(0,2),N,textPen);
label("$x'$",(a,a),N,textPen);
label("$y'$",(-a,a),NW,textPen);

draw((1,0)--(1,1)--(0,1),dashedHelperPen);
draw((1,-0.045)--(1,0.045),black+linewidth(0.6pt));
draw((-0.045,1)--(0.045,1),black+linewidth(0.6pt));
label("$1$",(1,0),S,black+fontsize(7pt));
label("$1$",(0,1),W,black+fontsize(7pt));

draw((0,0)--(1,1),c1+linewidth(0.8pt),vectorArrow);
label("$\bm{v}$",(1.18,0.83),textPen+fontsize(9pt));

draw(arc((0,0),0.39,0,45),c2+linewidth(0.6pt));
bookOrigin();

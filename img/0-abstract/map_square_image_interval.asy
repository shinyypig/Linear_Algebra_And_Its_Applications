import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";

size(6cm,5cm,keepAspect=true);
defaultpen(fontsize(9pt));

real xmin=-2.3, xmax=2.3, ymin=-0.5, ymax=4.5;
drawBookAxes(xmin,xmax,ymin,ymax,
             new real[] {-2,-1,0,1,2},
             new real[] {0,1,2,3,4},
             "$x$","$f(x)$");
draw(squareGraph(-2,2),c1+linewidth(0.8pt));
draw(squareGraph(-1,2),c2+linewidth(1.2pt));
draw((-1,0)--(2,0),c2+opacity(0.60)+linewidth(1.6pt));
draw((0,0)--(0,4),c2+opacity(0.60)+linewidth(1.6pt));
label("$S$",(0.55,-0.30),black+fontsize(7pt));
label("$f(S)$",(0.35,3.25),black+fontsize(7pt));
bookOrigin();

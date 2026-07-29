import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";

size(6cm,5cm,keepAspect=true);
defaultpen(fontsize(9pt));

real xmin=-2, xmax=2, ymin=-1.2, ymax=4.2;
fill(box((xmin,ymin),(xmax,0)),c2+opacity(0.10));
fill(box((xmin,0),(0,4)),c2+opacity(0.10));
drawBookAxes(xmin,xmax,ymin,ymax,
             new real[] {-2,-1,0,1,2},
             new real[] {-1,0,1,2,3,4},
             "$x$","$f(x)$");
draw(squareGraph(0,2),c1+linewidth(0.8pt));
draw((1,0)--(1,1)--(0,1),dashedHelperPen);
bookDot((1,1));
bookOrigin();

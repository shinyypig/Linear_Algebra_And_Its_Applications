import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";

size(6cm,5cm,keepAspect=true);
defaultpen(fontsize(9pt));

real xmin=-2, xmax=2, ymin=-1.2, ymax=4.2;
fill(box((xmin,ymin),(xmax,0)),c2+opacity(0.10));

path leftArea=(-1.5,0)--squareGraph(-1.5,-1)--(-1,0)--cycle;
path rightArea=(1,0)--squareGraph(1,1.5)--(1.5,0)--cycle;
fill(leftArea,c5+opacity(0.18));
fill(rightArea,c5+opacity(0.18));

path middle=(-1,1);
for(int i=1; i <= 40; ++i) {
    real x=-1-0.5*i/40;
    middle=middle--(x,x*x);
}
middle=middle--(1.5,2.25);
for(int i=1; i <= 40; ++i) {
    real x=1.5-0.5*i/40;
    middle=middle--(x,x*x);
}
middle=middle--cycle;
fill(middle,c5+opacity(0.18));

drawBookAxes(xmin,xmax,ymin,ymax,
             new real[] {-2,-1,0,1,2},
             new real[] {-1,0,1,2,3,4},
             "$x$","$f(x)$");
draw(squareGraph(-2,2),c1+linewidth(0.8pt));
draw((-1,0)--(-1,1)--(1,1)--(1,0),dashedHelperPen);
draw((-1.5,0)--(-1.5,2.25)--(1.5,2.25)--(1.5,0),dashedHelperPen);
for(pair z : new pair[] {(-1,1),(1,1),(-1.5,2.25),(1.5,2.25)})
    bookDot(z);
bookOrigin();

import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";

size(6cm,4cm,keepAspect=true);

real xmin=-2, xmax=2, ymin=-1.2, ymax=4.2;
fill(box((xmin,ymin),(xmax,0)),c2+opacity(0.10));
fill(box((xmin,0),(0,4)),c2+opacity(0.10));

path under=(1,0)--squareGraph(1,1.5)--(1.5,0)--cycle;
fill(under,c5+opacity(0.18));

path band=(0,1)--(1,1);
for(int i=1; i <= 40; ++i) {
    real x=1+0.5*i/40;
    band=band--(x,x*x);
}
band=band--(0,2.25)--cycle;
fill(band,c5+opacity(0.18));

drawBookAxes(xmin,xmax,ymin,ymax,
             new real[] {-2,-1,0,1,2},
             new real[] {-1,0,1,2,3,4},
             "$x$","$f(x)$");
draw(squareGraph(0,2),c1+linewidth(0.8pt));
draw((1,0)--(1,1)--(0,1),dashedHelperPen);
draw((1.5,0)--(1.5,2.25)--(0,2.25),dashedHelperPen);
for(pair z : new pair[] {(1,1),(1.5,2.25)})
    bookDot(z);
bookOrigin();

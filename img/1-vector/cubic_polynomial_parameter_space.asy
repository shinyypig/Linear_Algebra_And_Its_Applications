import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";
texpreamble("\usepackage{ctex}");

size(7cm,5.5cm,keepAspect=true);
defaultpen(fontsize(9pt));

real pmin=-4.5;
real pmax=4.5;
real qmin=-4.5;
real qmax=4.5;
real tmax=sqrt(-pmin/3);
int samples=120;

pair cuspPoint(real t)
{
    return (-3*t*t,2*t*t*t);
}

// The exterior has Delta<0.  Overlay the cusp interior, where Delta>0.
fill(box((pmin,qmin),(pmax,qmax)),c2Fill10);

path threeReal=cuspPoint(0);
for(int i=1; i <= samples; ++i) {
    threeReal=threeReal--cuspPoint(tmax*i/samples);
}
threeReal=threeReal--cuspPoint(-tmax);
for(int i=samples-1; i >= 0; --i) {
    threeReal=threeReal--cuspPoint(-tmax*i/samples);
}
threeReal=threeReal--cycle;
fill(threeReal,c5Fill18);

// The discriminant locus 4p^3+27q^2=0, parametrized by
// (p,q)=(-3t^2,2t^3).
path discriminantCurve=cuspPoint(-tmax);
for(int i=1; i <= 2*samples; ++i) {
    real t=-tmax+2*tmax*i/(2*samples);
    discriminantCurve=discriminantCurve--cuspPoint(t);
}
draw(discriminantCurve,c2+linewidth(0.8pt));

real[] noTicks;
drawBookAxes(pmin,pmax,qmin,qmax,noTicks,noTicks,"$p$","$q$");

label("$\Delta_3>0$",(-3.1,1),black+fontsize(9pt));
label("三个不同实根",(-3.1,0.4),black+fontsize(8pt));

label("$\Delta_3<0$",(1.5,-0.80),black+fontsize(9pt));
label("一个实根",(1.5,-1.40),black+fontsize(8pt));
label("一对共轭复根",(1.5,-2.00),black+fontsize(8pt));

label("重根 $\Delta_3=0$",(-2.65,-2.35),
      black+fontsize(8pt));

bookOrigin();
shipout(bbox(currentpicture,0.5mm,p=invisible));

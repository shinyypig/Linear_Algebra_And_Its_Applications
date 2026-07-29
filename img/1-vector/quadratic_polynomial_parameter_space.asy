import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";
texpreamble("\usepackage{ctex}");

size(4cm,keepAspect=true);

real a1min=-4.5;
real a1max=4.5;
real a0min=-4.5;
real a0max=4.5;
real intersection=2*sqrt(a0max);
int samples=120;

pair discriminantPoint(real a1)
{
    return (a1,a1*a1/4);
}

// Above the parabola Delta<0.  Overlay the region below it, where Delta>0.
fill(box((a1min,a0min),(a1max,a0max)),c2Fill10);

path twoReal=(a1min,a0min)--(a1max,a0min)--(a1max,a0max)--
             (intersection,a0max);
for(int i=1; i <= samples; ++i) {
    real a1=intersection-2*intersection*i/samples;
    twoReal=twoReal--discriminantPoint(a1);
}
twoReal=twoReal--(a1min,a0max)--cycle;
fill(twoReal,c5Fill18);

path discriminantCurve=discriminantPoint(-intersection);
for(int i=1; i <= samples; ++i) {
    real a1=-intersection+2*intersection*i/samples;
    discriminantCurve=discriminantCurve--discriminantPoint(a1);
}
draw(discriminantCurve,c1+linewidth(0.8pt));

real[] noTicks;
drawBookAxes(a1min,a1max,a0min,a0max,noTicks,noTicks,"$a_1$","$a_0$");

label("$\Delta_2<0$",(1.5,2.75),textPen);

label("$\Delta_2>0$",(1.5,-1.05),textPen);

label("$\Delta_2=0$",(-2.65,2.05),annotationTextPen);

bookOrigin();
shipout(bbox(currentpicture,0.5mm,p=invisible));

import graph3;
import bookstyle;

settings.tex = "xelatex";
// The build recovers alpha from matched black/white renders and wraps the
// result in PDF through the wrapper under scripts/.
settings.outformat = "png";
currentlight.background=(settings.user == "transparent-black;") ? black : white;

size(7cm);
defaultpen(fontsize(9pt));
currentprojection=orthographic(4,-1.5,1.5);

triple conePoint(pair t)
{
    real s=t.x;
    real theta=t.y;
    return (s*(1+cos(theta))/sqrt(2),
            sqrt(2)*s*sin(theta),
            s*(1-cos(theta))/sqrt(2));
}

surface discriminantCone=
    surface(conePoint,(-1.55,0),(1.55,2pi),18,36,Spline);

draw(discriminantCone,
     surfacepen=c3Fill18+opacity(0.48),
     meshpen=c3Line45+linewidth(0.35pt),
     light=nolight);

draw((-2.5,0,0)--(2.5,0,0),axisPen,axisArrow3);
draw((0,-2.5,0)--(0,2.5,0),axisPen,axisArrow3);
draw((0,0,-2.5)--(0,0,2.5),axisPen,axisArrow3);

triple labelOffset=0.10*unit(currentprojection.camera-currentprojection.target);
label("$a_0$",(2.7,0,0)+labelOffset,E,textPen);
label("$a_1$",(0,2.7,0)+labelOffset,E,textPen);
label("$a_2$",(0,0,2.7)+labelOffset,N,textPen);
dot(labelOffset*0.4,black+2.4pt);
label("$O$",labelOffset,SW,black+fontsize(7pt));

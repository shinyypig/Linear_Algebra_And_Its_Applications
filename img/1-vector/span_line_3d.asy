import bookstyle;

settings.tex = "xelatex";
// The build recovers alpha from matched black/white renders and wraps the
// result in PDF.
settings.outformat = "png";
currentlight.background=(settings.user == "transparent-black;") ? black : white;
texpreamble("\usepackage{bm}");

size(4cm);
currentprojection=orthographic(4,-4,2);

triple O=(0,0,0);
triple viewDirection=unit(currentprojection.camera-currentprojection.target);
triple faceOffset=0.04*viewDirection;
triple labelOffset=0.10*viewDirection;

draw((-2.3,0,0)--(2.3,0,0),axisPen,axisArrow3);
draw((0,-2.3,0)--(0,2.3,0),axisPen,axisArrow3);
draw((0,0,-1.8)--(0,0,1.8),axisPen,axisArrow3);
label("$x$",(2.3,0,0),E,textPen);
label("$y$",(0,2.3,0),E,textPen);
label("$z$",(0,0,1.8),N,textPen);

draw((-1.2,-1.2,-1.8)--(1.2,1.2,1.8),
     black+linewidth(0.6pt)+dashed);
draw(O+faceOffset--(1,1,1.5)+faceOffset,
     c1+linewidth(0.8pt),arrow=vectorArrow3,arrowheadlight=nolight);

dot(O+faceOffset,black+2.4pt);
label("$O$",O+labelOffset,SW,minorTextPen);
label("$\bm{v}$",(0.9,0.9,1.2)+labelOffset,E,textPen);

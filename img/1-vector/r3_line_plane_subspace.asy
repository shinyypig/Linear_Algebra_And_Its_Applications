import bookstyle;

settings.tex = "xelatex";
// The build recovers alpha from matched black/white renders and wraps the
// result in PDF.
settings.outformat = "png";
currentlight.background =
    (settings.user == "transparent-black;") ? black : white;

size(4cm);
currentprojection = orthographic(4,-4,2);

triple O = (0,0,0);
triple viewDirection =
    unit(currentprojection.camera-currentprojection.target);
triple faceOffset = 0.04*viewDirection;
triple labelOffset = 0.16*viewDirection;

// A plane through the origin: P={(x,y,z): y=z}.
path3 planeBoundary =
    (-1.35,-1.20,-1.20)--
    ( 1.35,-1.20,-1.20)--
    ( 1.35, 1.20, 1.20)--
    (-1.35, 1.20, 1.20)--cycle;
surface P = surface(planeBoundary);

draw(
    P,
    surfacepen=c3Fill18+opacity(0.65),
    meshpen=c3Line40+linewidth(0.4pt),
    light=nolight
);

// A line through the origin that intersects P only at O.
triple lineDirection = unit((0.45,-0.25,1));
triple lineEnd = 1.75*lineDirection;
draw(-lineEnd--lineEnd,c1+linewidth(0.8pt));

draw((-2.3,0,0)--(2.3,0,0),axisPen,axisArrow3);
draw((0,-2.3,0)--(0,2.3,0),axisPen,axisArrow3);
draw((0,0,-1.8)--(0,0,1.8),axisPen,axisArrow3);

label("$x$",(2.3,0,0),E,textPen);
label("$y$",(0,2.3,0),E,textPen);
label("$z$",(0,0,1.8),N,textPen);
label("$P$",(-1.05,0.90,0.90)+labelOffset,NW,textPen);
label("$\ell$",lineEnd+labelOffset,E,textPen);

dot(O+faceOffset,black+2.4pt);
label("$O$",O+labelOffset,SW,minorTextPen);

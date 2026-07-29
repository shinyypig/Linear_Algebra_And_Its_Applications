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
triple labelOffset=0.50*viewDirection;

// The plane span{u,v}: y=z.
path3 planeBoundary =
    (-1.2, -1.2, -1.2)--
    ( 1.2, -1.2, -1.2)--
    ( 1.2,  1.2,  1.2)--
    (-1.2,  1.2,  1.2)--cycle;
surface plane = surface(planeBoundary);

// All geometric objects remain in the same 3D scene.  The renderer determines
// visibility from the camera and depth buffer without manual axis splitting.
draw(
    plane,
    surfacepen=c3Fill18 + opacity(0.65),
    meshpen=c3Line40 + linewidth(0.4pt),
    light=nolight
);

draw((-2.3,0,0)--(2.3,0,0),axisPen,axisArrow3);
draw((0,-2.3,0)--(0,2.3,0),axisPen,axisArrow3);
draw((0,0,-1.8)--(0,0,1.8),axisPen,axisArrow3);

label("$x$",(2.3,0,0),E,textPen);
label("$y$",(0,2.3,0),E,textPen);
label("$z$",(0,0,1.8),N,textPen);

dot(O+faceOffset,black+2.4pt);
label("$O$",O+labelOffset,SW,minorTextPen);

// u=(1,0,0), v=(0,1,1).
// Lift coplanar decorations slightly towards the camera to avoid z-fighting.
triple uEnd = (1, 0, 0);
triple vEnd = (0, 0.707, 0.707);

draw((O + faceOffset)--(uEnd + faceOffset), c1 + linewidth(0.8pt),
     arrow=vectorArrow3, arrowheadlight=nolight);
label("$\bm{u}$", uEnd + labelOffset, S, textPen);

draw((O + faceOffset)--(vEnd + faceOffset), c2 + linewidth(0.8pt),
     arrow=vectorArrow3, arrowheadlight=nolight);
label("$\bm{v}$", vEnd + labelOffset, E, textPen);

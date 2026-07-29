import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";
texpreamble("\usepackage{bm}");

size(4cm);

real axisMax=4.3;
pair O=(0,0);
pair u=(2,1);
pair v=(1,2);
pair uv=(3,3);

drawBookAxes(0,axisMax,0,axisMax,
             new real[] {1,2,3,4},new real[] {1,2,3,4});

draw(u--uv,dashedHelperPen);
draw(v--uv,dashedHelperPen);

draw(O--u,c1+linewidth(0.8pt),vectorArrow);
draw(O--v,c2+linewidth(0.8pt),vectorArrow);
draw(O--uv,c5+linewidth(0.8pt),vectorArrow);

label("$\bm{u}$",(1,0.5),SE,textPen);
label("$\bm{v}$",(0.5,1),W,textPen);
label("$\bm{u}+\bm{v}$",(1.9,2.5),W,textPen);
bookOrigin(O);

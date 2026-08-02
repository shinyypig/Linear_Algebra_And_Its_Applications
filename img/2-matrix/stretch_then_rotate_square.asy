import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";
texpreamble("\usepackage{amsmath,bm}");

size(10cm,4cm,keepAspect=true);

void drawLocalAxes(pair O)
{
    real xmin=-2.5, xmax=2.5, ymin=-0.20, ymax=2.5;
    draw(O+(xmin,0)--O+(xmax,0),axisPen,axisArrow);
    draw(O+(0,ymin)--O+(0,ymax),axisPen,axisArrow);
    label("$x$",O+(xmax-0.05,0.08),NW,minorTextPen);
    label("$y$",O+(0.08,ymax-0.05),SE,minorTextPen);
}

path Q=(0,0)--(1,0)--(1,1)--(0,1)--cycle;
path AQ=(0,0)--(2,0)--(2,1)--(0,1)--cycle;
path BAQ=(0,0)--(0,2)--(-1,2)--(-1,0)--cycle;

pair O1=(2.30,0.50);
pair O2=(8.50,0.50);
pair O3=(14.70,0.50);

drawLocalAxes(O1);
filldraw(shift(O1.x,O1.y)*Q,c1Fill05,c1+linewidth(0.8pt));
dot(O1,black+2.4pt);

draw((4.90,1.45)--(5.90,1.45),axisPen,axisArrow);
label("$\mathbf A$",(5.40,1.55),N,textPen);

drawLocalAxes(O2);
filldraw(shift(O2.x,O2.y)*AQ,c2Fill10,c2+linewidth(0.8pt));
dot(O2,black+2.4pt);

draw((11.10,1.45)--(12.10,1.45),axisPen,axisArrow);
label("$\mathbf B$",(11.60,1.55),N,textPen);

drawLocalAxes(O3);
filldraw(shift(O3.x,O3.y)*BAQ,c5Fill18,c5+linewidth(0.8pt));
dot(O3,black+2.4pt);

shipout(bbox(currentpicture,0.4mm,p=invisible));

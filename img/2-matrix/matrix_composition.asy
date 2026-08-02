import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";
texpreamble("\usepackage{amsmath,bm}");

size(4.5cm,4.5cm,keepAspect=true);

pair v=(1,1);
pair Av=(1,2);
pair BAv=(3,2);

// Dashed guides show the horizontal and vertical projections of the
// three vector endpoints without adding coordinate labels.
draw((1,0)--(1,2),dashedHelperPen);
draw((3,0)--(3,2),dashedHelperPen);
draw((0,1)--(1,1),dashedHelperPen);
draw((0,2)--(3,2),dashedHelperPen);

draw((0,0)--(3.5,0),axisPen,axisArrow);
draw((0,0)--(0,3.5),axisPen,axisArrow);
real tickHalf=0.035;
for(real t : new real[]{1,2,3}) {
    draw((t,-tickHalf)--(t,tickHalf),tickPen);
    label("$"+string(t)+"$",(t,-0.10),S,minorTextPen);
    draw((-tickHalf,t)--(tickHalf,t),tickPen);
    label("$"+string(t)+"$",(-0.10,t),W,minorTextPen);
}
label("$x$",(3.45,0.08),NW,textPen);
label("$y$",(0.08,3.45),SE,textPen);

draw((0,0)--v,c1+linewidth(1.0pt),vectorArrow);
draw((0,0)--Av,c2+linewidth(1.0pt),vectorArrow);
draw((0,0)--BAv,c5+linewidth(1.0pt),vectorArrow);

label("$\bm v$",v,SE,textPen);
label("$\mathbf A\bm v$",Av,NE,textPen);
label("$\mathbf B\mathbf A\bm v$",BAv,NE,textPen);
bookOrigin();

shipout(bbox(currentpicture,0.4mm,p=invisible));

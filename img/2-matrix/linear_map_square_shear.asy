import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";

size(9cm,3.2cm,keepAspect=true);

pair leftOrigin = (-3.2,0);
pair rightOrigin = (1.2,0);
real axisLength = 2.35;

// The unit square and its image under (x,y) -> (x+y,y).
path unitSquare = leftOrigin -- leftOrigin+(1,0) -- leftOrigin+(1,1) -- 
leftOrigin+(0,1) -- cycle;
path shearedSquare = rightOrigin -- rightOrigin+(1,0) -- rightOrigin+(2,1) -- 
rightOrigin+(1,1) -- cycle;

fill(unitSquare,c1Fill05);
fill(shearedSquare,c2Fill10);

draw(leftOrigin -- leftOrigin+(axisLength,0),axisPen,axisArrow);
draw(leftOrigin -- leftOrigin+(0,1.65),axisPen,axisArrow);
draw(rightOrigin -- rightOrigin+(axisLength,0),axisPen,axisArrow);
draw(rightOrigin -- rightOrigin+(0,1.65),axisPen,axisArrow);

draw(unitSquare,c1+linewidth(0.8pt));
draw(shearedSquare,c2+linewidth(0.8pt));

draw((-0.55,0.55) -- (0.55,0.55),linewidth(0.8pt),vectorArrow);
label("$\varphi$",(0,0.55),N,textPen);

label("$V$",leftOrigin+(1.15,1.35),textPen);
label("$W$",rightOrigin+(1.15,1.35),textPen);
label("$x$",leftOrigin+(axisLength,0),SE,textPen);
label("$y$",leftOrigin+(0,1.65),NW,textPen);
label("$x$",rightOrigin+(axisLength,0),SE,textPen);
label("$y$",rightOrigin+(0,1.65),NW,textPen);

bookOrigin(leftOrigin);
bookOrigin(rightOrigin);
shipout(bbox(currentpicture,0.5mm,p=invisible));

import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";
texpreamble("\usepackage{ctex}");

size(14.5cm);
defaultpen(fontsize(9pt));

pair[] corners={(-0.78,0.78),(0.78,0.78),(0.78,-0.78),(-0.78,-0.78)};

void symmetrySquare(pair center, string operation, string[] digits)
{
    filldraw(shift(center)*box((-0.78,-0.78),(0.78,0.78)),
             c1Fill05,black+linewidth(0.8pt));
    for(int i=0; i < 4; ++i) {
        pair z=center+corners[i];
        filldraw(circle(z,0.16),white,c1+linewidth(0.8pt));
        label("\textbf{"+digits[i]+"}",z,black+fontsize(7pt));
    }
    label(operation,center+(0,-1.18),black+fontsize(7pt));
}

pair[] top={(0,2.55),(3.1,2.55),(6.2,2.55),(9.3,2.55)};
pair[] bottom={(0,0),(3.1,0),(6.2,0),(9.3,0)};

symmetrySquare(top[0],"旋转 $0^\circ$",new string[] {"1","2","3","4"});
label("$e$",top[0],textPen);

string[][] rotations={
    {"4","1","2","3"},
    {"3","4","1","2"},
    {"2","3","4","1"}
};
real[] ends={0,-90,-180};
for(int i=0; i < 3; ++i) {
    pair c=top[i+1];
    symmetrySquare(c,"旋转 $"+string(90*(i+1))+"^\circ$",rotations[i]);
    draw(circle(c,0.42),black+linewidth(0.4pt));
    draw(arc(c,0.42,90,ends[i]),c2+linewidth(0.8pt),vectorArrow);
}

symmetrySquare(bottom[0],"关于竖直轴反射",
               new string[] {"2","1","4","3"});
draw(bottom[0]+(0,-1)--bottom[0]+(0,1),c2+linewidth(0.8pt)+dashed);

symmetrySquare(bottom[1],"关于对角线 $24$ 反射",
               new string[] {"3","2","1","4"});
draw(bottom[1]+(-0.58,-0.58)--bottom[1]+(0.58,0.58),
     c2+linewidth(0.8pt)+dashed);

symmetrySquare(bottom[2],"关于水平轴反射",
               new string[] {"4","3","2","1"});
draw(bottom[2]+(-1,0)--bottom[2]+(1,0),c2+linewidth(0.8pt)+dashed);

symmetrySquare(bottom[3],"关于对角线 $13$ 反射",
               new string[] {"1","4","3","2"});
draw(bottom[3]+(-0.58,0.58)--bottom[3]+(0.58,-0.58),
     c2+linewidth(0.8pt)+dashed);

// Keep strokes on the outermost corner markers inside the PDF MediaBox.
shipout(bbox(currentpicture,0.3mm,p=invisible));

import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";

texpreamble("\usepackage{bm}");

size(12cm);

real cell = 0.38;
pen gridPen = black+linewidth(0.45pt);

void matrixGrid(pair O, int rows, int cols)
{
    for(int r=0; r < rows; ++r) {
        for(int c=0; c < cols; ++c) {
            pair z = O+(c*cell,(rows-1-r)*cell);
            filldraw(box(z,z+(cell,cell)),white,gridPen);
        }
    }
}

void fillColumn(pair O, int rows, int col, pen p)
{
    for(int r=0; r < rows; ++r) {
        pair z = O+(col*cell,(rows-1-r)*cell);
        filldraw(box(z,z+(cell,cell)),p,gridPen);
    }
}

void fillRow(pair O, int rows, int cols, int row, pen p)
{
    for(int c=0; c < cols; ++c) {
        pair z = O+(c*cell,(rows-1-row)*cell);
        filldraw(box(z,z+(cell,cell)),p,gridPen);
    }
}

pair A = (0,0.55);
pair B = (1.75,0.36);

matrixGrid(A,2,3);
fillColumn(A,2,0,c1Fill50);
fillColumn(A,2,1,c2Fill50);
fillColumn(A,2,2,c5Fill50);

matrixGrid(B,3,2);
fillRow(B,3,2,0,c3Fill50);
fillRow(B,3,2,1,c4Fill50);
fillRow(B,3,2,2,c6Fill50);

// label("$\mathbf A$",A+(1.5*cell,-0.15),S,textPen);
// label("$\mathbf B$",B+(cell,-0.15),S,textPen);
label("$\times$",(1.445,0.93),textPen);
label("$=$",(2.98,0.93),textPen);

pen[] columnFills = new pen[] {c1Fill50,c2Fill50,c5Fill50};
pen[] rowFills = new pen[] {c3Fill50,c4Fill50,c6Fill50};
real[] termX = new real[] {3.45,5.55,7.65};

for(int k=0; k < 3; ++k) {
    pair colO = (termX[k],0.55);
    pair rowO = (termX[k]+0.78,0.74);

    matrixGrid(colO,2,1);
    fillColumn(colO,2,0,columnFills[k]);
    matrixGrid(rowO,1,2);
    fillRow(rowO,1,2,0,rowFills[k]);

    // label("$\bm\alpha_"+string(k+1)+"$",
    //       colO+(0.5*cell,2*cell+0.10),N,minorTextPen);
    // label("$\bm\beta_"+string(k+1)+"^{\mathsf T}$",
    //       rowO+(cell,cell+0.10),N,minorTextPen);
    label("$\times$",(termX[k]+0.58,0.93),textPen);

    if(k < 2) {
        label("$+$",(termX[k]+1.75,0.93),textPen);
    }
}

shipout(bbox(currentpicture,0.5mm,p=invisible));

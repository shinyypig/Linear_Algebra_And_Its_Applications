import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";

size(10cm);

real cell = 0.38;
pen gridPen = black+linewidth(0.45pt);

void matrixGrid(pair O, int rows, int cols,
                real cellWidth=cell, real cellHeight=cell)
{
    for(int r=0; r < rows; ++r) {
        for(int c=0; c < cols; ++c) {
            pair z = O+(c*cellWidth,(rows-1-r)*cellHeight);
            filldraw(box(z,z+(cellWidth,cellHeight)),white,gridPen);
        }
    }
}

void fillColumn(pair O, int rows, int col, pen p,
                real cellWidth=cell, real cellHeight=cell)
{
    for(int r=0; r < rows; ++r) {
        pair z = O+(col*cellWidth,(rows-1-r)*cellHeight);
        filldraw(box(z,z+(cellWidth,cellHeight)),p,gridPen);
    }
}

void fillRow(pair O, int rows, int cols, int row, pen p,
             real cellWidth=cell, real cellHeight=cell)
{
    for(int c=0; c < cols; ++c) {
        pair z = O+(c*cellWidth,(rows-1-row)*cellHeight);
        filldraw(box(z,z+(cellWidth,cellHeight)),p,gridPen);
    }
}

void diagramProductCell(pair O, int row, int col, pen rowFill, pen columnFill,
                        real cellWidth, real cellHeight)
{
    pair z = O+(col*cellWidth,(1-row)*cellHeight);
    real miniCell = 0.16;
    real sideMargin = 0.28;
    pair rowO = z+(sideMargin,0.5*cellHeight-0.5*miniCell);
    pair columnO = z+(cellWidth-sideMargin-miniCell,
                     0.5*cellHeight-1.5*miniCell);
    real productX = 0.5*(rowO.x+3*miniCell+columnO.x);

    filldraw(box(z,z+(cellWidth,cellHeight)),white,gridPen);
    matrixGrid(rowO,1,3,miniCell,miniCell);
    fillRow(rowO,1,3,0,rowFill,miniCell,miniCell);
    matrixGrid(columnO,3,1,miniCell,miniCell);
    fillColumn(columnO,3,0,columnFill,miniCell,miniCell);
    label("$\times$",(productX,z.y+0.5*cellHeight),minorTextPen);
}

pair A = (0,0.80);
pair B = (1.95,0.61);
pair C = (3.85,0.25);
real productCellWidth = 1.48;
real productCellHeight = 1.02;

matrixGrid(A,2,3);
fillRow(A,2,3,0,c1Fill50);
fillRow(A,2,3,1,c2Fill50);

matrixGrid(B,3,2);
fillColumn(B,3,0,c3Fill50);
fillColumn(B,3,1,c4Fill50);

matrixGrid(C,2,2,productCellWidth,productCellHeight);
diagramProductCell(C,0,0,c1Fill50,c3Fill50,
                   productCellWidth,productCellHeight);
diagramProductCell(C,0,1,c1Fill50,c4Fill50,
                   productCellWidth,productCellHeight);
diagramProductCell(C,1,0,c2Fill50,c3Fill50,
                   productCellWidth,productCellHeight);
diagramProductCell(C,1,1,c2Fill50,c4Fill50,
                   productCellWidth,productCellHeight);

// label("$\mathbf A$",A+(1.5*cell,-0.15),S,textPen);
// label("$\mathbf B$",B+(cell,-0.15),S,textPen);
// label("$\mathbf A\mathbf B$",C+(productCellWidth,-0.15),S,textPen);
label("$\times$",(1.545,1.18),textPen);
label("$=$",(3.15,1.27),textPen);

shipout(bbox(currentpicture,0.5mm,p=invisible));

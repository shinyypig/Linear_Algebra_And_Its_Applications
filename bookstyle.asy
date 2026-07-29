// Shared Asymptote style for the book.

import three;

// Shared rendering quality.  Individual figures may override this value
// after importing bookstyle.
settings.render = 8;

pen textPen = black + fontsize(7pt);
pen annotationTextPen = black + fontsize(7pt);
pen minorTextPen = black + fontsize(6pt);
pen axisPen = black + linewidth(0.6pt);
pen helperPen = black + linewidth(0.45pt);
pen tickPen = black + linewidth(0.35pt);
pen dashedHelperPen = black + linewidth(0.6pt) + dashed;

defaultpen(textPen);

pen c1 = rgb(0, 0.4470, 0.7410);
pen c2 = rgb(0.8500, 0.3250, 0.0980);
pen c3 = rgb(0.9290, 0.6940, 0.1250);
pen c4 = rgb(0.4940, 0.1840, 0.5560);
pen c5 = rgb(0.4660, 0.6740, 0.1880);
pen c6 = rgb(0.3010, 0.7450, 0.9330);
pen c7 = rgb(0.6350, 0.0780, 0.1840);

// Exact xcolor-style mixtures on a white background.
pen c1Fill05 = rgb(0.95000, 0.97235, 0.98705);
pen c1Fill60 = rgb(0.40000, 0.66820, 0.84460);
pen c2Fill10 = rgb(0.98500, 0.93250, 0.90980);
pen c3Fill18 = rgb(0.98722, 0.94492, 0.84250);
pen c3Line40 = rgb(0.97160, 0.87760, 0.65000);
pen c3Line45 = rgb(0.96805, 0.86230, 0.60625);
pen c5Fill18 = rgb(0.90388, 0.94132, 0.85384);

arrowbar axisArrow = Arrow(DefaultHead, size=6pt, filltype=Fill);
arrowbar vectorArrow = Arrow(DefaultHead, size=6pt, filltype=Fill);
// DefaultHead2 is stable under OpenGL depth rendering; pure filling avoids the
// rounded outline that otherwise makes small 3D arrowheads look blunt.
arrowbar3 axisArrow3 =
    Arrow3(DefaultHead2, size=4pt, filltype=Fill);
arrowbar3 vectorArrow3 =
    Arrow3(DefaultHead2, size=4pt, filltype=Fill);

// Sample the parabola y=x^2 as a vector path.
path squareGraph(real a, real b, int samples=100)
{
    path g=(a,a*a);
    for(int i=1; i <= samples; ++i) {
        real x=a+(b-a)*i/samples;
        g=g--(x,x*x);
    }
    return g;
}

// Textbook-style Cartesian axes with explicit ticks.  The axes cross at zero
// when zero is visible; otherwise they follow the lower plot boundaries.
void drawBookAxes(real xmin, real xmax, real ymin, real ymax,
                  real[] xTicks, real[] yTicks,
                  string xLabel="$x$", string yLabel="$y$")
{
    real xAxisY=(ymin <= 0 && 0 <= ymax) ? 0 : ymin;
    real yAxisX=(xmin <= 0 && 0 <= xmax) ? 0 : xmin;
    real dx=xmax-xmin;
    real dy=ymax-ymin;
    real xTickHalf=0.010*dy;
    real yTickHalf=0.010*dx;

    draw((xmin,xAxisY)--(xmax,xAxisY),axisPen,axisArrow);
    draw((yAxisX,ymin)--(yAxisX,ymax),axisPen,axisArrow);

    for(real x : xTicks) {
        if(abs(x-yAxisX) > 1e-8) {
            draw((x,xAxisY-xTickHalf)--(x,xAxisY+xTickHalf),tickPen);
            label("$"+string(x)+"$",(x,xAxisY-0.030*dy),S,
                  minorTextPen);
        }
    }
    for(real y : yTicks) {
        if(abs(y-xAxisY) > 1e-8) {
            draw((yAxisX-yTickHalf,y)--(yAxisX+yTickHalf,y),tickPen);
            label("$"+string(y)+"$",(yAxisX-0.030*dx,y),W,
                  minorTextPen);
        }
    }

    label(xLabel,(xmax-0.015*dx,xAxisY+0.025*dy),NW,textPen);
    label(yLabel,(yAxisX+0.025*dx,ymax-0.015*dy),SE,textPen);
}

// Filled textbook marker with the same c1/c1!60 hierarchy as the TikZ plots.
void bookDot(pair z, real outerSize=3.2pt, real innerSize=2.4pt)
{
    dot(z,c1+outerSize);
    dot(z,c1Fill60+innerSize);
}

// Mark the actual coordinate origin, independently of data-point styling.
void bookOrigin(pair z=(0,0))
{
    dot(z,black+3.2pt);
    label("$O$",z,SW,minorTextPen);
}

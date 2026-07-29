import bookstyle;

settings.tex = "xelatex";
settings.outformat = "pdf";
texpreamble("\usepackage{ctex}");

size(5.5cm,5.5cm,IgnoreAspect);
defaultpen(fontsize(9pt));

real xmin=155, xmax=190, ymin=35, ymax=50;
drawBookAxes(xmin,xmax,ymin,ymax,
             new real[] {160,170,180,190},
             new real[] {35,40,45,50},
             "身高 (cm)","鞋码");

pair[] data={
    (158.3,37.5),(161.2,38.0),(163.7,39.5),
    (165.4,38.5),(167.8,40.5),(169.1,39.0),
    (170.5,41.0),(172.3,40.5),(174.6,42.5),
    (176.2,43.0),(177.9,41.5),(180.4,43.5),
    (181.8,44.5),(183.6,43.0),(185.2,44.5)
};
for(pair z : data)
    bookDot(z,4pt,3pt);

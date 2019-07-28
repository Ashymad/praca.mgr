using IOLA
using PGFPlotsX
PGFPlotsX.enable_interactive(false)

par = Codec.getParams(Codec.MP3)

win = par.window(par.length)

fig = @pgf TikzPicture(Axis(Plot(Table(; x = 1:par.length, y = win))))

pgfsave("plots/win_sine.pgf", fig)

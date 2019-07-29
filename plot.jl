using IOLA
using PGFPlotsX
PGFPlotsX.enable_interactive(false)

axis_theme = @pgf {xmajorgrids,
                   ymajorgrids,
                   "/pgf/number format/use comma",
                   "/pgf/number format/1000 sep"={},
                   "every axis plot/.style"={no_marks, thick}
                  };

for codec in instances(Codec.CodecType)
    par = Codec.getParams(codec)

    win = par.window(par.length)

    fig = @pgf TikzPicture(Axis({axis_theme..., xlabel = raw"$n$", ylabel = raw"$w(n)$"},
                                Plot(Table(; x = 1:par.length, y = win))))

    pgfsave("plots/win_$codec.pgf", fig)
end

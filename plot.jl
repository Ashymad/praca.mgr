using IOLA
using JLD2, FileIO
using PGFPlotsX
using IOLA.Utils: fast_sum_abs_log10_abs!
using BenchmarkTools
using Statistics
PGFPlotsX.enable_interactive(false)

axis_theme = @pgf {xmajorgrids,
                   ymajorgrids,
                   "/pgf/number format/use comma",
                   "/pgf/number format/1000 sep"={},
                   "every axis plot/.style"={no_marks, thick}
                  };

function plot_windows()
    for codec in instances(Codec.CodecType)
        par = Codec.getParams(codec)

        win = par.window(par.length)

        fig = @pgf TikzPicture(Axis({axis_theme..., xlabel = raw"$n$", ylabel = raw"$w(n)$"},
                                    Plot(Table(; x = 1:par.length, y = win))))

        pgfsave("plots/win_$codec.pgf", fig)
    end
end

function plot_sum_abs_log_abs(recalc=false)

    data = if recalc
        suite = BenchmarkGroup()
        suite["naive"] = BenchmarkGroup()
        suite["IOLA"] = BenchmarkGroup()

        function sum_abs_log10_abs(x)
            sum(abs.(log10.(abs.(x))))
        end

        sizes = 10 .^ (0:7)
        for size in sizes
            data = rand(size)
            suite["naive"][size] = @benchmarkable sum_abs_log10_abs($data)
            suite["IOLA"][size] = @benchmarkable fast_sum_abs_log10_abs!(copy($data))
        end

        tune!(suite)
        results = run(suite)

        res = Vector()

        for size in sizes
            push!(res, median(results["naive"][size].times)/median(results["IOLA"][size].times))
        end
        sum_abs_log_abs = Dict("x" => sizes, "y" => res)
        @save "plot_data.jld2" sum_abs_log_abs
        sum_abs_log_abs
    else
        @load "plot_data.jld2" sum_abs_log_abs
        sum_abs_log_abs
    end

    fig = @pgf TikzPicture(SemiLogXAxis({axis_theme..., xlabel=raw"$K$",
                                         ylabel=raw"Stosunek czasu wykonywania",
                                         ytick_distance=0.5, xtick=data["x"]},
                                        Plot(Table(; x=data["x"], y=data["y"]))))

    pgfsave("plots/sum_abs_log10_abs.pgf", fig)
end

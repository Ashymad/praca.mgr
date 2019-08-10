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
                   "every axis plot/.style"={thick}
                  };

function plot_windows()
    for codec in instances(Codec.CodecType)
        par = Codec.getParams(codec)

        win = par.window(par.length)

        fig = @pgf TikzPicture(Axis({axis_theme..., xlabel = raw"$n$", ylabel = raw"$w(n)$"},
                                    PlotInc({no_marks}, Table(; x = 1:par.length, y = win))))

        pgfsave("plots/win_$codec.pgf", fig)
    end
end

function plot_sum_abs_log_abs(recalc=false)

    data = if recalc
        suite = BenchmarkGroup()
        suite["naive"] = BenchmarkGroup()
        suite["IOLA"] = BenchmarkGroup()

        sizes = 10 .^ (1:8)
        for size in sizes
            data = rand(size)
            suite["naive"][size] = @benchmarkable sum(abs.(log10.(abs.($data))))
            suite["IOLA"][size] = @benchmarkable fast_sum_abs_log10_abs!(copy($data))
        end

        tune!(suite)
        results = run(suite)

        sum_abs_log_abs = Dict("sizes" => sizes, "results" => results)
        @save "plot_data.jld2" sum_abs_log_abs
        sum_abs_log_abs
    else
        @load "plot_data.jld2" sum_abs_log_abs
        sum_abs_log_abs
    end

    stdofratio(x, y) = sqrt(mean(x.^2)*mean(1 ./(y.^2)) - (mean(x)*mean(1 ./y))^2)

    results = sum_abs_log_abs["results"]
    x = sum_abs_log_abs["sizes"]
    y = Vector{Float64}()
    y_err = Vector{Float64}()

    for size in x
        push!(y, mean(results["naive"][size].times)/mean(results["IOLA"][size].times))
        push!(y_err, stdofratio(results["naive"][size].times, results["IOLA"][size].times))
    end
    fig = @pgf TikzPicture(SemiLogXAxis({axis_theme..., xlabel=raw"$K$",
                                         ylabel=raw"Stosunek czasów wykonywania",
                                         xtick=x, minor_tick_num=3, yminorgrids},
                                        PlotInc({"error bars/y dir=both",
                                                 "error bars/y explicit"},
                                                Coordinates(x, y; yerror=y_err))))
    pgfsave("plots/sum_abs_log10_abs.pgf", fig)
end

function plot_relu()
    x = -6:6
    y = max.(0, x)
    fig = @pgf TikzPicture(Axis({axis_theme..., xlabel = raw"$x$", ylabel = raw"$\max(0,x)$"},
                                PlotInc({no_marks}, Table(; x = x, y = y))))
    pgfsave("plots/relu.pgf", fig)
end

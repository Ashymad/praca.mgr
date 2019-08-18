using Statistics
using HDF5
using LaTeXTabulars
using IOLA.Utils
using LaTeXStrings
using JLD2, FileIO


function table_algo()
    C = h5open("results.h5") do results
        results["C"][:,:]
    end

    cat_len = 16


    C = reshape(C, size(C,1), cat_len, Int(size(C,2)/cat_len))
    Cm = zeros(size(C,1),size(C,2))
    Cstd = zeros(size(Cm)...)
    for i=1:size(C,1), j=1:size(C,2)
        fin_idx = isfinite.(C[i,j,:])
        Cm[i,j] = mean(C[i,j,fin_idx])
        Cstd[i,j] = std(C[i,j,fin_idx])
    end

    textable = hcat(["WAV";
                     L"\multirow{3}{*}{MP3}";"";"";
                     L"\multirow{3}{*}{AAC}";"";"";
                     L"\multirow{3}{*}{Vorbis}";"";"";
                     L"\multirow{3}{*}{WMA}";"";"";
                     L"\multirow{3}{*}{AC-3}";"";""],
                    ["---";repeat(["320";"192";"128"],5)],
                    map((m, std) -> isnan(m) ?  "---" : "\$\\num{$(m)}\\pm\\num{$(std)}\$", 10 .* Cm', 10 .* Cstd'))

    latex_tabular("tables/algo_eval.tex",
                  Tabular("ccccccc"),
                  [["","",L"", L"", L"", L"", L"\makecell[r]{$\times\num[round-precision=1]{0.1}$}"],
                   Rule(:top),
                   ["kodek","bitrate",L"\text{MP3}", L"\text{AAC}", L"\text{AC-3}", L"\text{Vorbis}", L"\text{WMA}"],
                   Rule(:mid),
                   textable[1,:],
                   Rule(),
                   textable[2:4,:],
                   Rule(),
                   textable[5:7,:],
                   Rule(),
                   textable[14:16,:],
                   Rule(),
                   textable[8:10,:],
                   Rule(),
                   textable[11:13,:],
                   Rule(:bottom)])
end

function table_model_c_tp()
    test_conf = load("model_c_t+p.jld2", "test_confs")[end]
    test_conf = 100*test_conf./repeat(sum(test_conf, dims=1), size(test_conf,1))

    textable = hcat([L"\multirow{16}{*}{\rotatebox[origin=c]{90}{Rzeczywisty format}}";repeat([""],15)],
                    ["WAV";
                     L"\multirow{3}{*}{MP3}";"";"";
                     L"\multirow{3}{*}{AAC}";"";"";
                     L"\multirow{3}{*}{Vorbis}";"";"";
                     L"\multirow{3}{*}{WMA}";"";"";
                     L"\multirow{3}{*}{AC-3}";"";""],
                    ["---";repeat(["320";"192";"128"],5)],
                    map((val) -> "\\cellcolor{red!$(10*sqrt(val))}\\num{$val}", test_conf'))
    latex_tabular("tables/model_c_t+p.tex",
                  Tabular("ccccccccccccccccccc"),
                  [
                   ["","","",MultiColumn(16, :c, "Format wykryty przez model")],
                   CMidRule("1pt", nothing, 4, 19),
                   ["", "", "", "WAV", MultiColumn(3, :c, "MP3"), MultiColumn(3, :c, "AAC"),
                    MultiColumn(3, :c, "Vorbis"), MultiColumn(3, :c, "WMA"), MultiColumn(3, :c, "AC-3")],
                   CMidRule(nothing,"r",4,4),
                   CMidRule(nothing,"rl",5,7),
                   CMidRule(nothing,"rl",8,10),
                   CMidRule(nothing,"rl",11,13),
                   CMidRule(nothing,"rl",14,16),
                   CMidRule(nothing,"l",17,19),
                   ["","","","---",repeat(["320","192","128"],5)...],
                   CMidRule("0.5pt",nothing,2,19),
                   textable[1,:],
                   CMidRule(nothing,nothing,2,19),
                   textable[2:4,:],
                   CMidRule(nothing,nothing,2,19),
                   textable[5:7,:],
                   CMidRule(nothing,nothing,2,19),
                   textable[8:10,:],
                   CMidRule(nothing,nothing,2,19),
                   textable[11:13,:],
                   CMidRule(nothing,nothing,2,19),
                   textable[14:16,:],
                   CMidRule("1pt",nothing,2,19),
                  ])

end

function table_model_c_t()
    test_conf = load("model_c_t.jld2", "test_confs")[end]
    test_conf = 100*test_conf./repeat(sum(test_conf, dims=1), size(test_conf,1))

    textable = hcat([L"\multirow{16}{*}{\rotatebox[origin=c]{90}{Rzeczywisty format}}";repeat([""],15)],
                    ["WAV";
                     L"\multirow{3}{*}{MP3}";"";"";
                     L"\multirow{3}{*}{AAC}";"";"";
                     L"\multirow{3}{*}{Vorbis}";"";"";
                     L"\multirow{3}{*}{WMA}";"";"";
                     L"\multirow{3}{*}{AC-3}";"";""],
                    ["---";repeat(["320";"192";"128"],5)],
                    map((val) -> "\\cellcolor{red!$(10*sqrt(val))}\\num{$val}", test_conf'))
    latex_tabular("tables/model_c_t.tex",
                  Tabular("ccccccccc"),
                  [
                   ["","","",MultiColumn(6, :c, "Format wykryty przez model")],
                   CMidRule("1pt", nothing, 4, 9),
                   ["","","","WAV","MP3","AAC","Vorbis","WMA","AC-3"],
                   CMidRule("0.5pt",nothing,2,9),
                   textable[1,:],
                   CMidRule(nothing,nothing,2,9),
                   textable[2:4,:],
                   CMidRule(nothing,nothing,2,9),
                   textable[5:7,:],
                   CMidRule(nothing,nothing,2,9),
                   textable[8:10,:],
                   CMidRule(nothing,nothing,2,9),
                   textable[11:13,:],
                   CMidRule(nothing,nothing,2,9),
                   textable[14:16,:],
                   CMidRule("1pt",nothing,2,9),
                  ])

end

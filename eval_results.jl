using Statistics
using HDF5
using LaTeXTabulars
using LaTeXStrings

cat_mapping =
Dict{Int8, UInt8}(
                  0  => 1, # WAV
                  11 => 2, # MP3 320
                  12 => 3, # MP3 192
                  13 => 4, # MP3 128
                  21 => 5, # AAC 320
                  22 => 6, # AAC 192
                  23 => 7, # AAC 128
                  31 => 8, # OGG 320
                  32 => 9, # OGG 192
                  33 => 10, # OGG 128
                  41 => 11, # WMA 320
                  42 => 12, # WMA 192
                  43 => 13, # WMA 128
                  51 => 14, # AC3 320
                  52 => 15, # AC3 192
                  53 => 16, # AC3 128
                 ) 

#Codecs
# MP3
# AAC
# AC3
# OGG
# WMA
C = h5open("results.h5") do results
    results["C"][:,:]
end


C = reshape(C, size(C,1), length(cat_mapping), Int(size(C,2)/length(cat_mapping)))
Cm = zeros(size(C,1),size(C,2))
Cstd = zeros(size(Cm)...)
for i=1:size(C,1), j=1:size(C,2)
    fin_idx = isfinite.(C[i,j,:])
    Cm[i,j] = mean(C[i,j,fin_idx])
    Cstd[i,j] = std(C[i,j,fin_idx])
end

textable = hcat(["WAV";L"\multirow{3}{*}{MP3}";"";"";L"\multirow{3}{*}{AAC}";"";"";L"\multirow{3}{*}{Vorbis}";"";"";L"\multirow{3}{*}{WMA}";"";"";L"\multirow{3}{*}{AC-3}";"";""],
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

#!/bin/bash

# bash rars_rarscli_testaprimo_bin_time.sh testa_primo "3 251 16381 1048261 66666667 2147483647" 10 rars_rarscli_testaprimo_media.tex rars_rarscli_testaprimo_desvio.tex
programa="$1"
entradas="$2"
total_run="$3"
saida_media="$4"
saida_desvio="$5"
TIMEFORMAT=%3R

echo -n "
\begin{table}[h]
    \centering
    \caption{Media com ${programa} com bin time}
    \label{tab${programa}_media}
    \begin{tabular}{ccccccc}
	\toprule
	& entrada 2 bits & entrada 8 bits & entrada 14 bits & entrada 20 & entrada 26 & entrada 31 \\\\
	\midrule
    RARS " >> $saida_media

echo -n "
\begin{table}[h]
    \centering
    \caption{Desvio padrao com ${programa} com bin time}
    \label{tab${programa}_desvio}
    \begin{tabular}{ccccccc}
	\toprule
	& entrada 2 bits & entrada 8 bits & entrada 14 bits & entrada 20 & entrada 26 & entrada 31 \\\\
	\midrule
    RARS " >> $saida_desvio

# RARS
for entrada in $entradas; do
    echo $entrada > arquivo_entrada
    total_bin_time=0;
    for (( run = 0; run <= $total_run; run++ )); do
        /usr/bin/time -vo output_bin_time java -jar rars.jar ${programa}.riscv < arquivo_entrada >> /dev/null 2>&1 
        bin_time=`grep 'wall clock' output_bin_time | cut -f8 -d' '`
        total_bin_time=$( echo "$total_bin_time + ${bin_time: -4}" | bc -l )
        echo ${bin_time: -4} >> bin_times
    done
    # medias
    media_bin_time=$( echo "$total_bin_time / $total_run" | bc -l )
    echo -n " & ${media_bin_time:0:5}s" >> $saida_media
    # desvios
    somatorio=0;
    for bin_time in `cat bin_times`; do somatorio=$(echo "$somatorio + (($bin_time - $media_bin_time)^2)" | bc -l); done
    rm bin_times
    variancia=$( echo "$somatorio / $total_run" | bc -l )
    desvio=$( echo "sqrt($variancia)" | bc -l )
    echo -n " & ${desvio:0:5}s" >> $saida_desvio
done

# RARS-CLI
echo -n " \\\\
    RARS-CLI " >> $saida_media
echo -n " \\\\
    RARS-CLI " >> $saida_desvio
for entrada in $entradas; do
    echo $entrada > arquivo_entrada
    total_bin_time=0;
    for (( run = 0; run <= $total_run; run++ )); do
        /usr/bin/time -vo output_bin_time java -jar rars-cli.jar ${programa}.riscv < arquivo_entrada >> /dev/null 2>&1
        bin_time=`grep 'wall clock' output_bin_time | cut -f8 -d' '`
        total_bin_time=$( echo "$total_bin_time + ${bin_time: -4}" | bc -l )
        echo ${bin_time: -4} >> bin_times
    done
    # medias
    media_bin_time=$( echo "$total_bin_time / $total_run" | bc -l )
    echo -n " & ${media_bin_time:0:5}s" >> $saida_media
    # desvios
    somatorio=0;
    for bin_time in `cat bin_times`; do somatorio=$(echo "$somatorio + (($bin_time - $media_bin_time)^2)" | bc -l); done
    rm bin_times
    variancia=$( echo "$somatorio / $total_run" | bc -l )
    desvio=$( echo "sqrt($variancia)" | bc -l )
    echo -n " & ${desvio:0:5}s" >> $saida_desvio
done

echo " \\\\
        \bottomrule
    \end{tabular}
\end{table}" >> $saida_media

echo " \\\\
        \bottomrule
    \end{tabular}
\end{table}" >> $saida_desvio
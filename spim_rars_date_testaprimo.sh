#!/bin/bash

# bash spim_rars_date_testaprimo.sh testaprimo "3 251 16381 1048261 66666667 2147483647" 10 spim_rars_testaprimo_media.tex spim_rars_testaprimo_desvio.tex
programa="$1"
entradas="$2"
total_run="$3"
saida_media="$4"
saida_desvio="$5"
TIMEFORMAT=%3R

echo -n "
\begin{table}[h]
    \centering
    \caption{Media com ${programa} com date}
    \label{tab${programa}_media}
    \begin{tabular}{ccccccc}
	\toprule
	& entrada 2 bits & entrada 8 bits & entrada 14 bits & entrada 20 & entrada 26 & entrada 31 \\\\
	\midrule
    SPIM " >> $saida_media

echo -n "
\begin{table}[h]
    \centering
    \caption{Desvio padrao com ${programa} com date}
    \label{tab${programa}_desvio}
    \begin{tabular}{ccccccc}
	\toprule
	& entrada 2 bits & entrada 8 bits & entrada 14 bits & entrada 20 & entrada 26 & entrada 31 \\\\
	\midrule
    SPIM " >> $saida_desvio

# SPIM
for entrada in $entradas; do
    echo $entrada > arquivo_entrada
    total_date=0
    for (( run = 1; run <= $total_run; run++ )); do
        # date
        start=`date +%s.%3N`
        spim -file ${programa}.mips < arquivo_entrada >> /dev/null 2>&1 
        end=`date +%s.%3N`; date=$( echo "$end - $start" | bc -l | sed 's/^\./0./')
        total_date=$( echo "$total_date + $date" | bc -l )
        echo $date >> dates
    done
    # medias
    media_date=$( echo "$total_date / $total_run" | bc -l )
    echo -n " & ${media_date:0:5}s" >> $saida_media
    # desvios
    somatorio=0;
    for date in `cat dates`; do somatorio=$(echo "$somatorio + (($date - $media_date)^2)" | bc -l); done
    rm dates
    variancia=$( echo "$somatorio / $total_run" | bc -l )
    desvio=$( echo "sqrt($variancia)" | bc -l )
    echo -n " & ${desvio:0:5}s" >> $saida_desvio
done

# RARS
echo -n " \\\\
    RARS " >> $saida_media
echo -n " \\\\
    RARS " >> $saida_desvio
for entrada in $entradas; do
    echo $entrada > arquivo_entrada
    total_date=0;
    for (( run = 0; run <= $total_run; run++ )); do
        # date
        start=`date +%s.%3N`
        java -jar rars.jar ${programa}.riscv < arquivo_entrada >> /dev/null 2>&1
        end=`date +%s.%3N`; date=$( echo "$end - $start" | bc -l | sed 's/^\./0./')
        total_date=$( echo "$total_date + $date" | bc -l )
        echo $date >> dates
    done
    # medias
    media_date=$( echo "$total_date / $total_run" | bc -l )
    echo -n " & ${media_date:0:5}s" >> $saida_media
    # desvios
    somatorio=0;
    for date in `cat dates`; do somatorio=$(echo "$somatorio + (($date - $media_date)^2)" | bc -l); done
    rm dates
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
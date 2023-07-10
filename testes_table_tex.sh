#!/bin/bash

# programas="crivo,entrada,1-1-1-1-1-10 exercicio,entradas,1-1-1-1-1-10 testaprimo,entrada_primo,1-1-1-1-1-10"
# programas="exercicio,entradas,1-1-1-1-1 testaprimo,entrada_primo,1-1-1-1-1"
# programas="exercicio,entradas,1-1-10-10 testaprimo,entrada_primo,1-1-10-10"
# programas="testaprimo,entrada_primo,1-1-1-10-10-10-100-100"
# programas="crivo,entrada,1 exercicio,entradas,1 testaprimo,entrada_primo,1"
programas="testaprimo,entrada_primo,1-1-1-10"
# programas="crivo,entrada,1-1-10"

for programa in $programas; do
    arquivo=$(echo $programa | cut -f1 -d,)
    entrada=$(echo $programa | cut -f2 -d,)
    repeticoes=$(echo $programa | cut -f3 -d,)
    
    echo "
\begin{table}[h]
    \centering
    \caption{Teste de Execução com ${arquivo}}
    \label{tab${arquivo}_teste}
    \begin{tabular}{ccccc}
	\toprule
	& repetições & date +\%s.\%3N & time (real) & /usr/bin/time (wall clock) \\\\
	\midrule" >> $1
    
    # SPIM
    for repeticao in ${repeticoes//-/ }; do
        # date
        start=`date +%s.%3N`
        for (( run = 1; run <= $repeticao; run++ )); do
            spim -file ${arquivo}.mips < $entrada >> /dev/null 2>&1
        done
        end=`date +%s.%3N`; date=$( echo "$end - $start" | bc -l )
        # time
        (time (for (( run = 1; run <= $repeticao; run++ )); do
            spim -file ${arquivo}.mips < $entrada >> /dev/null 2>&1
        done)) 2> output_time
        time=`grep real output_time | cut -f2 -d $'\x09'`
        # /usr/bin/time
        /usr/bin/time -vo output_bin_time bash -c "for (( run = 1; run <= $repeticao; run++ )); do
            spim -file ${arquivo}.mips < $entrada >> /dev/null 2>&1
        done"
        bin_time=`grep 'wall clock' output_bin_time | cut -f8 -d' '`
        echo "
        SPIM & $repeticao & $date & $time & $bin_time (m:ss) \\\\" >> $1
    done
        
    # RARS
    for repeticao in ${repeticoes//-/ }; do
        # date
        start=`date +%s.%3N`
        for (( run = 1; run <= $repeticao; run++ ))
        do
            java -jar rars.jar ${arquivo}.riscv < $entrada >> /dev/null 2>&1
        done
        end=`date +%s.%3N`; date=$( echo "$end - $start" | bc -l )
        # time
        (time (for (( run = 1; run <= $repeticao; run++ )); do
            java -jar rars.jar ${arquivo}.riscv < $entrada >> /dev/null 2>&1
        done)) 2> output_time
        time=`grep real output_time | cut -f2 -d $'\x09'`
        # /usr/bin/time
        /usr/bin/time -vo output_bin_time bash -c "for (( run = 1; run <= $repeticao; run++ )); do
            java -jar rars.jar ${arquivo}.riscv < $entrada >> /dev/null 2>&1
        done"
        bin_time=`grep 'wall clock' output_bin_time | cut -f8 -d' '`
        echo "
        RARS & $repeticao & $date & $time & $bin_time (m:ss) \\\\" >> $1
    done

    # RARS-CLI
    for repeticao in ${repeticoes//-/ }; do
        # date
        start=`date +%s.%3N`
        for (( run = 1; run <= $repeticao; run++ ))
        do
            java -jar my-rars.jar ${arquivo}.riscv < $entrada >> /dev/null 2>&1
        done
        end=`date +%s.%3N`; date=$( echo "$end - $start" | bc -l )
        # time
        (time (for (( run = 1; run <= $repeticao; run++ )); do
            java -jar my-rars.jar ${arquivo}.riscv < $entrada >> /dev/null 2>&1
        done)) 2> output_time
        time=`grep real output_time | cut -f2 -d $'\x09'`
        # /usr/bin/time
        /usr/bin/time -vo output_bin_time bash -c "for (( run = 1; run <= $repeticao; run++ )); do
            java -jar my-rars.jar ${arquivo}.riscv < $entrada >> /dev/null 2>&1
        done"
        bin_time=`grep 'wall clock' output_bin_time | cut -f8 -d' '`
        echo "
        RARS-CLI & $repeticao & $date & $time & $bin_time (m:ss) \\\\" >> $1
    done

    echo "
        \bottomrule
    \end{tabular}
\end{table}" >> $1
done




# for repeticao in ${repeticoes//-/ }; do
    #     # date
    #     start=`date +%s.%3N`
    #     for (( run = 1; run <= $repeticao; run++ ))
    #     do
    #         java -Djava.awt.headless=true -jar my-rars.jar ${arquivo}.riscv < $entrada >> /dev/null 2>&1
    #     done
    #     end=`date +%s.%3N`
    #     date=$( echo "$end - $start" | bc -l )
    #     # time
    #     (time (for (( run = 1; run <= $repeticao; run++ )); do java -Djava.awt.headless=true -jar my-rars.jar ${arquivo}.riscv < $entrada >> /dev/null 2>&1 ; done)) 2> output_time
    #     time=`grep real output_time | cut -f2 -d $'\x09'`
    #     # /usr/bin/time
    #     /usr/bin/time -vo output_bin_time bash -c "for (( run = 1; run <= $repeticao; run++ )); do java -Djava.awt.headless=true -jar my-rars.jar ${arquivo}.riscv < $entrada >> /dev/null 2>&1 ; done"
    #     bin_time=`grep 'wall clock' output_bin_time | cut -f8 -d' '`
    #     echo "
    #     RARS-CLI HM & $repeticao & $date & $time & $bin_time (m:ss) \\\\" >> $1
    # done
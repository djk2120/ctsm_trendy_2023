sims=('S0' 'S1' 'S2' 'S3')
for sim in ${sims[@]}; do
    while read pft; do
	job=$sim"PFT"$pft".job"
	echo $job
	sed 's/veg/'$pft'/g' pft.template > $job
	sed -i 's/sim/'$sim'/g' $job
	qsub $job
	sleep 60
    done<"active_pfts_"$sim".txt"
done

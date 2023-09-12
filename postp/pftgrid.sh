sim='S0'
while read pft; do
    job=$sim"PFT"$pft".job"
    sed 's/veg/'$pft'/g' pft.template > $job
    sed -i 's/sim/'$sim'/g' $job
    qsub $job
done<"active_pfts_"$sim".txt"

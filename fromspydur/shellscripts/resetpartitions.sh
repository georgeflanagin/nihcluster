export partitions="basic medium large ML sci bukach dias erickson johnson parish yang1 yang2 yangnolin all all_768 all_15tb condos cpunodes gpunodes communitynodes allyang"
for p in $partitions; do
    sudo -u slurm scontrol update PartitionName="$p" OverSubscribe=NO
done

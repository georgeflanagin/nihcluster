envs="AmberTools22 alphafold baselines boxtools cs395 env_cms3 env_healpy env_nodejs ipyrad leximeter mendeleev neda nltk numba p310 py2 qgis qgis27 qiime2-2022.2 saif szajda tedbunn treemix whapshap-env"

for e in $envs; do
    echo "creating $e"
    conda create -y --name $e python=3.9
    conda activate $e
    conda list > new$e.txt
done

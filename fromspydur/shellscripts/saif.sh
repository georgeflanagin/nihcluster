
export log="saif.install.log"

function saif
{
    rm -f $log
    source ~/condafy.sh
    conda remove -y -n saif --all | tee -a $log
    if [ ! $? ]; then return; fi

    echo ">>>>>>>>>>>  Creating Saif."
    conda create -y -n saif python=3.8  | tee -a $log
    if [ ! $? ]; then return; fi

    echo ">>>>>>>>>>>  Creating Saif."
    conda config --set channel_priority false  | tee -a $log
    if [ ! $? ]; then return; fi

    conda config --show  | tee -a $log
    if [ ! $? ]; then return; fi

    echo ">>>>>>>>>>>  Installing rl_zoo3"
    conda activate saif  | tee -a $log
    if [ ! $? ]; then return; fi

    
#    echo ">>>>>>>>>>>  Installing pytorch"
#    conda config --add channels conda-forge
#    conda config --set channel_priority strict
#    conda install -y pytorch torchvision torchaudio pytorch-cuda=11.7 -c pytorch -c nvidia  | tee -a $log
#    if [ ! $? ]; then return; fi
#    conda config --set channel_priority false
#
#    echo ">>>>>>>>>>>  Installing all of gymnasium"
#    pip install gymnasium[all]  | tee -a $log
#    if [ ! $? ]; then return; fi
#
#    echo ">>>>>>>>>>>  Installing Jupyter"
#    conda install -y jupyter  | tee -a $log
#    if [ ! $? ]; then return; fi

    echo ">>>>>>>>>>>  Installing rl_zoo3"
    pip install rl_zoo3 | tee -a $log
    if [ ! $? ]; then return; fi

    echo ">>>>>>>>>>>  Activating Saif"
    conda activate saif | tee -a $log

    echo ">>>>>>>>>>>  Listing all packages in Saif"
    conda list | tee -a $log

    echo ">>>>>>>>>>>  Activating Saif"
    python -m ipykernel install --name myenv --display-name "Saif!" 
}

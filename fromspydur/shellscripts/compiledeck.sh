export MPIVERSION="4.0.6"
export QEVERSION="6.8"
export QEHOME="$HOME/qe-$QEVERSION"
export QEINSTALLDIR="/usr/local/sw/qe/${QEVERSION}fftw3"

#################################################################################
# MPIF90	name of parallel Fortran 90 compiler (using MPI)
# export MPIF90="/opt/apps/mpi/openmpi-${MPIVERSION}_gcc-8.4.1/bin/mpif90"
#
# CC        name of C compiler
# export CC="/opt/apps/mpi/openmpi-${MPIVERSION}_gcc-8.4.1/bin/mpicc"
#
# CPP       source file preprocessor (defaults to $CC -E)
# export CPP="/opt/apps/mpi.bak/openmpi-${MPIVERSION}_gcc-8.4.1/bin/mpicpp"

# FFT libraries
export LIBDIRS="/usr/local/sw/libs/fftw3/lib"
#################################################################################

export logfile="$HOME/qe-$QEVERSION-$MPIVERSION-`date +%s`.log"

touch $logfile
date | tee -a $logfile
echo "MPIVERSION=$MPIVERSION" | tee -a $logfile
echo "QEVERSION=$QEVERSION" | tee -a $logfile
echo "QEHOME=$QEHOME" | tee -a $logfile
echo "QEINSTALLDIR=$QEINSTALLDIR" | tee -a $logfile
echo "MPIF90=$MPIF90" | tee -a $logfile
echo "CC=$CC" | tee -a $logfile
echo "CPP=$CPP" | tee -a $logfile
echo "LIBDIRS=$LIBDIRS" | tee -a $logfile

mkdir -p $QEINSTALLDIR
command pushd $QEHOME >/dev/null

# Wipe out previous run.
# echo "make clean | tee -a $logfile"
# make clean 2>&1 | tee -a $logfile
# if [ ! $? ]; then
#    echo "stopping after make clean failed."
#    return 1 || exit 1
# fi

date | tee -a $logfile

# Run configure to point to destination directory.
echo "./configure --prefix=$QEINSTALLDIR --disable-parallel --enable-openmp | tee -a $logfile"
./configure --prefix=$QEINSTALLDIR 2>&1 | tee -a $logfile
if [ ! $? ]; then
    echo "stopping after configure failed."
    return 1 || exit 1
else
    if [ grep -q "Parallel environment detected successfully." ]; then
        echo "Parallel environment not detected."
        return 1 || exit 1
    fi
fi

date | tee -a $logfile
echo "make all 2>&1 | tee -a $logfile"
make all 2>&1 | tee -a $logfile
if [ ! $? ]; then
    echo "stopping after make all failed."
    return 1 || exit 1
fi

date | tee -a $logfile
echo "make install 2>&1 | tee -a $logfile"
make install | tee -a $logfile
if [ ! $? ]; then
    echo "make install failed, but it is the last step."
    return 1 || exit 1
fi

date | tee -a $logfile
ls -l $QEINSTALLDIR
command popd >/dev/null

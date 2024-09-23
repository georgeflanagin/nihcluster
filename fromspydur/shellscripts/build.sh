export PROJ_DIR=/usr/local/sw/PROJ # root directory of the PROJ installation
# export PROJ_INCLUDE_DIR=/usr/local/include/proj # points to the directory containing the PROJ header files (.h files)
export PROJ_INCLUDE_DIR=/usr/local/sw/PROJ/src # points to the directory containing the PROJ header files (.h files)
export PROJ_LIBRARY=/usr/local/sw/libs/libproj.so # points to the PROJ library file itself (.so)
export CMAKE_PREFIX_PATH=/usr/local/sw/libs

cd ./build
cmake .. | tee -a ~/gdal.log
cd $OLDPWD

#!/bin/bash
function HELP {
    cat <<HELP


--------------------------------   pdCor.sh  ------------------------------------
  The script for an inhomogeneity correction of T1w image

  Description:
    This script includes
    1) rigid body registration of PD image to T1w image
    2) calculation of T1w_cor image

  Development History:
    Version 0.1: the script release (2019.6.5)

--------------------------------------------------------------------------------------
  Example Usage:
  pdCor.sh -t t1w -p pd

  (Optional)
  pdCor.sh -version (see the version)

  Compulsory arguments:
      -t:  T1w image
      -p:  PD image

--------------------------------------------------------------------------------------
  Requirement: FSL installation and other in-house script
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
  This method was created by:

  Uksu, Choi (uschoi@nict.go.jp)
  Center for Information and Neural Networks
  National Institute of Information and Communications Technology

--------------------------------------------------------------------------------------
                      Script writing and modification by Uksu
                      Do not modify without a permission.
--------------------------------------------------------------------------------------


HELP
    exit 1
}

# reading command line arguments
while getopts "h:t:p:v:" OPT
do
  case $OPT in
      h)
      HELP
   exit 0
   ;;
      t)
      t1w=$OPTARG
      ;;
      p)
      pd=$OPTARG
      ;;
      v)
      version=1
      ;;
      \?) # getopts issues an error message
   echo $USAGE >&2
   exit 1
   ;;
 esac
done

if [[ ${t1w: -7} == ".nii.gz" ]];
then
echo "
Please remove and an input input extension (nii.gz) \

"
exit 1
fi

if [[ ${pd: -7} == ".nii.gz" ]];
then
echo "
Please remove and an input input extension (nii.gz) \

"
exit 1
fi

if [[ ! -z ${version} ]];then
  echo "
  Current version is 0.1 \

  "
  exit 1
fi

########################################### Run main processing ####################################################################
# time_start
time_start_pdC=`date +%s`

### step 1: registration PD to T1w
flirt -dof 6 -interp nearestneighbour -in ${pd} -ref ${t1w} -out ${pd}2t1w

### step 2: calculation of t1wCor
fslmaths ${t1w} -thrP 10 -bin ${t1w}_mask
fslmaths ${t1w} -div ${pd}2t1w -thr 0 -uthr 1 ${t1w}_raw
fslmaths ${t1w} -div ${pd}2t1w -thr 1 -bin ${t1w}pd_uthr_mask
fslmaths ${t1w}_raw -add ${t1w}pd_uthr_mask ${t1w}pd_semi
fslmaths ${t1w}pd_semi -mas ${t1w}_mask -mul 5000 ${t1w}Cor



### step 3: summarize
rm ${t1w}pd_semi.nii.gz ${t1w}_mask.nii.gz ${t1w}pd_uthr_mask.nii.gz ${t1w}_raw.nii.gz
################## end of processing ################################################
echo "
      >>>>>>> Prepration of fmri pipeline for multi-echo dataset finished <<<<<<<<<<<
"
time_end_pdC=`date +%s`
time_elapsed_pdC=$((time_end_pdC - time_start_pdC))
echo "---------------------------------------------------------------------------------"
echo "          The processing was completed in $time_elapsed_pdC seconds"
echo "---------------------------------------------------------------------------------"
































#

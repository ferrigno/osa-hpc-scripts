#!/bin/bash
#
# PARAMETER
#
# par1: scwid without extension       e.g. "00520010010"
# par2: tbin for the lc extraction in sec
# note that the script assumes the scw are found in the archive
# and at peculiar location for the input catalogue
# 
### GRID SETUP
#
#$ -S /bin/bash
#$ -j y
#$ -o /gpfs0/ferrigno/INTEGRAL/nrt_analysis/logs
#$ -cwd

if [ $# -ne 1 ]; then
	echo "you must give exactly one parameter"
	exit 1
else
	export OGID=${1}
#	export do_og_create=${2}
	
fi

#
### ANALYSIS SETUP
#

export REP_BASE_PROD=/isdc/arc/rev_3
#export ISDC_REF_CAT=/unsaved_data/ferrigno/INTEGRAL/nrt_refr_cat.fits
#export ISDC_OMC_CAT=/isdc/arc/rev_3/cat/omc/omc_refr_cat.fits
#export ISDC_ENV=/gpfs0/ferrigno/INTEGRAL/osa11
#source $ISDC_ENV/bin/isdc_init_env.sh

#echo $ISDC_ENV


export COMMONLOG=comlog.txt



echo "Analysis is done on"
hostname
echo $PWD


export COMMONSCRIPT=1
export REVNO=`echo $OGID | cut -b1-4`
export COMMONLOGFILE=+log.$OGID

unset DISPLAY



rm -rf obs/${OGID}J1
mkdir -p obs/${OGID}J1/pfiles
export PFILES="${PWD}/obs/${OGID}J1/pfiles;${ISDC_ENV}/pfiles:$HEADAS/syspfiles"
echo $PFILES

echo $HOSTNAME


### OG CREATION
#
echo "$OGID" > /tmp/$$.So.lis
cat /tmp/$$.So.lis   
og_create \
   idxSwg=/tmp/$$.So.lis \
   ogid=${OGID}J1 baseDir=./ instrument=JMX1 obs_id=""
rm /tmp/$$.So.lis

### ANALYSIS
#METHOD 1

cd obs/${OGID}J1
#cp ../../isgri_srcl_res_oao1654.fits user_cat.fits
#cp ../../isgri_srcl_res_3A1822.fits user_cat.fits
#cp ../../isgri_srcl_res_v0332_clean.fits user_cat.fits
#cp ../../isgri_srcl_res_V404.fits user_cat.fits
#cp ../../isgri_srcl_res_velax1.fits user_cat.fits
#cp ../../gc2193_isgri_srcl_res_clean.fits user_cat.fits
cp ../../archived_cat_lists/maxi_isgri_srcl_res.fits user_cat.fits
export master_file=ic_master_file.fits

#j_rebin_rmf ic_master=${REP_BASE_PROD}/idx/ic/${master_file} jemx_num=1 binlist=STD_008 outfile=jmx1_rebinned_rmf.fits

export curr_dir=$PWD

#skipLevels="LCR" 


jemx_science_analysis ogDOL="${curr_dir}/og_jmx1.fits[1]" jemxNum=1 startLevel="COR" endLevel="LCR" \
skipLevels="SPE" chatter=2 clobber=yes osimData=no ignoreScwErrors=no skipSPEfirstScw = 'y' \
timeStart=-1 timeStop=-1 nPhaseBins=0 phaseBins="" radiusLimit=122 IC_Group="${REP_BASE_PROD}/idx/ic/${master_file}[1]" \
nChanBins=1 chanLow="46" chanHigh="178" \
IC_Alias="OSA" instMod="" response="jmx1_rebinned_rmf.fits" arf="" \
LCR_useIROS=yes LCR_timeStep=3000  LCR_doBurstSearch=yes \
IMA_burstImagesOut=yes \
CAT_I_usrCat=user_cat.fits


#nChanBins="2" chanLow="46 129" chanHigh="128 178" \
#nChanBins=-1 chanHigh="" chanLow="" \
#CAT_I_usrCat=user_cat.fits

#CAT_I_usrCat="$ISDC_REF_CAT" \
#CAT_I_usrCat="$REP_BASE_PROD/gnrl_refr_cat_0041_20180811.fits"

# chanLow="46 130" chanHigh="129 174" \
echo "JEM-X science window analysis finished up to spectral level. Results can be found under:"
echo $PWD




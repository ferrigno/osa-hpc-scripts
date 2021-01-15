#!/bin/bash
#
# PARAMETER
#
# par1: scwid without extension       e.g. "00520010010"
# par2: [optional] source name
# 
### GRID SETUP
#
#$ -S /bin/bash
#$ -j y
#$ -o /gpfs0/ferrigno/INTEGRAL/nrt_analysis/logs
#$ -cwd

set -e



OGID=${1:?first argument must be OGID}
do_og_create=${2:?do_og_create is 1 if do og create}

### ANALYSIS SETUP
#

#
# HEADAS
#
#export HEADAS=/gpfs0/software/astro/heasoft/x86_64-unknown-linux-gnu-libc2.12
#source ${HEADAS}/headas-init.sh

#
# OSA 
#
#export ISDC_ENV=/gpfs0/ferrigno/INTEGRAL/osa11
#export ROOTSYS=$ISDC_ENV/root
#export REP_BASE_PROD=/gpfs0/ferrigno/INTEGRAL/nrt_analysis
export REP_BASE_PROD=/isdc/arc/rev_3/
#export ISDC_REF_CAT="/unsaved_data/ferrigno/INTEGRAL/nrt_refr_cat.fits"
export ISDC_OMC_CAT="/isdc/arc/rev_3/cat/omc/omc_refr_cat_0005.fits"
export ISDC_REF_CAT="/isdc/arc/rev_3/cat/hec/gnrl_refr_cat_0043.fits[1]"
#source ${ISDC_ENV}/bin/isdc_init_env.sh

#export ROOTSYS=${ISDC_ENV_OSA10}/root

export COMMONLOG=comlog.txt

pwd

# singularity will bind the directories here, no need to symlink
export REP_BASE_PROD=/isdc/arc/rev_3


#fstruct /srv/beegfs/scratch/users/s/savchenk/Misc_Scripts/ISDC/ic/ibis/cal/ibis_isgr_gain_offset_0010.fits

unset AUXL_REF_DIR
export COMMONSCRIPT=1
export REVNO=`echo $OGID | cut -b1-4`
export COMMONLOGFILE=+log.$OGID


### OG CREATION
#

if [ "$do_og_create" -eq "1" ]; then

rm -rf obs/${OGID}
mkdir -p obs/${OGID}/pfiles
export PFILES="${PWD}/obs/${OGID}/pfiles;${ISDC_ENV}/pfiles:$HEADAS/syspfiles"
echo $PFILES

#Add Paths of components to be tested here
#export PATH "/gpfs0/ferrigno/INTEGRAL/test_analysis/test_bin:$PATH"

echo "${OGID}.001" > /tmp/$$.So.lis
#cat /tmp/$$.So.lis   
og_create \
   idxSwg=/tmp/$$.So.lis \
   ogid="${OGID}" baseDir=. instrument=IBIS obs_id="" 
#swgName="swg_prp" scwVer=""

rm -f /tmp/$$.So.lis

fi


### ANALYSIS
#METHOD 1

cd obs/${OGID} 
echo starting analysis at $PWD

ls -lotr /data/cat/hec/


user_cat="$ISDC_REF_CAT[ISGRI_FLAG>=1]"
#cat_for_extract="maxi_isgri_srcl_res.fits"
#chmod -w $cat_for_extract


#IBIS_nregions_ima=1 \
#IBIS_nbins_ima="1" \
#IBIS_energy_boundaries_ima="25 50" \


#IBIS_SI_inEnergyValues="$REP_BASE_PROD/dummy2.fits[2]" \

ibis_science_analysis \
	ogDOL="og_ibis.fits[1]" startLevel="COR" endLevel="IMA" \
	chatter=5 SWITCH_disableIsgri=no SWITCH_disablePICsIT=yes SWITCH_disableCompton=yes SWITCH_osimData=no \
	GENERAL_clobber=yes \
	IC_Group="$REP_BASE_PROD/idx/ic/ic_master_file.fits[1]" \
	IBIS_II_ChanNum=2 \
	IBIS_II_E_band_min="28 40" IBIS_II_E_band_max="40 80" \
	CAT_refCat="$user_cat" \
	corrDol="" \
	IBIS_nregions_spe=1 IBIS_nbins_spe="-12" IBIS_energy_boundaries_spe="28 100" \
	OBS2_detThr=3 \
	IBIS_NoisyDetMethod=1 \
	OBS1_SearchMode=3 \
	OBS1_ToSearch=3 \
	OBS1_DoPart2=0 \
	OBS1_MinCatSouSnr=5 \
	OBS1_MinNewSouSnr=15 \
	OBS1_SouFit=1 \
	OBS1_NegModels=1 \
	OBS1_ExtenType=2 \
	ILCR_delta_t=1500 \
	ILCR_num_e=1 \
	ILCR_e_min="28" \
	ILCR_e_max="80" 
	
#SCW2_ISPE_idx_isgrResp="$response" \

#CAT_refCat="${SOURCE}/cat.fits[1]" \
#brSrcDOL="${SOURCE}/brightcat.fits[1]" \
#SCW1_BKG_buster_src="${SOURCE}/verybrightcat.fits[1]" \
#SCW2_BKG_buster_src="${SOURCE}/verybrightcat.fits[1]" \

#SCW2_cat_for_extract="$cat_for_extract" \
#/scratch/ferrigno/INTEGRAL/scw_analysis/samplec_gaps og_ibis.fits y

#chmod +w $response

#gzip ./scw/*/*.fits
#gzip ./*.fits
rm -rf pfiles
echo "ISGRI science window analysis finished up to SPE level. Results can be found under:"
echo $PWD



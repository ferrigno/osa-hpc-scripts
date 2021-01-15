#!/bin/bash
#
#
### GRID SETUP
#
#$ -S /bin/bash
#$ -j y
#$ -o /gpfs0/ferrigno/INTEGRAL/test_analysis/logs
#$ -cwd
#####    $ -l arch=glinux

if [ $# -ne 2 ];
	 then
	echo "Usage is $0 obs_dir_name pattern"
	exit 1
fi

pattern="$2"

### ANALYSIS SETUP
#

#
# HEADS
#
#export HEADAS=/gpfs0/software/astro/heasoft/x86_64-unknown-linux-gnu-libc2.12
#source ${HEADAS}/headas-init.sh

#
# OSA 7.0 is installed in /opt/osa7.0.  To configure it do:
#
#export ISDC_ENV /gpfs0/software/integral/osa_10.2/2015NOV20/osa10.2
#export ISDC_ENV=/home/isdc/savchenk/osa11_deployment/deployment/Linux-x86_64/osa_sw

#export ISDC_ENV_OSA10=/gpfs0/software/integral/osa_10.2/2015NOV20/osa10.2;
#export ROOTSYS=${ISDC_ENV_OSA10}/root

#export ROOTSYS=/home/isdc/savchenk/osa11_deployment/deployment/Linux-x86_64/root

#export REP_BASE_PROD=/gpfs0/ferrigno/INTEGRAL/test_analysis
#export ISDC_REF_CAT="/gpfs0/ferrigno/INTEGRAL/nrt_refr_cat.fits"
#export ISDC_OMC_CAT="/isdc/arc/rev_3/cat/omc/omc_refr_cat_0005.fits"
#source ${ISDC_ENV}/bin/isdc_init_env.sh


export COMMONLOG=comlog.txt
unset DISPLAY

echo $PWD
export REP_BASE_PROD=/isdc/arc/rev_3
#Include here the reference catalogue you want to consider:
unset AUXL_REF_DIR
export COMMONSCRIPT=1

cd $1
rm -rf MOSA_I
mkdir MOSA_I
cd MOSA_I

#rm -rf pfiles
mkdir pfiles
export PFILES="${PWD}/pfiles;${ISDC_ENV}/pfiles:$HEADAS/syspfiles"

echo $PFILES

master_file=ic_master_file.fits

curr_dir=$PWD

echo $curr_dir

ls ../$pattern/scw/*/swg_ibis.fits | sort -n > scw_ibis.list
echo "../$pattern/scw/*/swg_ibis.fits"

for dir in `cat scw_ibis.list` ; do
	#dal_detach object="${dir}[1]" pattern=ISGR-SRCL-RES delete=n
	echo dal_detach object="${dir}[1]" pattern=ISGR-SRCL-RES delete=n
done

txt2idx scw_ibis.list swg_idx_ibis.fits
dal_create obj_name=og_ibis.fits template=GNRL-OBSG-GRP.tpl
fparkey IBIS og_ibis.fits\[1] INSTRUME add=yes
dal_attach og_ibis.fits\[1] swg_idx_ibis.fits\[1] ""

f1=`head -1 scw_ibis.list | gawk '{split($1,arr,"/");print arr[1] "/" arr[2] }'`
f2=`tail -1 scw_ibis.list | gawk '{split($1,arr,"/");print arr[1] "/" arr[2] }'`


echo "First file is $f1"
echo "Last  file is $f2"

dal_attr_copy $f1/og_ibis.fits\[1] og_ibis.fits\[1] TSTART
dal_attr_copy $f2/og_ibis.fits\[1] og_ibis.fits\[1] TSTOP

response=""
response_ext=""
user_cat="$ISDC_REF_CAT"
cat_for_extract=""


#dal_attach og_ibis.fits specat.fits ""
dal_detach og_ibis.fits "" "ISGR-SRCL-RES"
#IBIS_II_ChanNum=2 \
#IBIS_II_E_band_min="20 40" IBIS_II_E_band_max="40 100" \
#rebinned_corrDol_ima="/unsaved_data/ferrigno/INTEGRAL/nrt_analysis/rebinned_corr_ima.fits[1]" \

set SOURCE="/unsaved_data/ferrigno/INTEGRAL/"
#set corr_ima="${SOURCE}/nrt_analysis/rebinned_corr_ima_2_20-80.fits"
## 20-40, 40-100 keV
#set corr_ima="${SOURCE}/nrt_analysis/rebinned_corr_ima.fits"

#IBIS_II_inEnergyValues="/gpfs1/scratch/ferrigno/INTEGRAL/scw_analysis/test_bin/rebinned/isgri_user_bins_ima.fits" \

corr_ima=${HOME}/scratch/INTEGRAL/rebinned/rebinned_corr_ima.fits

if [ -f ${f1}/rebinned_corr_ima.fits ];
	then
	cp ${f1}/rebinned_corr_ima.fits .
	corr_ima="./rebinned_corr_ima.fits"
fi


#IBIS_II_ChanNum=2 \
#IBIS_II_E_band_min="20 40" IBIS_II_E_band_max="40 100" \

#CAT_refCat=$user_cat \

ibis_science_analysis ogDOL="og_ibis.fits[1]" startLevel="CAT_I" endLevel="IMA" tolerance=0.1 \
CAT_refCat="$ISDC_REF_CAT[ISGRI_FLAG >= 1]" \
chatter=2 SWITCH_disableIsgri=no SWITCH_disablePICsIT=yes SWITCH_disableCompton=yes SWITCH_osimData=no \
GENERAL_clobber=yes GENERAL_levelList="COR,GTI,DEAD,BIN_I,BKG_I,CAT_I,IMA,BIN_S,CAT_S,SPE" \
IC_Group="$REP_BASE_PROD/idx/ic/$master_file[1]" \
ibis_science_analysis ogDOL="og_ibis.fits[1]" startLevel="CAT_I" endLevel="IMA" tolerance=0.1 \
IBIS_II_ChanNum=2 \
IBIS_II_E_band_min="25 40" IBIS_II_E_band_max="40 100" \
corrDol="" \
rebinned_corrDol_ima="${corr_ima}" \
rebinned_backDol_ima="" \
OBS1_DataMode=0 \
OBS1_SearchMode=3 \
OBS1_ToSearch=50 \
OBS1_ScwType="POINTING" \
OBS1_DoPart2=1 \
OBS1_MapAlpha=83 OBS1_MapDelta=22 OBS1_MapSize=40 OBS1_PixSpread=1 \
OBS1_MinCatSouSnr=6 OBS1_MinNewSouSnr="10" OBS1_CAT_radiusMin="0" OBS1_CAT_radiusMax="20" OBS1_CAT_fluxDef="" OBS1_CAT_fluxMin="" \
OBS1_CAT_fluxMax="" OBS1_CAT_class="" OBS1_CAT_date=-1 OBS1_SouFit=0 PICSIT_detThr=3 PICSIT_inCorVar=1 PICSIT_outVarian=0 \
SCW2_cat_for_extract="$cat_for_extract" \
SCW2_catalog="" PICSIT_source_name="" \
SCW2_ISPE_idx_isgrResp="$response" 


#awk '{print "gzip " $1}' scw_ibis.list > compress.sh
#source compress.sh
#mosaic_spec "" "" DOL_idx=isgri_mosa_ima.fits DOL_spec="scw_spec.fits(ISGR-PHA1-SPE.tpl)" EXTNAME="ISGR-MOSA-IMA" ra=243.179167 dec=-52.42305 size=4


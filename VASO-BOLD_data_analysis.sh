#This script includes Korean.

for d in */ ; do
    dcm2nii -o  './' ${d}
done
gunzip *

1. 'used_for_NOVA_visual' 시퀀스로 촬영한 epi데이터는 ima이미지 순서가 1,2,3,...연속적으로 
가는 게 아니고 모자이크 뷰로 편하게 보기 위해 26의 등차수열로 되어 있다. 따라서, mri_convert 로 
원래 하듯이 바꿀 수 없고 dcm2nii (mricron) function 으로 컨버팅을 해 준다. 
(아니면 ima file 이름을 일일이 바꿔서 mri_convert로 해도 상관없다).


TargetNumer=264
for filename in ./*.nii
do
output1="$(3dinfo -nt $filename)"

if (( $output1 == TargetNumer )); then
    echo $filename
else
    rm $filename
fi
done

2. 파라미터 조절을 위해 찍은 이미지들이 있으므로, 내 런에 맞는 TR을 가진 nii파일만 남기고 다 지워준다.

mv *.nii ../
cd ../

fsleyes &

3. 7T data 는 fsleyes를 사용하여 보는 게 좋은데, 먼저 fsleyes에서 timeseries를 확인해보면 
지그재그가 심한 모습이 보인다. vaso-bold를 번갈아가며 찍었기 때문.

cnt=0
for filename in ./*.nii
do
echo $filename
cp $filename ./Basis_${cnt}a.nii
3dTcat -prefix Basis_${cnt}a.nii Basis_${cnt}a.nii'[4..7]' Basis_${cnt}a.nii'[4..$]' -overwrite
cp ./Basis_${cnt}a.nii ./Basis_${cnt}b.nii

3dinfo -nt Basis_${cnt}a.nii >> NT.txt
3dinfo -nt Basis_${cnt}b.nii >> NT.txt
cnt=$(($cnt+1))
done

4. 고정점만 제시된 0~3TR 은 시그널이 잘 안나왔을거라 가정하며 날리고, 4~7 TR로 붙여서 대체하는것.
tSNR을 최대한 높이려고 하는 과정이라 사실 대체안하고 버려도 됨. 그 다음 TR정보들을 NT.txt에 저장,
나중에 motion correction할 때 이 정보를 사용한다. 

rm ./2019*.nii

echo "CREATE MOMA" #motion correction with mask 의 준말이라 함
#draw mask using fsleyes  
5. motion correction 은 SPM을 이용하는데, spm에 mask를 씌워 그 부분을 최적화하여 
motion correction할 수 있는 기능이 있기 때문. fsleyes를 이용하여 edit-creat mask 하고,
마스크를 대충 visual cortex쪽에 슥슥 그려준다. (3D 옵션을 선택하여 그리면 여러 슬라이스를 한번에
그릴 수 있다). 그 다음, 가장 마지막 장엔 brain image가 없는데 마스크만 그려져 있으니
이건 다시 지워준다. 이렇게 하면 마스크를 씌운 부분만 맞춰서 더 잘맞고 mc 처리속도도 빠르다.

cp /media/ururru/layers/Layer_script/mocobatch_VASO3.m ./
export DYLD_FALLBACK_LIBRARY_PATH="/usr/lib/:$DYLD_LIBRARY_PATH"
/usr/local/MATLAB/R2018a/bin/matlab -nodesktop -nosplash -r "mocobatch_VASO3"

6. 위 코드로 matlab을 따로 실행시키지 않고 쉘 스크립트 내에서 matlab code를 돌릴 수 있다.
mocobatch.m 파일에서는 홀수 볼륨, 짝수 볼륨 따로 motion correction 을 해준다. VASO와 
BOLD 각각 motion correction을 한다는 말이다. 다 끝나면 rp_Basis_*a와 같이 motion parameter
가 나온다. 1dplot으로 3T data처럼 얼마나 움직였는지 확인해볼 수 있다. 중요한 건 레이어 별 분석을 하므로,
얼마나 움직였는지 다시 확인하자. 끝나면 exit으로 빠져나오면 된다.

rm ./Basis_*.nii
rm ./Basis*.mat

################################# allRuns  #################################

mkdir allRuns
cd allRuns

Nulled_* 는 VASO (blood signal이 null되었다는 말), Not_Nulled는 BOLD 이미지이다.

3dMean -prefix Nulled_Basis_b.nii ../Nulled_Basis_*b.nii -overwrite
3dMean -prefix Not_Nulled_Basis_a.nii ../Not_Nulled_Basis_*a.nii -overwrite

NumVol=`3dinfo -nv Nulled_Basis_b.nii`
3dcalc -a Nulled_Basis_b.nii'[3..'`expr $NumVol - 2`']' \
-b  Not_Nulled_Basis_a.nii'[3..'`expr $NumVol - 2`']' \
-expr 'a+b' -prefix combined.nii -overwrite

3dTstat -cvarinv -prefix T1_weighted.nii -overwrite combined.nii 
rm combined.nii

7. 위 코드는 epi 이미지를 이용해 T1-like image를 만들기 위한 과정이다. 
모든 run을 평균내서 하나로 만들고, 3dcalc 를 이용해 nulled + not_nulled image = combined.nii
를 만든다. 이렇게 되면 anatomical image대신 roi를 그릴 때 사용할 수 있는 높은 contrast의 
T1 weighted 이미지를 가질 수 있다. 마지막 3dTstat -cvarinv 는 tSNR이미지로 바꿔주는 과정인데,
signal value rescaling & 한 장의 이미지로 만들어주기 위함이다.

3dcalc -a Nulled_Basis_b.nii'[1..$(2)]' -expr 'a' -prefix Nulled.nii -overwrite
3dcalc -a Not_Nulled_Basis_a.nii'[0..$(2)]' -expr 'a' -prefix BOLD.nii -overwrite

8. 짝 - 홀 (VASO-BOLD)이미지를 나눈다.

3drefit -space ORIG -view orig -TR 4 BOLD.nii
3drefit -space ORIG -view orig -TR 4 Nulled.nii

9. 바뀌어있는 TR을 다시 바꿔준다.

3dTstat -mean -prefix mean_nulled.nii Nulled.nii -overwrite
3dTstat -mean -prefix mean_notnulled.nii BOLD.nii -overwrite

3dUpsample -overwrite  -datum short -prefix Nulled_intemp.nii -n 2 -input Nulled.nii
3dUpsample -overwrite  -datum short -prefix BOLD_intemp.nii   -n 2 -input   BOLD.nii

10. VASO 먼저 찍고 BOLD 를 찍으므로 두 시퀀스 이미지들 간 time point가 완전 일치하는 게 아니므로,
time point를 맞추기 위해 interpolation을 통해 데이터를 추가로 만든다. 결과적으로 데이터의 양은
2배로 늘어나고, TR은 반으로 줄은 것과 같다. 이 과정을 거치고 나면 데이터 크기가 매우 커지므로 추후
중간 데이터들은 지워주는 게 좋다.

NumVol=`3dinfo -nv BOLD_intemp.nii`

3dTcat -overwrite -prefix Nulled_intemp.nii Nulled_intemp.nii'[0]' Nulled_intemp.nii'[0..'`expr $NumVol - 2`']' 

11. 처음 실험을 할 때에는 VASO-BOLD 간 이미지 개수가 맞지 않을 때가 있었다고 한다. 그래서
뒷 부분의 일정 이미지들을 지워주는 코드인데, 지금은 필요가 없다.

mv Nulled_intemp.nii temp.nii 
mv BOLD_intemp.nii Nulled_intemp.nii
mv temp.nii  BOLD_intemp.nii

BOLD-VASO 순서에서 VASO-BOLD 순서로 바뀌었으므로 이름을 바꿔주는 과정임.

12. 아래 코드부터는 Renzo가 만든 function들을 사용하여 분석하게 된다. Renzo의 github에 들어가
미리 다운받는다. https://github.com/layerfMRI

LN_BOCO -Nulled Nulled_intemp.nii -BOLD BOLD_intemp.nii 

13. LN_BOCO function은 VASO의 tSNR을 최대한 올리는 위해 사용된다. 단순히 VASO 이미지를
BOLD 이미지로 나누어, VASO에 조금이라도 남아있는 Blood signal의 영향을 제거해준다. (추후 추가 필요)

  3dTstat  -overwrite -mean  -prefix BOLD.Mean.nii \
     BOLD_intemp.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix BOLD.tSNR.nii \
     BOLD_intemp.nii'[1..$]'
  3dTstat  -overwrite -mean  -prefix VASO.Mean.nii \
     VASO_LN.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix VASO.tSNR.nii \
     VASO_LN.nii'[1..$]'

#LN_SKEW -timeseries BOLD_intemp.nii
#LN_SKEW -timeseries VASO_LN.nii

3drefit -TR 2. BOLD_intemp.nii
3drefit -TR 2. VASO_LN.nii

14. timing correction으로 인해 바뀐 TR(4초->2초)로 재수정

mv BOLD_intemp.nii BOLD_LN.nii    
LN_MP2RAGE_DNOISE -INV1 mean_nulled.nii -INV2 mean_notnulled.nii \
-UNI T1_weighted.nii -beta 5

14. LN_MP2RAGE_DNOISE는 within layer에서 smoothing을 하기 위한 function이다.  




이후부터는 각자 실험의 목적대로 분석하면 되겠다.





################################# ALL GLM  #################################
mkdir GLM
cd GLM
3dDeconvolve -input ../BOLD_LN.nii                   \
    -polort 8                                                           \
    -num_stimts 2                                                       \
    -stim_times 1 /media/ururru/layers/mooney_VASO/stimFile/on.txt  'BLOCK(16,1)'              \
    -stim_label 1 StimOn                                                \
    -stim_times 2 /media/ururru/layers/mooney_VASO/stimFile/off.txt  'BLOCK(16,1)'              \
    -stim_label 2 StimOff                                               \
    -gltsym 'SYM: StimOn -StimOff'                      \
    -glt_label 1 on-off                         \
    -gltsym 'SYM: StimOff -StimOn'                      \
    -glt_label 2 off-on                                 \
    -local_times                                                        \
    -float                                                              \
    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg                             \
    -x1D_uncensored X.nocensor.xmat.1D                                  \
    -bucket stats_BOLD.all        \
    -overwrite

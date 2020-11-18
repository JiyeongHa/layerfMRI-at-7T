#Sorry, they're in Korean!

Renzo 방식으로 VASO - BOLD 교차 시퀀스 파라미터 셋팅하기

참가자 각각의 brain 에 맞게 shimming 하고, Reconstruction을 더 잘할 수 있도록 advanced user settings 변경함. (+Fat saturation 여부도 사람마다 다르게 됨) 따라서 아래 셋팅 변경은 매번 참가자를 오픈할 때마다 다시 해줘야 함

사용 헤드코일: Simens NOVA coil (엔센터에서 만든 헤드코일은 아직 파라미터 셋팅이 끝나지 않았다 함)

 Patient Open, Renzo_Playground - Excuted  시퀀스 모음을 선택하고 밑에 brain으로 셋팅 바꿔준 후 오픈 (이후부터 나오는 버튼들은 continue/ok/manual을 선택한다. 계속 뜨므로 주의)

열고 나면 renzo_localizer 부터 촬영. 이 로컬라이저는 inversion 을 넣어서 contrast를 더 높이는 방식으로 1분 정도 걸림.

촬영된 로컬라이저 다음 used_for_NOVA_visual 시퀀스로 FOV box 각도와 shimming box를 조절해준다.

Fov box는 각도를 조절할 때, 정 중앙에서부터 좌반구 우반구 모두의 calcarine sulcus 가 포함되도록 조절하는 게 좋다. 자극을 화면 중심부에 제시하므로 visual cortex 가장 바깥쪽 calcarine sulcus 에 맞추도록 하고, 양반구의 calcarine sulcus 각도가 다르다면 한쪽 선택해서 조절.

그 다음 체크를 누르지 말고, shimming 을 manual 하게 조절해야 한다. 상위 메뉴 중 Option-Adjustment 로 들어가 frequency 탭에서 먼저 'Go'를 눌러 확인.

가운데 픽이 뜨는 그래프가 뜨는데, 이게 tissue 의 frequency 로 좁게 모아져야 한다. (그 옆에 작은 혹처럼 또 다른 픽이 뜬다면 fat에 대한 frequency 이고 이게 없을수록 좋음). 그렇게 만들기 위해 3D Shim 탭에서 Shimming을 3번 정도 반복해준다. measure - calculate - apply 순으로 3번 반복한다. 숫자가 변하는 정도를 체크하고, 얼마나 homogeneous 한지는 그림으로 확인한다.

이제부턴 reconstruction을 향상시키기 위해 Advanced user settings 을 변경한다. Ctrl+Esc 눌러 advanced users 에 들어가 비밀번호 입력('meduser1'). 굳이 변경하지 않는 이상 모든 시멘스 머신이 같다고 함. 그 다음 다시 단축키 눌러 Command Prompt 창으로 들어가 'xbuilder' 을 입력한다.

나타난 폴더 창에서 File - Open - Iceconfig.~ 를 눌러 연다. 이후 

1)iPAT 에서 ImprovedGrappa를 1로 바꿔주고, GrappaNoiseReconstruction1에서 3000으로 늘려준다(피팅할때 noise term에 웨이트를 얼마나 넣어줄 건지에 대한). 2)Application 에서 POCS - Iteration - 8로 바꿔준다. 이 부분은 K-space에서 recon할 때, ~?

변경이 끝나면 반드시 !!저장!!후 창을 닫는다.

이제 'used_for_NOVA_visual' sequence 의 measurement 만 조절하여 시퀀스를 진행한다. 촬영 후, 이미지를 확인하여 fat 으로 인한 노이즈가 생기는지 확인하고, 생긴다면 Contrast-fat sat.을 선택, 다시 한번 이미지를 촬영해본다. 

*해당 시퀀스 주의점

VASO-BOLD 를 같이 찍는 시퀀스이므로 measurement가 3이면 실제 얻는 볼륨은 6 볼륨이 된다. VASO-BOLD순으로 얻는다.

파라미터 조절 창에서 TR1, TR2는 렌조가 이미 설정해놓은 값으로 변경이 되지 않는다. 실제 TR은 TR2이고 완전 같은건 아니나 대충 이정도 된다 (4초). TR1은 pulse로부터 VASO이미지를 얻기까지의 타임이다. (64ms)

따라서, VASO를 찍을때도 's'시그널이 찍히고 BOLD를 찍을 때에도 's' 시그널이 찍힌다. 거기에다가 fat saturation까지 하게 되면 TR이 바뀌게 된다. 실험 코드를 짜게 된다면 주의...

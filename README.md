# [Swift]TwitchClone

본 프로젝트는 개인프로젝트이며 본인이 크게 삽질한 부분을 위주로 정리, 기록용으로 작성됩니다.

개인프로젝트 주제를 고민하면서 기존에 진행하였던 프로젝트와 연계할 수 있는 주제를 고민하다가 Live Streaming 서비스인 Twitch App Cloning 해보기로 결정하였습니다.

기존 코드가 없기에 그냥 iOS에 깔린 Twitch App을 눈으로 보면서 이건 이렇게 만들었겠지?, 이건 어떻게 처리했을까 고민하면서 만들었기에 기존 시스템과 비교하면 다소 완성도는 떨어지지만 많은 배움이 있었습니다.

## Live List(시청자)

![image.jpg1](https://velog.velcdn.com/images/diddbstjr55/post/9777127e-1320-49db-8e5d-d97eb05b10eb/image.PNG) |![image.jpg2](https://velog.velcdn.com/images/diddbstjr55/post/ce44f7ef-64f4-4fb6-b5ba-1411ed5f93e9/image.PNG)
--- | --- |

시청자 모드에서는 Firebase의 GoogleSingIn 기능을 사용하여, 유저를 분리하고  카테고리, 팔로잉등으로 분리, 방송 미리보기, 채팅을 구현하였습니다.
채팅, 썸네일, 유저정보등 필요한 데이터는 Firebase DB를 사용하였습니다.


## Live Stream(Host)
![image.jpg1](https://velog.velcdn.com/images/diddbstjr55/post/e269d105-8427-4158-9130-bd74e6e1415a/image.PNG) |![image.jpg2](https://velog.velcdn.com/images/diddbstjr55/post/db04aee0-6072-48ca-9113-7e39ee0f7609/image.PNG)
--- | --- | 

영상 송출은 <a href='https://github.com/shogo4405/HaishinKit.swift.git' target='_blank'>HaishinKit</a> 라이브러리를 사용하여 진행하였다.
자세한 삽질 내용은 따로 작성할 예정.

기능은 RTMP 송출, 카메라 전환, 마이크 Mute, 송출 FPS 설정, PiP 카메라, 카테고리 설정등 구현하였습니다.

RTMP 송출은 RTMP(Host) -> Nginx -> HLS(시청자)로 구성되었습니다.

Nginx를 테스트 할때만 개인 컴퓨터로 돌리고 있기 때문에 Live Stream Push 기능이 정상적으로 작동하지 않을수도 있습니다.

개인 서버가 있으신분은 TwitchClone/StreamLive/StartStream/StartLive/StreamCam.swift -> let pushURL = ("URL" ) 변경하시면 사용이 가능합니다.






<a href='https://youtu.be/nMAJOGl9hnk?si=VhaxuF3HMdXN9egO'>시연영상</a>

# [Swift]TwitchClone

**iOS Twitch App**을 직접 **관찰**과 어떤 **기술**들이 **적용**되었는지 **추측** 하면서 진행한 **개인 프로젝트**입니다.

**사용성**과 **지속 가능**하고 **확장성**을 바탕으로 **유지보수**가 쉽도록 **제작**하였습니다.
 

> **velog** :  https://velog.io/@diddbstjr55/Swift-TwitchClone-Project-Prologue
> 

### 사용된 기술

- **Swift**, **UIKit**
- **Firebase**( RealtimeDatabase, Storage, Messaging, GoogleSignIn )
- **Nginx** Media Server ( RTMP → Nginx → HLS )
- **HaishinKit** ( RTMP → Nginx )
    
    > https://github.com/shogo4405/HaishinKit.swift
    > 
- **ACThumbnailGenerator** ( HLS → UIImage )
    
    > https://github.com/acotilla91/ACThumbnailGenerator-Swift
    >
### **주요기능**

기존 **Twitch App**과 동일하게 **시청 모드**와 **방송 모드**를 분리해 **시청**, **방송**에 **집중**할 수 있도록 **제작**하였습니다.

### **방송 시청**

- **실시간 방송 리스트**
    - 각 **사용자별** **팔로잉** **리스트**를 **DB**에 **저장**해 원하는 **방송**을 **화면**에 **노출**이 가능하도록 제작.
    - **탐색** 부분은 **팔로잉**, **실시간** **방송**을 **YouTube**, **Twitch**와 동일하게 일정 부분 **수직 스크롤** 시 **썸네일** 화면에 **방송**을 재생시켜 **사용자**가 해당 **방송**을 **미리 볼 수 있도록** 제작.
    - **찾기** 부분 또한, **새로운 방송**을 찾아볼 수 있고 일정 부분 **가로 스크롤**을 진행하면 리스트가 자동으로 고정되면서 **방송**이 **재생**되도록 **Carousel** 효과를 **적용**.
    - **방송** **리스트**에 **노출**시킬 **썸네일**을 **서버**에 **도움 없이** 생성해 **사용자**에게 **노출**.  **→ [시행착오](https://velog.io/@diddbstjr55/Swift-TwitchClone-%EC%82%BD%EC%A7%881.-HLS-Thumbnail)**
- **실시간 방송 시청**
    - **방송**을 **시청**하던 중 **App**을 **최소화**해 **다른 작업**을 하더라도 **PiP**기능으로 **작업**과 **시청**이 **동시**에 가능.
    - **FB Event** 기능을 사용해 **다른** **Users**와 **실시간 채팅**이 **가능.**
    - **TouchEvent 발생** 시 **Timer 설정**으로 **상세화면**을 **자동**으로 **노출**, **숨김** 기능.

### 방송 송출

- **방송 송출은 Nginx MediaServer를 이용해 RTMP → HLS 형식으로 실시간 송출, 시청이 가능**
    - **SRT**가 아닌 **RTMP** 형식으로 **딜레이**가 약 **3초** 정도 **발생**.
    - **시청자 수** 또한, **RTMP** 환경에서 **DB**를 이용해 **구현**할 수 있었지만, **유지보수** 측면에 **불리**해 **** **미구현**.
- **카메라 전후면, 가로 세로 전환이 가능하고 전후면 동시 송출이 가능.**
    - **카메라 전후면** 기능은 **방송 환경**에서 **꼭 필요한** **기능**임으로 **구현**. **전후면** **동시** **송출**은 **실험적**인 **기능**이기에 따로 **키고 끌 수 있는** **옵션**을 넣어 **제작**하였음.
- **마이크 Mute 기능과 방송 FPS(30, 60) 변경 기능을 추가해 사용성 증가.**
    - **30FPS** **송출**에서는 **이슈**가 **없지만**, **60FPS**에서는 **메모리**가 **작은** **기기**에서(iPhone 12 Mini) **메모리 부족**으로 **송출**이 **중단**되는 **이슈**가 존재함.
    - **Bit Rate** 수준을 **낮추어** 진행하면 **가능**은 하지만, **높은** **FPS**의 **의미**가 **없기에** **메모리**가 **적은** **기기**들은 기능을 **막거나** **주의문**을 **작성**할 예정.
- **User에게 노출될 카테고리, 타이틀을 설정 가능.**
    - 스트리머는 **사용자**에게 **노출**시킬 **타이틀**과 **카테고리** 설정이 가능함. **카테고리**를 고를 때 카테고리 **이미지**를 **준비**해 스트리머에게 **편의성**을 **제공**.
    - **카테고리** **이미지**는 **FB Storage**에서 받아오지만, 카테고리의 **바뀌지 않는 특성**을 고려해 **Storage**에서 받은 이미지를 **기기에 저장**해 사용.
- **User가 시청 중인 채팅방을 실시간으로 확인 가능.**
    - **스트리밍 특성**상 **사용자**와 스트리머는 **소통**이 필요하기에 **송출 화면**에 **실시간 채팅**을 구현.
    - **실시간 채팅**은 **FB Realtime Database Event** 기능을 활용해 **구현**.
      
[TwitchClone 시연 영상](https://youtu.be/nMAJOGl9hnk)
## Live List(시청자)

![image.jpg1](https://velog.velcdn.com/images/diddbstjr55/post/9777127e-1320-49db-8e5d-d97eb05b10eb/image.PNG) |![image.jpg2](https://velog.velcdn.com/images/diddbstjr55/post/ce44f7ef-64f4-4fb6-b5ba-1411ed5f93e9/image.PNG)
--- | --- |



## Live Stream(Host)
![image.jpg1](https://velog.velcdn.com/images/diddbstjr55/post/e269d105-8427-4158-9130-bd74e6e1415a/image.PNG) |![image.jpg2](https://velog.velcdn.com/images/diddbstjr55/post/db04aee0-6072-48ca-9113-7e39ee0f7609/image.PNG)
--- | --- | 


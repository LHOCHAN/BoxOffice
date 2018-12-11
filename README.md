# BoxOffice

> BOOSTCAMP 3기 사전과제 

&nbsp;
## 앱 설명

부스트코스 에이스 iOS 과정에서 완성했었던 동일 주제를 리팩토링.

&nbsp;
### 요구사항
* [x] 2가지 화면 구성, 기능 구현
* [x] 애플 프레임워크만 활용하여 서버 요청 작업 구현
* [x] 이미지는 백그라운드에서 다운받아서 표시
* [x] 네트워크 동작중 인디케이터 표시
* [x] 데이터 수신 실패한 경우 알림창으로 안내

&nbsp;
### 실행화면


#### 화면1

![화면1](https://github.com/0jun0815/BoxOffice/Images/1.png)

#### 화면2

![화면2](https://github.com/0jun0815/BoxOffice/Images/2.png)

#### 화면3

![화면3](https://github.com/0jun0815/BoxOffice/Images/3.png)



&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![](https://github.com/0jun0815/YJContentsViewer/blob/master/ImageZoomInOut.gif)

* 컨텐츠 내 영상/비디오 처리 가능

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![](https://github.com/0jun0815/YJContentsViewer/blob/master/PlayVideo.gif)

&nbsp;
### 사용된 기술
* 개발언어는 `Swift4.2`를 사용
* UI와 관련된 작업은 `DispatchQueue`로 메인 스레드에서 동작

&nbsp;
### 문제점 및 해결 과정
* [x] 컨텐츠 데이터 구조에 따라 동적으로 변경되지 않는 Auto Layout
    * Auto Layout Visual Format Language를 사용하여 해결
* [x] AVPlayer 관련 작업의 메인 스레드 차단
    * Xcode의 Runtime API Checking 기능을 사용하여 문제가 발생되는 위치를 확인
    * AVPlayer의 인스턴스 메서드인 replaceCurrentItem(with:)를 사용하여 해결
* [x] AVAsset의 중복 로드 작업
    * loadValuesAsynchronously(forKeys:completionHandler:)를 사용하여 이미 로드되어 있지 않은 키의 값만 작업
* [x] NotificationCenter에 등록한 옵저버가 메모리에서 해제되지 않는 문제 
    * NotificationCenter.default.removeObserver를 사용할때 매개변수로 self를 전달하는 잘못된 방법을 사용하였음
    * NSObjectProtocol 타입의 프로퍼티를 사용하여 addObserver 호출시 할당, 해제시 매개변수로 전달함으로 해결
* [ ]  TableViewCell에서 PlayerView를 사용하는 과정에서 메모리 누수 발생
    * 아직 해결하지 못함
    
&nbsp;
### 추가 구현할 기능
* [ ] 전체화면 비디오 플레이어
* [ ] 효율적인 비디오 처리
* [ ] 다양한 텍스트 폰트 제공
* [ ] 좋아요 기능 연동

&nbsp;
### 참고한 사이트
* Custom PlayerView
    * https://www.raywenderlich.com/5191-video-streaming-tutorial-for-ios-getting-started
    * https://github.com/MillmanY/MMPlayerView
* Auto Layout Visual Format Language
    * https://www.raywenderlich.com/277-auto-layout-visual-format-language-tutorial


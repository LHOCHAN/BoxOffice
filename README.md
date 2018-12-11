# BoxOffice

> BOOSTCAMP 3기 사전과제 

&nbsp;
## 앱 설명

부스트코스 에이스 iOS 과정에서 완성했었던 동일 주제를 리팩토링
* 이미지 캐시, 프리페치, 프로토콜 구현 및 코드 간결화

&nbsp;
### 사용된 기술
* 개발언어는 `Swift4.2`를 사용
* 비용이 많이 드는 작업을 줄이기 위해 `ImageCache`를 구현하여 메모리와 디스크 캐시 조작
* `ImagePrefetcher`를 구현하여 `tableView(_:prefetchRowsAt:)`와 `collectionView(_:prefetchItemsAt:)`에서 프리페치 작업
* 데이터 수신과 같은 비동기 네트워크 작업을 위한 `RequestAPI` 구현
* 공통된 규약을 정의한 `BOMovieProtocol` 구현              
* UI 작업은 `DispatchQueue`로 메인 스레드에서 동작, 디스크 I/O는 백그라운드에서 동작
* `UserDefault`를 이용한 데이터 저장 및 관리

&nbsp;
### 요구사항
* [x] 2가지 화면 구성, 기능 구현
* [x] 애플 프레임워크만 활용하여 서버 요청 작업 구현
* [x] 이미지는 백그라운드에서 다운받아서 표시
* [x] 네트워크 동작중 인디케이터 표시
* [x] 데이터 수신 실패한 경우 알림창으로 안내

&nbsp;
### 실행화면

**화면1**

![화면1](https://github.com/0jun0815/BoxOffice/blob/master/Images/1.png)

**화면2**

![화면2](https://github.com/0jun0815/BoxOffice/blob/master/Images/2.png)

**화면3**

![화면3](https://github.com/0jun0815/BoxOffice/blob/master/Images/3.png)


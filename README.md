# 은행 창구 관리 iOS 앱 개발

> 2024.02 (3주)
> 
- SeSAC x 맛있는코드 부트캠프 토이 프로젝트 (2인 1조)
- 원본 프로젝트 저장소: https://github.com/Changhyun-Kyle/ios-bank-manager/tree/develop

## 🍄‍🟫 스크린샷

![bankmanager-screenshot](https://github.com/user-attachments/assets/d1c4d981-e8df-4e23-a101-b778e073df77)


## 🍄‍🟫 개요

- 일정 업무 처리 시간 이후에 업무 종료를 처리하고 새로운 업무 추가에 대응하는 등 비동기 프로그래밍 경험을 핵심으로 하는 토이 프로젝트
- Dispatch 기술을 사용하여 비동기 프로그래밍하면서 여러 가지 멀티 스레딩 상황을 경험
- 객체가 적은 역할을 부여받도록 설계하고, 각 객체 사이에서 느슨하게 통신하도록 인터페이스 설계

## 🍄‍🟫 사용 기술

- UIKit
- UITableViewDiffableDataSource
- GCD
- SwiftLint

## 🍄‍🟫 프로젝트 구조

### 도메인 설계

![bank-refactor](https://github.com/user-attachments/assets/ce3a16fe-a581-4f72-a550-3a2703b68c69)


- 특정 업무를 맡은 은행원이 각 업무 대기열의 고객을 한 명씩 처리하는 상황으로, 각 업무 처리마다 하나의 스레드를 생성하도록 구현
- 메서드 호출 주체에 따라 다르게 설계할 수 있었음.
- **기존 설계 (3-1)**
    
    생성된 은행원(Banker) 각각이 루프를 돌며 고객 큐(clinet queue) 로부터 고객을 전달받아 자신의 스레드에서 업무를 처리하는 방식
    
- **리팩토링한 설계 (3-2)**
    
    업무별 관리자가 루프를 돌며 고객 큐와 가용한 은행원 큐에서 꺼낸 고객과 은행원을 매치해 새로운 스레드에서 업무를 처리하는 방식
    

### 이벤트 흐름


<p align="center">
  <img src="https://github.com/user-attachments/assets/8b4de050-1fd3-46d3-aa18-951cb6a25d52" width=800>
</p>


- 두 설계 모두 UI에서 발생한 이벤트가 사슬의 다음 객체의 동작을 트리거하고, 동작이 완료되면 처리할 대리 객체를 호출하는 방식으로 회귀하게 됨.

## 🍄‍🟫 주요 문제 해결 경험

### 비동기 프로그램 설계와 설계 변경

- 문제와 원인
    - 처음 고안한 설계로 구현하는 도중에, 보다 더 직관적인 설계를 논의하게 됨.
- 대안 비교와 도입
    - 은행 운영와 종료 조건을 결정하는 주체가 다른 것이 두 설계의 주된 차이점.
- 평가
    - 개선한 설계 방식은 업무가 가능한 은행원이 큐에 존재하는지를 끊임 없이 확인해야 하면서 CPU 자원 낭비가 발생한다는 문제가 있었음. (busy waiting, 바쁜 대기)
    - 하지만 이 비용을 줄이기 위해서 스레드 sleep-wake 하는 방식은 오버헤드가 있을 것으로 판단되었고, 개선한 설계를 유지하기로 결정.
    

### Delegate 패턴을 사용한 회귀형 구조의 이벤트 처리

- 대안 비교와 도입
    - 가장 단순한 형태의 delegate 패턴을 사용하되, 구체 타입이 아닌 인터페이스, 즉 책임에 의존하도록 추상화
    - 결과적으로 UI 에서 발생한 이벤트가 사슬 상의 여러 객체를 거쳐 도메인 계층에서 다시 View 로 회귀하는 구조로 설계하게 됨.
- 평가
    - 회귀형 구조에서 모든 계층을 Delegate 패턴, 즉 인터페이스로 구성할 때 생성자 주입이 아닌, 초기화 이후 속성에 참조를 할당하는 방식으로만 delegate 설정이 가능하며 delegate 속성을 외부로 노출시켜야만 한다는 사실을 알게 됨.
    - 전체 계층을 추상화면서 추상화에 큰 비용이 발생하는 것을 경험함.

## 🍄‍🟫 구현 단계별 기록

### 스텝별 현업자 코드 리뷰

| 단계 | PR |
| --- | --- |
| Step 1 | https://github.com/tasty-code/ios-bank-manager/pull/58 |
| Step 2 | https://github.com/tasty-code/ios-bank-manager/pull/75 |
| Step 3 | https://github.com/tasty-code/ios-bank-manager/pull/84 |
| Step 4 | https://github.com/tasty-code/ios-bank-manager/pull/96 |

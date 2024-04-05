# flutter_image_sample

## 향후 확장성을 위한 템플릿 프로젝트 구성

- MultiProvider로 Service 구현
  - 다국어
  - Theme
- Named Routes를 활용하여 화면 이동과 관련된 코드를 한 곳에 모아서 관리
- MVVM패턴을 위한 BaseView & BaseViewModel
- 모든 Dialog들의 공통된 디자인 요소를 BaseDialog에 구현
- BaseViewModel isBusy 속성을 이용해 로딩 애니메이션 추가
- mobile, tablet, desktop의 width를 지정하여 반응형 UI 구현

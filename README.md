# DustSweepGame (고양이 먼지 털기 게임)
고양이 얼굴에 묻은 먼지를 털어내는 게임입니다.
- `SpriteKit`으로 구현
- 개발과정을 담은 포스팅 시리즈 : https://velog.io/@emilyj4482/series/DustSweepGame

## 목차
- [주요 구현내용](#주요-구현내용)
- [트러블슈팅](#트러블슈팅)

<img src="https://github.com/user-attachments/assets/88b641d3-f584-4bfc-a556-c2c05f302422" width=400>

## 주요 구현내용
### 📌 드래그 제스쳐 처리
`touchesMoved` 메소드 활용 : 사용자의 드래그를 따라 터치 위치 실시간 추적 → 손가락 노드의 `position` 값에 적용. 이 때, 터치 시작 지점이 손가락 모양 영역이어야 적용되도록 플래그 변수 활용
```swift
class GameScene: SKScene {
    // ... //

    private var ishandImageTouched: Bool = false

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // 손가락 모양 노드 영역
        let xRange: ClosedRange<CGFloat> = handImage.position.x - handImage.size.width / 2 ... handImage.position.x + handImage.size.width / 2
        let yRange: ClosedRange<CGFloat> = handImage.position.y - handImage.size.height / 2 ... handImage.position.y + handImage.size.height / 2

        ishandImageTouched = xRange.contains(location.x) && yRange.contains(location.y)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // 플래그 조건에 맞으면 손가락 노드 이동
        if ishandImageTouched {
            let moveAction = SKAction.move(to: location, duration: 0.07)
            handImage.run(moveAction)
            cleanDusts()
            
            // ... //
        }
    }
}
```
### 📌 먼지 제거 로직


### 📌 SKAction 시퀀스 활용

## 트러블슈팅
### ⚠️ 오디오노드 추가/삭제 타이밍과 터치 이벤트 충돌 문제

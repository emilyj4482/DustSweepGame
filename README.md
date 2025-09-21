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
손가락 노드의 현위치 기준 왼쪽 상단 `position`(검지 부분)에 닿아있는 노드를 검사하여 게임 씬에서 제거(`removeFromParent()`)되도록 처리하였습니다. 해당 메소드는 `touchesMoved`에서 호출됩니다.
> 이 때, 고양이 얼굴 또한 손가락에 닿아 있을 거기 때문에 먼지 노드만 제거되도록 `node.name` 값을 활용하였습니다.
```swift
private func cleanDusts() {
    // 왼쪽 위(검지) point
    let x = handImage.position.x - handImage.size.width / 2
    let y = handImage.position.y + handImage.size.height / 2
    let point = CGPoint(x: x, y: y)
        
    for node in nodes(at: point) where node.name == "dust" {
        node.removeFromParent()
    }
}
```

### 📌 SKAction 시퀀스 활용
여러 애니메이션의 연속 적용을 위해 `SKAction.sequence`를 활용하였습니다. 시퀀스를 통해 좀더 자연스러운 시각 효과를 적용할 수 있습니다.
> ex. 먼지 제거 액션 : 손가락이 문지르는 위치로 짧게 쓸리도록 이동 액션 → 이미지가 서서히 투명해짐 → 노드를 씬에서 제거
```swift
for node in nodes(at: point) where node.name == "dust" {
    let moveAction = SKAction.move(to: point, duration: 0.01)
    let fadeAction = SKAction.fadeAlpha(to: 0, duration: 0.7)
    let removeAction = SKAction.removeFromParent()
            
    let sequenceAction = SKAction.sequence([moveAction, fadeAction, removeAction])
            
    node.run(sequenceAction)
}
```

## 트러블슈팅
### ⚠️ 오디오노드 추가/삭제 타이밍과 터치 이벤트 충돌 문제

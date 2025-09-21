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
### 📌 먼지 추가 로직
먼지를 (최대한)고양이 얼굴 위에만 배치하기 위해, 전체 화면에서 고양이 얼굴 범위를 계산하여 범위 내 랜덤 좌표를 연속적으로 추출하였습니다.
```swift
private func addDusts() {
    for _ in 1...50 {
        addDustImage()
    }
}

private func addDustImage() {
    let xRange: ClosedRange<CGFloat> = 60...(size.width - 60)    // 화면 양쪽 끝에서 각각 60 만큼 떨어진 범위
    let yOffset = (size.height - catFaceImage.size.width) / 2    // 고양이 얼굴 y 좌표 계산
    let yRange: ClosedRange<CGFloat> = (yOffset + 40)...(yOffset + catFaceImage.size.height - 40)    // 투명 공백 고려한 y 범위

    // x, y 범위에서 각각 무작위 좌표 추출
    let x = CGFloat.random(in: xRange)
    let y = CGFloat.random(in: yRange)
        
    let node = SKSpriteNode(imageNamed: "dust")
        
    node.size = CGSize(width: 40, height: 40)
    node.zPosition = 2
    node.position = CGPoint(x: x, y: y)
    node.name = "dust"
        
    addChild(node)
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
### ⚠️ 오디오 노드 추가/삭제 타이밍과 터치 이벤트 충돌 문제
#### ☹️ 문제
손가락 모양 노드를 빠르게 연속 터치하면 앱이 멈추거나 크래시 발생
>- 고양이를 문지르는 동안 그르릉 소리를 재생하기 위해 `SKAudioNode` 사용
>- 음원을 반복재생 하기 위해 `autoplayLooped`를 `true`로 설정 (`autoplayLooped = true`는 노드의 `addChild` 시점에 오디오를 자동으로 재생 시작)
>- 고양이를 문지를 때만 재생해야 하므로 `touchesBegan`에서 `addChild`, `touchesEnded`에서 `removeFromParent` 처리
>- 그러나 빠르게 연속 터치 시 `fatal error`가 발생하여 앱이 멈춤
```swift
private let purringSound: SKAudioNode = {
    let node = SKAudioNode(fileNamed: "purringSound.mp3")
    node.autoplayLooped = true
    return node
}()

override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if isHandImageTouched {
        addChild(purringSound)
    }
}

override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    isHandImageTouched = false
        
    purringSound.removeFromParent()
}
```
#### 🧐 원인
연속 터치로 인한 addChild / removeFromParent의 비동기성
- `SKScene`은 내부적으로 노드 트리 변경(add/remove)을 즉시 반영하지 않고, 렌더링 사이클의 특정 타이밍에 반영
- 따라서 터치 이벤트가 빠르게 연속 발생하면 이미 삭제가 예약된 노드에 대해 또 `removeFromParent()` 호출(fatal error)하거나 아직 추가되지 않은 노드를 다시 `addChild()` 호출(중복 추가)하는 경우가 생김
- 즉 터치 이벤트 처리 속도가 `SpriteKit`의 렌더링 속도보다 빨라지면서 add/remove 호출 순서가 꼬이게 되고, 그 결과 `SpriteKit`이 내부 트리 상태를 유지하지 못해 크래시 발생
#### 😇 해결
`addChild`, `removeFromParent` 연속 호출 방식을 제거하고 볼륨을 제어하는 방식으로 구현
```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if isHandImageTouched {
        if purringSound.parent == nil {
            addChild(purringSound)
        }
        let changeVolumeAction = SKAction.changeVolume(to: 1.0, duration: 0.1)
        purringSound.run(changeVolumeAction)
    }
}

override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    isHandImageTouched = false
        
    let fadeOutAction = SKAction.changeVolume(to: 0, duration: 0.3)
    purringSound.run(fadeOutAction)
}
```
#### 😎 성과
- `SpriteKit`의 노드 트리 변경(add/remove)은 즉시 반영되지 않는다는 사실을 학습
- UI 이벤트에 맞춰 노드를 계속 생성/제거하는 방식은 위험하다는 교훈을 얻음

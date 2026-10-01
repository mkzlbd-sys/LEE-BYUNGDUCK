-- 게임 설정값. 숫자만 바꿔도 게임이 달라집니다.
return {
	StarCount = 40, -- 맵에 떠 있는 별 개수
	StarRespawnSeconds = 8, -- 먹은 별이 다시 나타나는 시간
	MapRadius = 80, -- 놀이터 반지름
	JumpPower = 60, -- 점프 힘 (기본 50)
	BouncePadPower = 120, -- 트램펄린 발판 힘
	Colors = {
		Color3.fromRGB(255, 105, 180), -- 분홍
		Color3.fromRGB(255, 200, 60), -- 노랑
		Color3.fromRGB(100, 220, 255), -- 하늘
		Color3.fromRGB(150, 255, 150), -- 연두
		Color3.fromRGB(200, 150, 255), -- 보라
	},
}

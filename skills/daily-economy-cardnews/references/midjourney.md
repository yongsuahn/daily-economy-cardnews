# Midjourney 실사 사진 만들기 (Aside REPL)

계정: 브라우저(`config.json` 의 `browser_profile`)에 로그인된 Midjourney 계정(유료 플랜, Fast 시간 필요). 웹 `https://www.midjourney.com/imagine`.

## 프롬프트 형식

카드 12장마다 하나씩, 총 12개. 각 장면은 **그 카드 내용을 한눈에 떠올리게 하는 실제 같은 장면**으로 고른다. 2026-11-11 사용자 지시: "이상한 괴물 같은 거 쓰지마… 진짜 현실 같으면서도 멋있는 사진". 클레이·캐릭터·일러스트는 쓰지 않는다.

```
<장면 묘사 영어 한두 문장>, photorealistic documentary editorial news photography, natural cinematic light, shot on full-frame camera, realistic textures, high detail, no writing --no text letters numbers logos watermark illustration cartoon CGI 3d render toy --raw --stylize 60 --ar <비율>
```

- 표지(A1·B1·C1): `--ar 4:5`. 카드 전체에 깔리고 아래쪽 1/3 에 흰 제목이 올라가므로 **아래쪽이 어둡거나 단순한 구도**(바닥·하늘·어두운 복도)를 고른다. 상징 건물(연준·거래소·한국은행), 제품 접사, 분위기 있는 장소가 잘 맞는다.
- 나머지 9장: `--ar 4:3`.
- 글자가 보이면 안 되는 이유: 생성 이미지 속 글자는 깨져서 나온다. 화면·가격표·간판은 "out of focus / blurred" 로 지정한다.
- 얼굴이 정면으로 크게 나오는 실존 인물(CEO 등)은 만들지 않는다. 뒷모습·손·실루엣으로 연출한다.

2026-11-11 쓴 장면 예시(잘 나왔던 것):
- 연준 건물 저녁(표지) · 마트 장보기 · 빨간 차트 모니터 앞 트레이더 뒷모습 · 계산기와 대출 서류 위 손
- AI 칩 접사 초록 림 조명(표지) · 실리콘밸리 유리 사옥 야경 · 노란 조명 반도체 클린룸 · 카페에서 주식 앱 보는 손
- 파란 서버실 복도 끝 붉은 경고등(표지) · 어두운 방 노트북 치는 손 · 서버랙 조사하는 수사관 뒷모습 · 모르는 전화 거절하는 손

## 제출

```js
await openTab('https://www.midjourney.com/imagine');
const bx = page.locator('#desktop_input_bar');
for (const [k, p] of Object.entries(PROMPTS)) { await bx.click(); await bx.fill(p); await bx.press('Enter'); await sleep(3500); }
```
12개를 한 번에 넣어도 Fast 대기열이 처리한다(약 1~2분).

## 작업 ID 찾기

목록은 가상 스크롤이라 한 화면에 다 없다. 가장 긴 스크롤 컨테이너의 `scrollTop` 을 1100 씩 내리며 `img` 의 `cdn.midjourney.com/<job-uuid>/0_<n>_` 과 그 조상 요소의 프롬프트 텍스트를 짝지어 모은다. 같은 단어로 시작하는 옛 작업이 섞여 있으니 프롬프트 앞 50자로 키(A1…C4)를 맞춘다.

## 컷 고르기

작업마다 4장. 페이지 안에서 `fetch(https://cdn.midjourney.com/<id>/0_<k>_640_N.webp?method=shortest)` → canvas 4x4 로 이슈별 접촉 시트를 만들어 `display()` 로 본다. 고를 때 볼 것: 글자·로고가 또렷이 생기지 않았는지, 손·얼굴이 뭉개지지 않았는지, 표지는 제목 들어갈 아래쪽이 비었는지.

## 원본 받기

REPL `fetch` 와 curl 은 CDN 에서 403. **페이지 문맥 fetch** 는 된다:
```js
const r = await page.evaluate(async u => { const b = await (await fetch(u)).blob(); return await new Promise(ok => { const fr = new FileReader(); fr.onload = () => ok(fr.result); fr.readAsDataURL(b); }); }, `https://cdn.midjourney.com/${id}/0_${k}.png`);
await fs.writeFile(`${pwd}/tmp/mj/${key}.png`, Buffer.from(r.split(',')[1], 'base64'));
```
그 뒤 Bash 로 세션 tmp → `<workdir>/assets/<key>.png` 복사. 원본은 4:3 이 2544×1904, 4:5 가 약 1856×2320.

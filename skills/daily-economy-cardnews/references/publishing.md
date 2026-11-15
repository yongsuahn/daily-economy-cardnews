# 6곳 게시 절차 (Aside REPL, 2026-11-11 확인 · 11-12 이슈별 게시로 바꿈)

**이슈별로 따로 올린다.** 플랫폼마다 A·B·C 각각 4장짜리 게시물 하나씩, ③(C) → ②(B) → ①(A) 순서로 올려 ① 이 맨 위에 오게 한다. 본문은 `publish/split/<키>-long.txt`·`<키>-threads.txt`·`<키>-yt-title.txt`. 한 이슈 게시 과정을 함수로 만들어 두고 키만 바꿔 세 번 돌리면 빠르다(11-12 15건 약 40분).

준비: 카드 12장·영상·본문 파일을 **Aside 세션 디렉터리**(Aside 브라우저 기준. 다른 자동화 도구면 그 도구가 파일을 올릴 수 있는 폴더)(`pwd` + `/tmp/post/`)로 복사한다. `setInputFiles` 는 세션 디렉터리 밖 경로를 거부한다. 세션이 바뀌면 `pwd` 도 바뀌니 다시 복사한다.

화면 좌표: 스크린샷은 2000px 폭으로 표시되고 CSS 좌표는 **표시 좌표 × 0.7125**(뷰포트 1425 폭). 가능하면 좌표 대신 `page.evaluate` 로 요소의 `getBoundingClientRect()` 중심을 구해 `mouse.click` 한다.

**메뉴가 안 열리거나 눌러도 반응이 없으면** 그 탭이 뒤에 있어서다(메뉴 항목 위치가 0,0). `page.bringToFront()` 뒤 다시 한다. FB 「게시물 삭제」처럼 좌표 클릭이 안 먹는 메뉴 항목은 `evaluate` 안에서 `element.click()`.

**Aside 가 중간에 끊기면**(REPL 이 "Aside isn't running") 세션 디렉터리(`pwd`)가 새로 바뀐다. 파일을 다시 복사하고, 끊기기 전 하던 곳의 상태부터 확인한다(11-12 YouTube 한 건이 「초안」으로 남아 「초안 수정」으로 마저 올림).

계정: 모두 `config.json` 의 `browser_profile` 로 로그인된 브라우저에서. FB 페이지 `{facebook_page}`, IG `@{instagram}`, Threads `@{threads}`, TikTok `@{tiktok}`, X `@{x}`, YouTube 채널 `{youtube_channel_id}`. 아래의 `{…}` 는 모두 `config.json` 값으로 바꿔 읽는다.

## 1. Facebook + Instagram 릴스 — Business Suite 「릴스 만들기」 (2026-11-14 부터 기본)

`https://business.facebook.com/latest/reels_composer/?asset_id={meta_asset_id}&business_id={meta_business_id}`

- 「게시할 위치」 기본값 「{facebook_page}, {instagram}」 그대로 → FB·IG 에 한 번에(목록에 「릴스 · 교차 게시됨」).
- 「동영상 추가」 는 사진 composer 와 같은 방식(`HTMLInputElement.prototype.click` 가로채 `#fbup`)으로 `publish/issue-<키>-16s.mp4`. 10초쯤 기다리면 100%.
- 텍스트 칸 `[contenteditable=true][role=combobox]` 에 `<키>-long.txt` 를 `insertText` + `Shift+Enter` 로 넣고 원문 비교가 같을 때만 다음으로.
- **썸네일을 표지로 지정한다(필수).** 기본 「추천 썸네일」은 중간 화면(2/4)이 잡히고, 게시 뒤엔 FB·IG 모두 커버를 못 바꾼다(IG 「릴스 수정」 비활성, FB 「미디어 수정 불가」 — 2026-11-14 다시 올려야 했다). 「썸네일」 › 「이미지 업로드」 탭 › 오른쪽 「이미지 업로드」 링크 → 가로챈 input(accept image/*)에 `publish/cover-<키>.png`(영상 첫 프레임: `ffmpeg -ss 0 -i issue-<키>-16s.mp4 -frames:v 1 cover-<키>.png`). 체크된 미리보기가 표지인지 스크린샷으로 확인. 이 썸네일이 IG 커버에도 들어간다.
- 「다음」(수정 단계, 음악 추가는 하지 않음) → 「다음」(공유하기 단계: Facebook 스토리·Threads 스위치는 끈 채, 공개 범위 라디오는 비활성 상태로 기본 「전체 공개」) → 「공유하기」 → 「릴스 처리 중」 창의 「완료」.
- 확인: IG `instagram.com/{instagram}/reels/` 첫 `/reel/` 3개 본문, FB `facebook.com/{facebook_page_slug}/reels/` 의 `/reel/<id>/` 를 열어 「경제 이슈 ①②③」.

## 1-b. Facebook + Instagram 사진 게시물 — Meta Business Suite 한 번에 (11-13 까지의 방식)

`https://business.facebook.com/latest/composer/?asset_id={meta_asset_id}&business_id={meta_business_id}`

- 「게시할 위치」 는 기본값 「{facebook_page}, {instagram}」 그대로 둔다. 4장이라 IG 10장 제한에 안 걸려 **FB·IG 가 한 번에** 올라간다(11-12 확인, IG 미리보기 4:5 그대로). 「공유하기」 의 Threads 스위치는 켜지 않는다(본문 500자 초과, Threads 는 따로).
- **사진은 한 장씩 차례로 넣는다.** 여러 장을 한 번에 넣으면 업로드 끝난 순서로 섞인다.
- 「사진/동영상 추가」 는 `input[type=file]` 을 클릭할 때 만든다. 매번 `HTMLInputElement.prototype.click` 을 가로채 그 input 에 `id='fbup'` 을 달아 body 에 붙이고, 버튼은 **너비가 0 이 아닌 것**(숨은 복제본이 하나 있음)의 좌표를 `mouse.click` 한다 → `#fbup` 에 `setInputFiles(한 장)` → 「1080 x 1350」 행 수가 늘 때까지 대기.
- 본문은 `[contenteditable=true][role=combobox]`(role=textbox 쪽은 숨은 요소). 줄 단위 `keyboard.type` + Enter, 간격 300ms. 빠르게 치면 줄 순서가 섞인다. 입력 뒤 공백 제거 비교로 원문과 같은지 확인. 마지막 해시태그 추천 팝업은 제목 「게시물 만들기」 를 클릭해 닫는다.
- 「게시」 는 텍스트가 정확히 `게시` 인 마지막 보이는 버튼(rect 중심 클릭). 「게시물 게시 중」 → 「게시물을 홍보해보세요」 → 「나중에 하기」. 다음 이슈는 composer URL 로 다시 들어가 처음부터.
- 확인: `https://business.facebook.com/latest/posts/published_posts?asset_id={meta_asset_id}&business_id={meta_business_id}` 본문에 세 이슈 첫 줄이 「교차 게시됨 · {facebook_page}, {instagram}」 로 보이면 FB·IG 둘 다 됨.
- FB URL: 페이지 피드는 가상 스크롤이라 한 번에 안 잡힌다. `facebook.com/{facebook_page_slug}` 에서 700px 씩 스크롤하며 `[aria-posinset]` 안 본문의 「경제 이슈 ①②③」 와 그 안 `a[href*="/posts/pfbid"]` 를 짝짓는다. 열어서 탭 제목으로 맞는지 본다.
- IG URL: `instagram.com/{instagram}/` 첫 `a[href*="/p/"]` 3개, 각 페이지 본문으로 이슈 확인.

## 2. Instagram — instagram.com 웹 (Business Suite 가 안 될 때만)

1번에서 FB 와 같이 올라가므로 보통은 건너뛴다. 5장 이상을 한 게시물로 올려야 할 때만 쓴다.

- 홈에서 「새로운 게시물」(`a:has(svg[aria-label="새로운 게시물"])`) → 메뉴의 「게시물」 → `input[type=file]` 에 한 번에 `setInputFiles`(순서 유지).
- **자르기 기본값이 1:1** → 왼쪽 아래 자르기 아이콘 → 「4:5」.
- 「다음」 두 번 → 문구 칸 `div[aria-label="문구를 입력하세요..."]` 에 줄 단위 입력. 해시태그 추천 팝업은 Escape 말고 문구 위쪽 빈 곳 클릭으로 닫는다.
- 「공유하기」 → 「완료」.

## 3. Threads — threads.com

- 홈의 「새로운 소식을 공유해보세요」 → 마지막 `[role=dialog]` 안 첫 `[contenteditable=true]` 에 `<키>-threads.txt`(**500자 이하**) 줄 단위 입력 → 대화창 안 `input[type=file]` 에 그 이슈 4장(순서 유지).
- 대화창 안 텍스트가 `게시` 인 마지막 버튼 rect 중심 클릭 → 대화창이 사라지면 성공. 몇 초 쉬고 다음 이슈.
- `https://www.threads.com/@{threads}` 첫 `/post/` 링크 3개, 본문의 「경제 이슈 ①②③」 로 짝짓는다.

## 4. X — 이슈별 4장씩 3개 글 스레드

X 는 글 하나에 사진 4장, 가중 280자(한글 2). `scripts/xlen.py` 로 미리 검사한다.

- `https://x.com/compose/post`. 모든 선택자를 **`[role=dialog]` 안으로 한정**한다. 뒤에 깔린 홈 작성창에도 같은 `tweetTextarea_0`·`fileInput` 이 있어서, 한정하지 않으면 글·사진이 거기로 들어간다.
- 글 1: `tweetTextarea_0` 클릭 → 줄은 `Shift+Enter` 로 → 대화창 안 마지막 `input[data-testid="fileInput"]` 에 A-01~04.
- `[data-testid="addButton"]` → `tweetTextarea_1` → B 4장, 다시 → `tweetTextarea_2` → C 4장.
- 게시 전 대화창 안 첨부 이미지가 12개인지 확인 → `[data-testid="tweetButton"]`(Post all).
- 게시 뒤 뒤쪽 홈 작성창에 실수로 붙은 사진이 있으면 `[data-testid="primaryColumn"] [aria-label="Remove media"]` 로 지운다.
- 첫 글 URL 을 열어 article 3개가 이어져 있고 각 4장인지 확인.

## 5. TikTok — 16초 영상 (2026-11-14 부터 기본)

- `https://www.tiktok.com/tiktokstudio/upload` → `input[type=file]` 에 `publish/issue-<키>-16s.mp4`.
- 영상에는 제목 칸이 없고 「설명」(`[role=combobox][contenteditable=true]`, 4000자) 하나다. 파일명이 들어가 있으니 Meta+a·Backspace 로 지우고 `<키>-long.txt` 전체를 `insertText` + Enter 로 넣고 원문 비교.
- 설정 「펼치기」 → **「AI 생성 콘텐츠」 스위치를 켠다.** DOM 의 switch 상태값은 믿지 말고 라벨 오른쪽(라벨 rect.right+28) 을 클릭한 뒤 스크린샷으로 켜졌는지 본다(11-14 상태값이 true 로 나왔는데 꺼져 있었음).
- 「게시」 → 콘텐츠 검사 중이면 「계속 게시할까요?」 창 → 「지금 게시」. `/tiktokstudio/content` 로 가면 성공.
- 사진 게시물 지우기: Studio 목록에서 `a[href*="/video/<id>"]` 를 하나만 포함하는 가장 바깥 조상을 행으로 잡고(여러 id 를 품은 조상까지 올라가면 다른 행을 누른다) 그 행의 마지막 버튼(…) → 「삭제」 → 확인 창 「삭제」. 30일 안엔 복원 가능.

## 5-b. TikTok — TikTok Studio 사진 게시물 (11-13 까지의 방식)

- `https://www.tiktok.com/tiktokstudio/upload?tab=photo` → `input[type=file]` 에 그 이슈 4장(순서 유지).
- 제목 `input[placeholder="눈에 띄는 제목 추가"]`(90자) 에 `<키>-long.txt` 첫 줄 `fill`, 설명 `[role=combobox][contenteditable=true]` 를 Meta+a·Backspace 로 비운 뒤 나머지 줄 단위 입력, Escape.
- 「게시」 는 `button:has-text("게시")` 마지막 것을 `scrollIntoViewIfNeeded` 뒤 클릭.
- 「게시」 → `/tiktokstudio/content` 로 이동하면 성공. 처음엔 「콘텐츠 검토 중 / 나만」, 몇 분 뒤 「모두」.
- **제목이 빠진 것처럼 보여도 저장돼 있다.** Studio 목록과 PC 웹 플레이어는 설명만 보여 준다. 확인은 수정 화면 `/tiktokstudio/upload/post/photo?item_id=<id>` 의 제목 칸으로 한다(2026-11-12 확인).
- URL: Studio 목록의 `a[href*="/video/"]` 첫 번째.

## 6. YouTube — 이슈별 16초 Shorts 3개

- **썸네일:** 업로드 뒤 Studio 「세부정보」 › 「썸네일」 › 「동영상에서 선택」 › 첫 번째(표지) 프레임 › 완료 › 저장. 「파일 업로드」는 채널 전화번호 인증 전이라 막힌다. 안 하면 중간 화면이 썸네일이 된다.
- TikTok 은 영상 첫 화면이 그대로 커버가 되어 따로 할 일 없음(2026-11-14 확인).

사진 게시물이 안 되니 `scripts/make-video.sh` 로 만든 `publish/issue-<키>-16s.mp4` 를 올린다.

- `https://studio.youtube.com/channel/{youtube_channel_id}/videos/upload?d=ud` 로 바로 업로드 창을 연다(「만들기」 메뉴를 거치지 않아도 됨) → `input[type=file]` 에 mp4.
- 제목 `#title-textarea #textbox`(Meta+a 로 파일명 지우고 `<키>-yt-title.txt`), 설명 `#description-textarea #textbox` 에 `<키>-long.txt` 줄 단위 입력. `<` `>` 문자는 설명에 쓸 수 없다. 해시태그 추천 팝업은 창 위쪽(단계 표시줄) 클릭으로 닫는다.
- `tp-yt-paper-radio-button[name="VIDEO_MADE_FOR_KIDS_NOT_MFK"]` → 「자세히 보기」(`#toggle-button`) → `getByRole('radio', {name: '아니요, 동영상에 유료 프로모션이 포함되어 있지 않습니다.'})` → **`getByRole('radio', {name: '예, AI가 사용되었습니다.'})`**.
- `#next-button` 세 번 → `tp-yt-paper-radio-button[name="PUBLIC"]` → `#done-button`. 「게시된 동영상」 창의 `youtube.com/shorts/…` 링크를 기록하고 「닫기」.
- 한 번에 두 개 이상을 120초 안에 돌리면 REPL 이 배경 작업으로 넘어가고 끊길 수 있다. **한 호출에 한 개씩.**
- 하루 업로드 한도에 걸리면 같은 날 늦게 풀린다. 자동 재시도하지 말고 사용자에게 알린다.
- 지우기(다시 올릴 때): Studio 콘텐츠 › Shorts 행에 hover → 옵션 → 「영구 삭제」 → 확인 체크 → 대화창 안 「영구 삭제」 버튼 rect 중심 클릭.

## 결과 기록

`<workdir>/publish/publish-results.txt` 에 이슈별(①②③)로 6곳 URL 과 확인 내용을 적는다. 각 URL 을 다시 열어 본문 첫 줄이 보이는지(또는 HTML 에 있는지)로 확인하고, 확인 못 한 것은 그렇다고 적는다.

## 2026-11-13 메모

- **Aside 창 폭이 좁으면**(innerWidth 477 등) Business Suite 「게시」 버튼이 화면 밖에 있어 클릭이 안 먹는다. `page.setViewportSize({width:1425,height:900})` 뒤 버튼을 `scrollIntoView({block:'center'})` 하고 rect 중심을 클릭한다.
- **YouTube 입력은 `keyboard.insertText`** 로 한다. `keyboard.type` 도중 Google 「본인 인증」 창이 뜨면 공백·숫자·기호가 빠진 채 입력된다. 인증 창이 뜨면 창 안의 「다음」(y 400~600 사이에 있는 것)을 누르고, 인증이 끝나면 제목·설명을 다시 넣은 뒤 원문과 비교한다.
- Aside 를 막 켰을 때 첫 REPL 호출은 `page` 가 null 일 수 있다. `openTab` 결과가 출력되는지 먼저 확인한다.

## 2026-11-14 메모

- **Business Suite 본문은 `keyboard.type` 말고 `keyboard.insertText` + `Shift+Enter`(줄 사이 400ms)로 넣는다.** `type` + Enter 로 넣은 ② 가 줄 순서가 섞인 채(「이미지: …」·해시태그가 맨 앞) 게시됐다. 넣은 뒤 원문과 공백 제외 비교가 **같을 때만** 「게시」 를 누른다 — 비교 결과를 찍기만 하고 게시를 막지 않으면 소용없다.
- 이미 게시된 본문을 고칠 때: FB 는 Business Suite 게시됨 목록 › 행 클릭 › 오른쪽 미리 보기 「…」 › 「게시물 수정」(행의 「…」 메뉴엔 수정이 없다). 이 수정은 FB 에만 걸리므로 IG 는 instagram.com 게시물 「옵션 더 보기」 › 「수정」 › 문구 칸을 비우고 다시 넣고 「완료」. 편집기는 Meta+a·Backspace 한 번으로 안 비워질 때가 있어 비었는지 확인하며 되풀이한다.
- Aside REPL 의 Page 에는 `waitForTimeout`·`isClosed` 가 없다. `sleep(ms)` 를 쓰고 탭은 변수에 담아 `goto` 로 재사용한다.

- 이미 올린 FB 게시물 지우기: Business Suite 게시됨 목록 › 행 클릭 › 오른쪽 미리 보기 「…」 › 「게시물 삭제」 › 「삭제」. 상단에 「게시물 · 게시 시간」(사진) 인지 「릴스」 인지 먼저 확인. FB 만 지워지고 IG 사본은 목록에 「슬라이드 · {instagram}」 로 남는다 → IG 는 instagram.com 게시물 「옵션 더 보기」 › 「삭제」 › 「삭제」.

## 2026-11-15 메모

- 영상은 이날부터 `vertical/` 9:16 카드로 만든 화면 꽉 찬 영상이다(올리는 방법은 같음). 릴스 composer 미리보기·YouTube·TikTok 모두 1080x1920 로 인식.
- **Business Suite 릴스 본문 칸이 동영상 업로드 뒤 `role=textbox` 로 바뀌었다**(`[role=combobox]` 로 찾으면 없음). `[contenteditable=true]` 첫 번째로 잡는다. 본문 끝 해시태그 추천 팝업은 「썸네일」 제목 쪽을 클릭해 닫는다. 「이미지 업로드」 탭 안의 오른쪽 링크는 `a` 태그(같은 글자의 탭 버튼과 구분).
- 릴스 공유하기 단계에 「선택 캡션 · 자동 생성 캡션 설정됨」 이 체크돼 나온다. 무음 영상이라 그대로 둠.
- X 「Post all」 뒤 `graduated-access` 로 넘어가며 「You've unlocked more on X」 창이 뜰 수 있다. 「Your posts were sent」 가 보이면 게시는 된 것, 「Got it」 으로 닫는다.
- YouTube 「동영상에서 선택」 은 업로드 직후 프레임 칸이 비어 있다. 「취소」 로 닫고 몇 초 뒤 다시 열면 채워진다. 프레임 로드 여부를 `img.naturalWidth` 로 판단하면 틀릴 때가 있으니 스크린샷으로 본다. 첫 번째 프레임 = 표지.
- TikTok·YouTube 세부 화면 스크린샷에 `clip` 을 주면 스크롤 컨테이너 때문에 엉뚱한 곳이 찍힌다. 전체 스크린샷으로 확인.

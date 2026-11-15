# Figma 월 페이지에 제작 기록 남기기 (게시 뒤)

월마다 페이지를 따로 두고, 해당 월 페이지에 레이어를 나눈 편집 가능한 사본을 남긴다. 순서는 **사용자 최종 검토 → SNS 게시 → Figma 제작**이다.

## 어디에

- `config.json` 의 `figma`: `file_key`(기록할 파일), `month_pages`(월 → 페이지 ID, 선택), `account_note`(어떤 Figma 계정·팀으로 열어야 파일이 보이는지 메모).
- Figma MCP 가 연결돼 있어야 한다(`create_session`·`use_figma`·`upload_assets`·`get_screenshot`). 없으면 이 단계는 건너뛰고 사용자에게 알린다.
- 페이지: `month_pages` 에 있으면 그 ID 를 `--page-id` 로 넘기고, 없으면 이름이 `SNS 게시물 (N월)` 인 페이지를 찾는다. 새 달 페이지가 없으면 스크립트가 멈춘다. 그때는 `figma.createPage()` 로 새 달 페이지를 만들고, 앞 달 페이지 바로 뒤로 옮긴다(`figma.root.insertChild(앞달index+1, page)`). 만든 사실을 사용자에게 알린다.
- 글꼴은 **Noto Sans KR**(Figma 기본 제공). Figma 에는 Pretendard 가 없을 수 있다. Regular/Medium/Bold 를 쓴다.

## 형식

게시물 하나 = 섹션 하나. 섹션들은 x=0 에 세로로, 간격 160 으로 쌓는다.
- 섹션 이름: `YYYY-MM-DD · 주제 · 실사 카드뉴스 N장`, 흰 배경, 폭 4656
- 그 안 (32,32) 에 세로 오토레이아웃 프레임 「게시용 원본 · …」 (패딩 64, 간격 28): `게시물 제목`(Bold 60) → `제작 및 게시 정보`(30) → 카드 행(가로 오토레이아웃, 간격 48) → `원본 안내`(28) → `게시글 및 출처`(30) → `플랫폼별 게시 링크 및 상태`(30)
- 카드 프레임 이름 `A01 / cover / 주제` (data · effect · check), 1080×1350. 레이어마다 한국어 이름(사진 원본 / Midjourney A2, 제목, 핵심 수치, 뉴스 해설, 요점 상자 배경…)
- 2026-11-15 부터 카드에 머리글·날짜·「넘겨서 보기」·쪽 번호가 없어 「카드 상단」 컴포넌트도 만들지 않는다

경제 카드뉴스는 12장 한 게시물이라 섹션 하나에 이슈별 카드 행 3개를 둔다.

## 절차

1. `python3 -I $S/scripts/figma-build.py <workdir> --page-id <월 페이지 id>` → `publish/figma-build.js`. 이 파일은 `content.json`, `publish/caption-long.txt`, `publish/publish-results.txt` 를 읽는다. 그래서 **게시 결과 파일을 다 쓴 뒤에** 돌린다.
2. figma-use 스킬(`get_figma_skill skill://figma/figma-use/SKILL.md`)을 읽고 `create_session` 을 한다. 그다음 `figma-build.js` 내용을 그대로 `use_figma` code 로 넘긴다. 같은 이름 섹션이 있으면 지우고 다시 만들어서, 다시 돌려도 안전하다. 돌려받는 값은 `photos`({A1: 노드ID …})와 `sectionId`.
3. `upload_assets(count=12, nodeIds=[photos 의 A1…C4 순서], scaleMode=FILL, currentPageId=월 페이지)` → 받은 submitUrl 을 `publish/figma-urls.txt` 에 `A1 <url>` 형식으로 한 줄씩 적는다. 그다음 `sh $S/scripts/figma-upload.sh <workdir> publish/figma-urls.txt`. raw JPEG 로 보내야 레이어 이름이 유지된다(multipart 로 보내면 파일명으로 바뀐다). 모두 200 이 나오는지 확인한다.
4. `get_screenshot(sectionId, maxDimension 2400)` 을 받아 Read 로 본다. 빈 회색 사진이 없는지, 글이 넘치지 않는지 확인한다. Noto Sans KR 이 Pretendard 보다 넓어서 해설·요점 문장이 한 줄 더 길어질 수 있다. 넘치면 그 텍스트 노드만 고친다.
5. 사용자에게 Figma 링크를 준다: `https://www.figma.com/design/{file_key}/?node-id=<sectionId 의 : 를 - 로>`.

`figma-upload.sh` 의 URL 목록 인자는 **절대경로**로 준다(상대경로면 못 찾음).

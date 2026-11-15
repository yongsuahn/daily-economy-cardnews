#!/usr/bin/env python3
"""작업 폴더 → Figma use_figma 용 JS 생성.

usage: python3 -I figma-build.py <workdir> [--page-id 511:650]
출력: <workdir>/publish/figma-build.js  (그 내용을 use_figma 의 code 로 그대로 넘긴다)

읽는 것: content.json, publish/split/<키>-long.txt(없으면 publish/caption-long.txt), publish/publish-results.txt
만드는 것: 월 페이지 맨 아래에 섹션 「YYYY-MM-DD · 주제들 · 실사 카드뉴스 12장」 하나.
  안에 「게시용 원본」 세로 프레임(제목·게시 정보·이슈별 카드 행 3개·원본 안내·게시글 및 출처·게시 링크).
  카드는 1080x1350 프레임, 사진·그라데이션·문구가 각각 레이어. 사진 사각형은 비워 두고 ID 를 돌려준다
  → figma-upload.sh 로 채운다. 같은 이름 섹션이 있으면 지우고 다시 만든다(재실행 안전).
"""
import json, sys, pathlib

args = sys.argv[1:]
wd = pathlib.Path(args[0])
page_id = args[args.index('--page-id') + 1] if '--page-id' in args else None
content = json.loads((wd / 'content.json').read_text())
pub = wd / 'publish'
split = sorted((pub / 'split').glob('?-long.txt')) if (pub / 'split').exists() else []
if split:  # 2026-11-12 부터 이슈별 게시 → 이슈별 본문을 이어 붙인다
    caption = '\n\n― ― ―\n\n'.join(f.read_text().strip() for f in split)
else:
    caption = (pub / 'caption-long.txt').read_text().strip() if (pub / 'caption-long.txt').exists() else ''
results = (pub / 'publish-results.txt').read_text().strip() if (pub / 'publish-results.txt').exists() else '게시 전'

date_dot = content['date']                      # 2026.11.11
date_iso = date_dot.replace('.', '-')
topics = [i['tag'].split('·', 1)[-1].strip() for i in content['issues']]
data = {
    'pageId': page_id,
    'month': int(date_iso.split('-')[1]),
    'dateIso': date_iso,
    'sectionName': f"{date_iso} · {' / '.join(topics)} · 실사 카드뉴스 {len(content['issues']) * 4}장",
    'title': f"{content['header']} ({content['date']})" if split else (caption.splitlines()[0] if caption else content['header']),
    'info': f"게시 완료 · Facebook / Instagram / Threads / X / TikTok / YouTube Shorts · 이슈별 4장 게시물 {len(content['issues'])}개씩 (X 는 이슈별 4장씩 스레드, YouTube 는 이슈별 16초 Shorts)",
    'guide': "1080 × 1350 · 사진은 개별 이미지 레이어(Midjourney 원본), 문구는 편집 가능한 텍스트 · 파일 글꼴 Noto Sans KR (게시한 PNG 는 Pretendard 로 렌더링해 글자 폭이 조금 다름)\n"
             f"이슈별 4장 × {len(content['issues'])} · 마지막 장은 대처법 · 원본 폴더 output/economy-cards-{date_iso}/",
    'caption': caption,
    'results': results,
    'content': content,
}

JS = r'''
const D = __DATA__;
const C = D.content;
const page = D.pageId ? await figma.getNodeByIdAsync(D.pageId) : figma.root.children.find(p => p.name === `SNS 게시물 (${D.month}월)`);
if (!page) throw new Error(`SNS 게시물 (${D.month}월) 페이지가 없음 — 먼저 페이지를 만들 것`);
await figma.setCurrentPageAsync(page);
const F = { R: { family: 'Noto Sans KR', style: 'Regular' }, M: { family: 'Noto Sans KR', style: 'Medium' }, B: { family: 'Noto Sans KR', style: 'Bold' } };
await Promise.all(Object.values(F).map(f => figma.loadFontAsync(f)));
const hex = h => ({ r: parseInt(h.slice(0, 2), 16) / 255, g: parseInt(h.slice(2, 4), 16) / 255, b: parseInt(h.slice(4, 6), 16) / 255 });
const solid = h => [{ type: 'SOLID', color: hex(h) }];
const INK = '1E1D26', MUTED = '6C6A75', WHITE = 'FFFFFF';
const SHADOW = [{ type: 'DROP_SHADOW', color: { r: 0, g: 0, b: 0, a: 0.45 }, offset: { x: 0, y: 0 }, radius: 18, spread: 0, visible: true, blendMode: 'NORMAL' }];

// 재실행 안전: 같은 이름 섹션 제거
for (const n of page.children.filter(n => n.type === 'SECTION' && n.name === D.sectionName)) n.remove();
let maxY = 0; for (const n of page.children) if (n.type === 'SECTION') maxY = Math.max(maxY, n.y + n.height);
const baseY = maxY + 160;

function text(parent, name, s, x, y, w, size, color = INK, font = 'R', o = {}) {
  const t = figma.createText();
  t.fontName = F[font]; t.fontSize = size; t.characters = s; t.name = name;
  t.lineHeight = { unit: 'PIXELS', value: Math.round(size * (o.lh || 1.35)) };
  if (o.kern) t.letterSpacing = { unit: 'PIXELS', value: o.kern };
  if (o.align) t.textAlignHorizontal = o.align;
  t.fills = solid(color);
  if (o.shadow) t.effects = SHADOW;
  parent.appendChild(t);
  t.textAutoResize = 'HEIGHT'; t.resize(w, t.height); t.x = x; t.y = y;
  return t;
}
function rect(parent, name, x, y, w, h, fill, r = 0, ellipse = false) {
  const n = ellipse ? figma.createEllipse() : figma.createRectangle();
  n.name = name; n.resize(w, h); n.x = x; n.y = y; if (!ellipse) n.cornerRadius = r;
  n.fills = fill === null ? [{ type: 'SOLID', color: { r: 0.85, g: 0.85, b: 0.85 } }] : (typeof fill === 'string' ? solid(fill) : fill);
  parent.appendChild(n); return n;
}
const light = (h, k = 0.62) => [0, 2, 4].map(i => { const c = parseInt(h.slice(i, i + 2), 16); return Math.round(c + (255 - c) * k).toString(16).padStart(2, '0'); }).join('').toUpperCase();
const BOX = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 }, opacity: 0.18 }];  // 거의 투명한 흰 유리 문장 상자 + 흰 글씨
const grad = (a0, a1) => [{ type: 'GRADIENT_LINEAR', gradientTransform: [[0, 1, 0], [-1, 0, 1]], gradientStops: [{ position: 0, color: { r: 0, g: 0, b: 0, a: a0 } }, { position: 1, color: { r: 0, g: 0, b: 0, a: a1 } }] }];

// 카드에 머리글·날짜·「넘겨서 보기」·쪽 번호는 넣지 않는다(2026-11-15 사용자 지시). 카드 상단 컴포넌트도 만들지 않는다.

const section = figma.createSection(); section.name = D.sectionName; page.appendChild(section);
section.x = 0; section.y = baseY; section.fills = solid(WHITE);
const wrap = figma.createAutoLayout('VERTICAL', { name: '게시용 원본 · 12장 + 캡션 + 출처 + 게시 링크', itemSpacing: 28 });
wrap.paddingTop = wrap.paddingBottom = wrap.paddingLeft = wrap.paddingRight = 64; wrap.fills = solid(WHITE);
section.appendChild(wrap); wrap.x = 32; wrap.y = 32;
const block = (name, s, size, color, font, w = 4464) => { const t = text(wrap, name, s, 0, 0, w, size, color, font); t.layoutSizingHorizontal = 'FIXED'; return t; };
block('게시물 제목', D.title, 60, '202735', 'B');
block('제작 및 게시 정보', D.info, 30, '626974', 'R');

const photos = {}; const kinds = ['cover', 'data', 'effect', 'check'];
for (const iss of C.issues) {
  const topic = iss.tag.split('·').slice(1).join('·').trim();
  const row = figma.createAutoLayout('HORIZONTAL', { name: `카드 ${iss.key}01–${iss.key}04 · ${topic}`, itemSpacing: 48 });
  row.fills = []; wrap.appendChild(row);
  for (let n = 1; n <= 4; n++) {
    const f = figma.createFrame(); f.name = `${iss.key}0${n} / ${kinds[n - 1]} / ${topic}`; f.resize(1080, 1350); f.clipsContent = true;
    f.fills = solid(iss.bg); row.appendChild(f);
    const photo = (x, y, w, h, r) => { const p = rect(f, `사진 원본 / Midjourney ${iss.key}${n}`, x, y, w, h, null, r); photos[`${iss.key}${n}`] = p.id; };
    if (n === 1) {
      photo(0, 0, 1080, 1350, 0);
      rect(f, '하단 그라데이션', 0, 650, 1080, 700, grad(0, 0.72));
      text(f, '표지 제목', iss.cover, 62, 990, 960, 84, WHITE, 'B', { lh: 1.25, kern: -1.5, shadow: true });
      continue;
    }
    // 2~4장도 사진을 배경으로 꽉 채운다(2026-11-15 사용자 지시)
    photo(0, 0, 1080, 1350, 0);
    rect(f, '사진 어둡게', 0, 0, 1080, 1350, [{ type: 'SOLID', color: { r: 0, g: 0, b: 0 }, opacity: 0.22 }]);
    rect(f, '상단 그라데이션', 0, 0, 1080, n === 4 ? 520 : 560, grad(0.78, 0));
    rect(f, '하단 그라데이션', 0, n === 4 ? 560 : 680, 1080, n === 4 ? 790 : 670, grad(0, 0.88));
    rect(f, '주제 알약 배경', 64, 107, 640, 45, WHITE, 22);
    text(f, '순서 · 주제', n === 4 ? `${iss.tag}  →  대처법` : iss.tag, 86, 112, 610, 23, iss.accent, 'B');
    if (n < 4) {
      const c = iss.cards[n - 2];
      text(f, '제목', c.title, 60, 172, 970, 72, WHITE, 'B', { lh: 1.22, shadow: true });
      text(f, '핵심 수치', c.fact, 64, 352, 960, 29, light(iss.accent), 'B', { shadow: true });
      text(f, '뉴스 해설', c.tip, 64, 992, 960, 28, WHITE, 'M', { shadow: true });
      rect(f, '요점 상자 배경', 64, 1085, 952, 150, BOX, 22);
      text(f, '요점 제목', c.head, 90, 1103, 900, 25, light(iss.accent), 'B', { shadow: true });
      text(f, '요점 설명', c.note, 90, 1145, 900, 26, WHITE, 'R', { shadow: true });
    } else {
      text(f, '제목', '그럼 나는\n어떻게 대비할까?', 60, 172, 970, 72, WHITE, 'B', { lh: 1.22, shadow: true });
      iss.todo.slice(0, 4).forEach((t, j) => {
        const y = 795 + j * 102;
        rect(f, `대처 ${j + 1} 배경`, 64, y, 952, 88, BOX, 20);
        rect(f, `대처 ${j + 1} 번호 배경`, 86, y + 20, 48, 48, iss.accent, 0, true);
        text(f, `번호 ${j + 1}`, String(j + 1), 86, y + 22, 48, 28, WHITE, 'B', { align: 'CENTER' });
        text(f, `대처 ${j + 1}`, t, 154, y + 25, 840, 27, WHITE, 'M', { shadow: true });
      });
      text(f, '주의 문구', '* ' + iss.todoNote, 64, 1206, 950, 21, 'D9D9D9', 'R');
    }
    text(f, '기사 출처', iss.source, 64, 1278, 950, 19, 'D9D9D9', 'R');
  }
}
block('원본 안내', D.guide, 28, '626974', 'R');
block('게시글 및 출처', D.caption, 30, '202735', 'R');
block('플랫폼별 게시 링크 및 상태', D.results, 30, '626974', 'R');
section.resizeWithoutConstraints(wrap.width + 64, wrap.height + 64);
figma.viewport.scrollAndZoomIntoView([section]);
return { sectionId: section.id, wrapId: wrap.id, photos, size: [section.width, section.height] };
'''

out = pub / 'figma-build.js'
pub.mkdir(exist_ok=True)
out.write_text(JS.replace('__DATA__', json.dumps(data, ensure_ascii=False)))
print(f'{out} ({out.stat().st_size} bytes)')

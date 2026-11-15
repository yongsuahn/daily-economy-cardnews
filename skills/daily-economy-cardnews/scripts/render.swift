// 카드뉴스 렌더러: content.json + assets/{A..C}{1..4}.png → {A..C}-0{1..4}.png (1080x1350, 사진 게시·Figma용)
//   + vertical/{A..C}-0{1..4}.png (1080x1920, 릴스·Shorts·TikTok 영상용, 2026-11-15 추가)
// usage: swift render.swift <workdir>   (workdir 안에 content.json, assets/ 가 있어야 함)
import AppKit
import CoreText

let root = URL(fileURLWithPath: CommandLine.arguments[1])
let skillDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let fontRoot = skillDir.appendingPathComponent("assets/fonts")
for n in ["Regular", "SemiBold", "Bold", "ExtraBold"] { CTFontManagerRegisterFontsForURL(fontRoot.appendingPathComponent("Pretendard-\(n).otf") as CFURL, .process, nil) }

struct Card: Codable { let title: String; let fact: String; let tip: String; let head: String; let note: String }
struct Issue: Codable { let key: String; let tag: String; let cover: String; let accent: String; let bg: String; let source: String; let coverFocusX: Double?; let cards: [Card]; let todo: [String]; let todoNote: String }
struct Content: Codable { let date: String; let header: String; let issues: [Issue] }
let content = try JSONDecoder().decode(Content.self, from: Data(contentsOf: root.appendingPathComponent("content.json")))

func color(_ h: String, _ a: CGFloat = 1) -> NSColor { let v = Int(h, radix: 16)!; return NSColor(srgbRed: CGFloat((v >> 16) & 255) / 255, green: CGFloat((v >> 8) & 255) / 255, blue: CGFloat(v & 255) / 255, alpha: a) }
let ink = "1E1D26", muted = "6C6A75"
func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ fill: String, _ r: CGFloat = 0) { color(fill).setFill(); NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h), xRadius: r, yRadius: r).fill() }
func txt(_ s: String, _ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ size: CGFloat, _ fill: String = ink, _ weight: String = "Regular", _ ls: CGFloat = 4, shadow: Bool = false, kern: CGFloat = 0) {
  let p = NSMutableParagraphStyle(); p.lineSpacing = ls; p.lineBreakStrategy = .hangulWordPriority  // 한글 단어 중간에서 끊지 않음
  let f = NSFont(name: "Pretendard-\(weight)", size: size) ?? NSFont.systemFont(ofSize: size)
  var attrs: [NSAttributedString.Key: Any] = [.font: f, .foregroundColor: color(fill), .paragraphStyle: p, .kern: kern]
  if shadow { let sh = NSShadow(); sh.shadowColor = color("000000", 0.45); sh.shadowBlurRadius = 18; sh.shadowOffset = .zero; attrs[.shadow] = sh }
  (s as NSString).draw(in: NSRect(x: x, y: y, width: w, height: 500), withAttributes: attrs)
}
func image(_ name: String, _ box: NSRect, radius: CGFloat = 28, focusX: CGFloat = 0.5) {
  NSGraphicsContext.saveGraphicsState(); NSBezierPath(roundedRect: box, xRadius: radius, yRadius: radius).addClip()
  let im = NSImage(contentsOf: root.appendingPathComponent("assets/\(name).png"))!; let sz = im.size
  let s = max(box.width / sz.width, box.height / sz.height)
  im.draw(in: NSRect(x: box.minX + (box.width - sz.width * s) * focusX, y: box.midY - sz.height * s / 2, width: sz.width * s, height: sz.height * s), from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
  NSGraphicsContext.restoreGraphicsState()
}
var H: CGFloat = 1350
func begin() -> NSBitmapImageRep {
  let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1080, pixelsHigh: Int(H), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
  NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
  let ctx = NSGraphicsContext.current!.cgContext; ctx.translateBy(x: 0, y: H); ctx.scaleBy(x: 1, y: -1)
  NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: true); return rep
}
func save(_ rep: NSBitmapImageRep, _ name: String) throws { NSGraphicsContext.restoreGraphicsState(); try rep.representation(using: .png, properties: [:])!.write(to: root.appendingPathComponent(name)) }
// 2~4장도 사진을 배경으로 꽉 채운다(2026-11-15 사용자 지시, insta-cardnews 식). 글이 읽히게 전체를 살짝 어둡게 하고 위·아래에 그라데이션을 깐다.
let soft = "D9D9D9"  // 어두운 사진 위 출처·주의 문구
func light(_ h: String, _ t: Double = 0.62) -> String {  // 어두운 배경 위 강조색: 이슈 색을 흰색 쪽으로 섞는다
  let v = Int(h, radix: 16)!; func m(_ c: Int) -> Int { Int(Double(c) + (255 - Double(c)) * t) }
  return String(format: "%02X%02X%02X", m((v >> 16) & 255), m((v >> 8) & 255), m(v & 255))
}
func photoBg(_ name: String, top: CGFloat, bottom: CGFloat) {
  image(name, NSRect(x: 0, y: 0, width: 1080, height: H), radius: 0)
  color("000000", 0.22).setFill(); NSRect(x: 0, y: 0, width: 1080, height: H).fill(using: .sourceOver)
  let ctx = NSGraphicsContext.current!.cgContext, cs = CGColorSpaceCreateDeviceRGB()
  let gt = CGGradient(colorsSpace: cs, colors: [color("000000", 0.78).cgColor, color("000000", 0).cgColor] as CFArray, locations: [0, 1])!
  ctx.drawLinearGradient(gt, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: top), options: [])
  let gb = CGGradient(colorsSpace: cs, colors: [color("000000", 0).cgColor, color("000000", 0.88).cgColor] as CFArray, locations: [0, 1])!
  ctx.drawLinearGradient(gb, start: CGPoint(x: 0, y: bottom), end: CGPoint(x: 0, y: H), options: [])
}
func header(_ iss: Issue, _ n: Int, _ tag: String, top: CGFloat, bottom: CGFloat) {
  photoBg("\(iss.key)\(n)", top: top, bottom: bottom)
  rect(64, 107, 640, 45, "FFFFFF", 22); txt(tag, 86, 114, 620, 23, iss.accent, "Bold")
  txt(iss.source, 64, 1280, 950, 19, soft)
}

for iss in content.issues {
  // 1: 사진 꽉 채운 표지 + 왼쪽 아래 흰 굵은 두 줄 제목 (eyesmag식). 머리글·날짜·「넘겨서 보기」·쪽 번호는 넣지 않는다(2026-11-15 사용자 지시)
  do {
    let rep = begin()
    image("\(iss.key)1", NSRect(x: 0, y: 0, width: 1080, height: 1350), radius: 0)
    let ctx = NSGraphicsContext.current!.cgContext
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [color("000000", 0).cgColor, color("000000", 0.72).cgColor] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: 650), end: CGPoint(x: 0, y: 1350), options: [])
    txt(iss.cover, 62, 1000, 960, 84, "FFFFFF", "Bold", 6, shadow: true, kern: -1.5)
    try save(rep, "\(iss.key)-01.png")
  }
  // 2-3: 설명 카드
  for (i, c) in iss.cards.prefix(2).enumerated() {
    let rep = begin(); header(iss, i + 2, iss.tag, top: 560, bottom: 680)
    txt(c.title, 60, 177, 970, 72, "FFFFFF", "Bold", shadow: true); txt(c.fact, 64, 355, 960, 29, light(iss.accent), "Bold", shadow: true)
    txt(c.tip, 64, 995, 960, 28, "FFFFFF", "SemiBold", shadow: true)
    rect(64, 1085, 952, 150, "FFFFFF", 22); txt(c.head, 90, 1105, 900, 25, iss.accent, "Bold"); txt(c.note, 90, 1148, 900, 26, ink, "Regular")
    try save(rep, "\(iss.key)-0\(i + 2).png")
  }
  // 4: 대처법
  let rep = begin(); header(iss, 4, "\(iss.tag)  →  대처법", top: 520, bottom: 560)
  txt("그럼 나는\n어떻게 대비할까?", 60, 177, 970, 72, "FFFFFF", "Bold", shadow: true)
  for (j, t) in iss.todo.prefix(4).enumerated() {
    let y = CGFloat(795 + j * 102)
    rect(64, y, 952, 88, "FFFFFF", 20)
    rect(86, y + 20, 48, 48, iss.accent, 24); txt("\(j + 1)", j == 0 ? 103 : 101, y + 25, 30, 28, "FFFFFF", "Bold")
    txt(t, 154, y + 27, 840, 27, ink, "SemiBold")
  }
  txt("* " + iss.todoNote, 64, 1208, 950, 21, soft)
  try save(rep, "\(iss.key)-04.png")
}

// ── 9:16 영상용 (1080x1920) ──
// 릴스·Shorts·TikTok 은 아래 약 350px(설명·음악)과 오른쪽 약 130px(좋아요 버튼)을 가린다.
// 글은 y 1500 위, x 950 왼쪽에만 둔다. 사진은 가려져도 되니 오른쪽까지 깐다.
H = 1920
try? FileManager.default.createDirectory(at: root.appendingPathComponent("vertical"), withIntermediateDirectories: true)
let TW: CGFloat = 886  // 글 폭 (64 → 950)
func vtop(_ iss: Issue, _ n: Int, _ tag: String, top: CGFloat, bottom: CGFloat) {
  photoBg("\(iss.key)\(n)", top: top, bottom: bottom)
  txt(iss.source, 64, 100, TW, 21, soft)
  rect(64, 150, 640, 48, "FFFFFF", 24); txt(tag, 88, 158, 610, 25, iss.accent, "Bold")
}
for iss in content.issues {
  do {  // 표지: 4:5 사진을 9:16 으로 잘라 깐다. 피사체가 한쪽이면 content.json 의 coverFocusX(0 왼쪽~1 오른쪽)로 조정
    let rep = begin()
    image("\(iss.key)1", NSRect(x: 0, y: 0, width: 1080, height: 1920), radius: 0, focusX: CGFloat(iss.coverFocusX ?? 0.5))
    let ctx = NSGraphicsContext.current!.cgContext
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [color("000000", 0).cgColor, color("000000", 0.75).cgColor] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: 850), end: CGPoint(x: 0, y: 1920), options: [])
    txt(iss.cover, 62, 1190, TW, 92, "FFFFFF", "Bold", 8, shadow: true, kern: -1.5)
    try save(rep, "vertical/\(iss.key)-01.png")
  }
  for (i, c) in iss.cards.prefix(2).enumerated() {
    let rep = begin(); vtop(iss, i + 2, iss.tag, top: 760, bottom: 960)
    txt(c.title, 60, 232, TW, 84, "FFFFFF", "Bold", shadow: true); txt(c.fact, 64, 452, TW, 34, light(iss.accent), "Bold", shadow: true)
    txt(c.tip, 64, 1202, TW, 31, "FFFFFF", "SemiBold", 6, shadow: true)  // 두 줄까지 들어감
    rect(64, 1330, TW, 142, "FFFFFF", 24); txt(c.head, 92, 1350, TW - 56, 27, iss.accent, "Bold"); txt(c.note, 92, 1392, TW - 56, 27, ink, "Regular")
    try save(rep, "vertical/\(iss.key)-0\(i + 2).png")
  }
  let rep = begin(); vtop(iss, 4, "\(iss.tag)  →  대처법", top: 700, bottom: 820)
  txt("그럼 나는\n어떻게 대비할까?", 60, 232, TW, 84, "FFFFFF", "Bold", shadow: true)
  for (j, t) in iss.todo.prefix(4).enumerated() {
    let y = CGFloat(1015 + j * 110)
    rect(64, y, TW, 96, "FFFFFF", 22)
    rect(86, y + 22, 52, 52, iss.accent, 26); txt("\(j + 1)", j == 0 ? 104 : 103, y + 28, 30, 30, "FFFFFF", "Bold")
    txt(t, 160, y + 29, TW - 110, 29, ink, "SemiBold")
  }
  txt("* " + iss.todoNote, 64, 1462, TW, 22, soft)
  try save(rep, "vertical/\(iss.key)-04.png")
}
print("rendered \(content.issues.count * 4) cards + \(content.issues.count * 4) vertical")

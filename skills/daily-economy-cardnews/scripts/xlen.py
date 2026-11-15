# X 가중 글자 수 검사: 한글·CJK·이모지 2, 나머지 1, 한도 280. usage: python3 -I xlen.py x-thread.txt
import sys
for i, t in enumerate(open(sys.argv[1], encoding="utf-8").read().split("---"), 1):
    t = t.strip(); n = sum(2 if ord(c) > 0x10FF else 1 for c in t)
    print(f"[{i}] {n}/280 {'OK' if n <= 280 else 'TOO LONG'}")

# app_final.ring: 最終版ヘルパー関数の使用例

load "utf8lib.ring"

oUtils = new UTF8Utils()

see "--- 1. 文字列と配列の相互変換 ---" + nl
cString = "🍣寿司"
aArray = oUtils.string_to_array(cString)
see "文字列: " + cString + nl
see "配列化: " + string(aArray) + nl
see "文字列に戻す: " + oUtils.array_to_string(aArray) + nl + nl


see "--- 2. バイトとビット配列の変換 ---" + nl
nByte = 240 # UTF-8の4バイト文字の開始バイト (0xF0)
aBits = oUtils.byte_to_bits(nByte)
see "バイト値: " + nByte + nl
# 結果: [1, 1, 1, 1, 0, 0, 0, 0] となるはず
see "ビット配列: " + string(aBits) + nl 
see "ビット配列をバイトに戻す: " + oUtils.bits_to_byte(aBits) + nl + nl


see "--- 3. 文字列全体のビット表現 ---" + nl
cUniString = "A🍣" # A は 0x41, 🍣 は 4バイトシーケンス
aAllBits = oUtils.string_to_bits(cUniString)
see "文字列: " + cUniString + nl
see "全ビット配列の長さ: " + len(aAllBits) + nl # 1バイト + 4バイト = 5バイト = 40ビット
# 配列の表示は長すぎるため省略
# see "全ビット配列: " + string(aAllBits) + nl 

cBackToString = oUtils.bits_to_string(aAllBits)
see "ビット配列から文字列へ戻す: " + cBackToString + nl

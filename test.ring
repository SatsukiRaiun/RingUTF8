# tests.ring: UTF8Utilsライブラリのユニットテストスイート

load "utf8lib.ring"

func main()
    see "--- UTF8Utils ユニットテスト開始 ---" + nl

    oUtils = new UTF8Utils()
    
    # テストケース用の標準出力ヘルパー
    func assertEqual(cLabel, expected, actual)
        if expected = actual
            see "✅ TEST PASSED: " + cLabel + nl
        else
            see "❌ TEST FAILED: " + cLabel + " (期待値: " + string(expected) + ", 実際値: " + string(actual) + ")" + nl
        ok
    
    # --- テスト実行 ---

    cAscii = "abcdefg"
    cMulti = "Hello, 世界! 🍣"
    cEmpty = ""
    cBoundary = "a" + char(224) + char(128) + char(128) + "b" # 不正な3バイトシーケンスを含む可能性のあるバイト列

    see nl + ">> 基本機能テスト" + nl
    assertEqual("ASCII文字数カウント", 7, oUtils.count_chars(cAscii))
    assertEqual("マルチバイト文字数カウント", 12, oUtils.count_chars(cMulti))
    assertEqual("空文字列カウント", 0, oUtils.count_chars(cEmpty))
    
    assertEqual("get_char ASCII", "b", oUtils.get_char(cAscii, 2))
    assertEqual("get_char マルチバイト (世)", "世", oUtils.get_char(cMulti, 8))
    assertEqual("get_char マルチバイト (🍣)", "🍣", oUtils.get_char(cMulti, 12))
    assertEqual("get_char 範囲外", "", oUtils.get_char(cMulti, 99))

    see nl + ">> サニタイズテスト" + nl
    cSanitizeTest = "<tag> & \"quote\""
    cSanitizedExpected = "&lt;tag&gt; &amp; &quot;quote&quot;"
    assertEqual("HTMLサニタイズ", cSanitizedExpected, oUtils.sanitize_html(cSanitizeTest))

    see nl + ">> デコード・エンコード・ルーン処理テスト" + nl
    aRunesMulti = oUtils.decode_runes(cMulti)
    # 期待されるコードポイントの一部をチェック
    assertEqual("デコード結果配列長", 12, len(aRunesMulti))
    assertEqual("デコードされたルーン値 (世)", 32032, aRunesMulti[8]) # '世' のUnicode値

    cReEncodedMulti = oUtils.encode_runes(aRunesMulti)
    assertEqual("エンコード結果の一致", cMulti, cReEncodedMulti)

    see nl + ">> ヘルパー関数テスト" + nl
    aStringArray = oUtils.string_to_array("テスト")
    assertEqual("string_to_array 長さ", 3, len(aStringArray))
    assertEqual("array_to_string 結合", "テスト", oUtils.array_to_string(aStringArray))

    see nl + ">> ビット・バイト変換テスト" + nl
    aBitsB = oUtils.byte_to_bits(66) # 'B'
    assertEqual("byte_to_bits 長さ", 8, len(aBitsB))
    assertEqual("byte_to_bits 結果確認", [0, 1, 0, 0, 0, 0, 1, 0], aBitsB)
    assertEqual("bits_to_byte 逆変換", 66, oUtils.bits_to_byte(aBitsB))

    cBitsString = oUtils.bits_to_string(oUtils.string_to_bits("Hi"))
    assertEqual("string_to_bits/bits_to_string 往復変換", "Hi", cBitsString)


    see nl + "--- UTF8Utils ユニットテスト終了 ---" + nl

func main

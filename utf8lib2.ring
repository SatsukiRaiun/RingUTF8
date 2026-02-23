# utf8lib.ring: 拡張UTF-8処理ライブラリおよびヘルパー関数

class UTF8Utils
    
    # --- 既存の機能は省略 ---
    # count_chars, get_char, sanitize_html, decode_runes, encode_runes はそのまま含まれています

    # --- 新機能: 文字列と配列の相互変換ヘルパー ---

    # func string_to_array(cStr)
    # 文字列を1文字ごとの要素を持つ配列に変換します (UTF-8対応)
    func string_to_array(cStr)
        aChars = []
        nLen = this.count_chars(cStr)
        for nIndex = 1 to nLen
            aChars + this.get_char(cStr, nIndex)
        next
        return aChars

    # func array_to_string(aChars)
    # 文字の配列を単一の文字列に結合します
    func array_to_string(aChars)
        cStr = ""
        for cChar in aChars
            cStr += cChar
        next
        return cStr

    # --- 新機能: バイト/ビット配列の相互変換ヘルパー ---
    # ここでいう「ビット配列」は、0と1を要素とするRingの数値リストです。

    # func byte_to_bits(nByteValue)
    # 1バイトの数値 (0-255) を8つの数値 (0または1) の配列に変換します。
    func byte_to_bits(nByteValue)
        aBits = []
        for nBitIndex = 7 to 0 step -1
            # 右シフトして最下位ビットを抽出し、1と比較
            nBit = (nByteValue >> nBitIndex) & 1
            aBits + nBit
        next
        return aBits

    # func bits_to_byte(aBits)
    # 8つの数値 (0または1) の配列を1バイトの数値に変換します。
    # 配列の長さが8であることを前提とします。
    func bits_to_byte(aBits)
        nByteValue = 0
        for nIndex = 1 to 8
            nBit = aBits[nIndex]
            # ビットを適切な位置にシフトして加算
            nByteValue = nByteValue | (nBit << (8 - nIndex))
        next
        return nByteValue
        
    # func string_to_bits(cStr)
    # UTF-8文字列を、全てのバイトの連続したビット表現の配列に変換します。
    func string_to_bits(cStr)
        aAllBits = []
        nLenBytes = len(cStr)
        for nIndex = 1 to nLenBytes
            nByteVal = ascii(substr(cStr, nIndex, 1))
            aBits = this.byte_to_bits(nByteVal)
            for nBit in aBits
                aAllBits + nBit
            next
        next
        return aAllBits
        
    # func bits_to_string(aBits)
    # 連続したビット表現の配列をUTF-8文字列（バイト列）に再変換します。
    # 配列の長さが8の倍数であることを前提とします。
    func bits_to_string(aBits)
        cStr = ""
        nLenBits = len(aBits)
        for nIndex = 1 to nLenBits step 8
            # 8ビットごとにスライスしてバイトに戻す
            aByteBits = []
            for nSubIndex = 0 to 7
                aByteBits + aBits[nIndex + nSubIndex]
            next
            nByteVal = this.bits_to_byte(aByteBits)
            cStr += char(nByteVal)
        next
        return cStr

class UTF8Utils

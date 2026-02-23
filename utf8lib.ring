# utf8lib.ring: 拡張UTF-8処理ライブラリ (純粋なRingスクリプト)

class UTF8Utils

    # --- 基本機能 (前回のコードから) ---

    func count_chars(cStr)
        nChars = 0 nIndex = 1 nLen = len(cStr)
        while nIndex <= nLen
            nByteVal = ascii(substr(cStr, nIndex, 1))
            if nByteVal < 128 nIndex += 1
            elseif nByteVal >= 192 and nByteVal < 224 nIndex += 2
            elseif nByteVal >= 224 and nByteVal < 240 nIndex += 3
            elseif nByteVal >= 240 and nByteVal < 248 nIndex += 4
            else nIndex += 1 ok nChars += 1
        end return nChars

    func get_char(cStr, nCharIndex)
        nChars = 0 nIndex = 1 nLen = len(cStr)
        while nIndex <= nLen
            nByteVal = ascii(substr(cStr, nIndex, 1))
            nCharLen = 0
            if nByteVal < 128 nCharLen = 1
            elseif nByteVal >= 192 and nByteVal < 224 nCharLen = 2
            elseif nByteVal >= 224 and nByteVal < 240 nCharLen = 3
            elseif nByteVal >= 240 and nByteVal < 248 nCharLen = 4
            ok
            if nCharLen > 0
                nChars += 1
                if nChars = nCharIndex return substr(cStr, nIndex, nCharLen) ok
                nIndex += nCharLen
            else nIndex += 1 ok
        end return ""

    # --- 新機能: サニタイズ (HTMLエスケープの例) ---

    # func sanitize_html(cStr)
    # HTMLコンテキスト向けに特殊文字をエスケープします (&, <, >, ", ')
    func sanitize_html(cStr)
        cStr = replacestr(cStr, "&", "&amp;")
        cStr = replacestr(cStr, "<", "&lt;")
        cStr = replacestr(cStr, ">", "&gt;")
        cStr = replacestr(cStr, """", "&quot;")
        cStr = replacestr(cStr, "'", "&#39;")
        return cStr

    # --- 新機能: デコード (ルーン/コードポイントのリストへ) ---

    # func decode_runes(cStr)
    # UTF-8バイト列を、Unicodeコードポイント (数値/ルーン) のリストにデコードします。
    func decode_runes(cStr)
        aRunes = []
        nIndex = 1
        nLen = len(cStr)
        while nIndex <= nLen
            cByte1 = substr(cStr, nIndex, 1)
            nByte1Val = ascii(cByte1)
            nCodePoint = 0
            nCharLen = 0

            if nByte1Val < 128
                # 1バイト ASCII
                nCodePoint = nByte1Val
                nCharLen = 1
            elseif nByte1Val >= 192 and nByte1Val < 224
                # 2バイト
                nByte2Val = ascii(substr(cStr, nIndex + 1, 1))
                nCodePoint = ((nByte1Val & 0x1F) << 6) | (nByte2Val & 0x3F)
                nCharLen = 2
            elseif nByte1Val >= 224 and nByte1Val < 240
                # 3バイト
                nByte2Val = ascii(substr(cStr, nIndex + 1, 1))
                nByte3Val = ascii(substr(cStr, nIndex + 2, 1))
                nCodePoint = ((nByte1Val & 0x0F) << 12) | ((nByte2Val & 0x3F) << 6) | (nByte3Val & 0x3F)
                nCharLen = 3
            elseif nByte1Val >= 240 and nByte1Val < 248
                # 4バイト
                nByte2Val = ascii(substr(cStr, nIndex + 1, 1))
                nByte3Val = ascii(substr(cStr, nIndex + 2, 1))
                nByte4Val = ascii(substr(cStr, nIndex + 3, 1))
                nCodePoint = ((nByte1Val & 0x07) << 18) | ((nByte2Val & 0x3F) << 12) | ((nByte3Val & 0x3F) << 6) | (nByte4Val & 0x3F)
                nCharLen = 4
            ok

            if nCharLen > 0
                aRunes + nCodePoint
                nIndex += nCharLen
            else
                # 不正なバイトはスキップ
                nIndex += 1
            ok
        end
        return aRunes

    # --- 新機能: エンコード (ルーン/コードポイントのリストから文字列へ) ---

    # func encode_runes(aRunes)
    # Unicodeコードポイント (数値のリスト) をUTF-8バイト列 (文字列) にエンコードします。
    func encode_runes(aRunes)
        cStr = ""
        for nCodePoint in aRunes
            if nCodePoint < 0x80
                # 1バイト
                cStr += char(nCodePoint)
            elseif nCodePoint < 0x800
                # 2バイト
                cStr += char(0xC0 | ((nCodePoint >> 6) & 0x1F))
                cStr += char(0x80 | (nCodePoint & 0x3F))
            elseif nCodePoint < 0x10000
                # 3バイト
                cStr += char(0xE0 | ((nCodePoint >> 12) & 0x0F))
                cStr += char(0x80 | ((nCodePoint >> 6) & 0x3F))
                cStr += char(0x80 | (nCodePoint & 0x3F))
            elseif nCodePoint < 0x110000
                # 4バイト
                cStr += char(0xF0 | ((nCodePoint >> 18) & 0x07))
                cStr += char(0x80 | ((nCodePoint >> 12) & 0x3F))
                cStr += char(0x80 | ((nCodePoint >> 6) & 0x3F))
                cStr += char(0x80 | (nCodePoint & 0x3F))
            ok
        next
        return cStr
    
    # --- 新機能: ルーン処理 (文字列のイテレーションとマップ) ---
    
    # func map_runes(cStr, fMapFunc)
    # 文字列の各ルーンに関数を適用し、結果の文字列を返します。
    # fMapFunc は単一のコードポイント (数値) を受け取り、新しいコードポイント (数値) を返す必要があります。
    func map_runes(cStr, fMapFunc)
        aRunes = this.decode_runes(cStr)
        aNewRunes = []
        for nRune in aRunes
            # 提供された関数をルーンに適用
            nNewRune = call(fMapFunc, nRune)
            aNewRunes + nNewRune
        next
        return this.encode_runes(aNewRunes)

class UTF8Utils

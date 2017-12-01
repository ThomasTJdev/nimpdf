# Copyright (c) 2015 Andri Lim
#
# Distributed under the MIT license
# (See accompanying file LICENSE.txt)
#
#-----------------------------------------
import FontIOStreams, FontData

const
  IndexToLocFormat* = (kShortOffset : 0, kLongOffset : 1)

type
  LocaList = seq[int]

  LOCATable* = ref object of FontTable
    version: int
    numGlyphs: int

proc GetFormatVersion*(t: LOCATable): int = t.version
proc GetNumGlyphs*(t: LOCATable): int = t.numGlyphs

proc Loca*(t: LOCATable, index: int): int =
  if index > t.numGlyphs:
    raise newIndexError("loca outside bound")
  if t.version == IndexToLocFormat.kShortOffset:
    return 2 * t.data.ReadUShort(index * DataSize.kUSHORT)
  result = t.data.ReadULongAsInt(index * DataSize.kULONG)

proc GlyphOffset*(t: LOCATable, glyph_id: int): int =
  if (glyph_id < 0) or (glyph_id >= t.numGlyphs):
    raise newIndexError("Glyph ID is out of bounds.")
  result = t.Loca(glyph_id)

proc GlyphLength*(t: LOCATable, glyph_id: int): int =
  if (glyph_id < 0) or (glyph_id >= t.numGlyphs):
    raise newIndexError("Glyph ID is out of bounds. " & $glyph_id)
  result = t.Loca(glyph_id + 1) - t.Loca(glyph_id)

proc NumLocas*(t: LOCATable): int = t.numGlyphs + 1

proc newLOCATable*(header: Header, data: FontData): LOCATable =
  new(result)
  initFontTable(result, header, data)
  result.version = 0
  result.numGlyphs = 0

iterator items*(t: LOCATable): int =
  var i = 0
  while i < t.numGlyphs:
    yield t.Loca(i)
    inc(i)

proc SetFormatVersion*(t: LOCATable, value: int) = t.version = value
proc SetNumGlyphs*(t: LOCATable, numGlyphs: int) = t.numGlyphs = numGlyphs

proc encodeLOCATable*(loca: LocaList): LOCATable =
  var LocFormat = IndexToLocFormat.kLongOffset
  if loca[high(loca)] <= 0x20000:
    LocFormat = IndexToLocFormat.kShortOffset

  var newlocalength = loca.len * 2
  if LocFormat == IndexToLocFormat.kLongOffset: newlocalength = loca.len * 4

  var size = 0
  var newlocadata = makeFontData(newlocalength)
  for loc in loca:
    if LocFormat == IndexToLocFormat.kLongOffset:
      size += newlocadata.WriteULong(size, loc)
    else:
      let lc = int(float(loc) / 2)
      size += newlocadata.WriteUShort(size, lc)

  var newloca = newLOCATable(initHeader(TAG.loca, checksum(newlocadata, newlocadata.length()), 0, newlocadata.length()), newlocadata)

  newloca.SetFormatVersion(LocFormat)
  newloca.SetNumGlyphs(loca.len - 1)
  result = newloca


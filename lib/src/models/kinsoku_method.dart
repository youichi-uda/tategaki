/// Method for kinsoku processing (Japanese line breaking rules)
enum KinsokuMethod {
  /// Oikomi (追い込み): Push forbidden characters back to the previous line
  /// When a line-start forbidden character (like 。、) would appear at the
  /// start of a new line, move it and preceding characters to the previous line.
  oikomi,

  /// Burasage (ぶら下げ): Allow line-start forbidden characters to hang
  /// When a line-start forbidden character (like 。、) would appear at the
  /// start of a new line, allow it to hang at the end of the previous line,
  /// exceeding the maxHeight constraint.
  burasage,
}

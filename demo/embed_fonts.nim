import streams, nimPDF, unittest

proc draw_title(doc: PDF, text: string) =
  let size = getSizeFromName("A4")

  # Embed this specific font for better text copying
  doc.setFont("KaiTi", {FS_REGULAR}, 5, ENC_STANDARD, renderMode = frmEmbed)
  let tw = doc.getTextWidth(text)
  let x = size.width.toMM / 2 - tw / 2

  doc.setFillColor(0, 0, 0)
  doc.drawText(x, 10.0, text)
  doc.setStrokeColor(0, 0, 0)
  doc.drawRect(10, 15, size.width.toMM - 20, size.height.toMM - 25)
  doc.stroke()

proc createPDF(doc: PDF) =
  let size = getSizeFromName("A4")
  let SAMP_TEXT = "The Quick Brown Fox Jump Over The Lazy Dog"

  doc.addPage(size, PGO_PORTRAIT)
  draw_title(doc, "FONT RENDERING MODES DEMO")

  # Example 1: Font with individual embedding enabled
  doc.setFont("Calligrapher", {FS_REGULAR}, 10, ENC_STANDARD, renderMode = frmEmbed)
  doc.drawText(15, 30, "Calligrapher - renderMode=frmEmbed")

  # Example 2: Font without embedding (standard text rendering)
  doc.setFont("Eunjin", {FS_REGULAR}, 10, ENC_STANDARD, renderMode = frmDefault)
  doc.drawText(15, 50, "Eunjin - renderMode=frmDefault (no embedding)")

  # Example 3: Path rendering (text drawn as vector paths)
  doc.setFont("Eunjin", {FS_REGULAR}, 10, ENC_STANDARD, renderMode = frmPathRendering)
  doc.drawText(15, 70, "Eunjin - renderMode=frmPathRendering (not selectable)")

  # Example 4: Using convenience method with embedding
  doc.setFont("KaiTi", 10, renderMode = frmEmbed)
  doc.drawText(15, 90, "KaiTi - convenience method")

  # Example 5: Small text with embedding
  doc.setFont("Calligrapher", {FS_REGULAR}, 8, ENC_STANDARD, renderMode = frmEmbed)
  doc.drawText(15, 110, "Sample text with smaller embedded font")

  # Example 6: Base14 font (embedding flag ignored)
  doc.setFont("Times", {FS_REGULAR}, 10, ENC_STANDARD, renderMode = frmEmbed)
  doc.drawText(15, 130, "Times - Base14 ignores flag")

  doc.setInfo(DI_TITLE, "Font Rendering Modes Demo")
  doc.setInfo(DI_AUTHOR, "Andri Lim")
  doc.setInfo(DI_SUBJECT, "Demonstrating three font rendering modes: frmDefault, frmEmbed, frmPathRendering")

proc main(): bool {.discardable.} =
  #echo currentSourcePath()
  var fileName = "embed_fonts.pdf"
  var file = newFileStream(fileName, fmWrite)

  if file != nil:
    var opts = newPDFOptions()
    opts.addFontsPath("fonts")

    echo "Creating PDF with font rendering modes demonstration..."
    echo "- frmDefault: No embedding, standard text rendering"
    echo "- frmEmbed: Text rendering with font embedding"
    echo "- frmPathRendering: Text drawn as vector paths (not selectable)"
    echo "- Check text copying/pasting to verify different behaviors"

    var doc = newPDF(opts)
    doc.createPDF()
    doc.writePDF(file)
    file.close()
    echo "PDF created successfully: ", fileName
    echo "Try copying text from different lines to see embedding effects"
    return true

  echo "cannot open: ", fileName
  result = false

main()

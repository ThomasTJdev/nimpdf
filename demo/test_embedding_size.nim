import streams, nimPDF, unittest

proc draw_title(doc: PDF, text: string) =
  let size = getSizeFromName("A4")

  # Embed this specific font for better text copying
  doc.setFont("KaiTi", {FS_BOLD}, 5, ENC_STANDARD, embedFont = true)
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
  draw_title(doc, "PER-FONT EMBEDDING DEMO")

  # Example 1: Font with individual embedding enabled
  doc.setFont("Calligrapher", {FS_REGULAR}, 10, ENC_STANDARD, embedFont = true)
  doc.drawText(15, 30, "Calligrapher - embedded=true")

  # Example 2: Font without individual embedding
  doc.setFont("Eunjin", {FS_REGULAR}, 10, ENC_STANDARD, embedFont = false)
  doc.drawText(15, 50, "Eunjin - embedded=false")

  # Example 3: Using convenience method with embedding
  doc.setFont("KaiTi", 10, embedFont = true)
  doc.drawText(15, 70, "KaiTi - convenience method")

  # Example 4: Small text with embedding
  doc.setFont("Calligrapher", {FS_REGULAR}, 8, ENC_STANDARD, embedFont = true)
  doc.drawText(15, 90, "Sample text with smaller embedded font")

  # Example 5: Base14 font (embedding flag ignored)
  doc.setFont("Times", {FS_REGULAR}, 10, ENC_STANDARD, embedFont = true)
  doc.drawText(15, 110, "Times - Base14 ignores flag")

  # Example 6: Show global override behavior
  doc.setFont("Helvetica", {FS_REGULAR}, 8, ENC_STANDARD, embedFont = false)
  doc.drawText(15, 130, "Note: Global flag overrides individual settings")

  doc.setInfo(DI_TITLE, "Per-Font Embedding Demo")
  doc.setInfo(DI_AUTHOR, "Andri Lim")
  doc.setInfo(DI_SUBJECT, "Demonstrating individual font embedding")

proc main(): bool {.discardable.} =
  #echo currentSourcePath()
  var fileName = "embed_fonts.pdf"
  var file = newFileStream(fileName, fmWrite)

  if file != nil:
    var opts = newPDFOptions()
    opts.addFontsPath("fonts")
    # Set global embedding to false to demonstrate per-font control
    opts.setEmbedFont(false)

    echo "Creating PDF with per-font embedding demonstration..."
    echo "- Some fonts will be embedded individually using embedFont parameter"
    echo "- Global embedding is disabled to show individual font control"
    echo "- Check text copying/pasting to verify embedding worked"

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
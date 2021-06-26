//Cols will be cleared after duplicate
let clearCols = ["D", "E", "F"];

//Message please update
let msgPleaseUpdate = "<!--Please update->";

function onEdit(e) {
  let rg = /dr(\d*)$/;
  let match = rg.exec(e.value);
  if (match == null) {
    return;
  }

  let numNewRows = match[1] == "" ? 1 : parseInt(match[1]);
  e.range.setValue(e.oldValue);

  var sheet = SpreadsheetApp.getActiveSheet();
  sheet.insertRowsAfter(e.range.getRow(), numNewRows);
  var rangeToCopy = sheet.getRange(e.range.getRow(), 1, 1, 20);
  rangeToCopy.copyTo(sheet.getRange(e.range.getRow() + 1, 1, numNewRows));
  var range = sheet.getRange(e.range.getRow(), e.range.getColumn());
  sheet.setActiveRange(range);
  let arr = Array(numNewRows);
  arr.fill([msgPleaseUpdate]);
  SpreadsheetApp.getActiveSheet()
    .getRange(e.range.getRow() + 1, e.range.getColumn(), numNewRows)
    .setValues(arr);

  for (let i = 0; i < clearCols.length; i++) {
    SpreadsheetApp.getActiveSheet()
      .getRange(
        e.range.getRow() + 1,
        clearCols[i].charCodeAt(0) - 64,
        numNewRows
      )
      .clearContent();
  }
}
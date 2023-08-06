import QtQuick 2.0
import MuseScore 3.0
MuseScore {
    menuPath: "Plugins.MusicaFicta"
    description: "Place editorial accidentals (musica ficta) above the staff."
    version: "1.7"
    
   Component.onCompleted : {
        if (mscoreMajorVersion >= 4) {
           title = qsTr("Musica Ficta") ;
           // thumbnailName = ".png";
           categoryCode = "composing-arranging-tools";
        }
    }

    function makeFicta(accidental) {
      var targetLine = -4; // -4 is two ledger lines above staff
      var origLine = accidental.parent.line;
      var targetOffsetY;
      if(origLine<1) { //avoid collision with notes high on the staff
            targetOffsetY = -2;
      } else {
            targetOffsetY = (targetLine-origLine)/2; // calculate the difference & convert to staff spaces
      }

      // calculate horizontal center, accounting for resizing the accidental to small
      var smallNoteRatio;
      if (accidental.small == 1) { //if already small
            smallNoteRatio = 1; // don't need to adjust X calculations
      } else {
            smallNoteRatio = curScore.style.value("smallNoteMag");
      }
      
      var accidentalPosX = (accidental.posX-accidental.offsetX)*smallNoteRatio; //account for prior X offset
      var accidentalWidth = accidental.bbox.width*smallNoteRatio;
      var noteWidth = accidental.parent.bbox.width;
      var targetOffsetX = (noteWidth-accidentalWidth)/2-accidentalPosX;
            
      //apply properties 
      accidental.small = 1; 
      accidental.offsetX = targetOffsetX;
      accidental.offsetY = targetOffsetY;
    } //end makeFicta function
    
    onRun: {

        curScore.startCmd()

        var elementsList = curScore.selection.elements;
        //Make sure something is selected.
        if (elementsList.length==0) {
            console.log("No selection.");
        }
        else if (elementsList.length==1 && elementsList[0].name=="Note") { //if a single note is selected
            if (curScore.selection.elements[0].accidentalType == Accidental.NONE) { //if no accidental
                  console.log("No accidental on that note.");
            } else {
                  console.log("Processing the accidental of the selected note.");
                  makeFicta(elementsList[0].accidental);
            }
        } //end single note selection
        else {
            for (var i=0; i<elementsList.length; i++) {
                  if (elementsList[i].name != "Accidental") {
                        console.log("Element",i,"is",elementsList[i].name,"type so we do nothing.");
                  } else {
                        console.log("Processing Element",i,".");
                        makeFicta(elementsList[i]);
                  }
            } //end element list loop
        } //end selection check

        curScore.endCmd()

        quit();
    } //end onRun
}

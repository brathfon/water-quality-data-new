#!/usr/bin/env node 

"use strict";

var util  = require('util');
//var chalk = require("chalk");
var fs    = require('fs');
var path  = require('path');


var readMantaFile = function(teamFileFile) {
  var locations = [];
  var lines;
  var pieces;
  var lineCount = 0;
  var j;
  var obj = null;

  var contents = fs.readFileSync(teamFileFile, 'utf8')
  //console.log("contents: " + contents);
  lines = contents.split("\r");
  lines.forEach( function (line) {
     // console.log("line: " + line);
      ++lineCount;
      if (lineCount > 1) {
        pieces = line.split(",");
       // console.log("line " + lineCount + " line length " + pieces.length);
       // for (j = 0; j < pieces.length; ++j) { console.log(j + "\t" + pieces[j]); }
        obj = {};
        obj['date'] = pieces[0];
        obj['time'] = pieces[1];
        obj['lat'] = pieces[13];
        obj['lon'] = pieces[14];
        locations.push(obj);
      }

  });

  return locations;
};


var main = function()  {

 var locations = readMantaFile('/Users/bill/Development/water-quality-data/manta-data/kapalua-20180330/Kapalua_20180330-graphable.csv');

  for (var i = 0; i < locations.length; ++i) {

    //console.log(locations[i]);

    var placemark = 
    "\t\t" + "<Placemark>" + "\n" +
    "\t\t\t" + "<name>" + locations[i].time + "</name>" + "\n" +
    "\t\t\t" + "<visibility>0</visibility>" + "\n" +
    "\t\t\t" + "<styleUrl>#m_ylw-pushpin6</styleUrl>" + "\n" +
    "\t\t\t" + "<Point>" + "\n" +
    "\t\t\t\t" + "<gx:drawOrder>1</gx:drawOrder>" + "\n" +
    "\t\t\t\t" + "<coordinates>" + locations[i].lon +"," + locations[i].lat + "</coordinates>" + "\n" +
    "\t\t\t" + "</Point>" + "\n" +
    "\t\t" + "</Placemark>" + "\n";

    console.log(placemark);
  }

  var ending =
   "\t" + "</Folder>" + "\n" +
   "</Document>" + "\n" +
   "</kml>" + "\n";
  console.log(ending);

};

main();

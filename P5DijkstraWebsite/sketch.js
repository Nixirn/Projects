// Erick Lagunas: Dijkstra
// Grid Info
var rows = 15;
var cols = 15;
var canvasSize = 800;

var endFound = false;
var start, end;

// Width, Height
var w, h;

// Arrays that hold cell items
var grid = new Array(cols);
var visited = [];
var notVisited = [];
var path = [];
var walls = [];

let lastWallLen = walls.length;

// Wall Bools
let overCell = false;
let doneDrawing = false;
let cellX, cellY;

// Cell class
class Cell {
  visit = false;
  weight = Infinity; 
  prevCell = undefined;
  wall = false;

  constructor(i, j) {
    this.x = i; // Cols
    this.y = j; // Rows 
  }

  // Function that draws the cell
  show(color) {
    fill(color);
    noStroke(0);
    rect(this.x * w, this.y * h, w - 1, h - 1);
  };

  compare(otherCell) {
    if(this.x === otherCell.x && this.y === otherCell.y) {
      return true;
    }
    else {
      return false;
    }
  }
}

function setup() {
  let size =
        window.innerHeight < window.innerWidth
            ? window.innerHeight
            : window.innerWidth;
  createCanvas(size, size);
  console.log("Dijkstra");
   
  // Width of the canvas divided by # of columns (same for rows and height)
  w = width / cols;
  h = height / rows;

  // Loop that create the grid array and populate it with cells
  for (let i = 0; i < cols; i++) {
    grid[i] = new Array(rows);
    for (let j = 0; j < rows; j++) {
      grid[i][j] = new Cell(i, j);
    }
  }

  // Setting the start point and setting its values to start the search
  start = grid[1][1]; // FIXME: Gen start point
  start.weight = 0;
  start.visit = true;
  end = grid[cols - 1][rows - 1]; // FIXME: Gen end point (must be at least a few blocks away from start)
  visited.push(start);
}


// Loop that denotes cells as walls by setting their weight to canvasSize * 2
function doneDrawingPhase() {
  doneDrawing = true;
}

function dijkstra(gridCopy) {
  var neighbors = [];
  var neighbor;
  var currentCell = start;
  var min = {
    cost: Infinity,
    'cell': undefined
  };

  while (!endFound) {

    // Find neighbors add to array Left, Right, Top, Bottom if they exsist 
    // Check if neighbor is not visited or can be visited

    console.log({currentCell});
    neighbors = getNeighbors(currentCell, gridCopy);

    //  Check if neighbor is the end node
    //  Update the cost of the neigbor 

    // Save initial array neighbors length 
    neighborLen = neighbors.length;
    for (let i = 0; i < neighborLen; i++) {

      neighbor = neighbors.pop();

      if (neighbor.wall) {
        console.log('Wall Found');
        continue;
      } else {
        neighbor.weight = 1 + currentCell.weight;
        neighbor.prevCell = currentCell;
      }

      // Add each neighbor to the notVisited list
      notVisited.push(neighbor);
    }

    // Reset the min to accurately measure the min cost neighbor
    min.cost = Infinity;

    // Move on to the lowest cost unvisited neighbor
    for (let i = 0; i < notVisited.length; i++) { 
      if (notVisited[i]) { // Existence
        // Save the weight and cell info of the min
        if (notVisited[i].weight < min.cost) {
          min.cost = notVisited[i].weight;
          min.cell = notVisited[i];
        }
      }
    }
    
    console.log({notVisited});
    // Mark the min cell as undefined on the notVisited list (stand in code for removing the cell form the list entirely)
    for (let i = 0; i < notVisited.length; i++) {
      if (notVisited[i]) {
        if (notVisited[i].compare(min.cell)) {
          notVisited.splice(i,1);
          console.log({notVisited});
        }
      }
    }

    // Preps the next cell for the next iteration and add it the the visited list
    currentCell = min.cell;
    currentCell.visit = true; // Redundant? (I don't need this)
    gridCopy[currentCell.x][currentCell.y].visit = true;
    visited.push(currentCell);

    // End loop if the current node is the end node
    if (currentCell.x == end.x && currentCell.y == end.y) endFound = true;
  }

  console.log('-OUT OF MAIN LOOP-');
  findDijkstraPath(gridCopy);
}

// Path code
function findDijkstraPath(finalGrid) {
  /*
  This code block finds the path by looking at the pervious cell of the end cell
  And then looking at that cells previous cell, repeating till the right path is found
  */
  path.push(start);
  var currCell;
  currCell = finalGrid[end.x][end.y];
  console.log({ currCell });
  while (currCell.weight != 0) {
    if (!currCell.prevCell) {
      break;
    }
    path.push(currCell);
    currCell = currCell.prevCell;
    // console.log({ currCell });
  }
}

function getNeighbors(cell, gridC) {
  // left, right, top, bottom cells relative to the cell passed in
  // Checks if a cell exists and if a cell had been visited 
  // Returns an array filled with valid, yet to be visited cells
  let out = [];

  let neighborChecks = [
    { side: "top", x: 0, y: -1 },
    { side: "bottom", x: 0, y: 1 },
    { side: "left", x: -1, y: 0 },
    { side: "right", x: 1, y: 0 },
  ];

  // Loop that will go through each of the checks in the neighbor checks object
  for (let check of neighborChecks) {
    let x = cell.x + check.x; // will be 0, 0, -1, 1
    let y = cell.y + check.y; // will be -1, 1, 0, 0

    //
    if (x >= 0 && x < cols && y >= 0 && y < rows) {
      if (gridC[x][y].visit == false) {
        out.push(gridC[x][y]);
        // console.log(check.side);
      }
    }
  }

  return out;
}

// Clear start but no clear end yet need to find that
function draw() {
  // Animation Loop
  background(0);

  for (let i = 0; i < cols; i++) {
    for (let j = 0; j < rows; j++) {
      grid[i][j].show(color(255));
    }
  }

  // Paint visited cells green
  for (let cell of visited) {
    //console.log({ cell });
    cell.show = Cell.prototype.show
    cell.show(color(0, 255, 0));
  }

  // Paint not Visited cells blue
  for (let i = 0; i < notVisited.length; i++) {
    if (notVisited[i]) {
      notVisited[i].show = Cell.prototype.show
      notVisited[i].show(color(0, 0, 255));
    }
  }

  // Paint final path cells yellow
  for (let cell of path) { cell.show(color(255, 255, 0)); }

  // Paint walls black
  for (let cell of walls) { cell.show(color('black')); }

  start.show(color(2550,100,0));  // Start Orange
  end.show(color(255,0,255));     // End Purple

  // push() // saves the current style to stack (fill, stoke size, no stroke, rectangle corner)
  fill(255, 0, 0);
  ellipse(mouseX, mouseY, 10, 10);
  // pop() // goes back to save

  cellX = floor(mouseX / w);
  cellY = floor(mouseY / h);

  if (cellX < rows && cellY < cols) {
    let cell = grid[cellX][cellY];
    if (cell) {
      overCell = true;

      // Do not highlight start and end cells
      cell.show(color(0, 0, 0, 100))

    } else {
      overCell = false;
    }
  }

  if (walls.length > lastWallLen) {
    let gridClone = grid; // Grid with just walls
    console.log({grid});
    console.log({gridClone});
    
    reset();
    endFound = false;
    dijkstra(gridClone);
    lastWallLen = walls.length;
  }
}

function reset() {

  // Dose Not actually reset cells
  // for (let cell of grid) {
  //   console.log("IN RESET LOOP");
  //   if (cell.compare(start)) {
  //     continue;
  //   } else {
  //     cell.weight = Infinity;
  //     cell.visit = false;
  //     cell.prevCell = undefined;
  //   }
  // }

  for (let i = 0; i < cols; i++) {
    console.log("IN RESET LOOP");
    for (let j = 0; j < rows; j++) {
      if (grid[i][j].compare(start)) {
        continue;
      } else {
        grid[i][j].weight = Infinity;
        grid[i][j].visit = false;
        grid[i][j].prevCell = undefined;
      }
    }
  }

  visited = [];
  notVisited = [];
  path = [];
  console.log('Reset!');
  console.log({grid});
}

// Change Later
function mousePressed() {
  if (overCell) {
    if (grid[cellX][cellY]) { // FIXME: Crashes when the mouse goes off screen to the right
      if(grid[cellX][cellY].compare(start) || grid[cellX][cellY].compare(end)) {
        console.log("Start or the End cannot be walls");
      }
      else {
        grid[cellX][cellY].wall = true;
        walls.push(grid[cellX][cellY]);
      }
    }
  }
}

// Change grid creation loop
// Learn Let of for loops
// Undifind == false, empty objects
// ?. if exists(optional chaining)
// Update when walls are placed
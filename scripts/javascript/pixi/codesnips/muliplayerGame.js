
import { initializeApp } from "https://www.gstatic.com/firebasejs/9.3.0/firebase-app.js";
import { getDatabase, ref, set, onValue, get, child, remove, update } from "https://www.gstatic.com/firebasejs/9.3.0/firebase-database.js"

// UTILS

function uuidv4() {
  return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
    (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
  );
}

function getCachedUUID(){
  let uuid = localStorage.getItem('uuid');
  if (uuid === null){
    uuid = uuidv4();
    localStorage.setItem('uuid', uuid);
  }
  return uuid;
}

function hashFnv32a(str, asString, seed) {
    var i, l,
        hval = (seed === undefined) ? 0x811c9dc5 : seed;

    for (i = 0, l = str.length; i < l; i++) {
        hval ^= str.charCodeAt(i);
        hval += (hval << 1) + (hval << 4) + (hval << 7) + (hval << 8) + (hval << 24);
    }
    if( asString ){
        // Convert to 8 digit hex string
        return ("0000000" + (hval >>> 0).toString(16)).substr(-8);
    }
    return hval >>> 0;
}

function getPlayerData(uuid){
  let hashedId = hashFnv32a(uuid) % AVATAR_DATA.avatars.length;
  let name = AVATAR_DATA.avatars[hashedId];
  return {
    hashedId, name
  }
}

function lerp(a,b){
  return a + (b-a)/30;
}

function checkCollision(a,b){      
  if (a && b){
    return Math.hypot(b.x-a.x, b.y-a.y) < Math.max(a.getBounds().width, b.getBounds().width)/2
  }
}

// CONSTS
const firebaseConfig = {
  apiKey: "AIzaSyDGxlqcz3GF4SL5q_W1EIHpNWaL6wXIVt0",
  authDomain: "monsters-730fd.firebaseapp.com",
  projectId: "monsters-730fd",
  storageBucket: "monsters-730fd.appspot.com",
  messagingSenderId: "187823369708",
  appId: "1:187823369708:web:aa9c03fdd0ebef325424c9"
};

const ITEM_NAME_MAP = {
  feather: "I_Feather01",
  death: "S_Death02",
  mushroom: "I_C_Mushroom"
}

const AVATAR_BASE_URL =  "https://www.opherv.com/monsters";
const BACKGROUND_URL = "https://www.opherv.com/monsters/background2.png?1";
const DISPLACEMENT_SPRITE_URL = "https://res.cloudinary.com/dvxikybyi/image/upload/v1486634113/2yYayZk_vqsyzx.png";

let MIN_AVATAR_SCALE = 0.8;
let MAX_AVATAR_SCALE = 3;
let MAX_AVATAR_SPAWN_SCALE = 1.5;
let MIN_SPEED = 0.5;
let MAX_SPEED = 5;
let DEATH_TIMEOUT_INTERVAl = 15;
let PLAYER_TIMEOUT = 30000;

// SETUP GAME DATA

//player stuff
const PLAYER_UUID = getCachedUUID();
let PLAYER_HASEHD_ID;
let PLAYER_NAME;
let AVATAR_DATA;
let playerAvatar;

let worldObjects = {};
let remoteWorldObjects = {};

let updateInterval;
let heartbeatInterval;

fetch(`${AVATAR_BASE_URL}/monsterDict.json`)
  .then(response => response.json())
  .then(data => {
    AVATAR_DATA = data;
    let playerData = getPlayerData(PLAYER_UUID);
    PLAYER_HASEHD_ID = playerData.hasedId;
    PLAYER_NAME = playerData.name;    
});



// SETUP FIREBASE
const fbApp = initializeApp(firebaseConfig);
const db = getDatabase();


get(child(ref(db), `worldObjects`)).then( initialSnapshot => {  
  remoteWorldObjects = initialSnapshot.val() || {};
  initPlayer(remoteWorldObjects);
  const worldObjectsFromServer = ref(db, 'worldObjects');
  onValue(worldObjectsFromServer, (snapshot) => remoteWorldObjects = snapshot.val());
});


function syncPlayerToDB(uuid, props){
  update(ref(db, `worldObjects/${uuid}`), props);
}

function heartBeat(){
  update(ref(db, `worldObjects/${PLAYER_UUID}`), {lastActive: Date.now()});        
}

function syncSelfToDB(){
  if (playerAvatar){ 
    syncPlayerToDB(PLAYER_UUID, {
            x: playerAvatar.x,
            y: playerAvatar.y,
            scale: playerAvatar.scale.x,            
            type: playerAvatar.type
          });    
  }
}


// SETUP PIXI AND STAGE
// This scaling mode works better of pixel art
PIXI.settings.SCALE_MODE = PIXI.SCALE_MODES.NEAREST

let app = new PIXI.Application({ resizeTo: window });
document.body.appendChild(app.view);

let background = PIXI.Sprite.from(BACKGROUND_URL);
app.stage.addChild(background);
	    
// SETUP FILTERS (SHADERS)
let displacementSprite = PIXI.Sprite.from(DISPLACEMENT_SPRITE_URL);
displacementSprite.texture.baseTexture.wrapMode = PIXI.WRAP_MODES.REPEAT;

let displacementFilter = new PIXI.filters.DisplacementFilter(displacementSprite);

displacementSprite.scale.y = 0.6;
displacementSprite.scale.x = 0.6;
app.stage.addChild(displacementSprite);
background.filters = [displacementFilter];	        
background.height =  window.innerHeight;
background.width =  window.innerWidth;

function initPlayer(remoteObjects){  
  playerAvatar = createAvatar(PLAYER_UUID);      
  let newScale = (MIN_AVATAR_SCALE + Math.random() * (MAX_AVATAR_SPAWN_SCALE-MIN_AVATAR_SCALE)).toFixed(2);
  playerAvatar.x = Math.random() * window.innerWidth;
  playerAvatar.y = Math.random() * window.innerHeight;
  
  playerAvatar.scale.set(newScale, newScale);
  playerAvatar.type = "monster";  
  app.stage.addChild(playerAvatar);  
  worldObjects[PLAYER_UUID] = playerAvatar;
  
  if(PLAYER_UUID in remoteObjects){
    playerAvatar.x = remoteObjects[PLAYER_UUID].x;
    playerAvatar.y = remoteObjects[PLAYER_UUID].y;
    playerAvatar.score.text = remoteObjects[PLAYER_UUID].kills || "0";
    playerAvatar.scale.set(remoteObjects[PLAYER_UUID].scale,remoteObjects[PLAYER_UUID].scale);
    applyPowerUps(PLAYER_UUID,remoteObjects[PLAYER_UUID]);
  }
  
 
  addRandomItem();
    
  updateInterval = setInterval(syncSelfToDB, 250 );
  heartbeatInterval = setInterval(heartBeat, 5000);  
}

function createAvatar(uuid){  
  let playerData = getPlayerData(uuid);
  let avatarName = playerData.name;
  let newAvatar = PIXI.Sprite.from(`${AVATAR_BASE_URL}/avatars/${avatarName}.png`);
  newAvatar.anchor.set(0.5, 0.5);    
  let nameTag = new PIXI.Text(avatarName,{fontFamily : 'Arial', fontSize: 16, fill : 0xffffff, align : 'center'});
  nameTag.anchor.x = 0.5;
  nameTag.x = 0;
  nameTag.y = -60; 
  
  let score = new PIXI.Text("0", {fontFamily : 'Arial', fontSize: 16, fill : 0xffffff, align : 'center'});
  score.anchor.x = 0.5;
  score.x = 0;
  score.y = 45;     
  
  let container = new PIXI.Container();
  container.addChild(newAvatar);
  container.addChild(nameTag);
  container.addChild(score);
  
  container.score = score;
  return container;
}

function destroyPlayer(uuid){
      remove(ref(db, `worldObjects/${uuid}`));
      worldObjects[uuid].destroy({children: true});
      delete worldObjects[uuid];  
}

function die(){
      clearInterval(updateInterval); 
      clearInterval(heartbeatInterval);
      destroyPlayer(PLAYER_UUID);      
      playerAvatar = null;   
      setTimeout(()=>initPlayer({}), DEATH_TIMEOUT_INTERVAl*1000);    
}

function gotEaten(otherPlayerId){
      die();
        
      // make other monster bigger, increase kills!
      syncPlayerToDB(otherPlayerId, {
        scale: Math.min(MAX_AVATAR_SCALE, worldObjects[otherPlayerId].scale.x * 1.4),
        kills: worldObjects[otherPlayerId].kills + 1 || 1
      })      
}

function quickMode(uuid){  
  if (!uuid in worldObjects){ return }
  let avatar = worldObjects[uuid];   
  let convolutionFilter = new PIXI.filters.ConvolutionFilter()
  convolutionFilter.matrix = [0, 0.5, 0, 0.5, 1, 0.5, 0, 0.5, 0];
  avatar.filters = avatar.filters || [];
  avatar.filters.push(convolutionFilter);    
}

function glitchOut(uuid){  
  if (!uuid in worldObjects){ return }  
  let avatar = worldObjects[uuid];   
  let glitchFilter = new PIXI.filters.GlitchFilter({
    fillMode: 2   
  })
  avatar.filters = avatar.filters || [];
  avatar.filters.push(glitchFilter);
  
  let glitchInterval = setInterval(()=>{
    glitchFilter.red = [Math.random() * 10 - 5, Math.random() * 10 - 5];
    glitchFilter.green = [Math.random() * 10 - 5, Math.random() * 10 - 5];
    glitchFilter.blue = [Math.random() * 10 - 5, Math.random() * 10 - 5];
    glitchFilter.slices = Math.round(Math.random()*6);
    glitchFilter.direction = Math.round(Math.random()*60) - 30;
  } ,100);
    
  avatar.on("destroyed", ()=>clearInterval(glitchInterval))
}

function pickupItem(itemId){
      switch(worldObjects[itemId].name){
        case "death":
          die();
          break;
        case "mushroom":         
          if (playerAvatar.glitched) {break;}
          syncPlayerToDB(PLAYER_UUID, {
            glitched: true
          });
          glitchOut(PLAYER_UUID);
          break;
        case "feather":
          if (playerAvatar.quick) {break;}
          syncPlayerToDB(PLAYER_UUID, {
            quick: true
          });
          quickMode(PLAYER_UUID);
          break;
      }      
  
      remove(ref(db, `worldObjects/${itemId}`));      
      worldObjects[itemId].destroy({children: true});
      delete worldObjects[itemId];          
}

function applyPowerUps(uuid, playerData){  
    if (playerData.glitched && !worldObjects[uuid].glitched){
      worldObjects[uuid].glitched = true;
      glitchOut(uuid);
    }
                  
  if (playerData.quick && !worldObjects[uuid].quick){                  
    worldObjects[uuid].quick = true;    
    quickMode(uuid);
  }
}

function addItem(itemName){      
  let itemId = uuidv4();
  set(ref(db, `worldObjects/${itemId}`), {            
    x: Math.random() * window.innerWidth,
    y: Math.random() * window.innerHeight,
    type: "item",    
    name: itemName,
    scale: 2
  });
}

function addRandomItem(){
  let itemNames = Object.keys(ITEM_NAME_MAP);
  let itemName = itemNames[Math.floor(Math.random()*itemNames.length)];
  addItem(itemName);
}

// SETUP CONTROLS

let pressedKeys = {};
let trackedKeys = ['ArrowUp', 'ArrowRight', 'ArrowDown', 'ArrowLeft'];
window.addEventListener('keydown', e=>{
    if (trackedKeys.includes(e.key)){
        pressedKeys[e.key] = true;      
    }
});
window.addEventListener('keyup', e=>{
    if (trackedKeys.includes(e.key)){
        pressedKeys[e.key] = false;
    }
});

// SETUP RAF


let count = 0;
app.ticker.add((delta) => {
      displacementSprite.x = count*5;
    	displacementSprite.y = count*5;
  	  count += 0.05;  
        
      if (playerAvatar){
        // the smaller you are the faster you go
        let playerSpeed = (1 - (playerAvatar.scale.x - MIN_AVATAR_SCALE)/(MAX_AVATAR_SCALE-MIN_AVATAR_SCALE)) * (MAX_SPEED-MIN_SPEED) + MIN_SPEED;
        if (playerAvatar.quick){
          playerSpeed *= 1.2;
        }
        if (pressedKeys['ArrowUp']){
          playerAvatar.y -= playerSpeed;                
        } 
        if (pressedKeys['ArrowDown']){
          playerAvatar.y += playerSpeed;
        }
        if (pressedKeys['ArrowRight']){
          playerAvatar.x += playerSpeed;                
        } 
        if (pressedKeys['ArrowLeft']){
          playerAvatar.x -= playerSpeed;
        };
      }
  
      if (!(remoteWorldObjects && AVATAR_DATA)){ return;}
      
      //sync from server
      Object.keys(remoteWorldObjects).forEach(objectKey => {
          // player avatar needs special treatment
           if (objectKey !== PLAYER_UUID){
              let remoteObject = remoteWorldObjects[objectKey];
                                                   
             // object exists remotely but not locally, create it
              if (objectKey in worldObjects === false){                                
                let remoteObject = remoteWorldObjects[objectKey];
                if (remoteObject.type === "monster"){
                  let remoteAvatar = createAvatar(objectKey);
                  remoteAvatar.x = remoteObject.x;
                  remoteAvatar.y = remoteObject.y;
                  remoteAvatar.type = remoteObject.type;                
                  worldObjects[objectKey] = remoteAvatar;                
                  app.stage.addChild(remoteAvatar);
                } else if (remoteObject.type === "item"){
                    let itemSprite = PIXI.Sprite.from(`${AVATAR_BASE_URL}/${ITEM_NAME_MAP[remoteObject.name]}.png`);                                      
                    itemSprite.x = remoteObject.x;
                    itemSprite.y = remoteObject.y;
                    itemSprite.name = remoteObject.name;
                    itemSprite.type = remoteObject.type;
                    worldObjects[objectKey] = itemSprite;      
                    app.stage.addChild(itemSprite);                  
                }                
              }             
             
              // object exists both locally and remotely
              if (objectKey in worldObjects && objectKey in remoteWorldObjects){                 
                worldObjects[objectKey].x = lerp(worldObjects[objectKey].x, remoteObject.x);
                worldObjects[objectKey].y = lerp(worldObjects[objectKey].y, remoteObject.y);
                worldObjects[objectKey].scale.set(remoteObject.scale, remoteObject.scale);
                
                // power ups sync
                if (remoteObject.type === "monster"){                  
                  applyPowerUps(objectKey, remoteObject);
                  //destroy timed out players
                  if (Date.now() - remoteObject.lastActive > PLAYER_TIMEOUT){
                    destroyPlayer(objectKey);
                  }
                }
                
              }            
           }
                
          //score needs special treatment
          if (worldObjects[objectKey] && worldObjects[objectKey].type === "monster"){            
            worldObjects[objectKey].kills = remoteWorldObjects[objectKey].kills || 0;
            worldObjects[objectKey].score.text = worldObjects[objectKey].kills;                      
          }        
        });
        
      //object exists only locally            
      Object.keys(worldObjects).forEach(objectKey => {            
          if (objectKey !== PLAYER_UUID  && objectKey in worldObjects && objectKey in remoteWorldObjects === false){                                      
            app.stage.removeChild(worldObjects[objectKey]);                
            delete worldObjects[objectKey];
          }                                        
        });
        
      // simple "collision" with self
      Object.keys(worldObjects).forEach(objectKey => {
          // no self intersection            
          if (objectKey === PLAYER_UUID) { return };
                 
          let otherObject = worldObjects[objectKey];            
          if (checkCollision(playerAvatar, otherObject)){                   
            switch(otherObject.type){
              case "monster":
                let glitchCheck = playerAvatar.glitched ? Math.random() > 0.5 : true;
                if (playerAvatar.scale.x < otherObject.scale.x && glitchCheck){
                  gotEaten(objectKey);
                }
                break;
              case "item":
                pickupItem(objectKey);
                break;                  
            }
          }
        });
      
});

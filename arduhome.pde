
/*
  DigitalReadSerial
 Reads a digital input on pin 2, prints the result to the serial monitor 
 
 This example code is in the public domain.
 */

#define SENSOR_TYPE_BUTTON 1;

#define ACTUATOR_TYPE_RELAY 1;

#define WHEN_OPEN 1;
#define WHEN_CLOSE 2;
#define COMMAND_BUFFER_LEN 50;

/*

RELE 1
1 Luz baño
2 
3
4 Luz invitados
5
6
7
8

RELE 2
1 Luz entrada principal
2
3 Luz comedor tele
4 
5 
6
7
8 Luces cocina alogenas


RELE 3
1
2 Luz sofa
3 Despacho Estanteria
4 Despacho encima
5 Luz pasillo distribuidor
6 ?? Puede ser un sensor de movim..
7 Dormitorio
8 Luz Pasillo delante despacho


RELES MANUALES:
-->Sensor
1
2
3
4
--> sensor , sensor
5 Comedor mesa




*/

//de la direccion 1 a la x
class Sensor {
public:
  int id;
  int type;
  int the_port;
  int state;
  long lastRead;
  long lastReadDown;
  short id_room;
  long lastReadHigh;
};

class SensorAction {
public:
  int id_sensor;
  int type;
  int actuate_when; 
  int id_actuator;
  int actuator_mode;

};

class Actuator {
public:
  int id;
  int port;
  int state;
  int type;
};
class actuator_triple {
public:
  int id;
  int port1;
  int port2;
  int state;
  int type;
  long init_time;
  int prev_state;
  int time_to_down; 
};


class Room{
public:
  short id_room;
  short actual_scene;

};




class Scene{
public:

  short id_scene; 
  short id_room;
  short order;

};



class SceneActuator{
public:
  int id_scene;
  int id_actuator;
  int actuator_mode;
};



boolean DEBUG_MODE = true;
int NUM_SENSOR=0;
int NUM_ACTUATOR = 0;
int NUM_ACTUATOR_TRIPLE = 0;
int NUM_ACTIONS = 0;
int NUM_SCENE = 0;
int NUM_ROOM = 0;


int NUM_SCENE_ACTUATOR =0;
int NUM_scene_sensor =0;

Sensor sensor[50];
Actuator actuator[50];
actuator_triple actuator_triple[10];
SensorAction actions[100];

Room room[20];
Scene scene[50];

SceneActuator scene_actuator[100];



//BUFFER PARA PROGRAMACION Y INSTRUCCIONES...
char command_buffer[50];
int command_buffer_pointer = 0;

bool house_state = true;
int sensorValue =0;
//boolean sensortate[20];
//boolean releState[20] ;
//long lastRead[20];
//long lastReadDown[20];

long one_day = 86400000;
long duration = 14400000 ;// 4 horas

long last_start = -64800000;
boolean persiana_subida = false;

void setup() {

  //SENSORES----------------
  //addSensor(1,17,1,2);
  //-----------------comedor
  addRoom(1);


  //comedor tocando habitaciones (uno de los dos)
  addSensor(2,15,1,1);
  //comedor tocando habitaciones (uno de los dos)
  
  //Comedor  ( de los 4 el 4o)
  addSensor(11,7,1,1);
  //Comedor-Sofa
  addActuator(7,40,0);


  //Comedor tele
  addActuator(14,33,0);

  addScene(1,1);
  addSceneActuator(1,7,1);
  addScene(2,1);
  addSceneActuator(2,7,1);
  addSceneActuator(2,14,1);
 
  //--------------pasillo
  addRoom(2);

  //pasillo el solo
  addSensor(4,17,1,2); //Interruptor Entrada
  addSensor(7,4,1,2);  //Interruptor pasillo ( esquina)
  //Pasillo delante despacho
  addActuator(4,45,0);
  //entrada..
  addActuator(13,27,0);

  addScene(3,2);
  addSceneActuator(3,4,1);
  addSceneActuator(3,13,1);
  //-------------dormitori

  addRoom(3);
  //mesita noche, marc
  addSensor(13,11,1,3);

  //Dormitorio OK
  addSensor(1,14,1,3);

  //mesita_NOCHE Cris 
  addSensor(8,3,1,3);

  //Dormitorio
  addActuator(1,42,0);

  addScene(5,3);
  addSceneActuator(5,1,1);




  //------------------despacho
  addRoom(4);


  //Despacho 
  addSensor(3,16,1,4);

  //Dspacho encima mesa
  addActuator(2,43,0);

  //Despacho estanteria
  addActuator(8,41,0);

  addScene(7,4);
  addSceneActuator(7,2,1);
  addSceneActuator(7,8,1);
  addScene(8,4);

  addSceneActuator(8,2,1);
  //-------------------invitados
  addRoom(5);


  //luz convidats
  addActuator(18,46,0);
  //Invitados mesita de dormir..
  addSensor(10,12,1,5);
  //Invitados entrada
  addSensor(12,10,1,5);

  addScene(9,5);
  addSceneActuator(9,18,1);
  //-------------------------lavavo
  addRoom(6);


  //Lavavo OK 
  addSensor(9,13,1,6);

  //Lavavo
  addActuator(15,22,0);

  addScene(11,6);
  addSceneActuator(11,15,1);
  //----------------------------------cocina
  addRoom(7);

  //Cocina
  addActuator(5,38,0);
  addActuator(19,30,0);
  //OK Pasillo  ( de los 4 el 3o)
  addSensor(5,2,1,7);
  addSensor(6,9,1,7);
  addScene(12,7);
  addSceneActuator(12,5,1);
  addSceneActuator(12,19,1);

  addScene(13,7);
  addSceneActuator(13,5,1);
  //---------------------------------------


  //CASOS ESPECIALES....
  //Principal de casa...
  addSensor(7,4,1,0);


  //DESCONOCIDOS


  addActuator(6,39,0);//Luz pasillo-distribuidor
   
  /*
  //el  puerto 6 no funciona!!!
   
   //ACTUADORES----------------   
   
   
   
   //parece que es el distribuidor
   addActuator(3,44,0);
   
   
   
   
   
   //??-- no conectado
   addActuator(9,34,0);
   //????
   addActuator(10,35,0);
   //????
   addActuator(11,36,0);
   //
   addActuator(12,37,0);
   
   
   
   */

   addRoom(8);
   addRoom(9);

  //persiana subir comedor
  addSensor(14,18,1,8);
  //persiana bajar comedor
  addSensor(15,19,1,8);
  //persiana subir habitacion
  addSensor(16,24,1,9);
  //persiana bajar abitacion
  addSensor(17,23,1,9);


  //levantar persiana comedor
  //addActuator(16,50,0);
  //bajar persiana comedor
  //addActuator(17,51,0);

  //Levantar persiana comedor
  addActuator_triple(1,2,50,51,20);

  //la otra
  addActuator_triple(2,2,48,49,20);



  //persiana subir
  addAction(14,2,1);
  //persiana bajar
  addAction(15,3,1);


  //persiana habitaxion subir..
  addAction(16,2,2);
  //persiana habitacion bajar...
  addAction(17,3,2);

  switch_actuator_triple(1,100);
  switch_actuator_triple(2,100);
  

  /*

   
   //1 ----> Abrir/apagar luz
   //2 ----> Subir/Bajar persiana
   
   //addAction(2,13);
   // addAction(2,4);
   // addAction(2,7);
   addAction(11,1,3);
   //Despacho..
   addAction(3,1,2);
   addAction(3,1,8);
   
   //Pasillo..
   addAction(5,1,13);
   addAction(5,1,5);
   
   //Cocina
   addAction(4,1,4);
   addAction(4,1,15);
   //Comedor
   addAction(11,1,7);
   addAction(11,1,14);
   //Dormitorio
   addAction(1,1,1);
   //Lavavo
   addAction(9,1,15);
   //encender luz convidats
   addAction(12,1,18);
   */




  //HASTA AKI BUENOS...


  //BY DEFAULT
  for (int i =0 ; i < NUM_SENSOR ; i++){
    sensor[i].state =0;
    sensor[i].lastRead =  millis();
    sensor[i].lastReadDown =0;
    sensor[i].lastReadHigh = 0;

    pinMode(sensor[i].the_port,INPUT);
  }

  for (int i = 0;i < NUM_ACTUATOR;i++){
    pinMode(actuator[i].port,OUTPUT);

    digitalWrite(actuator[i].port,0);
  }
  for (int i = 0;i < NUM_ACTUATOR_TRIPLE;i++){
    pinMode(actuator_triple[i].port1,OUTPUT);
    pinMode(actuator_triple[i].port2,OUTPUT);
  }
  for (int i = 0;i < NUM_ROOM;i++){
    room[i].actual_scene = 0;

  }
     switch_actuator(15);
   switch_actuator(18);

  Serial.begin(9600);
  Serial.print("HOLA");
}

void loop() {

  checksensor();

  //readSerial();

  check_timmers();
  
  /*
  if ( house_state ==false){
    
    long actual_time = millis() ;
    
    if ((actual_time - last_start) > one_day ){
      

      if ( persiana_subida ){ 
        if ((actual_time - last_start) > (one_day + duration)){
           Serial.println("Caso de subir persiana..");
           //Bajamos la persiana del comedor
          switch_actuator_triple( 1, 0);
          last_start = millis();
          persiana_subida = false;
        }
        else{
          //nada
        }
         
      }
      else{
         if (!persiana_subida){
            Serial.println("Caso de subir  persiana..");
            switch_actuator_triple( 1, 100);
            persiana_subida = true;
        }{
          //nada
        }
          
     }
        
      
    }
    
  }
  
*/

}

void checksensor(){
  for ( int a = 0 ; a < NUM_SENSOR; a++){
    int sensor_state;
    sensor_state = digitalRead(sensor[a].the_port);


    if (sensor[a].type == 1 ){ 
      if (sensor_state == HIGH &&  ( millis() - sensor[a].lastRead ) >300){
        if (DEBUG_MODE){
          Serial.print("Sensor leido ");
          Serial.println(sensor[a].id);
        }
        //Sensor esta activo y hace mas de 300 milis que no se lee...
        if ((millis() - sensor[a].lastReadDown) > 50 ){


          //EL SENSOR SE MANTIENE APRETADO MAS DE 50 milis
          sensor[a].lastRead = millis();
          //SE HA APRETADO EL SENSOR!!!

//          if (sensor[a].id == 7  ){
//            switch_full_house();
//          }
//          else{
            Serial.print(millis() - sensor[a].lastReadHigh);
            if  (millis() - sensor[a].lastReadHigh  > 2000 && sensor[a].lastReadHigh != 0 ) {
              Serial.print("Ponemos a 0 el sensor");
              switch_off_room(sensor[a].id_room,true);
              sensor[a].lastReadHigh = 0;
            }
            else{
              Serial.print("Vamos a sensor button click...");
              switch_off_room(sensor[a].id_room,false);
              sensor_button_click(sensor[a].id);
              sensor[a].lastReadHigh = millis();
            }
//          }


          //HAY QUE VER LAS ACCIONES QUE LE TOCAN HACER
        }
        else{         

        }
      }
      else{
        sensor[a].lastReadDown = millis();
      }
    } 
  }


}


void addRoom(short i  ) {
  if( i != 0){
    room[NUM_ROOM].id_room = i;
  }
  NUM_ROOM++;


}
void addSensor(int id, int port, int type, short id_room){
  sensor[NUM_SENSOR].id = id;
  sensor[NUM_SENSOR].the_port = port;
  sensor[NUM_SENSOR].type = type;
  sensor[NUM_SENSOR].id_room = id_room;
  NUM_SENSOR ++;
}
void addActuator(int id, int port,int type){
  actuator[NUM_ACTUATOR].id = id;
  actuator[NUM_ACTUATOR].port = port;
  actuator[NUM_ACTUATOR].state = 0;
  actuator[NUM_ACTUATOR].type = type;
  NUM_ACTUATOR ++;

}
void addActuator_triple(int id, int type, int port,int port2,int  time_to_down){
  actuator_triple[NUM_ACTUATOR_TRIPLE].id = id;
  actuator_triple[NUM_ACTUATOR_TRIPLE].port1 = port;
  actuator_triple[NUM_ACTUATOR_TRIPLE].port2 = port2;
  actuator_triple[NUM_ACTUATOR_TRIPLE].state = 0;
  actuator_triple[NUM_ACTUATOR_TRIPLE].prev_state = 0;
  actuator_triple[NUM_ACTUATOR_TRIPLE].type = type;
  actuator_triple[NUM_ACTUATOR_TRIPLE].init_time = -1;
  actuator_triple[NUM_ACTUATOR_TRIPLE].time_to_down = time_to_down;
  NUM_ACTUATOR_TRIPLE ++;

}
void addAction(int id_sensor,int action_type, int id_actuator ){
  actions[NUM_ACTIONS].id_sensor = id_sensor; 
  actions[NUM_ACTIONS].id_actuator =id_actuator;
  actions[NUM_ACTIONS].type = action_type;


  NUM_ACTIONS++;
}


void addSceneActuator(int id_scene, int id_actuator, int mode_actuator  ){
  scene_actuator[NUM_SCENE_ACTUATOR].id_scene  =id_scene;
  scene_actuator[NUM_SCENE_ACTUATOR].id_actuator  =id_actuator;

  scene_actuator[NUM_SCENE_ACTUATOR].actuator_mode = mode_actuator;


  NUM_SCENE_ACTUATOR++;
}

void addScene ( short id_scene, short id_room){
  scene[NUM_SCENE].id_scene  = id_scene;
  scene[NUM_SCENE].id_room = id_room;
  NUM_SCENE++;

}



void  sensor_button_click(int id_sensor){
  if (DEBUG_MODE){
    Serial.print("Sensor ");
    Serial.println(id_sensor);
  }


  //PARTE DE LAS ESCENAS..
  int id_room=0;
  int last_scene = 0;
  int x_pointer =0;
  Room rr;

  for (int  i = 0; i< NUM_SENSOR;i++){
    if (sensor[i].id == id_sensor){

      Serial.print("Sensor encontrado pertenece a room= ");
      Serial.println(sensor[i].id_room);
      //buscamos la room...
      for (int x =0;x < NUM_ROOM;x++){
        //Serial.println(room[x].id_room);
        if (room[x].id_room == sensor[i].id_room){

          Serial.print("Room encontrada.. last scene vale = ");
          id_room = room[x].id_room;
          rr = room[x];
          x_pointer = x;

          last_scene  = room[x].actual_scene;
          Serial.println(rr.actual_scene);
          break;
        }


      }
    }
  }

  boolean encontrado_superior = false;
  for (int r = 0 ; r < NUM_SCENE ; r++){
    //buscamos la siguiente escena 
    if (  scene[r].id_room  == id_room && scene[r].id_scene > last_scene ){

      Serial.print("Encontrada escena superior a la anterior la nueva vale =  ");
      Serial.println(scene[r].id_scene);

      rr.actual_scene = scene[r].id_scene;
      room[x_pointer].actual_scene = scene[r].id_scene;

      //ternemos la escena!!!



      for (int t = 0 ; t < NUM_SCENE_ACTUATOR ; t++){

        if ( scene_actuator[t].id_scene == scene[r].id_scene){
          Serial.print("Encontrado Actuador.. ");
          switch_actuator( scene_actuator[t].id_actuator);
        }

      }
      encontrado_superior = true;
      break;
    }

  }
  if ( ! encontrado_superior){
    //si llegamos aki es que no hemos encontrado escena superior...
    switch_off_room(room[x_pointer].id_room,true);

  }


  //Leemos el listado de acciones para el evento x

  for (int x=0 ; x< NUM_ACTIONS; x++){
    if (actions[x].id_sensor == id_sensor){

      //Buscamos cual es su actuador....

      if  (actions[x].type == 1){
        switch_actuator(actions[x].id_actuator);
      }
      else  if  (actions[x].type == 2){
        if (DEBUG_MODE){
          Serial.print("Sensor aciton 2 ");
        }
        switch_actuator_triple(actions[x].id_actuator,100);
      }
      else  if  (actions[x].type == 3){
        if (DEBUG_MODE){
          Serial.print("Sensor action 3 ");
        }
        switch_actuator_triple(actions[x].id_actuator,0);
      }
      else  if  (actions[x].type == 3){
        if (DEBUG_MODE){
          Serial.print("Sensor action 4 ");
        }

      }


    }
  }
}

void switch_off_room(short id_room,boolean change_scene){

  //Buscamos todos los actuadores de la room y los ponemos a 0...
  for ( int x = 0; x < NUM_SCENE;x++){
    if( scene[x].id_room == id_room){
      for (int i = 0; i < NUM_SCENE_ACTUATOR;i++ ){
        if (scene_actuator[i].id_scene == scene[x].id_scene){

          set_actuator(scene_actuator[i].id_actuator, 0 );
        }
      }
    }
  }
  if  ( change_scene ){
    for (int  i = 0; i < NUM_ROOM;i++){
      if (room[i].id_room == id_room){
        room[i].actual_scene = 0;
      }
    }
  }
}


void set_actuator(int id_actuator,int mode){
  for ( int y = 0; y < NUM_ACTUATOR; y++){
    if (actuator[y].id == id_actuator){

      actuator[y].state = mode;

      if (DEBUG_MODE){
        Serial.print("Actuator ");
        Serial.println(actuator[y].port);
      }
      digitalWrite( actuator[y].port, actuator[y].state);
    }
  }
}


void switch_full_house(){

  house_state = ! house_state;
  for (int i = 0; i < NUM_ACTUATOR; i++){
    if ( house_state == false){
      digitalWrite( actuator[i].port, LOW);

    }
    else{
      digitalWrite( actuator[i].port, actuator[i].state);
    }
  }
  for (int i = 0; i < NUM_ACTUATOR_TRIPLE; i++){
    if ( house_state == false){
      switch_actuator_triple( actuator_triple[i].id, 0);

    }
    else{
      switch_actuator_triple( actuator_triple[i].id, 100);

    }       
  }
}


void check_timmers(){

  //timmer for persianas
  for (int x=0 ; x< NUM_ACTUATOR_TRIPLE; x++){

    //Buscamos cual es su actuador....
    if (actuator_triple[x].init_time != -1 ){
      if (actuator_triple[x].state - actuator_triple[x].prev_state >0){
        //estamos subiendo...

        int time_for_finish = (actuator_triple[x].time_to_down)*(actuator_triple[x].state-actuator_triple[x].prev_state)/100;

        if ( ((millis()-actuator_triple[x].init_time )/1000) > time_for_finish ){
          actuator_triple[x].init_time = -1;
          actuator_triple[x].prev_state =actuator_triple[x].state;
          if (DEBUG_MODE){
            Serial.print("Actuator persiana, fin-subiendo... ");
            Serial.println(actuator_triple[x].id);
          }
          digitalWrite( actuator_triple[x].port1, LOW);

        }	
      }
      else{
        //bajando
        int time_for_finish = (actuator_triple[x].time_to_down)*(actuator_triple[x].prev_state - actuator_triple[x].state)/100;

        if ( ((millis()-actuator_triple[x].init_time )/1000) > time_for_finish ){
          actuator_triple[x].init_time = -1;
          actuator_triple[x].prev_state =actuator_triple[x].state;
          if (DEBUG_MODE){
            Serial.print("Actuator persiana, fin-bajando... ");
            Serial.println(actuator_triple[x].id);
          }
          digitalWrite( actuator_triple[x].port2, LOW);

        }	

      }
    }
  }
}

void switch_actuator(int id_actuator){
  for ( int y = 0; y < NUM_ACTUATOR; y++){
    if (actuator[y].id == id_actuator){
      if (actuator[y].state == 0  ){
        actuator[y].state =1;
      }
      else {
        actuator[y].state = 0;
      }
      if (DEBUG_MODE){
        Serial.print("Actuator ");
        Serial.println(actuator[y].port);
        Serial.print("Value ");
        Serial.println(actuator[y].state);
      }
      digitalWrite( actuator[y].port, actuator[y].state);
    }
  }
}
void switch_actuator_triple(int id_actuator,int state){

  Serial.print(id_actuator);
  for ( int y = 0; y < NUM_ACTUATOR_TRIPLE; y++){
    if (actuator_triple[y].id == id_actuator){

      //si no est� en movimiento....
      if (actuator_triple[y].state != state  && actuator_triple[y].state == actuator_triple[y].prev_state ){

        actuator_triple[y].prev_state = actuator_triple[y].state;
        actuator_triple[y].state = state;
        actuator_triple[y].init_time = millis();

        if (actuator_triple[y].state >= actuator_triple[y].prev_state ){
          //subir persiana
          if (DEBUG_MODE){
            Serial.print("Actuator persiana, inicio-subiendo... ");
            Serial.println(actuator_triple[y].id);
          }
          digitalWrite( actuator_triple[y].port1, HIGH);

        }
        else{
          //subir persiana
          if (DEBUG_MODE){
            Serial.print("Actuator persiana, inicio-bajando... ");
            Serial.println(actuator_triple[y].id);
          }
          digitalWrite( actuator_triple[y].port2, HIGH);
        }
      }
      else{
        if (DEBUG_MODE){
          Serial.print("Subirpersiana no funciona porque no ha acabado la accion anterior...");
        }
        actuator_triple[y].prev_state = 50;
        actuator_triple[y].state = 50;
        actuator_triple[y].init_time = -1;

        digitalWrite( actuator_triple[y].port1, LOW);
        digitalWrite( actuator_triple[y].port2, LOW);


      }
    }

  }
}

























/*
void reset_command_buffer(){

  for (int i = 0; i < 50 ;i++){
    command_buffer[i] = 0;
  }
  command_buffer_pointer = 0;
}
 void readSerial(){

  //LEEMOS DEL SERIAL
  int incoming;
  if (Serial.available() > 0) {

    // read the incoming byte:

    incoming = Serial.read();
    //comandos
    //lsensor List sensor
    //lactuator List actuators
    //laction  List of actions

    //lroomscene list of room  scene
    //lsceneactuators 

    if (incoming == (int) ';'){
      process_buffer();
    }
    else{
      command_buffer[command_buffer_pointer] = incoming ;
      command_buffer_pointer++;
    }

    /*
    if (incoming == 101){
     int x = readInt();
     
     
     for (int i = 0 ; i < NUM_ACTUATOR ; i++){
     
     if (  actuator[i].id == x ){
     actuator[i].state = 1; 
     digitalWrite( actuator[i].port, actuator[i].state);
     Serial.print("Activating actuator: ");
     Serial.println(actuator[i].id, DEC);
     }
     }
     }
     else if (incoming == 100){
     int x = readInt();
     
     
     for (int i = 0 ; i < NUM_ACTUATOR ; i++){
     if (  actuator[i].id == x ){
     actuator[i].state = 0; 
     digitalWrite( actuator[i].port, actuator[i].state);
     Serial.print("DEActivating actuator: ");
     Serial.println(actuator[i].id, DEC);
     }
     }
     }
     else{
     Serial.print("Reciving incorrect data ");
     
     }
     
  }
}

int readInt (){
  int x;
  while  (Serial.available() <= 0) {

  }
  x =( Serial.read()-48) *10;       

  while  (Serial.available() <= 0) {

  }
  x += Serial.read()-48;



  return x;

}



void process_buffer(){

  //comandos
  //lsensor List sensor
  //lactuator List actuators
  //laction  List of actions
  //lroom list of rooms
  //lroomscenes list of room  scene
  //lsceneactuators 

  //asensor
  if (strcmp(command_buffer, "lsensor")== 0){
    Serial.println("-----SENSORS-----");
    Serial.println("id\ttype");
    for (int i =0;i < NUM_SENSOR;i++){
      Serial.print (sensor[i].id );
      Serial.print("\t");
      if (sensor[i].type == 1){
        Serial.print("PULSADOR S/N");

      }
      else {
        Serial.print("Tipo desconocido, no deberia existir");
      }
      Serial.print("\t");
      Serial.println(sensor[i].the_port );

    }


  }
  else if  (strcmp(command_buffer, "lactuator")== 0){
    Serial.println("-----ACTUATORS-----");
    Serial.println("id\ttype\t\tport1\tport2\tparam3");
    //POR ahora solo 2 tipos, switch on/of y persiana
    for (int i =0;i < NUM_ACTUATOR;i++){
      Serial.print (actuator[i].id );
      Serial.print("\t");
      if (actuator[i].type == 0){
        Serial.print("SWITCH ON/OF");

      }
      else {
        Serial.print("Tipo desconocido, no deberia existir");
      }
      Serial.print("\t");
      Serial.println(actuator[i].port );

    }

    for (int i =0;i < NUM_ACTUATOR_TRIPLE;i++){
      Serial.print (actuator_triple[i].id );
      Serial.print("\t");
      if (actuator_triple[i].type == 2){
        Serial.print("PERSIANA ");

      }
      else {
        Serial.print("Tipo desconocido, no deberia existir");
      }
      Serial.print("\t");
      Serial.print(actuator_triple[i].port1 );
      Serial.print("\t");
      Serial.print(actuator_triple[i].port2 );
      Serial.print("\t");
      Serial.println(actuator_triple[i].time_to_down );

    }

  }

  else if  (strcmp(command_buffer, "lscene")== 0){
    Serial.println("-----SCENES-----");
    Serial.println("id_room\tid_scene\torder");

    for (int x = 0;x < 20;x++){

      for (int i =0;i < NUM_SCENE;i++){
        if (scene[i].id_room == x){
          Serial.print (scene[i].id_room );
          Serial.print("\t");
          Serial.print(scene[i].id_scene);
          Serial.print("\t\t");
          Serial.println(scene[i].order);
        }

      }
    }

  }
  else if  (strcmp(command_buffer, "lsceneactuator")== 0){

    Serial.println("-----ROOMS-----");
    Serial.println("id_scene\tid_actuator\t\tactuator_mode");
    for (int i =0;i < NUM_SCENE_ACTUATOR;i++){
      Serial.print (scene_actuator[i].id_scene );

      Serial.print("\t");
      Serial.print (scene_actuator[i].id_actuator );
      Serial.print("\t");
      Serial.println(scene_actuator[i].actuator_mode );
      ;

    }

  }

  else if  (strncmp(command_buffer, "debugmode on",7)== 0){
    Serial.println("DEBUG MODE ON");
    DEBUG_MODE = true;

  }
  else if  (strncmp(command_buffer, "debugmode off",7)== 0){
    Serial.println("DEBUG MODE OFF");
    DEBUG_MODE = false;

  }
  else if  (strncmp(command_buffer, "?",7)== 0){
    Serial.println("------List of actions-------");
    Serial.println("-lsensor //List sensor");
    Serial.println("-lactuator //List actuators");
    Serial.println("-laction  //List of actions");
    Serial.println("-lroom //list of rooms");
    Serial.println("-lscene //list of scenes");
    Serial.println("-lsceneactuator //list of scene actuators");
    Serial.println("-lscenesensor //list of scene actuators");
    Serial.println("-debugmode on   //enable debug mode");
    Serial.println("-debugmode off   //disable debug mode");

  }  
  else if  (strncmp(command_buffer, "asensor",7)== 0){
    //Add Sensor... 

  }

  else{
    Serial.print("BAD COMMAND -->");
    Serial.println(command_buffer);
  }
  reset_command_buffer();



}

*/

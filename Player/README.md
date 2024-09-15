First Person Player
En una escena vacia agregar un CharacterBody3D que sera nuestro personaje.
A este le asignamos un Node3D al que llamaremos "CamOrigin", al que asignaremos un SpringArm3D y a este ultimo una Camara3D.
En el SpringArm3D modificamos los parametros para que la camara se encuentre en los ojos de nuestro modelo, en mi caso: Spring Lenght: -0.3 y Margin: 0.5

# Objetos de la Escena "Player"
CharacterBody3D
|-MeshInstance3D "Cuerpo"
|  |- MeshInstance3D "Ojos"
|-CollisionShape3D
|-Node3D "CamOrigin"
  |- SpringArm3D
    |- Camara3D

Le asignamos un Script al CharacterBody3D para manipular su comportamiento, por defecto Godot nos da un "esqueleto" del movimiento del jugador, al que nosotros modificaremos.

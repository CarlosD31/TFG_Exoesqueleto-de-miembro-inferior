# TFG_Exoesqueleto-de-miembro-inferior

Para la simulación del exoesqueleto se han creado varios archivos para facilitar la instalación y el funcionamiento en cualquier ordenador.

El urdf se ha creado en ROS Noetic, para su ejecución es necesario incluir el paquete llamado 'urdf_ortesis' dentro de una carpeta que ejecute perfectamente ROS. 
Para facilitar la ejecución del modelo se ha incluido el archivo 'Instalar_paquete.sh' donde crea y estableciendo los directorios necesarios para ejecutar el urdf. 
Es tan fácil como abrir el terminal en la carpeta donde esten ubicados los archivos y ejecutar el comando 
	$ ./Intalar_paquete.sh
	
Una vez creados los directorios se ejecuta, de la misma forma, la simulación en Gazebo del modelo URDF.

Despues de visualizar el URDF es necesario desactivar las fisicas para evitar errores:
	Physics -> enable physics -> False
	
Por último, se incluyen dos archivos que ejecutan dos programas.
	-'Mover_exoesqueleto.sh': realiza el movimiento de cada pierna independiente, especificando desde el terminal los angulos de movimiento de cada articulación
	-'Comunicar_Noraxon.sh': ejecuta el programa principal del proyecto, donde crea topic para poder comunicarse desde matlab, recibiendo los ángulos y el Control On/Off según la información de los sensores EMG.
